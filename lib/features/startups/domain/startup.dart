import 'package:cloud_firestore/cloud_firestore.dart';

class Startup {
  const Startup({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.isVerified,
    this.website,
    this.ownerUid,
    this.createdAt,
  });

  factory Startup.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data()!;
    return Startup(
      id: doc.id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'Other',
      isVerified: map['isVerified'] as bool? ?? false,
      website: map['website'] as String?,
      ownerUid: map['ownerUid'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  final String id;
  final String name;
  final String description;
  final String category;
  final bool isVerified;
  final String? website;
  final String? ownerUid;
  final DateTime? createdAt;
}
