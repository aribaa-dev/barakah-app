// lib/features/order/domain/repositories/order_repository.dart
import 'package:order_link/features/order_history/domain/entities/saved_order.dart';
import 'package:order_link/features/summary/domain/entities/order_draft.dart';

/// What the app needs from "somewhere that stores orders".
/// Screens and controllers only know this interface, never Firestore.
abstract class OrderRepository {
  /// Live list of the current salesman's orders, newest first.
  Stream<List<SavedOrder>> watchOrders();

  /// One order by id, or null if it doesn't exist / isn't theirs.
  Future<SavedOrder?> getOrder(String id);

  /// Saves a confirmed draft and returns the new order id.
  /// Returns immediately even when the phone is offline (see datasource).
  Future<String> saveOrder(OrderDraft draft);
}
