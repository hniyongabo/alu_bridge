import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import 'opportunity_providers.dart';
import 'opportunity.dart';
import 'package:alu_bridge/core/widgets/app_error_state.dart';

class MyOpportunitiesScreen extends ConsumerWidget {
  const MyOpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunitiesAsync = ref.watch(myStartupOpportunitiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Opportunities')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.tertiaryFixed,
        foregroundColor: AppColors.primaryContainer,
        onPressed: () => context.push('/opportunities/post'),
        child: const Icon(Icons.add),
      ),
      body: opportunitiesAsync.when(
        data: (opportunities) {
          if (opportunities.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No opportunities posted yet. Tap + to post one.'),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final opportunity in opportunities)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _OpportunityManageCard(opportunity: opportunity),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(child: AppErrorState()),
      ),
    );
  }
}

class _OpportunityManageCard extends ConsumerWidget {
  const _OpportunityManageCard({required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(opportunity.title, style: Theme.of(context).textTheme.titleMedium),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: opportunity.isActive
                        ? AppColors.secondaryContainer
                        : AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    opportunity.isActive ? 'Active' : 'Closed',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: opportunity.isActive
                              ? AppColors.onSecondaryContainer
                              : AppColors.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${opportunity.type.label} · ${opportunity.category}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(
                  onPressed: () => ref
                      .read(opportunityRepositoryProvider)
                      .setActive(opportunity.id, !opportunity.isActive),
                  child: Text(opportunity.isActive ? 'Close' : 'Reopen'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => ref
                      .read(opportunityRepositoryProvider)
                      .deleteOpportunity(opportunity.id),
                  child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
