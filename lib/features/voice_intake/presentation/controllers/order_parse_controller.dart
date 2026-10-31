// lib/features/voice_intake/presentation/controllers/order_parse_controller.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_link/features/summary/presentation/controllers/order_draft_controller.dart';
import 'package:order_link/features/voice_intake/data/fake_order_parser_service.dart';
import 'package:order_link/features/voice_intake/data/gemini_order_parser_service.dart';
import 'package:order_link/features/voice_intake/domain/services/order_parser_service.dart';

/// DEMO SWITCH. true = skip the AI and always return the dummy order.
/// Handy when you have no internet, or the free AI limit is used up.
const bool kUseFakeParser = false;

/// The ONE place that decides which parser the app uses.
final orderParserServiceProvider = Provider<OrderParserService>(
  (ref) => kUseFakeParser
      ? const FakeOrderParserService()
      : GeminiOrderParserService(),
);

/// State = `AsyncValue<void>`: loading while parsing, error if it failed.
/// The parsed order itself is stored in orderDraftProvider.
class OrderParseController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Returns true when a draft is ready and the screen can move on.
  Future<bool> parse(VoiceRecording recording) async {
    if (state.isLoading) return false; // ignore a second tap

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final draft = await ref.read(orderParserServiceProvider).parse(recording);
      ref.read(orderDraftProvider.notifier).setDraft(draft);
    });
    return !state.hasError;
  }
}

final orderParseControllerProvider =
    AsyncNotifierProvider<OrderParseController, void>(OrderParseController.new);
