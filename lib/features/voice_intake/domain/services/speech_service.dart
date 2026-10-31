// lib/features/voice_intake/domain/services/speech_service.dart

/// What the recorder needs from "something that turns speech into text".
/// The controller only knows this interface, never the speech_to_text package,
/// so the engine can be swapped (e.g. a cloud service) without touching it.
abstract class SpeechService {
  /// Asks for the microphone permission and prepares the engine.
  /// Returns false if speech recognition is not available on this device.
  ///
  /// [onSessionEnded]: the engine stopped by itself (e.g. after silence).
  /// [onError]: [fatal] = true means listening cannot continue.
  Future<bool> initialize({
    required void Function() onSessionEnded,
    required void Function(String message, bool fatal) onError,
  });

  /// Starts one listening session. [onWords] receives the FULL text of this
  /// session so far every time it changes (not just the new words).
  Future<void> startSession({required void Function(String words) onWords});

  /// Ends the session and lets the engine deliver its final words.
  Future<void> stopSession();

  /// Ends the session and throws the words away.
  Future<void> cancel();

  void dispose();
}
