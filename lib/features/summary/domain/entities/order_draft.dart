// lib/features/summary/domain/entities/order_draft.dart
class OrderDraftItem {
  final String name;
  final double quantity;
  final String unit;
  final double unitPrice;

  const OrderDraftItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
  });

  double get lineTotal => quantity * unitPrice;

  OrderDraftItem copyWith({double? quantity, double? unitPrice}) {
    return OrderDraftItem(
      name: name,
      quantity: quantity ?? this.quantity,
      unit: unit,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}

class OrderDraft {
  final String shopName;
  final List<OrderDraftItem> items;

  const OrderDraft({required this.shopName, required this.items});

  double get total => items.fold(0, (sum, item) => sum + item.lineTotal);

  OrderDraft copyWith({String? shopName, List<OrderDraftItem>? items}) {
    return OrderDraft(
      shopName: shopName ?? this.shopName,
      items: items ?? this.items,
    );
  }

  /// Placeholder data until a real speech-to-text pipeline exists.
  static const dummy = OrderDraft(
    shopName: 'Al-Noor General Store',
    items: [
      OrderDraftItem(name: 'Milk', quantity: 10, unit: 'Litre', unitPrice: 150),
      OrderDraftItem(name: 'Sugar', quantity: 5, unit: 'Kg', unitPrice: 130),
      OrderDraftItem(
        name: 'Rice (Basmati)',
        quantity: 2,
        unit: 'Kg',
        unitPrice: 450,
      ),
    ],
  );
}

/// 1500 -> "₨ 1,500", 12.5 -> "₨ 12.50"
String formatRupees(num value) {
  final isWhole = value == value.roundToDouble();
  final fixed = value.abs().toStringAsFixed(isWhole ? 0 : 2);
  final parts = fixed.split('.');
  final digits = parts.first;

  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }

  final decimals = parts.length > 1 ? '.${parts[1]}' : '';
  final sign = value < 0 ? '-' : '';
  return '₨ $sign$buffer$decimals';
}

/// 10.0 -> "10", 2.5 -> "2.5"
String formatQuantity(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toString();
