// lib/features/order_detail/presentation/screens/order_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:order_link/core/router/app_routes.dart';
import 'package:order_link/features/order_detail/presentation/controllers/order_detail_controller.dart';
import 'package:order_link/features/order_detail/presentation/widgets/detail_card.dart';
import 'package:order_link/features/order_detail/presentation/widgets/order_item_row.dart';
import 'package:order_link/features/order_detail/presentation/widgets/order_total_bar.dart';
import 'package:order_link/features/order_history/domain/entities/saved_order.dart';

/// Read-only view of one confirmed order.
/// It receives only the order's id; the data comes from the controller.
class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.orderHistory);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailControllerProvider(orderId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _Header(
                subtitle: orderAsync.value?.orderNumber,
                onBack: () => _handleBack(context),
              ),
            ),
            Expanded(
              child: orderAsync.when(
                data: (saved) => saved == null
                    ? _Message(
                        title: 'Order not found',
                        actionLabel: 'Back to history',
                        onAction: () => _handleBack(context),
                      )
                    : _DetailBody(saved: saved),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _Message(
                  title: 'Could not load this order',
                  actionLabel: 'Retry',
                  onAction: () =>
                      ref.invalidate(orderDetailControllerProvider(orderId)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String? subtitle;
  final VoidCallback onBack;

  const _Header({required this.subtitle, required this.onBack});

  @override
  Widget build(BuildContext context) {
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
                'Order Details',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
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

class _DetailBody extends StatelessWidget {
  final SavedOrder saved;

  const _DetailBody({required this.saved});

  @override
  Widget build(BuildContext context) {
    final order = saved.order;
    final items = order.items;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          DetailCard(
            label: 'Shop Name',
            child: Row(
              children: [
                const Icon(
                  Icons.storefront_rounded,
                  color: Colors.black,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.shopName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          DetailCard(
            label: 'Order Info',
            child: Row(
              children: [
                Expanded(
                  child: _InfoCell(
                    label: 'Order No.',
                    value: saved.orderNumber,
                  ),
                ),
                Expanded(
                  child: _InfoCell(
                    label: 'Placed on',
                    value: DateFormat(
                      'd MMM yyyy, h:mm a',
                    ).format(saved.placedAt),
                  ),
                ),
              ],
            ),
          ),
          DetailCard(
            label: 'Items (${saved.itemCount})',
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const Divider(height: 20, thickness: 0.6),
                  OrderItemRow(index: i, item: items[i]),
                ],
              ],
            ),
          ),
          OrderTotalBar(order: order),
        ],
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final String label;
  final String value;

  const _InfoCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 11.5),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Centered message used for "not found" and "error".
class _Message extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _Message({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
