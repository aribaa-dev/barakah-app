// lib/features/profile/presentation/providers/profile_providers.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_link/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:order_link/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:order_link/features/profile/domain/entities/salesman_profile.dart';
import 'package:order_link/features/profile/domain/repositories/profile_repository.dart';
import 'package:order_link/core/firebase/firebase_provider.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final db = ref.watch(firestoreProvider);
  final uid = ref.watch(currentUserIdProvider);
  return ProfileRepositoryImpl(ProfileRemoteDataSource(db, uid));
});

/// Live profile. Loading = still checking, data(null) = not filled in yet.
final profileStreamProvider = StreamProvider<SalesmanProfile?>(
  (ref) => ref.watch(profileRepositoryProvider).watchProfile(),
);

/// State = `AsyncValue<void>`: loading while saving, error if it failed.
class SaveProfileController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Returns true when the profile was saved.
  Future<bool> save(SalesmanProfile profile) async {
    if (state.isLoading) return false; // ignore a second tap

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(profileRepositoryProvider)
          .saveProfile(profile)
          .timeout(const Duration(seconds: 15)),
    );
    return !state.hasError;
  }
}

final saveProfileControllerProvider =
    AsyncNotifierProvider.autoDispose<SaveProfileController, void>(
      SaveProfileController.new,
    );
