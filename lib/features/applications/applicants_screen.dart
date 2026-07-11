import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/status_chip.dart';
import '../startups/startup_providers.dart';
import 'application_providers.dart';
import 'student_application.dart';

class ApplicantsScreen extends ConsumerWidget {
  const ApplicantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupAsync = ref.watch(currentUserStartupProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Applicants')),
      body: startupAsync.when(
        data: (startup) {
          if (startup == null) {
            return const Center(child: Text('You need a startup profile first.'));
          }
          final applicantsAsync = ref.watch(applicantsForStartupProvider(startup.id));
          return applicantsAsync.when(
            data: (applicants) {
              if (applicants.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No applicants yet.'),
                  ),
                );
              }
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final application in applicants)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ApplicantCard(application: application),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

Color _statusColor(ApplicationStatus status) => switch (status) {
      ApplicationStatus.inReview => AppColors.tertiary,
      ApplicationStatus.interviewed => AppColors.secondary,
      ApplicationStatus.accepted => AppColors.secondary,
      ApplicationStatus.rejected => AppColors.error,
    };

class _ApplicantCard extends ConsumerWidget {
  const _ApplicantCard({required this.application});

  final StudentApplication application;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerState = ref.watch(applicationControllerProvider);
    final date = application.createdAt;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child:
                    Text(application.studentName, style: Theme.of(context).textTheme.titleMedium),
              ),
              StatusChip(label: application.status.label, color: _statusColor(application.status)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            application.opportunityTitle,
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          if (date != null) ...[
            const SizedBox(height: 4),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.outline),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton(
                onPressed: controllerState.isLoading
                    ? null
                    : () => ref
                        .read(applicationControllerProvider.notifier)
                        .updateStatus(application.id, ApplicationStatus.accepted),
                child: const Text('Accept'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: controllerState.isLoading
                    ? null
                    : () => ref
                        .read(applicationControllerProvider.notifier)
                        .updateStatus(application.id, ApplicationStatus.rejected),
                child: const Text('Reject', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
