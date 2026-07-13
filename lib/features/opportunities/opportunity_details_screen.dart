import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import 'opportunity.dart';

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

class OpportunityDetailsScreen extends StatelessWidget {
  const OpportunityDetailsScreen({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    final tagColors = _typeTagColors(opportunity.type);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {},
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginMobile,
                0,
                AppSpacing.marginMobile,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: AppColors.cardShadow,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        opportunity.startupName.isNotEmpty
                            ? opportunity.startupName[0].toUpperCase()
                            : '?',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(opportunity.title, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    opportunity.startupName,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      _Tag(label: opportunity.type.label, background: tagColors.bg, text: tagColors.text),
                      _Tag(
                        label: opportunity.category,
                        background: AppColors.surfaceContainer,
                        text: AppColors.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (opportunity.commitment.isNotEmpty)
                    _MetaRow(icon: Icons.schedule, label: opportunity.commitment),
                  if (opportunity.location.isNotEmpty)
                    _MetaRow(icon: Icons.location_on_outlined, label: opportunity.location),
                  if (opportunity.createdAt != null)
                    _MetaRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Posted ${DateFormat.yMMMd().format(opportunity.createdAt!)}',
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('About this opportunity', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    opportunity.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (opportunity.skillsRequired.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text('Skills required', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        for (final skill in opportunity.skillsRequired)
                          _Tag(
                            label: skill,
                            background: AppColors.secondaryContainer,
                            text: AppColors.onSecondaryContainer,
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
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
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
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
