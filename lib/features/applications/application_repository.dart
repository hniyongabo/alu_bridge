import 'package:cloud_firestore/cloud_firestore.dart';

import 'student_application.dart';

class ApplicationAlreadyExistsException implements Exception {
  const ApplicationAlreadyExistsException();

  @override
  String toString() => 'You have already applied to this opportunity';
}

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

  Stream<List<StudentApplication>> watchApplicationsForStartup(String startupId) {
    return _collection.where('startupId', isEqualTo: startupId).snapshots().map((snapshot) {
      final apps = snapshot.docs.map(StudentApplication.fromDoc).toList();
      apps.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      return apps;
    });
  }

  Future<void> submitApplication({
    required String studentUid,
    required String studentName,
    required String opportunityId,
    required String opportunityTitle,
    required String startupId,
    required String startupName,
    required String motivation,
    required String experience,
    String? portfolioUrl,
  }) async {
    final existing = await _collection
        .where('opportunityId', isEqualTo: opportunityId)
        .where('studentUid', isEqualTo: studentUid)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      throw const ApplicationAlreadyExistsException();
    }

    await _collection.add({
      'studentUid': studentUid,
      'studentName': studentName,
      'opportunityId': opportunityId,
      'opportunityTitle': opportunityTitle,
      'startupId': startupId,
      'startupName': startupName,
      'motivation': motivation,
      'experience': experience,
      'portfolioUrl': portfolioUrl,
      'status': ApplicationStatus.inReview.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStatus(String applicationId, ApplicationStatus status) async {
    await _collection.doc(applicationId).update({'status': status.name});
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
