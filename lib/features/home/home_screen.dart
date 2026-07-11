import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../applications/application/application_providers.dart';
import '../applications/data/student_application.dart';
import '../auth/application/auth_providers.dart';
import '../auth/data/app_user.dart';
import '../opportunities/application/opportunity_providers.dart';
import '../opportunities/data/opportunity.dart';
import '../startups/application/startup_providers.dart';
import '../startups/data/startup.dart';

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
    final startupsAsync = ref.watch(verifiedStartupsProvider);
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.assignment_turned_in_outlined, color: AppColors.primaryContainer),
                  const SizedBox(width: AppSpacing.xs),
                  Text('Applications', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              IconButton(
                tooltip: 'Seed sample applications (dev)',
                icon: const Icon(Icons.cloud_upload_outlined, size: 20),
                onPressed: () =>
                    ref.read(applicationRepositoryProvider).seedSampleApplications(appUser.uid),
              ),
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

          // Featured Startups
          Row(
            children: [
              const Icon(Icons.trending_up, color: AppColors.secondary),
              const SizedBox(width: AppSpacing.xs),
              Text('Featured Startups', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          startupsAsync.when(
            data: (startups) {
              if (startups.isEmpty) return const Text('No startups yet.');
              return Column(
                children: [
                  for (final s in startups.take(3))
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _StartupRow(startup: s),
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

class _StartupRow extends StatelessWidget {
  const _StartupRow({required this.startup});

  final Startup startup;

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
            startup.name.isNotEmpty ? startup.name[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified, size: 14, color: AppColors.tertiaryFixedDim),
                const SizedBox(width: 4),
                Text(startup.name, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
            Text(
              startup.category,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: AppColors.outline, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }
}

class _StartupHomeBody extends StatelessWidget {
  const _StartupHomeBody({required this.appUser});

  final AppUser appUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          OutlinedButton(
            onPressed: () => context.push('/startups'),
            child: const Text('Browse ALU Startups'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: () => context.push('/opportunities/mine'),
            child: const Text('My Opportunities'),
          ),
        ],
      ),
    );
  }
}
