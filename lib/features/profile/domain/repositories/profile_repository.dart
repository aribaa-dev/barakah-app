// lib/features/profile/domain/repositories/profile_repository.dart
import 'package:order_link/features/profile/domain/entities/salesman_profile.dart';

abstract class ProfileRepository {
  /// Live profile of the signed-in salesman. null = not filled in yet.
  Stream<SalesmanProfile?> watchProfile();

  Future<void> saveProfile(SalesmanProfile profile);
}
