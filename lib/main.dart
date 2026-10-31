// lib/main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_link/core/router/app_router.dart';
import 'package:order_link/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final auth = FirebaseAuth.instance;
  try {
    if (auth.currentUser == null) {
      await auth.signInAnonymously().timeout(const Duration(seconds: 15));
    }
  } catch (e) {
    debugPrint('Anonymous sign-in failed: $e');
  }

  runApp(const ProviderScope(child: OrderLink()));
}

class OrderLink extends ConsumerWidget {
  const OrderLink({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
