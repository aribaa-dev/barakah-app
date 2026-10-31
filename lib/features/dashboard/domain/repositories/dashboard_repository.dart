// lib/features/dashboard/domain/repositories/dashboard_repository.dart
import 'package:order_link/features/dashboard/domain/entities/dashboard_metrics.dart';

/// The controller talks to THIS interface, never to a concrete source.
/// Today: a fake. Later: swap the implementation in ONE provider
/// (dashboardRepositoryProvider) and no screen or controller changes.
abstract interface class DashboardRepository {
  Future<DashboardMetrics> fetchMetrics();
}
