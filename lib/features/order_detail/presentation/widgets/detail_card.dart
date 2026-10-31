// lib/features/order_detail/presentation/widgets/detail_card.dart
import 'package:flutter/material.dart';

/// White rounded card with a small grey label on top.
/// Pure UI: same look as the cards on the summary screen.
class DetailCard extends StatelessWidget {
  final String label;
  final Widget child;

  const DetailCard({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
