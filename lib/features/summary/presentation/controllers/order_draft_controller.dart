// lib/features/summary/presentation/controllers/order_draft_controller.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_link/features/order/presentation/providers/order_providers.dart';
import 'package:order_link/features/summary/domain/entities/order_draft.dart';

/// The order being reviewed right now. null = nothing in progress.
/// This REPLACES passing the draft through `extra:` in go_router.
class OrderDraftController extends Notifier<OrderDraft?> {
  @override
  OrderDraft? build() => null;

  void setDraft(OrderDraft draft) => state = draft;

  void clear() => state = null;

  /// Called by the edit sheet on the summary screen.
  void updateItem(int index, OrderDraftItem item) {
    final draft = state;
    if (draft == null || index < 0 || index >= draft.items.length) return;

    final items = [...draft.items];
    items[index] = item;
    state = draft.copyWith(items: items);
  }

  /// Called by the "edit shop name" sheet on the summary screen.
  void updateShopName(String name) {
    final draft = state;
    final trimmed = name.trim();
    if (draft == null || trimmed.isEmpty) return;
    state = draft.copyWith(shopName: trimmed);
  }

  /// Called by the trash icon on an item row.
  void removeItem(int index) {
    final draft = state;
    if (draft == null || index < 0 || index >= draft.items.length) return;

    final items = [...draft.items]..removeAt(index);
    state = draft.copyWith(items: items);
  }

  /// Puts a removed item back at its old position (the Undo button).
  void insertItem(int index, OrderDraftItem item) {
    final draft = state;
    if (draft == null) return;

    final items = [...draft.items];
    items.insert(index.clamp(0, items.length), item);
    state = draft.copyWith(items: items);
  }

  /// Saves the draft to Firestore, then clears it.
  /// Returns false if there was nothing to save or the save failed.
  /// The draft is cleared BEFORE the await, so a double tap on
  /// "Confirm Order" finds nothing and does nothing.
  Future<bool> confirm() async {
    final draft = state;
    if (draft == null) return false;

    state = null;
    try {
      await ref.read(orderRepositoryProvider).saveOrder(draft);
      return true;
    } catch (e) {
      debugPrint('Could not save order: $e');
      state = draft; // give the order back so the salesman can retry
      return false;
    }
  }
}

final orderDraftProvider = NotifierProvider<OrderDraftController, OrderDraft?>(
  OrderDraftController.new,
);
