// lib/features/dashboard/presentation/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:order_link/core/router/app_routes.dart';
import 'package:order_link/core/session/session_provider.dart';
import 'package:order_link/core/theme/app_colors.dart';
import 'package:order_link/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:order_link/features/dashboard/domain/entities/dashboard_metrics_orders.dart';
import 'package:order_link/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:order_link/features/dashboard/presentation/widgets/dashboard_bottom_bar.dart';
import 'package:order_link/features/dashboard/presentation/widgets/dashboard_grid.dart';
import 'package:order_link/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:order_link/features/dashboard/presentation/widgets/voice_hint_card.dart';
import 'package:order_link/features/order_history/presentation/controllers/order_history_controller.dart';

// DESIGN CHOICE: this screen stays a StatelessWidget on purpose.
// The two things that need Riverpod (header names, metrics) live in their own
// small ConsumerWidgets below. When metrics refresh, ONLY the sheet rebuilds;
// the Scaffold, header and floating bar are untouched.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const double _bottomBarClearance = 100;

  void _onTabSelected(BuildContext context, DashboardTab tab) {
    switch (tab) {
      case DashboardTab.dashboard:
        break; // already here
      case DashboardTab.voiceIntake:
        // The voice flow state machine (Riverpod) will start from this screen.
        context.push(AppRoutes.voiceIntake);
      case DashboardTab.orderHistory:
        context.push(AppRoutes.orderHistory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 17),
                  child: _SessionHeader(),
                ),
              ),
              Expanded(child: _DashboardSheet()),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: DashboardBottomBar(
                selectedTab: DashboardTab.dashboard,
                onTabSelected: (tab) => _onTabSelected(context, tab),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reads the logged-in user and feeds the (still pure-UI) DashboardHeader.
class _SessionHeader extends ConsumerWidget {
  const _SessionHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    return DashboardHeader(
      businessName: session.businessName,
      salesmanName: session.salesmanName,
    );
  }
}

/// The light-grey rounded sheet. Owns the loading / error / data switch.
class _DashboardSheet extends ConsumerWidget {
  const _DashboardSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(dashboardControllerProvider);
    // Confirmed orders. When one is saved, the numbers below update by
    // themselves, with no refetch and no loading spinner.
    final orders = ref.watch(orderHistoryProvider);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(45)),
      ),
      child: metricsAsync.when(
        data: (metrics) => RefreshIndicator(
          onRefresh: () =>
              ref.read(dashboardControllerProvider.notifier).refresh(),
          child: _DashboardBody(metrics: metrics.withOrders(orders)),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _DashboardError(
          onRetry: () => ref.invalidate(dashboardControllerProvider),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final DashboardMetrics metrics;
  const _DashboardBody({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        // Always scrollable, otherwise pull-to-refresh does nothing when the
        // content is shorter than the screen.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          15,
          0,
          15,
          DashboardScreen._bottomBarClearance,
        ),
        child: Column(
          spacing: 15,
          children: [
            DashboardGrid(metrics: metrics),
            const VoiceHintCard(),
          ],
        ),
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  final VoidCallback onRetry;
  const _DashboardError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          const Text(
            'Could not load dashboard',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
