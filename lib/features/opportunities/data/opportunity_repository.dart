import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/opportunity.dart';

class OpportunityRepository {
  OpportunityRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('opportunities');

  Stream<List<Opportunity>> watchActiveOpportunities() {
    return _collection.where('isActive', isEqualTo: true).snapshots().map((snapshot) {
      final items = snapshot.docs.map(Opportunity.fromDoc).toList();
      items.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      return items;
    });
  }

  Stream<List<Opportunity>> watchOpportunitiesForStartup(String startupId) {
    return _collection.where('startupId', isEqualTo: startupId).snapshots().map((snapshot) {
      final items = snapshot.docs.map(Opportunity.fromDoc).toList();
      items.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      return items;
    });
  }

  Future<void> createOpportunity({
    required String startupId,
    required String startupName,
    required String title,
    required String description,
    required OpportunityType type,
    required String category,
    required String commitment,
    required String location,
    required List<String> skillsRequired,
  }) async {
    await _collection.add({
      'startupId': startupId,
      'startupName': startupName,
      'title': title,
      'description': description,
      'type': type.value,
      'category': category,
      'commitment': commitment,
      'location': location,
      'skillsRequired': skillsRequired,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setActive(String opportunityId, bool isActive) async {
    await _collection.doc(opportunityId).update({'isActive': isActive});
  }

  Future<void> deleteOpportunity(String opportunityId) async {
    await _collection.doc(opportunityId).delete();
  }
}
