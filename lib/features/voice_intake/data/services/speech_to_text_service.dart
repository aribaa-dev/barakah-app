// lib/features/voice_intake/data/speech_to_text_service.dart
import 'package:order_link/features/voice_intake/domain/services/speech_service.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// The ONLY file that talks to the speech_to_text package.
/// No API key: it uses the phone's own recognizer (Google on Android).
class SpeechToTextService implements SpeechService {
  /// 'en_US' is the safe default. For Urdu try 'ur_PK'.
  /// See which languages the phone supports with `SpeechToText().locales()`.
  SpeechToTextService({this.localeId = 'en_US'});

  final String localeId;
  final SpeechToText _speech = SpeechToText();
  bool _ready = false;

  @override
  Future<bool> initialize({
    required void Function() onSessionEnded,
    required void Function(String message, bool fatal) onError,
  }) async {
    if (_ready) return true;
    _ready = await _speech.initialize(
      onStatus: (status) {
        if (status == SpeechToText.doneStatus ||
            status == SpeechToText.notListeningStatus) {
          onSessionEnded();
        }
      },
      onError: (SpeechRecognitionError e) =>
          onError(_friendlyMessage(e), e.permanent),
    );
    return _ready;
  }

  @override
  Future<void> startSession({
    required void Function(String words) onWords,
  }) async {
    if (!_ready) return;
    await _speech.listen(
      onResult: (SpeechRecognitionResult r) => onWords(r.recognizedWords),
      listenOptions: SpeechListenOptions(
        localeId: localeId,
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 8),
        partialResults: true,
        listenMode: ListenMode.dictation,
        cancelOnError: true,
      ),
    );
  }

  @override
  Future<void> stopSession() => _speech.stop();

  @override
  Future<void> cancel() => _speech.cancel();

  @override
  void dispose() {
    _speech.cancel();
  }

  String _friendlyMessage(SpeechRecognitionError e) {
    final code = e.errorMsg;
    if (code.contains('permission')) {
      return 'Microphone permission is needed. Allow it in the phone settings.';
    }
    if (code.contains('network') || code.contains('server')) {
      return 'No internet. Speech recognition needs a connection.';
    }
    if (code.contains('language')) {
      return 'This language is not available on your phone.';
    }
    return 'Speech recognition stopped ($code). Please try again.';
  }
}
