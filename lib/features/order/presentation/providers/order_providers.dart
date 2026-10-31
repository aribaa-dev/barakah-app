// lib/features/order/presentation/providers/order_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_link/core/firebase/firebase_provider.dart';
import 'package:order_link/features/order/data/datasources/order_remote_datasource.dart';
import 'package:order_link/features/order/data/repositories/order_repository_impl.dart';
import 'package:order_link/features/order/domain/repositories/order_repository.dart';
import 'package:order_link/features/order_history/domain/entities/saved_order.dart';

/// The ONE place that decides orders live in Firestore.
/// Rebuilds automatically if the signed-in user changes.
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final db = ref.watch(firestoreProvider);
  final userId = ref.watch(currentUserIdProvider);
  return OrderRepositoryImpl(OrderRemoteDataSource(db, userId));
});

/// Live stream of this salesman's orders, newest first.
final orderHistoryStreamProvider = StreamProvider<List<SavedOrder>>(
  (ref) => ref.watch(orderRepositoryProvider).watchOrders(),
);
