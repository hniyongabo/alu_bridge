import 'package:cloud_firestore/cloud_firestore.dart';

enum ApplicationStatus { inReview, interviewed, accepted, rejected }

extension ApplicationStatusX on ApplicationStatus {
  String get label => switch (this) {
        ApplicationStatus.inReview => 'In Review',
        ApplicationStatus.interviewed => 'Interviewed',
        ApplicationStatus.accepted => 'Accepted',
        ApplicationStatus.rejected => 'Rejected',
      };

  static ApplicationStatus fromString(String value) {
    return ApplicationStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => ApplicationStatus.inReview,
    );
  }
}

class StudentApplication {
  const StudentApplication({
    required this.id,
    required this.opportunityTitle,
    required this.status,
    this.createdAt,
  });

  factory StudentApplication.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data()!;
    return StudentApplication(
      id: doc.id,
      opportunityTitle: map['opportunityTitle'] as String? ?? '',
      status: ApplicationStatusX.fromString(map['status'] as String? ?? 'inReview'),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  final String id;
  final String opportunityTitle;
  final ApplicationStatus status;
  final DateTime? createdAt;
}
