// lib/features/profile/data/datasources/profile_remote_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:order_link/features/profile/domain/entities/salesman_profile.dart';

/// The ONLY profile file that talks to Firestore.
///
/// Document: salesmen/{uid}
///   name, businessName, phone : String
///   updatedAt                 : server timestamp
///
/// LATER (agency plan): add `companyId` here so the web dashboard can list
/// every salesman of one company.
class ProfileRemoteDataSource {
  final FirebaseFirestore _db;
  final String _uid;

  ProfileRemoteDataSource(this._db, this._uid);

  DocumentReference<Map<String, dynamic>> get _doc =>
      _db.collection('salesmen').doc(_uid);

  Stream<SalesmanProfile?> watchProfile() {
    return _doc.snapshots().map((snap) {
      final data = snap.data();
      if (!snap.exists || data == null) return null;

      final name = (data['name'] as String?)?.trim() ?? '';
      final business = (data['businessName'] as String?)?.trim() ?? '';
      if (name.isEmpty || business.isEmpty) return null; // incomplete = redo

      return SalesmanProfile(
        name: name,
        businessName: business,
        phone: (data['phone'] as String?)?.trim() ?? '',
      );
    });
  }

  Future<void> saveProfile(SalesmanProfile profile) {
    return _doc.set({
      'name': profile.name,
      'businessName': profile.businessName,
      'phone': profile.phone,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
