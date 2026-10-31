// lib/features/order_detail/presentation/widgets/order_total_bar.dart
import 'package:flutter/material.dart';
import 'package:order_link/features/summary/domain/entities/order_draft.dart';

class OrderTotalBar extends StatelessWidget {
  final OrderDraft order;

  const OrderTotalBar({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Total Amount',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatRupees(order.total),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w800,
              fontSize: 19,
            ),
          ),
        ],
      ),
    );
  }
}
