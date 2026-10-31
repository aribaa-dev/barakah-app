// lib/features/order_history/presentation/screens/order_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:order_link/core/router/app_routes.dart';
import 'package:order_link/features/order_history/domain/entities/saved_order.dart';
import 'package:order_link/features/order_history/presentation/controllers/order_history_controller.dart';
import 'package:order_link/features/order_history/presentation/controllers/order_search_controller.dart';
import 'package:order_link/features/order_history/presentation/widgets/no_results_state.dart';
import 'package:order_link/features/order_history/presentation/widgets/order_search_bar.dart';
import 'package:order_link/features/summary/domain/entities/order_draft.dart';

// No local state: search text lives in OrderSearchController (Riverpod),
// and the filtered list comes from filteredOrdersProvider.
class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allOrders = ref.watch(orderHistoryProvider);
    final filtered = ref.watch(filteredOrdersProvider);
    final query = ref.watch(orderSearchControllerProvider).trim();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                count: allOrders.length,
                onBack: () => _handleBack(context),
              ),
              const SizedBox(height: 16),
              if (allOrders.isNotEmpty) ...[
                const OrderSearchBar(),
                const SizedBox(height: 16),
              ],
              Expanded(
                child: allOrders.isEmpty
                    ? _EmptyState(
                        onAction: () => context.push(AppRoutes.voiceIntake),
                      )
                    : filtered.isEmpty
                    ? NoResultsState(query: query)
                    : ListView.separated(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final saved = filtered[index];
                          return _OrderTile(
                            saved: saved,
                            // Only the id is passed; the detail screen loads it.
                            onTap: () => context.push(
                              AppRoutes.orderDetailPath(saved.id),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int count;
  final VoidCallback onBack;

  const _Header({required this.count, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final subtitle = count == 0
        ? 'No orders yet'
        : '$count ${count == 1 ? 'order' : 'orders'}';

    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.black87,
            size: 24,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Order History',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderTile extends StatelessWidget {
  final SavedOrder saved;
  final VoidCallback onTap;

  const _OrderTile({required this.saved, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final order = saved.order;
    final itemCount = order.items.length;
    final radius = BorderRadius.circular(16);

    return Material(
      color: Colors.white,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  size: 20,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.shopName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$itemCount ${itemCount == 1 ? 'item' : 'items'}'
                      ' · ${_formatPlacedAt(saved.placedAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatRupees(order.total),
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Today, 3:42 PM" for today, "9 Oct, 3:42 PM" for older orders.
String _formatPlacedAt(DateTime t) {
  final now = DateTime.now();
  final isToday =
      t.year == now.year && t.month == now.month && t.day == now.day;
  return isToday
      ? 'Today, ${DateFormat('h:mm a').format(t)}'
      : DateFormat('d MMM, h:mm a').format(t);
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAction;

  const _EmptyState({required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 38,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No orders yet',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Orders you confirm will show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.mic_rounded),
              label: const Text('Record Order'),
            ),
          ],
        ),
      ),
    );
  }
}
