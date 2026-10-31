// lib/features/dashboard/domain/entities/dashboard_metrics_orders.dart
import 'package:order_link/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:order_link/features/order_history/domain/entities/saved_order.dart';

extension DashboardMetricsOrders on DashboardMetrics {
  /// Adds this session's confirmed orders on top of the base numbers.
  /// When a real database returns these totals itself, delete this file.
  DashboardMetrics withOrders(List<SavedOrder> orders, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final todays = orders
        .where(
          (o) =>
              o.placedAt.year == today.year &&
              o.placedAt.month == today.month &&
              o.placedAt.day == today.day,
        )
        .toList();
    final extraSales = todays.fold<double>(0, (sum, o) => sum + o.order.total);

    return DashboardMetrics(
      todaySales: todaySales + extraSales,
      salesTarget: salesTarget,
      ordersBooked: ordersBooked + orders.length,
      ordersToday: ordersToday + todays.length,
      outletVisits: outletVisits,
      totalOutlets: totalOutlets,
      collections: collections,
      invoicesConnected: invoicesConnected,
    );
  }
}
