// lib/features/order_history/presentation/controllers/order_history_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_link/features/order/presentation/providers/order_providers.dart';
import 'package:order_link/features/order_history/domain/entities/saved_order.dart';

/// Confirmed orders, newest first, straight from Firestore.
///
/// Kept as a plain List provider on purpose: the dashboard, history screen
/// and search controller already read it as a List, so they don't change.
/// Saving happens through OrderRepository (see OrderDraftController.confirm);
/// the stream then pushes the new order in here by itself.
final orderHistoryProvider = Provider<List<SavedOrder>>(
  (ref) => ref.watch(orderHistoryStreamProvider).value ?? const [],
);

/// True only while the very first load has no data yet.
/// Lets the history screen show a spinner instead of a false "No orders yet".
final orderHistoryLoadingProvider = Provider<bool>((ref) {
  final async = ref.watch(orderHistoryStreamProvider);
  return async.isLoading && !async.hasValue;
});
