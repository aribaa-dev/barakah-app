// lib/features/dashboard/data/repositories/fake_dashboard_repository.dart
import 'package:order_link/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:order_link/features/dashboard/domain/repositories/dashboard_repository.dart';

/// Placeholder source so the loading state is real and visible.
class FakeDashboardRepository implements DashboardRepository {
  const FakeDashboardRepository();

  @override
  Future<DashboardMetrics> fetchMetrics() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return DashboardMetrics.dummy;
  }
}
