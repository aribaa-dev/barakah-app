// lib/features/order_detail/presentation/widgets/order_item_row.dart
import 'package:flutter/material.dart';
import 'package:order_link/features/summary/domain/entities/order_draft.dart';

/// One line of the order: number, name, "10 kg × Rs. 200", line total.
class OrderItemRow extends StatelessWidget {
  final int index;
  final OrderDraftItem item;

  const OrderItemRow({super.key, required this.index, required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${formatQuantity(item.quantity)} ${item.unit} × ${formatRupees(item.unitPrice)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11.5),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          formatRupees(item.lineTotal),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
      ],
    );
  }
}
