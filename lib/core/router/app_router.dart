// lib/core/router/app_router.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show CircularProgressIndicator, Colors, Scaffold;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:order_link/core/router/app_routes.dart';
import 'package:order_link/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:order_link/features/order_detail/presentation/screen/order_detail_screen.dart';
import 'package:order_link/features/order_history/presentation/screens/order_history_screen.dart';
import 'package:order_link/features/profile/presentation/screens/profile_setup_screen.dart';
import 'package:order_link/features/summary/presentation/screens/summary_screen.dart';
import 'package:order_link/features/voice_intake/presentation/screens/voice_intake_screen.dart';
import 'package:order_link/features/profile/presentation/providers/profile_provider.dart';

/// The router is a provider so it can react to the profile:
///   still checking  -> splash
///   no profile yet  -> profile setup (the user can't reach anything else)
///   profile exists  -> normal app
final appRouterProvider = Provider<GoRouter>((ref) {
  // Tells GoRouter to run `redirect` again whenever the profile changes.
  final refresh = ValueNotifier<int>(0);
  ref.listen(profileStreamProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    refreshListenable: refresh,
    redirect: (context, state) {
      final profile = ref.read(profileStreamProvider);
      final here = state.matchedLocation;

      // First answer from Firestore not here yet.
      if (profile.isLoading && !profile.hasValue) {
        return here == AppRoutes.splash ? null : AppRoutes.splash;
      }

      // No profile (or it could not be read): ask for it.
      if (profile.value == null) {
        return here == AppRoutes.profileSetup ? null : AppRoutes.profileSetup;
      }

      // Profile exists: leave the splash behind.
      if (here == AppRoutes.splash) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) =>
            const CupertinoPage(child: _SplashScreen()),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        pageBuilder: (context, state) =>
            const CupertinoPage(child: ProfileSetupScreen()),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        pageBuilder: (context, state) =>
            const CupertinoPage(child: DashboardScreen()),
      ),
      GoRoute(
        path: AppRoutes.voiceIntake,
        pageBuilder: (context, state) => const CupertinoPage(
          fullscreenDialog: true,
          child: VoiceIntakeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.summary,
        // The live draft lives in orderDraftProvider, so no `extra:`.
        pageBuilder: (context, state) =>
            const CupertinoPage(child: SummaryScreen()),
      ),
      GoRoute(
        path: AppRoutes.orderHistory,
        pageBuilder: (context, state) =>
            const CupertinoPage(child: OrderHistoryScreen()),
      ),
      GoRoute(
        path: AppRoutes.orderDetail,
        // Only the id travels in the URL. The screen loads the order itself.
        pageBuilder: (context, state) => CupertinoPage(
          child: OrderDetailScreen(orderId: state.pathParameters['id']!),
        ),
      ),
    ],
  );
});

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}
