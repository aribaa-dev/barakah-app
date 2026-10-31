// lib/features/order/data/repositories/order_repository_impl.dart
import 'package:order_link/features/order/data/datasources/order_remote_datasource.dart';
import 'package:order_link/features/order/domain/repositories/order_repository.dart';
import 'package:order_link/features/order_history/domain/entities/saved_order.dart';
import 'package:order_link/features/summary/domain/entities/order_draft.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remote;

  OrderRepositoryImpl(this._remote);

  @override
  Stream<List<SavedOrder>> watchOrders() => _remote.watchOrders();

  @override
  Future<SavedOrder?> getOrder(String id) => _remote.getOrder(id);

  @override
  Future<String> saveOrder(OrderDraft draft) async => _remote.saveOrder(draft);
}
