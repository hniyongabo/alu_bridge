import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../startups/application/startup_providers.dart';
import '../data/opportunity_repository.dart';
import '../domain/opportunity.dart';

final opportunityRepositoryProvider =
    Provider<OpportunityRepository>((ref) => OpportunityRepository());

final activeOpportunitiesProvider = StreamProvider<List<Opportunity>>((ref) {
  return ref.watch(opportunityRepositoryProvider).watchActiveOpportunities();
});

/// Opportunities posted by the current user's own startup (empty if the user
/// doesn't own a startup, e.g. students or unverified reps with no doc yet).
final myStartupOpportunitiesProvider = StreamProvider<List<Opportunity>>((ref) {
  final startup = ref.watch(currentUserStartupProvider).valueOrNull;
  if (startup == null) return Stream.value(const []);
  return ref.watch(opportunityRepositoryProvider).watchOpportunitiesForStartup(startup.id);
});
