import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/status_chip.dart';
import '../startups/startup_providers.dart';
import 'application_providers.dart';
import 'student_application.dart';
import 'package:alu_bridge/core/widgets/app_error_state.dart';

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
            error: (error, stack) => const Center(child: AppErrorState()),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(child: AppErrorState()),
      ),
    );
  }
}

Color _statusColor(ApplicationStatus status) => switch (status) {
      ApplicationStatus.inReview => AppColors.tertiary,
      ApplicationStatus.accepted => AppColors.secondary,
      ApplicationStatus.rejected => AppColors.error,
    };

class _ApplicantCard extends ConsumerStatefulWidget {
  const _ApplicantCard({required this.application});

  final StudentApplication application;

  @override
  ConsumerState<_ApplicantCard> createState() => _ApplicantCardState();
}

class _ApplicantCardState extends ConsumerState<_ApplicantCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final application = widget.application;
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
          const SizedBox(height: 8),
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                Text(
                  _expanded ? 'Hide details' : 'Show motivation & experience',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.secondary),
                ),
                Icon(
                  _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 18,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 8),
            if (application.motivation.isNotEmpty) ...[
              Text('Why interested', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 2),
              Text(application.motivation, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
            ],
            if (application.experience.isNotEmpty) ...[
              Text('Relevant experience', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 2),
              Text(application.experience, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
            ],
            if (application.resumeUrl != null && application.resumeUrl!.isNotEmpty)
              Text('Resume: ${application.resumeUrl}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondary)),
            if (application.portfolioUrl != null && application.portfolioUrl!.isNotEmpty)
              Text('Portfolio: ${application.portfolioUrl}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondary)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: (controllerState.isLoading ||
                          application.status == ApplicationStatus.inReview)
                      ? null
                      : () => ref
                          .read(applicationControllerProvider.notifier)
                          .updateStatus(application.id, ApplicationStatus.inReview),
                  child: const Text('In Review'),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: (controllerState.isLoading ||
                          application.status == ApplicationStatus.accepted)
                      ? null
                      : () => ref
                          .read(applicationControllerProvider.notifier)
                          .updateStatus(application.id, ApplicationStatus.accepted),
                  child: const Text('Accept'),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: (controllerState.isLoading ||
                          application.status == ApplicationStatus.rejected)
                      ? null
                      : () => ref
                          .read(applicationControllerProvider.notifier)
                          .updateStatus(application.id, ApplicationStatus.rejected),
                  child: const Text('Decline', style: TextStyle(color: AppColors.error)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
