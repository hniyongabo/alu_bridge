import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/status_chip.dart';
import 'application_providers.dart';
import 'student_application.dart';

Color _statusColor(ApplicationStatus status) => switch (status) {
      ApplicationStatus.inReview => AppColors.tertiary,
      ApplicationStatus.accepted => AppColors.secondary,
      ApplicationStatus.rejected => AppColors.error,
    };

class MyApplicationsScreen extends ConsumerStatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  ConsumerState<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends ConsumerState<MyApplicationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = ['Applied', 'Accepted', 'All'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<StudentApplication> _filter(List<StudentApplication> applications, int tabIndex) {
    return switch (tabIndex) {
      0 => applications.where((a) => a.status == ApplicationStatus.inReview).toList(),
      1 => applications.where((a) => a.status == ApplicationStatus.accepted).toList(),
      _ => applications,
    };
  }

  @override
  Widget build(BuildContext context) {
    final applicationsAsync = ref.watch(myApplicationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.secondary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.secondary,
          tabs: [for (final tab in _tabs) Tab(text: tab)],
        ),
      ),
      body: applicationsAsync.when(
        data: (applications) {
          return TabBarView(
            controller: _tabController,
            children: [
              for (var i = 0; i < _tabs.length; i++)
                _ApplicationsList(applications: _filter(applications, i)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(child: AppErrorState()),
      ),
    );
  }
}

class _ApplicationsList extends StatelessWidget {
  const _ApplicationsList({required this.applications});

  final List<StudentApplication> applications;

  @override
  Widget build(BuildContext context) {
    if (applications.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No applications here yet.'),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      children: [
        for (final application in applications)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _ApplicationCard(application: application),
          ),
      ],
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.application});

  final StudentApplication application;

  @override
  Widget build(BuildContext context) {
    final date = application.createdAt;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child:
                    Text(application.opportunityTitle, style: Theme.of(context).textTheme.titleMedium),
              ),
              StatusChip(label: application.status.label, color: _statusColor(application.status)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            application.startupName,
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          if (date != null) ...[
            const SizedBox(height: 4),
            Text(
              'Applied ${date.day}/${date.month}/${date.year}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.outline),
            ),
          ],
        ],
      ),
    );
  }
}
