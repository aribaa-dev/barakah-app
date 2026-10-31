// lib/core/firebase/firebase_providers.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

/// The id every order is stamped with (salesmanId).
///
/// TODAY: an anonymous Firebase user, signed in from main().
/// LATER (login screen): make this watch `authStateChanges()` so every
/// provider that depends on it rebuilds when the salesman logs in or out.
final currentUserIdProvider = Provider<String>((ref) {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  if (user == null) {
    throw StateError('No signed-in user. Sign in before reading orders.');
  }
  return user.uid;
});
