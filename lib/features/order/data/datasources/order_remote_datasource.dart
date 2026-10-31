// lib/features/order/data/datasources/order_remote_datasource.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:order_link/features/order/data/models/order_model.dart';
import 'package:order_link/features/order_history/domain/entities/saved_order.dart';
import 'package:order_link/features/summary/domain/entities/order_draft.dart';

/// The ONLY file that talks to Firestore.
class OrderRemoteDataSource {
  final FirebaseFirestore _db;
  final String _salesmanId;

  OrderRemoteDataSource(this._db, this._salesmanId);

  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection('orders');

  /// Needs a composite index (salesmanId ASC, placedAt DESC).
  /// See firestore.indexes.json, or tap the link Firestore prints in the
  /// debug console the first time this runs.
  Stream<List<SavedOrder>> watchOrders() {
    return _orders
        .where('salesmanId', isEqualTo: _salesmanId)
        .orderBy('placedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(OrderModel.fromDoc).toList());
  }

  Future<SavedOrder?> getOrder(String id) async {
    final doc = await _orders.doc(id).get();
    if (!doc.exists) return null;
    // Never show another salesman's order, even if someone guesses the id.
    if (doc.data()?['salesmanId'] != _salesmanId) return null;
    return OrderModel.fromDoc(doc);
  }

  /// Does NOT wait for the server.
  ///
  /// Firestore's set() only completes once the server confirms, which can be
  /// hours away for a salesman with no signal. The write is already in the
  /// local cache and shows up in watchOrders() instantly, and Firestore
  /// uploads it by itself when the connection returns.
  String saveOrder(OrderDraft draft) {
    final ref = _orders.doc(); // id is generated on the phone
    unawaited(
      ref.set(OrderModel.toMap(draft, salesmanId: _salesmanId)).catchError((
        Object error,
      ) {
        // Reaches here if the server rejects it later (e.g. security rules).
        debugPrint('Order ${ref.id} failed to sync: $error');
      }),
    );
    return ref.id;
  }
}
