import 'package:cloud_firestore/cloud_firestore.dart';

import 'opportunity.dart';

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

  /// Idempotent: seeds sample opportunities under the known seeded startups
  /// so Discover/Home aren't empty. Safe to call repeatedly (merges).
  Future<void> seedSampleOpportunities() async {
    final samples = <Map<String, Object?>>[
      {
        'id': 'she-connect-frontend',
        'startupId': 'she-connect',
        'startupName': 'SheConnect',
        'title': 'Frontend Developer Intern',
        'description':
            'Help build the SheConnect mobile app UI in Flutter, working closely with our founding design team.',
        'type': OpportunityType.internship,
        'category': 'Engineering',
        'commitment': 'Part-time, 8-10 hrs/week',
        'location': 'Remote',
        'skillsRequired': ['Flutter', 'Dart', 'Figma'],
      },
      {
        'id': 'she-connect-outreach',
        'startupId': 'she-connect',
        'startupName': 'SheConnect',
        'title': 'Community Outreach Volunteer',
        'description':
            'Support mentorship events and peer-support programs for women at ALU.',
        'type': OpportunityType.volunteering,
        'category': 'Marketing',
        'commitment': 'Flexible, 4-6 hrs/week',
        'location': 'Kigali, Rwanda',
        'skillsRequired': ['Communication', 'Event Planning'],
      },
      {
        'id': 'lighted-research',
        'startupId': 'lighted',
        'startupName': 'LightEd',
        'title': 'Curriculum Research Assistant',
        'description':
            'Research accessible learning methods for African students and help shape our course content.',
        'type': OpportunityType.research,
        'category': 'Data',
        'commitment': 'Part-time, 6 hrs/week',
        'location': 'On-campus',
        'skillsRequired': ['Research', 'Writing'],
      },
      {
        'id': 'enligne-growth',
        'startupId': 'enligne',
        'startupName': 'Enligne',
        'title': 'Marketplace Growth Associate',
        'description':
            'Grow our vendor network and help onboard local businesses onto the Enligne marketplace.',
        'type': OpportunityType.internship,
        'category': 'Marketing',
        'commitment': 'Part-time, 10 hrs/week',
        'location': 'Remote',
        'skillsRequired': ['Sales', 'Marketing'],
      },
      {
        'id': 'earthwise-data',
        'startupId': 'earthwise-chicken',
        'startupName': 'Earthwise Chicken',
        'title': 'Agribusiness Data Analyst',
        'description':
            'Analyze production data to help optimize our sustainable poultry operations.',
        'type': OpportunityType.internship,
        'category': 'Data',
        'commitment': 'Part-time, 8 hrs/week',
        'location': 'Kigali, Rwanda',
        'skillsRequired': ['Excel', 'Data Analysis'],
      },
      {
        'id': 'marmar-design',
        'startupId': 'marmar',
        'startupName': 'MARMAR',
        'title': 'Brand Design Intern',
        'description':
            'Design creative and lifestyle product visuals for the ALU community.',
        'type': OpportunityType.internship,
        'category': 'Design',
        'commitment': 'Part-time, 8 hrs/week',
        'location': 'Remote',
        'skillsRequired': ['Graphic Design', 'Adobe Illustrator'],
      },
    ];

    final batch = _firestore.batch();
    for (final s in samples) {
      final id = s['id']! as String;
      batch.set(
        _collection.doc(id),
        {
          'startupId': s['startupId'],
          'startupName': s['startupName'],
          'title': s['title'],
          'description': s['description'],
          'type': (s['type'] as OpportunityType).value,
          'category': s['category'],
          'commitment': s['commitment'],
          'location': s['location'],
          'skillsRequired': s['skillsRequired'],
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }
}
