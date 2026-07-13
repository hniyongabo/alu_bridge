import 'package:cloud_firestore/cloud_firestore.dart';

import 'startup.dart';

class StartupRepository {
  StartupRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('startups');

  Stream<Startup?> watchStartupForOwner(String uid) {
    return _collection.where('ownerUid', isEqualTo: uid).limit(1).snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return Startup.fromDoc(snapshot.docs.first);
    });
  }

  Future<void> submitStartup({
    required String ownerUid,
    required String name,
    required String description,
    required String category,
    String? website,
  }) async {
    await _collection.add({
      'name': name,
      'description': description,
      'category': category,
      'website': website,
      'ownerUid': ownerUid,
      'isVerified': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setVerified(String startupId, bool isVerified) async {
    await _collection.doc(startupId).update({'isVerified': isVerified});
  }

  Future<void> updateStartup({
    required String startupId,
    required String name,
    required String description,
    required String category,
    String? website,
  }) async {
    await _collection.doc(startupId).update({
      'name': name,
      'description': description,
      'category': category,
      'website': website,
    });
  }
}
