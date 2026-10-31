// lib/features/order/data/models/order_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:order_link/features/order_history/domain/entities/saved_order.dart';
import 'package:order_link/features/summary/domain/entities/order_draft.dart';

/// The only place that knows how an order looks inside Firestore.
/// Timestamp / DocumentSnapshot never leave the data layer.
///
/// Document shape (collection `orders`):
///   salesmanId : String   <- whose order (the app filters on this)
///   shopName   : String
///   items      : List<{name, quantity, unit, unitPrice, lineTotal}>
///   itemCount  : int
///   total      : double   <- stored so the web dashboard can sum without math
///   placedAt   : Timestamp (device time = when the salesman confirmed)
///   createdAt  : Timestamp (server time = when it reached Firebase)
///
/// LATER, when login exists, also stamp `companyId` here so the agency's
/// web dashboard can query all of its salesmen's orders.
class OrderModel {
  const OrderModel._();

  static Map<String, dynamic> toMap(
    OrderDraft draft, {
    required String salesmanId,
  }) {
    return {
      'salesmanId': salesmanId,
      'shopName': draft.shopName,
      'items': [for (final item in draft.items) _itemToMap(item)],
      'itemCount': draft.items.length,
      'total': draft.total,
      // Device time on purpose: an order booked offline at 3 PM must say 3 PM,
      // not the time the phone finally got signal.
      'placedAt': Timestamp.now(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static SavedOrder fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw const FormatException('Order document has no data');
    }

    final rawItems = (data['items'] as List<dynamic>?) ?? const [];

    return SavedOrder(
      id: doc.id,
      placedAt: (data['placedAt'] as Timestamp).toDate(),
      order: OrderDraft(
        shopName: (data['shopName'] as String?) ?? '',
        items: [
          for (final raw in rawItems)
            _itemFromMap(Map<String, dynamic>.from(raw as Map)),
        ],
      ),
    );
  }

  static Map<String, dynamic> _itemToMap(OrderDraftItem item) => {
    'name': item.name,
    'quantity': item.quantity,
    'unit': item.unit,
    'unitPrice': item.unitPrice,
    'lineTotal': item.lineTotal,
  };

  static OrderDraftItem _itemFromMap(Map<String, dynamic> map) {
    return OrderDraftItem(
      name: map['name'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'] as String,
      unitPrice: (map['unitPrice'] as num).toDouble(),
    );
  }
}
