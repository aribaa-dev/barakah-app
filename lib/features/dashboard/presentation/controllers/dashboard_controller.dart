// lib/features/dashboard/presentation/controllers/dashboard_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_link/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:order_link/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:order_link/features/dashboard/domain/repositories/dashboard_repository.dart';

/// The ONE place that decides which repository the dashboard uses.
final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => const FakeDashboardRepository(),
);

/// Holds
///  `AsyncValue<DashboardMetrics>`: loading, error, or data.
class DashboardController extends AsyncNotifier<DashboardMetrics> {
  @override
  Future<DashboardMetrics> build() {
    // watch (not read): if the repository provider is swapped, this rebuilds.
    return ref.watch(dashboardRepositoryProvider).fetchMetrics();
  }

  /// Used by pull-to-refresh. invalidateSelf re-runs build(); awaiting
  /// `future` keeps the refresh spinner alive until the new data arrives.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final dashboardControllerProvider =
    AsyncNotifierProvider<DashboardController, DashboardMetrics>(
      DashboardController.new,
    );
