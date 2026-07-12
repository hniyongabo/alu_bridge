import 'package:cloud_firestore/cloud_firestore.dart';

enum OpportunityType { internship, volunteering, research, contract }

extension OpportunityTypeX on OpportunityType {
  String get value => name;

  String get label => switch (this) {
        OpportunityType.internship => 'Internship',
        OpportunityType.volunteering => 'Volunteering',
        OpportunityType.research => 'Research',
        OpportunityType.contract => 'Contract',
      };

  static OpportunityType fromString(String value) {
    return OpportunityType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => OpportunityType.internship,
    );
  }
}

const opportunityCategories = ['Design', 'Engineering', 'Marketing', 'Data', 'Other'];

class Opportunity {
  const Opportunity({
    required this.id,
    required this.startupId,
    required this.startupName,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.commitment,
    required this.location,
    required this.skillsRequired,
    required this.isActive,
    this.createdAt,
  });

  factory Opportunity.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data()!;
    return Opportunity(
      id: doc.id,
      startupId: map['startupId'] as String? ?? '',
      startupName: map['startupName'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      type: OpportunityTypeX.fromString(map['type'] as String? ?? 'internship'),
      category: map['category'] as String? ?? 'Other',
      commitment: map['commitment'] as String? ?? '',
      location: map['location'] as String? ?? '',
      skillsRequired: (map['skillsRequired'] as List<dynamic>?)?.cast<String>() ?? const [],
      isActive: map['isActive'] as bool? ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  final String id;
  final String startupId;
  final String startupName;
  final String title;
  final String description;
  final OpportunityType type;
  final String category;
  final String commitment;
  final String location;
  final List<String> skillsRequired;
  final bool isActive;
  final DateTime? createdAt;
}
