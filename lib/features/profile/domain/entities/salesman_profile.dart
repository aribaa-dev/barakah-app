// lib/features/profile/domain/entities/salesman_profile.dart

/// Who the salesman is. Saved once, on first launch.
class SalesmanProfile {
  final String name;
  final String businessName;
  final String phone;

  const SalesmanProfile({
    required this.name,
    required this.businessName,
    required this.phone,
  });
}
