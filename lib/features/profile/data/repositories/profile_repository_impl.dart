// lib/features/profile/data/repositories/profile_repository_impl.dart
import 'package:order_link/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:order_link/features/profile/domain/entities/salesman_profile.dart';
import 'package:order_link/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remote;

  ProfileRepositoryImpl(this._remote);

  @override
  Stream<SalesmanProfile?> watchProfile() => _remote.watchProfile();

  @override
  Future<void> saveProfile(SalesmanProfile profile) =>
      _remote.saveProfile(profile);
}
