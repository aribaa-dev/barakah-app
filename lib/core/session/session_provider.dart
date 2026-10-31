// lib/core/session/session_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_link/features/profile/presentation/providers/profile_provider.dart';

/// Who is using the app. Comes from the profile the salesman filled in on
/// first launch (Firestore: salesmen/{uid}), so the dashboard header shows
/// the real name and business.
class Session {
  final String businessName;
  final String salesmanName;

  const Session({required this.businessName, required this.salesmanName});
}

final sessionProvider = Provider<Session>((ref) {
  final profile = ref.watch(profileStreamProvider).value;
  return Session(
    businessName: profile?.businessName ?? '',
    salesmanName: profile?.name ?? '',
  );
});
