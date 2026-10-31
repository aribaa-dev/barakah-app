// lib/features/order_detail/data/repositories/order_detail_repository_impl.dart
import 'package:order_link/features/order_detail/domain/repositories/order_detail_repository.dart';
import 'package:order_link/features/order_history/domain/entities/saved_order.dart';
import 'package:order_link/features/order_detail/data/source/order_detail_source.dart';

/// Sits between the controller and the source. Today it just forwards.
/// Later this is where you turn source errors into friendly ones, or merge
/// a remote source with a local cache.
class OrderDetailRepositoryImpl implements OrderDetailRepository {
  final OrderDetailSource _source;

  const OrderDetailRepositoryImpl(this._source);

  @override
  Future<SavedOrder?> getOrderDetail(String orderId) =>
      _source.fetchById(orderId);
}
