import 'package:cloud_firestore/cloud_firestore.dart';

enum ApplicationStatus { inReview, accepted, rejected }

extension ApplicationStatusX on ApplicationStatus {
  String get label => switch (this) {
        ApplicationStatus.inReview => 'In Review',
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
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupId,
    required this.startupName,
    required this.studentName,
    required this.status,
    required this.motivation,
    required this.experience,
    this.portfolioUrl,
    this.resumeUrl,
    this.createdAt,
  });

  factory StudentApplication.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data()!;
    return StudentApplication(
      id: doc.id,
      opportunityId: map['opportunityId'] as String? ?? '',
      opportunityTitle: map['opportunityTitle'] as String? ?? '',
      startupId: map['startupId'] as String? ?? '',
      startupName: map['startupName'] as String? ?? '',
      studentName: map['studentName'] as String? ?? '',
      status: ApplicationStatusX.fromString(map['status'] as String? ?? 'inReview'),
      motivation: map['motivation'] as String? ?? '',
      experience: map['experience'] as String? ?? '',
      portfolioUrl: map['portfolioUrl'] as String?,
      resumeUrl: map['resumeUrl'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String startupId;
  final String startupName;
  final String studentName;
  final ApplicationStatus status;
  final String motivation;
  final String experience;
  final String? portfolioUrl;
  final String? resumeUrl;
  final DateTime? createdAt;
}
