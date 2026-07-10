import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/startup.dart';

class StartupRepository {
  StartupRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('startups');

  /// Verified startups, sorted client-side to avoid requiring a composite index.
  Stream<List<Startup>> watchVerifiedStartups() {
    return _collection.where('isVerified', isEqualTo: true).snapshots().map((snapshot) {
      final startups = snapshot.docs.map(Startup.fromDoc).toList();
      startups.sort((a, b) => a.name.compareTo(b.name));
      return startups;
    });
  }

  Stream<List<Startup>> watchPendingStartups() {
    return _collection.where('isVerified', isEqualTo: false).snapshots().map((snapshot) {
      final startups = snapshot.docs.map(Startup.fromDoc).toList();
      startups.sort((a, b) => (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0)));
      return startups;
    });
  }

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

  /// Idempotent: pre-verifies the known ALU startups so the platform is
  /// demonstrably gated to recognized ventures from day one. Safe to call
  /// repeatedly (merges, doesn't duplicate).
  Future<void> seedKnownStartups() async {
    final seeds = <Map<String, Object?>>[
      {
        'id': 'she-connect',
        'name': 'SheConnect',
        'description':
            'Community platform empowering women at ALU through mentorship, events, and peer support.',
        'category': 'Community',
      },
      {
        'id': 'lighted',
        'name': 'LightEd',
        'description': 'EdTech venture building accessible learning tools for African students.',
        'category': 'EdTech',
      },
      {
        'id': 'enligne',
        'name': 'Enligne',
        'description': 'Marketplace connecting local vendors with ALU students online.',
        'category': 'Marketplace',
      },
      {
        'id': 'earthwise-chicken',
        'name': 'Earthwise Chicken',
        'description': 'Sustainable poultry agribusiness based in Rwanda.',
        'category': 'AgriTech',
      },
      {
        'id': 'marmar',
        'name': 'MARMAR',
        'description': 'Student-led venture building creative and lifestyle products for the ALU community.',
        'category': 'Lifestyle',
      },
    ];

    final batch = _firestore.batch();
    for (final seed in seeds) {
      final id = seed['id']! as String;
      batch.set(
        _collection.doc(id),
        {
          'name': seed['name'],
          'description': seed['description'],
          'category': seed['category'],
          'website': null,
          'ownerUid': null,
          'isVerified': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }
}
