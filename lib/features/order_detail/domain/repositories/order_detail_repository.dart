// lib/features/order_detail/domain/repositories/order_detail_repository.dart
import 'package:order_link/features/order_history/domain/entities/saved_order.dart';

/// The controller talks to THIS interface only.
abstract interface class OrderDetailRepository {
  /// null = no order with that id.
  Future<SavedOrder?> getOrderDetail(String orderId);
}
