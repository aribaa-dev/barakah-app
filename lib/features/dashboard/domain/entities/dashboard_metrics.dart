// lib/features/dashboard/presentation/widgets/dashboard_metrics.dart
// RESCO tip: when you wire Riverpod, move this class to domain/entities/
// (it is your "Entity"). The UI only reads it, never changes it.

class DashboardMetrics {
  final double todaySales;
  final double salesTarget;
  final int ordersBooked;
  final int ordersToday;
  final int outletVisits;
  final int totalOutlets;
  final double collections;
  final int invoicesConnected;

  const DashboardMetrics({
    required this.todaySales,
    required this.salesTarget,
    required this.ordersBooked,
    required this.ordersToday,
    required this.outletVisits,
    required this.totalOutlets,
    required this.collections,
    required this.invoicesConnected,
  });

  // Small calculations live HERE, not inside widgets.
  // They also protect us from dividing by zero (which gives NaN and crashes bars).
  double get salesProgress =>
      salesTarget <= 0 ? 0 : (todaySales / salesTarget).clamp(0.0, 1.0);

  double get visitProgress =>
      totalOutlets <= 0 ? 0 : (outletVisits / totalOutlets).clamp(0.0, 1.0);

  int get remainingOutlets => totalOutlets - outletVisits;

  // FIREBASE/SUPABASE (later): add `factory DashboardMetrics.fromJson(...)` here.

  /// Placeholder data so the UI has something to show.
  static const dummy = DashboardMetrics(
    todaySales: 45000,
    salesTarget: 60000,
    ordersBooked: 128,
    ordersToday: 14,
    outletVisits: 32,
    totalOutlets: 50,
    collections: 21500,
    invoicesConnected: 9,
  );
}
