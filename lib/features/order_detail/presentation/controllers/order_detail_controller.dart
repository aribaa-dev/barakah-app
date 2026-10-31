// lib/features/order_detail/presentation/controllers/order_detail_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_link/features/order/presentation/providers/order_providers.dart';
import 'package:order_link/features/order_history/domain/entities/saved_order.dart';

/// One controller per order id. State: loading, error, data (null = not found).
/// Riverpod 3 syntax: the id arrives through the constructor.
///
/// Data now comes from the shared OrderRepository (Firestore), so the old
/// orderDetailSourceProvider / orderDetailRepositoryProvider are gone.
class OrderDetailController extends AsyncNotifier<SavedOrder?> {
  final String orderId;

  OrderDetailController(this.orderId);

  @override
  Future<SavedOrder?> build() {
    return ref.watch(orderRepositoryProvider).getOrder(orderId);
  }
}

/// autoDispose: leaving the screen drops it, so the next visit loads fresh.
final orderDetailControllerProvider = AsyncNotifierProvider.autoDispose
    .family<OrderDetailController, SavedOrder?, String>(
      OrderDetailController.new,
    );
