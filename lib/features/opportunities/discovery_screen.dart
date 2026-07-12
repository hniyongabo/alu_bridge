import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import 'opportunity_providers.dart';
import 'opportunity.dart';

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _category;
  OpportunityType? _type;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Opportunity> _filter(List<Opportunity> opportunities) {
    return opportunities.where((o) {
      final matchesQuery = _query.isEmpty ||
          o.title.toLowerCase().contains(_query.toLowerCase()) ||
          o.startupName.toLowerCase().contains(_query.toLowerCase());
      final matchesCategory = _category == null || o.category == _category;
      final matchesType = _type == null || o.type == _type;
      return matchesQuery && matchesCategory && matchesType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final opportunitiesAsync = ref.watch(activeOpportunitiesProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'ALU Bridge',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: AppColors.primaryContainer, fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.marginMobile,
              AppSpacing.md,
              AppSpacing.marginMobile,
              0,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Find your next venture...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surfaceContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.secondary, width: 2),
                ),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
              children: [
                _FilterChip(
                  label: 'All types',
                  selected: _type == null,
                  onTap: () => setState(() => _type = null),
                ),
                for (final type in OpportunityType.values)
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                    child: _FilterChip(
                      label: type.label,
                      selected: _type == type,
                      onTap: () => setState(() => _type = type),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
              children: [
                _FilterChip(
                  label: 'All categories',
                  selected: _category == null,
                  onTap: () => setState(() => _category = null),
                ),
                for (final category in opportunityCategories)
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                    child: _FilterChip(
                      label: category,
                      selected: _category == category,
                      onTap: () => setState(() => _category = category),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
            child: Row(
              children: [
                Text('Opportunities', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(width: AppSpacing.xs),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: opportunitiesAsync.when(
              data: (opportunities) {
                final filtered = _filter(opportunities);
                if (filtered.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No opportunities match your filters yet.'),
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.marginMobile,
                    0,
                    AppSpacing.marginMobile,
                    AppSpacing.marginMobile,
                  ),
                  children: [
                    for (final opportunity in filtered)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _OpportunityCard(opportunity: opportunity),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: AppColors.surfaceContainerHigh,
      selectedColor: AppColors.secondary,
      shape: const StadiumBorder(),
      side: BorderSide.none,
      labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: selected ? AppColors.onSecondary : AppColors.onSurfaceVariant,
          ),
    );
  }
}

/// Maps an opportunity type to the Kinetic Horizon tag colors. DESIGN.md
/// only defines Internship/Volunteering/Full-time tag colors; "research"
/// reuses the peach/burnt-orange ("full-time") pairing, and "contract"
/// reuses the tertiary (gold/brown) token family as a 4th distinct tag.
({Color bg, Color text}) _typeTagColors(OpportunityType type) {
  switch (type) {
    case OpportunityType.internship:
      return (bg: AppColors.internshipBg, text: AppColors.internshipText);
    case OpportunityType.volunteering:
      return (bg: AppColors.volunteeringBg, text: AppColors.volunteeringText);
    case OpportunityType.research:
      return (bg: AppColors.fullTimeBg, text: AppColors.fullTimeText);
    case OpportunityType.contract:
      return (bg: AppColors.tertiaryContainer, text: AppColors.onTertiaryContainer);
  }
}

class _OpportunityCard extends StatelessWidget {
  const _OpportunityCard({required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    final tagColors = _typeTagColors(opportunity.type);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  opportunity.startupName.isNotEmpty
                      ? opportunity.startupName[0].toUpperCase()
                      : '?',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: AppColors.primaryContainer),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(opportunity.title, style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      opportunity.startupName,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: AppColors.outline),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _Tag(label: opportunity.type.label, background: tagColors.bg, text: tagColors.text),
              if (opportunity.commitment.isNotEmpty)
                _Tag(
                  label: opportunity.commitment,
                  background: AppColors.surfaceContainer,
                  text: AppColors.onSurfaceVariant,
                ),
              if (opportunity.location.isNotEmpty)
                _Tag(
                  label: opportunity.location,
                  background: AppColors.surfaceContainer,
                  text: AppColors.onSurfaceVariant,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: AppTheme.achievementButtonStyle,
              onPressed: () =>
                  context.push('/opportunities/${opportunity.id}/apply', extra: opportunity),
              child: const Text('Apply Now'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.background, required this.text});

  final String label;
  final Color background;
  final Color text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: text),
      ),
    );
  }
}
