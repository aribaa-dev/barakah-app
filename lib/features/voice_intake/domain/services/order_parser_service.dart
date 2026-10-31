// lib/features/voice_intake/domain/services/order_parser_service.dart
import 'package:order_link/features/summary/domain/entities/order_draft.dart';

/// What the recorder hands to the parser.
class VoiceRecording {
  final Duration duration;

  /// Everything the phone heard, as text (English, Urdu or a mix).
  /// Empty when nothing was recognised.
  final String transcript;

  const VoiceRecording({required this.duration, this.transcript = ''});
}

/// A failure the user can understand. The UI shows [message] as-is.
class OrderParseException implements Exception {
  final String message;

  const OrderParseException(this.message);

  @override
  String toString() => message;
}

/// "Voice in, OrderDraft out." The controller only knows this interface.
/// Implementations: FakeOrderParserService (demo data) and
/// GeminiOrderParserService (real AI).
abstract interface class OrderParserService {
  Future<OrderDraft> parse(VoiceRecording recording);
}
