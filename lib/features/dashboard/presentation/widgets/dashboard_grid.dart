// lib/features/dashboard/presentation/widgets/dashboard_grid.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:order_link/core/theme/app_colors.dart';
import 'package:order_link/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:order_link/features/dashboard/presentation/widgets/stat_card.dart';

class DashboardGrid extends StatelessWidget {
  // `required` on purpose: the grid must not secretly use dummy data.
  // The screen decides where the data comes from.
  final DashboardMetrics metrics;

  const DashboardGrid({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final cards = _cardsFrom(metrics);

    return GridView.builder(
      shrinkWrap: true, // grid is only as tall as its cards
      physics: const NeverScrollableScrollPhysics(), // parent scrolls, not me
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.10,
      ),
      itemBuilder: (_, i) => StatCard(model: cards[i]),
    );
  }
}

final _rs = NumberFormat('#,##0'); // 45000 -> 45,000

/// Turns raw numbers into card-shaped data.
/// Typed (DashboardMetrics) instead of `dynamic`, so typos like
/// `m.todaySale` become red errors instead of crashes at runtime.
List<StatCardModel> _cardsFrom(DashboardMetrics m) => [
  StatCardModel(
    title: "Today's Sales",
    value: _rs.format(m.todaySales),
    showCurrency: true,
    footnote: 'Target: Rs. ${_rs.format(m.salesTarget)}',
    progress: m.salesProgress,
    icon: Icons.monetization_on,
    iconColor: AppColors.accent,
    iconBackground: AppColors.accentSoft,
  ),
  StatCardModel(
    title: 'Orders Booked',
    value: '${m.ordersBooked} Orders',
    footnote: '${m.ordersToday} booked today',
    icon: Icons.receipt_long,
    iconColor: AppColors.accent,
    iconBackground: AppColors.accentSoft,
  ),
  StatCardModel(
    title: 'Outlet Visits',
    value: '${m.outletVisits}/${m.totalOutlets}',
    footnote: '${m.remainingOutlets} remaining',
    progress: m.visitProgress,
    icon: Icons.storefront,
    iconColor: AppColors.blue,
    iconBackground: AppColors.blueSoft,
    circleBadge: true,
  ),
  StatCardModel(
    title: 'Collections',
    value: _rs.format(m.collections),
    showCurrency: true,
    footnote: '${m.invoicesConnected} invoices connected',
    icon: Icons.account_balance_wallet,
    iconColor: AppColors.green,
    iconBackground: AppColors.greenSoft,
  ),
];
