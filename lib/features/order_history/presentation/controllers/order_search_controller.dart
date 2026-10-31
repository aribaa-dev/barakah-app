// lib/features/order_history/presentation/controllers/order_search_controller.dart
import 'package:order_link/features/order_history/domain/entities/saved_order.dart';
import 'package:order_link/features/order_history/presentation/controllers/order_history_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'order_search_controller.g.dart';

/// Holds the current search text. Auto-disposes when the screen is gone,
/// so the search resets itself next time the user opens History.
@riverpod
class OrderSearchController extends _$OrderSearchController {
  @override
  String build() => '';

  void setQuery(String value) => state = value;

  void clear() => state = '';
}

/// Orders after applying the search. Rebuilds when either the saved
/// orders or the query changes, so newly confirmed orders still show up live.
@riverpod
List<SavedOrder> filteredOrders(Ref ref) {
  final orders = ref.watch(orderHistoryProvider);
  final query = ref.watch(orderSearchControllerProvider).trim().toLowerCase();

  if (query.isEmpty) return orders;

  return orders.where((saved) {
    final order = saved.order;
    if (order.shopName.toLowerCase().contains(query)) return true;
    // NOTE: change `name` if your item field is called something else.
    return order.items.any((item) => item.name.toLowerCase().contains(query));
  }).toList();
}
