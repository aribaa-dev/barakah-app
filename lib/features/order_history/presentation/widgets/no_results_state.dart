// lib/features/order_history/presentation/widgets/no_results_state.dart
import 'package:flutter/material.dart';

class NoResultsState extends StatelessWidget {
  final String query;

  const NoResultsState({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 44,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 16),
            const Text(
              'No matching orders',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Nothing found for "$query".',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
