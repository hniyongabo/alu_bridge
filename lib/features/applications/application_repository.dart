import 'package:cloud_firestore/cloud_firestore.dart';

import 'student_application.dart';

class ApplicationRepository {
  ApplicationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('applications');

  Stream<List<StudentApplication>> watchMyApplications(String studentUid) {
    return _collection.where('studentUid', isEqualTo: studentUid).snapshots().map((snapshot) {
      final apps = snapshot.docs.map(StudentApplication.fromDoc).toList();
      apps.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      return apps;
    });
  }

  Future<void> submitApplication({
    required String studentUid,
    required String opportunityId,
    required String opportunityTitle,
    required String motivation,
    required String experience,
    String? portfolioUrl,
  }) async {
    await _collection.add({
      'studentUid': studentUid,
      'opportunityId': opportunityId,
      'opportunityTitle': opportunityTitle,
      'motivation': motivation,
      'experience': experience,
      'portfolioUrl': portfolioUrl,
      'status': ApplicationStatus.inReview.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Idempotent: seeds 2 sample applications for [studentUid] so the
  /// dashboard has real (not hardcoded) data to demo. Safe to call
  /// repeatedly (merges, doesn't duplicate).
  Future<void> seedSampleApplications(String studentUid) async {
    final batch = _firestore.batch();
    final samples = [
      {'id': 'sample-1', 'title': 'Frontend Developer', 'status': ApplicationStatus.inReview},
      {'id': 'sample-2', 'title': 'Data Analyst Intern', 'status': ApplicationStatus.interviewed},
    ];
    for (final s in samples) {
      batch.set(
        _collection.doc('${studentUid}_${s['id']}'),
        {
          'studentUid': studentUid,
          'opportunityTitle': s['title'],
          'status': (s['status'] as ApplicationStatus).name,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }
}
