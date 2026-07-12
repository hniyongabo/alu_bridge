import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app_user.dart';

class AuthRepository {
  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Stream<AppUser?> watchAppUser(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromMap(uid, doc.data()!);
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;
    await credential.user!.updateDisplayName(displayName);
    await _firestore.collection('users').doc(uid).set(
          AppUser(
            uid: uid,
            email: email,
            displayName: displayName,
            role: role,
          ).toMap(),
        );
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> updateStudentProfile({
    required String uid,
    required String displayName,
    required List<String> skills,
    String? portfolioUrl,
  }) async {
    if (_auth.currentUser != null) {
      await _auth.currentUser!.updateDisplayName(displayName);
    }
    await _firestore.collection('users').doc(uid).update({
      'displayName': displayName,
      'skills': skills,
      'portfolioUrl': portfolioUrl,
    });
  }
}
