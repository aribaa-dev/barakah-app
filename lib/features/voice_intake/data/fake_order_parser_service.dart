// lib/features/voice_intake/data/services/fake_order_parser_service.dart
import 'package:order_link/features/summary/domain/entities/order_draft.dart';
import 'package:order_link/features/voice_intake/domain/services/order_parser_service.dart';

/// Pretends to "listen" for a moment, then returns the dummy order.
/// A recording under 2 seconds fails on purpose, so you can test the error UI.
class FakeOrderParserService implements OrderParserService {
  const FakeOrderParserService();

  @override
  Future<OrderDraft> parse(VoiceRecording recording) async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    if (recording.duration.inSeconds < 2) {
      throw const OrderParseException(
        'Recording is too short. Say the shop name and the items.',
      );
    }
    return OrderDraft.dummy;
  }
}
