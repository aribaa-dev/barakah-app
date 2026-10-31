// lib/features/order_detail/data/sources/order_detail_source.dart
import 'package:order_link/features/order_history/domain/entities/saved_order.dart';

/// WHERE the data comes from. The only layer that knows about storage.
/// FIREBASE (later): add a second class here that reads one document by id.
/// Nothing above this layer changes.
abstract interface class OrderDetailSource {
  Future<SavedOrder?> fetchById(String orderId);
}

/// Reads from the confirmed orders kept in memory by the history controller.
class InMemoryOrderDetailSource implements OrderDetailSource {
  /// A function instead of a list, so we always read the CURRENT orders.
  final List<SavedOrder> Function() _readOrders;

  const InMemoryOrderDetailSource(this._readOrders);

  @override
  Future<SavedOrder?> fetchById(String orderId) async {
    for (final saved in _readOrders()) {
      if (saved.id == orderId) return saved;
    }
    return null;
  }
}
