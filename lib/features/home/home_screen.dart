import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../applications/application_providers.dart';
import '../applications/student_application.dart';
import '../auth/auth_providers.dart';
import '../auth/app_user.dart';
import '../opportunities/opportunity_providers.dart';
import '../opportunities/opportunity.dart';
import '../startups/startup_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUserAsync = ref.watch(currentAppUserProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryContainer,
              child: Icon(Icons.person, color: Colors.white, size: 20),
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
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
        ],
      ),
      body: appUserAsync.when(
        data: (appUser) {
          if (appUser == null) {
            return const Center(child: Text('No profile found.'));
          }
          return appUser.role == UserRole.startup
              ? _StartupHomeBody(appUser: appUser)
              : _StudentHomeBody(appUser: appUser);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _StudentHomeBody extends ConsumerWidget {
  const _StudentHomeBody({required this.appUser});

  final AppUser appUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunitiesAsync = ref.watch(activeOpportunitiesProvider);
    final applicationsAsync = ref.watch(myApplicationsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Icon(
                    Icons.rocket_launch,
                    size: 140,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WELCOME BACK',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.onPrimaryContainer,
                            letterSpacing: 1.2,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Ready to grow, ${appUser.displayName}?',
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(color: Colors.white, fontSize: 28),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Latest Opportunities
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.psychology_outlined, color: AppColors.secondary),
                  const SizedBox(width: AppSpacing.xs),
                  Text('Latest Opportunities', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          opportunitiesAsync.when(
            data: (opportunities) {
              final top = opportunities.take(3).toList();
              if (top.isEmpty) {
                return const Text('No opportunities posted yet.');
              }
              return Column(
                children: [
                  for (final o in top)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _RecommendationCard(opportunity: o),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Text('Error: $e'),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Applications
          Row(
            children: [
              const Icon(Icons.assignment_turned_in_outlined, color: AppColors.primaryContainer),
              const SizedBox(width: AppSpacing.xs),
              Text('Applications', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: applicationsAsync.when(
              data: (applications) {
                if (applications.isEmpty) {
                  return const Text('No applications yet.');
                }
                return Column(
                  children: [
                    for (final app in applications)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _ApplicationRow(application: app),
                      ),
                    OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Full applications list coming soon')),
                        );
                      },
                      child: const Text('Check Status'),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Error: $e'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Startups You Applied To
          Row(
            children: [
              const Icon(CupertinoIcons.briefcase_fill, color: AppColors.tertiary, size: 20),
              const SizedBox(width: AppSpacing.xs),
              Text('Startups You Applied To', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          applicationsAsync.when(
            data: (applications) {
              final seen = <String>{};
              final appliedStartupNames = <String>[];
              for (final app in applications) {
                if (app.startupId.isEmpty || seen.contains(app.startupId)) continue;
                seen.add(app.startupId);
                appliedStartupNames.add(app.startupName);
              }
              if (appliedStartupNames.isEmpty) {
                return const Text("You haven't applied to any startups yet.");
              }
              return Column(
                children: [
                  for (final name in appliedStartupNames)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _AppliedStartupRow(startupName: name),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
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
                    Text(opportunity.type.label.toUpperCase(),
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: AppColors.secondary)),
                    Text(opportunity.title, style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${opportunity.startupName}. ${opportunity.description}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: AppTheme.achievementButtonStyle,
              onPressed: () => context.push('/opportunities/${opportunity.id}/apply', extra: opportunity),
              child: const Text('Apply Now'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicationRow extends StatelessWidget {
  const _ApplicationRow({required this.application});

  final StudentApplication application;

  @override
  Widget build(BuildContext context) {
    final color = switch (application.status) {
      ApplicationStatus.inReview => AppColors.tertiary,
      ApplicationStatus.interviewed => AppColors.secondary,
      ApplicationStatus.accepted => AppColors.secondary,
      ApplicationStatus.rejected => AppColors.error,
    };
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(application.opportunityTitle, style: Theme.of(context).textTheme.labelSmall),
          Row(
            children: [
              Text(
                application.status.label.toUpperCase(),
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: AppColors.outline, fontSize: 10),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppliedStartupRow extends StatelessWidget {
  const _AppliedStartupRow({required this.startupName});

  final String startupName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            startupName.isNotEmpty ? startupName[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Row(
          children: [
            const Icon(CupertinoIcons.checkmark_seal_fill,
                size: 14, color: AppColors.tertiaryFixedDim),
            const SizedBox(width: 4),
            Text(startupName, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ],
    );
  }
}

class _StartupHomeBody extends ConsumerWidget {
  const _StartupHomeBody({required this.appUser});

  final AppUser appUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupAsync = ref.watch(currentUserStartupProvider);
    final opportunitiesAsync = ref.watch(myStartupOpportunitiesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WELCOME BACK',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.onPrimaryContainer, letterSpacing: 1.2),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Ready to scale, ${appUser.displayName}?',
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(color: Colors.white, fontSize: 28),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          startupAsync.when(
            data: (startup) {
              if (startup == null) return const SizedBox.shrink();
              final applicantsAsync = ref.watch(applicantsForStartupProvider(startup.id));
              final applicantsCount = applicantsAsync.valueOrNull?.length ?? 0;
              final opportunitiesCount = opportunitiesAsync.valueOrNull?.length ?? 0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.add_a_photo_outlined,
                              color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (startup.isVerified) ...[
                                    const Icon(Icons.verified,
                                        size: 16, color: AppColors.tertiaryFixedDim),
                                    const SizedBox(width: 4),
                                  ],
                                  Expanded(
                                    child: Text(startup.name,
                                        style: Theme.of(context).textTheme.titleMedium),
                                  ),
                                ],
                              ),
                              Text(
                                startup.category,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: AppColors.outline),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                startup.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          icon: Icons.work_outline,
                          label: 'Opportunities',
                          value: '$opportunitiesCount',
                          onTap: () => context.push('/opportunities/mine'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _StatTile(
                          icon: Icons.people_outline,
                          label: 'Applicants',
                          value: '$applicantsCount',
                          onTap: () => context.push('/applicants'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text('Error: $error'),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Opportunities', style: Theme.of(context).textTheme.titleMedium),
              TextButton(
                onPressed: () => context.push('/opportunities/mine'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          opportunitiesAsync.when(
            data: (opportunities) {
              if (opportunities.isEmpty) {
                return const Text('No opportunities posted yet.');
              }
              return Column(
                children: [
                  for (final o in opportunities.take(2))
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: AppCard(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(o.title, style: Theme.of(context).textTheme.labelSmall),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: o.isActive
                                    ? AppColors.secondaryContainer
                                    : AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                o.isActive ? 'Active' : 'Closed',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: o.isActive
                                          ? AppColors.onSecondaryContainer
                                          : AppColors.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text('Error: $error'),
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton(
            onPressed: () => context.push('/startups'),
            child: const Text('Browse ALU Startups'),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.secondary),
            const SizedBox(height: AppSpacing.xs),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
