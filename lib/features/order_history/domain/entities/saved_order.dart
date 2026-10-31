// lib/features/order_history/domain/entities/saved_order.dart
import 'package:order_link/features/summary/domain/entities/order_draft.dart';

/// A confirmed order: the draft plus when it was placed.
/// Shared by the history list and the order detail screen.
class SavedOrder {
  final String id;
  final DateTime placedAt;
  final OrderDraft order;

  const SavedOrder({
    required this.id,
    required this.placedAt,
    required this.order,
  });

  // Small calculations live HERE, not inside widgets.

  /// Short number to show people, e.g. "#482913". The full id stays internal.
  String get orderNumber =>
      '#${id.length > 6 ? id.substring(id.length - 6) : id}';

  int get itemCount => order.items.length;
}
