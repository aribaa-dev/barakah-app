// lib/core/router/app_routes.dart
class AppRoutes {
  /// Shown for a moment while the app checks whether a profile exists.
  static const splash = '/splash';

  /// First-launch screen: name, business name, phone.
  static const profileSetup = '/profile_setup';

  static const dashboard = '/dashboard';
  static const voiceIntake = '/voice_intake';
  static const summary = '/summary';
  static const orderHistory = '/order_history';

  /// Pattern used by the router: the order id is part of the path.
  static const orderDetail = '/order_detail/:id';

  /// Use this when navigating: context.push(AppRoutes.orderDetailPath(id)).
  static String orderDetailPath(String id) => '/order_detail/$id';

  AppRoutes._();
}
