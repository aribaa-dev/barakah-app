// lib/features/voice_intake/presentation/controllers/voice_recorder_controller.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_link/features/voice_intake/domain/services/speech_service.dart';
import 'package:order_link/features/voice_intake/data/services/speech_to_text_service.dart';

enum RecorderStatus { idle, recording, paused, recorded }

/// The ONE place that decides which speech engine the app uses.
/// autoDispose: leaving the screen releases the microphone.
final speechServiceProvider = Provider.autoDispose<SpeechService>((ref) {
  final service = SpeechToTextService();
  ref.onDispose(service.dispose);
  return service;
});

/// Everything the voice screen needs to DRAW. Animations stay in the widget.
class VoiceRecorderState {
  final RecorderStatus status;
  final int seconds;

  /// Everything heard so far (live while recording, final once recorded).
  final String transcript;

  /// Set once when something goes wrong; the screen shows it as a snackbar.
  final String? errorMessage;

  const VoiceRecorderState({
    this.status = RecorderStatus.idle,
    this.seconds = 0,
    this.transcript = '',
    this.errorMessage,
  });

  bool get isIdle => status == RecorderStatus.idle;
  bool get isPaused => status == RecorderStatus.paused;
  bool get hasRecording => status == RecorderStatus.recorded;
  bool get hasTranscript => transcript.trim().isNotEmpty;

  /// True while recording, including while paused (same meaning as before).
  bool get isRecording =>
      status == RecorderStatus.recording || status == RecorderStatus.paused;

  String get timerLabel {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }

  /// Any copyWith clears errorMessage on purpose: an error is shown once.
  VoiceRecorderState copyWith({
    RecorderStatus? status,
    int? seconds,
    String? transcript,
  }) => VoiceRecorderState(
    status: status ?? this.status,
    seconds: seconds ?? this.seconds,
    transcript: transcript ?? this.transcript,
  );
}

class VoiceRecorderController extends Notifier<VoiceRecorderState> {
  Timer? _timer;
  late SpeechService _speech;

  bool _disposed = false;
  bool _starting = false;
  bool _restartScheduled = false;

  /// Each listening session has an id; words from an old session are ignored.
  int _sessionId = 0;

  /// Text of finished sessions + text of the session that is running now.
  /// Pause and "engine stopped by itself" both end a session, so the
  /// transcript is built from several sessions joined together.
  String _committed = '';
  String _current = '';

  @override
  VoiceRecorderState build() {
    _disposed = false;
    _speech = ref.watch(speechServiceProvider);
    // autoDispose + this = leaving the screen always stops the timer.
    ref.onDispose(() {
      _disposed = true;
      _timer?.cancel();
    });
    return const VoiceRecorderState();
  }

  Future<void> start() async {
    if (_starting) return; // ignore a second tap while the permission shows
    _starting = true;
    try {
      _timer?.cancel();
      _resetTranscript();

      final ready = await _speech.initialize(
        onSessionEnded: _onSessionEnded,
        onError: _onError,
      );
      if (_disposed) return;

      if (!ready) {
        state = const VoiceRecorderState(
          errorMessage:
              'Speech recognition is not available. Check the microphone '
              'permission and that Google speech services are installed.',
        );
        return;
      }

      state = const VoiceRecorderState(status: RecorderStatus.recording);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (state.status == RecorderStatus.recording) {
          state = state.copyWith(seconds: state.seconds + 1);
        }
      });
      await _listen();
    } finally {
      _starting = false;
    }
  }

  Future<void> pauseResume() async {
    switch (state.status) {
      case RecorderStatus.recording:
        state = state.copyWith(status: RecorderStatus.paused);
        await _speech.stopSession();
        await _letFinalWordsArrive();
        // The user may have resumed while we waited.
        if (_disposed || state.status != RecorderStatus.paused) return;
        _commit();
        _publish();
      case RecorderStatus.paused:
        state = state.copyWith(status: RecorderStatus.recording);
        await _listen();
      case RecorderStatus.idle || RecorderStatus.recorded:
        break;
    }
  }

  Future<void> stop() async {
    if (!state.isRecording) return;
    _timer?.cancel();
    state = state.copyWith(status: RecorderStatus.recorded);
    await _speech.stopSession();
    await _letFinalWordsArrive();
    if (_disposed || state.status != RecorderStatus.recorded) return;
    _commit();
    _publish();
  }

  /// The salesman fixed a misheard word. Only allowed once recording is done,
  /// so the live speech engine can't overwrite his correction.
  void editTranscript(String text) {
    if (!state.hasRecording) return;
    final cleaned = text.trim();
    // Keep the bookkeeping in step so nothing old is re-added later.
    _committed = cleaned;
    _current = '';
    state = state.copyWith(transcript: cleaned);
  }

  Future<void> discard() async {
    _timer?.cancel();
    _resetTranscript();
    state = const VoiceRecorderState();
    await _speech.cancel();
  }

  // ---- listening sessions -------------------------------------------------

  Future<void> _listen() async {
    _commit(); // keep what was heard before this new session
    final id = ++_sessionId;
    await _speech.startSession(
      onWords: (words) {
        if (_disposed || id != _sessionId) return;
        _current = words;
        _publish();
      },
    );
  }

  /// The engine stopped by itself (silence). Keep listening if still recording.
  void _onSessionEnded() {
    if (_disposed || state.status != RecorderStatus.recording) return;
    _scheduleRestart();
  }

  void _onError(String message, bool fatal) {
    if (_disposed) return;

    if (!fatal) {
      // "No speech" / "timeout" are normal during a pause in talking.
      if (state.status == RecorderStatus.recording) _scheduleRestart();
      return;
    }

    if (!state.isRecording) return; // late error after the user stopped
    _timer?.cancel();
    _commit();
    final heardSomething = _committed.trim().isNotEmpty;
    state = VoiceRecorderState(
      status: heardSomething ? RecorderStatus.recorded : RecorderStatus.idle,
      seconds: heardSomething ? state.seconds : 0,
      transcript: _committed,
      errorMessage: message,
    );
  }

  void _scheduleRestart() {
    if (_restartScheduled) return; // 'notListening' and 'done' both arrive
    _restartScheduled = true;
    Future<void>.delayed(const Duration(milliseconds: 400), () async {
      _restartScheduled = false;
      if (_disposed || state.status != RecorderStatus.recording) return;
      await _listen();
    });
  }

  // ---- transcript bookkeeping --------------------------------------------

  /// After stop() the engine still delivers its last words a moment later.
  Future<void> _letFinalWordsArrive() =>
      Future<void>.delayed(const Duration(milliseconds: 350));

  void _commit() {
    _committed = _join(_committed, _current);
    _current = '';
    _sessionId++; // anything still arriving from the old session is dropped
  }

  void _publish() {
    state = state.copyWith(transcript: _join(_committed, _current));
  }

  void _resetTranscript() {
    _committed = '';
    _current = '';
    _sessionId++;
    _restartScheduled = false;
  }

  static String _join(String a, String b) {
    final right = b.trim();
    if (a.isEmpty) return right;
    if (right.isEmpty) return a;
    return '$a $right';
  }
}

/// Riverpod 3 syntax. autoDispose: a fresh recorder every time the screen opens.
final voiceRecorderControllerProvider =
    NotifierProvider.autoDispose<VoiceRecorderController, VoiceRecorderState>(
      VoiceRecorderController.new,
    );
