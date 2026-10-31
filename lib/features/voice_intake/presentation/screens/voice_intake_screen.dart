// lib/features/voice_intake/presentation/screens/voice_intake_screen.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:order_link/core/router/app_routes.dart';
import 'package:order_link/features/summary/presentation/controllers/order_draft_controller.dart';
import 'package:order_link/features/voice_intake/domain/services/order_parser_service.dart';
import 'package:order_link/features/voice_intake/presentation/controllers/order_parse_controller.dart';
import 'package:order_link/features/voice_intake/presentation/controllers/voice_recorder_controller.dart';
import 'package:order_link/features/voice_intake/presentation/widgets/live_waveform_painter.dart';
import 'package:order_link/features/voice_intake/presentation/widgets/recording_buttons.dart';

// What moved to Riverpod:
//   recording status + timer  -> voiceRecorderControllerProvider
//   "generate summary" work   -> orderParseControllerProvider
// What stays here: animations (pure UI) and navigation.
class VoiceIntakeScreen extends ConsumerStatefulWidget {
  const VoiceIntakeScreen({super.key});

  @override
  ConsumerState<VoiceIntakeScreen> createState() => _VoiceIntakeScreenState();
}

class _VoiceIntakeScreenState extends ConsumerState<VoiceIntakeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _waveController;
  late final AnimationController _pulseController;
  late final List<double> _barHeights;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    final rng = math.Random(7);
    _barHeights = List.generate(46, (_) => rng.nextDouble() * 0.75 + 0.15);
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // The wave animation follows the recorder status.
  void _syncWave(RecorderStatus status) {
    switch (status) {
      case RecorderStatus.recording:
        _waveController.repeat();
      case RecorderStatus.paused || RecorderStatus.recorded:
        _waveController.stop();
      case RecorderStatus.idle:
        _waveController.stop();
        _waveController.reset();
    }
  }

  VoiceRecorderController get _recorder =>
      ref.read(voiceRecorderControllerProvider.notifier);

  void _startRecording() {
    // A new recording means a new order: drop any old draft first.
    ref.read(orderDraftProvider.notifier).clear();
    _recorder.start();
  }

  void _pauseResume() => _recorder.pauseResume();
  void _stopRecording() => _recorder.stop();
  void _discard() => _recorder.discard();

  void _handleClose() {
    if (ref.read(orderParseControllerProvider).isLoading) return;

    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.dashboard);
    }
  }

  /// Lets the salesman fix a misheard word before the AI reads the text.
  Future<void> _editTranscript() async {
    final current = ref.read(voiceRecorderControllerProvider).transcript;
    final edited = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _EditTranscriptSheet(initial: current),
    );
    if (edited == null || !mounted) return;
    _recorder.editTranscript(edited);
  }

  Future<void> _generateSummary() async {
    final rec = ref.read(voiceRecorderControllerProvider);

    // The transcript (what the phone heard) goes to the AI parser.
    final ready = await ref
        .read(orderParseControllerProvider.notifier)
        .parse(
          VoiceRecording(
            duration: Duration(seconds: rec.seconds),
            transcript: rec.transcript,
          ),
        );

    // The screen may have been closed while we waited.
    if (!mounted || !ready) return;
    // The draft lives in orderDraftProvider, so no `extra:` needed.
    context.pushReplacement(AppRoutes.summary);
  }

  @override
  Widget build(BuildContext context) {
    final rec = ref.watch(voiceRecorderControllerProvider);
    final isParsing = ref.watch(
      orderParseControllerProvider.select((s) => s.isLoading),
    );

    ref.listen(
      voiceRecorderControllerProvider.select((s) => s.status),
      (_, status) => _syncWave(status),
    );

    ref.listen(orderParseControllerProvider, (_, next) {
      if (next.hasError && !next.isLoading) {
        final error = next.error;
        final message = error is OrderParseException
            ? error.message
            : 'Something went wrong. Please try again.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    });

    // Speech problems (no permission, no internet...) show once as a snackbar.
    ref.listen(voiceRecorderControllerProvider.select((s) => s.errorMessage), (
      _,
      message,
    ) {
      if (message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    });

    return PopScope(
      canPop: !isParsing, // block the back button while the AI is working
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            SafeArea(child: _buildMainView(rec)),
            if (isParsing) const Positioned.fill(child: _ProcessingOverlay()),
          ],
        ),
      ),
    );
  }

  Widget _buildMainView(VoiceRecorderState rec) {
    return Column(
      children: [
        _buildTopBar(),
        const SizedBox(height: 8),
        if (rec.isIdle) _buildHintCard(),
        if (rec.isRecording || rec.hasRecording) _buildTimer(rec),
        Expanded(child: _buildCenterArea(rec)),
        if (rec.isRecording) _buildSpeakFasterHint(),
        const SizedBox(height: 24),
        _buildControls(rec),
        const SizedBox(height: 36),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(19.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: _handleClose,
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const Expanded(
            child: Text(
              'Recording',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Balances the close icon's width so the title is truly centered.
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildHintCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(19, 12, 19, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C2C2C)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: Color(0xFFFBBF24),
                size: 13,
              ),
              SizedBox(width: 5),
              Text(
                'Tip',
                style: TextStyle(
                  color: Color(0xFFFBBF24),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Text(
            'Say: Al-Noor Store… Milk 10 litre, Sugar 5 kg…',
            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTimer(VoiceRecorderState rec) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(
        rec.timerLabel,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 42,
          fontWeight: FontWeight.w300,
          letterSpacing: 4,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  Widget _buildCenterArea(VoiceRecorderState rec) {
    if (rec.isRecording) return _buildLiveWaveform(rec);
    if (rec.hasRecording) return _buildDoneState(rec);
    return const SizedBox.shrink();
  }

  Widget _buildLiveWaveform(VoiceRecorderState rec) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            return SizedBox(
              height: 120,
              child: CustomPaint(
                size: const Size(double.infinity, 130),
                painter: LiveWaveformPainter(
                  progress: _waveController.value,
                  barHeights: _barHeights,
                  isPaused: rec.isPaused,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        // What the phone heard so far, live.
        Flexible(
          child: _TranscriptBox(
            text: rec.transcript,
            placeholder: rec.isPaused ? 'Paused' : 'Listening…',
          ),
        ),
      ],
    );
  }

  Widget _buildDoneState(VoiceRecorderState rec) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Recording ready',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rec.timerLabel,
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: _TranscriptBox(
              text: rec.transcript,
              placeholder: 'No speech was captured',
              onEdit: _editTranscript,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakFasterHint() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C2C2C)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.speed_rounded, color: Colors.white60, size: 15),
          SizedBox(width: 6),
          Text(
            'Try to speak a bit slower',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(VoiceRecorderState rec) {
    if (rec.isIdle) {
      return BigRecordButton(icon: Icons.mic_rounded, onTap: _startRecording);
    }

    if (rec.isRecording) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SmallRecordButton(
            icon: Icons.stop_rounded,
            bgColor: Colors.white.withValues(alpha: 0.2),
            iconColor: Colors.white,
            onTap: _stopRecording,
          ),
          const SizedBox(width: 28),
          BigRecordButton(
            icon: rec.isPaused ? Icons.mic_rounded : Icons.pause_rounded,
            onTap: _pauseResume,
          ),
          const SizedBox(width: 28),
          SmallRecordButton(
            icon: Icons.delete_outline_rounded,
            bgColor: Colors.white.withValues(alpha: 0.2),
            iconColor: Colors.white,
            onTap: _discard,
          ),
        ],
      );
    }

    // Recording finished: show the generate-summary button
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SmallRecordButton(
          icon: Icons.delete_outline_rounded,
          bgColor: Colors.white.withValues(alpha: 0.2),
          iconColor: Colors.white,
          onTap: _discard,
        ),
        const SizedBox(width: 28),
        BigRecordButton(
          icon: Icons.auto_awesome_rounded,
          onTap: _generateSummary,
        ),
        const SizedBox(width: 28),
        SmallRecordButton(
          icon: Icons.refresh_rounded,
          bgColor: Colors.white.withValues(alpha: 0.2),
          iconColor: Colors.white,
          onTap: _startRecording,
        ),
      ],
    );
  }
}

/// Shows the words the phone heard. Scrolls so the newest words stay visible.
class _TranscriptBox extends StatelessWidget {
  final String text;
  final String placeholder;

  /// Null hides the "Edit text" button (used while recording).
  final VoidCallback? onEdit;

  const _TranscriptBox({
    required this.text,
    required this.placeholder,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = text.trim().isEmpty;

    final box = Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 19),
      padding: const EdgeInsets.all(14),
      constraints: const BoxConstraints(maxHeight: 160),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C2C2C)),
      ),
      child: SingleChildScrollView(
        reverse: true,
        child: Text(
          isEmpty ? placeholder : text,
          style: TextStyle(
            color: isEmpty ? Colors.white38 : Colors.white,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );

    if (onEdit == null) return box;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: box),
        TextButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: Text(isEmpty ? 'Type the order' : 'Edit text'),
          style: TextButton.styleFrom(foregroundColor: Colors.white70),
        ),
      ],
    );
  }
}

/// Bottom sheet for fixing a misheard word before the AI reads the text.
class _EditTranscriptSheet extends StatefulWidget {
  final String initial;

  const _EditTranscriptSheet({required this.initial});

  @override
  State<_EditTranscriptSheet> createState() => _EditTranscriptSheetState();
}

class _EditTranscriptSheetState extends State<_EditTranscriptSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fix the text',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Correct any word the phone heard wrongly.',
                style: TextStyle(fontSize: 12.5, color: Colors.black54),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _controller,
                autofocus: true,
                minLines: 3,
                maxLines: 6,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 14, height: 1.4),
                decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, _controller.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dims the screen and blocks taps while the order is being parsed.
class _ProcessingOverlay extends StatelessWidget {
  const _ProcessingOverlay();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        ModalBarrier(dismissible: false, color: Colors.black87),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Understanding your order…',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
