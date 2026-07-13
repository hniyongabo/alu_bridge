import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/primary_button.dart';
import '../applications/application_providers.dart';
import '../applications/student_application.dart';
import '../auth/app_user.dart';
import '../auth/auth_providers.dart';
import '../opportunities/opportunity_providers.dart';
import '../startups/startup.dart';
import '../startups/startup_providers.dart';
import 'package:alu_bridge/core/widgets/app_error_state.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUserAsync = ref.watch(currentAppUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: appUserAsync.when(
        data: (appUser) {
          if (appUser == null) {
            return const Center(child: Text('No profile found.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(
                        BorderSide(color: AppColors.tertiaryFixedDim, width: 3),
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.primaryContainer,
                      child: Text(
                        appUser.displayName.isNotEmpty
                            ? appUser.displayName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(color: Colors.white, fontSize: 32),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: Text(appUser.displayName, style: Theme.of(context).textTheme.headlineMedium),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    appUser.email,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Center(child: Chip(label: Text(appUser.role.value.toUpperCase()))),
                const SizedBox(height: AppSpacing.lg),
                if (appUser.role == UserRole.startup)
                  _StartupStatsRow()
                else
                  _StudentStatsRow(),
                const SizedBox(height: AppSpacing.lg),
                if (appUser.role == UserRole.startup)
                  _StartupMenuList(appUser: appUser)
                else
                  _StudentMenuList(appUser: appUser),
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton.icon(
                  onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.tertiary,
                    side: const BorderSide(color: AppColors.tertiaryFixedDim),
                  ),
                  icon: const Icon(Icons.logout_outlined),
                  label: const Text('Sign Out'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(child: AppErrorState()),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: AppColors.primaryContainer)),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _StatsRowCard extends StatelessWidget {
  const _StatsRowCard({required this.tiles});

  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(children: tiles),
    );
  }
}

class _StudentStatsRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applications = ref.watch(myApplicationsProvider).valueOrNull ?? const <StudentApplication>[];
    final accepted = applications.where((a) => a.status == ApplicationStatus.accepted).length;

    return _StatsRowCard(tiles: [
      _StatTile(value: '${applications.length}', label: 'Applications'),
      _StatTile(value: '$accepted', label: 'Accepted'),
    ]);
  }
}

class _StartupStatsRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startup = ref.watch(currentUserStartupProvider).valueOrNull;
    final opportunities = ref.watch(myStartupOpportunitiesProvider).valueOrNull ?? const [];
    final applicants = startup == null
        ? const <StudentApplication>[]
        : ref.watch(applicantsForStartupProvider(startup.id)).valueOrNull ?? const <StudentApplication>[];
    final accepted = applicants.where((a) => a.status == ApplicationStatus.accepted).length;

    return _StatsRowCard(tiles: [
      _StatTile(value: '${opportunities.length}', label: 'Opportunities'),
      _StatTile(value: '${applicants.length}', label: 'Applicants'),
      _StatTile(value: '$accepted', label: 'Accepted'),
    ]);
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.large = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: large ? AppSpacing.md : AppSpacing.sm),
        child: Row(
          children: [
            Icon(icon, color: AppColors.tertiaryFixedDim, size: large ? 28 : 22),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: large
                    ? Theme.of(context).textTheme.titleMedium
                    : Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.outline),
          ],
        ),
      ),
    );
  }
}

class _MenuListCard extends StatelessWidget {
  const _MenuListCard({required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i != rows.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _StudentMenuList extends StatelessWidget {
  const _StudentMenuList({required this.appUser});

  final AppUser appUser;

  @override
  Widget build(BuildContext context) {
    return _MenuListCard(rows: [
      _MenuRow(
        icon: Icons.person_outline,
        label: 'My Profile',
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => _EditStudentProfileSheet(appUser: appUser),
        ),
      ),
      _MenuRow(
        icon: Icons.star_border,
        label: 'Skills & Interests',
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => _SkillsAndInterestsSheet(appUser: appUser),
        ),
      ),
      _MenuRow(
        icon: Icons.assignment_outlined,
        label: 'My Applications',
        onTap: () => context.push('/applications/mine'),
      ),
    ]);
  }
}

class _StartupMenuList extends ConsumerWidget {
  const _StartupMenuList({required this.appUser});

  final AppUser appUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupAsync = ref.watch(currentUserStartupProvider);

    return startupAsync.when(
      data: (startup) {
        if (startup == null) {
          return const Text('No startup profile found.');
        }
        return _MenuListCard(rows: [
          _MenuRow(
            icon: Icons.storefront_outlined,
            label: 'My Profile',
            large: true,
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => _EditStartupProfileSheet(startup: startup),
            ),
          ),
          _MenuRow(
            icon: Icons.people_outline,
            label: 'Applications Submitted',
            large: true,
            onTap: () => context.push('/applicants'),
          ),
        ]);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const AppErrorState(),
    );
  }
}

class _SkillsAndInterestsSheet extends StatelessWidget {
  const _SkillsAndInterestsSheet({required this.appUser});

  final AppUser appUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.marginMobile,
        AppSpacing.lg,
        AppSpacing.marginMobile,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Skills & Interests', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.lg),
          Text('Skills', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          if (appUser.skills.isEmpty)
            Text(
              'No skills added yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
            )
          else
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final skill in appUser.skills)
                  Chip(
                    label: Text(skill),
                    backgroundColor: AppColors.surfaceContainerLowest,
                    labelStyle: const TextStyle(color: AppColors.tertiary),
                    shape: StadiumBorder(
                      side: const BorderSide(color: AppColors.tertiaryFixedDim, width: 1.5),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: AppSpacing.md),
          Text('Portfolio URL', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            (appUser.portfolioUrl?.isNotEmpty ?? false) ? appUser.portfolioUrl! : 'Not added yet.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => _EditStudentProfileSheet(appUser: appUser),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.tertiary,
              side: const BorderSide(color: AppColors.tertiaryFixedDim),
            ),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit'),
          ),
        ],
      ),
    );
  }
}

class _EditStudentProfileSheet extends ConsumerStatefulWidget {
  const _EditStudentProfileSheet({required this.appUser});

  final AppUser appUser;

  @override
  ConsumerState<_EditStudentProfileSheet> createState() => _EditStudentProfileSheetState();
}

class _EditStudentProfileSheetState extends ConsumerState<_EditStudentProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _skillsController;
  late final TextEditingController _portfolioController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.appUser.displayName);
    _skillsController = TextEditingController(text: widget.appUser.skills.join(', '));
    _portfolioController = TextEditingController(text: widget.appUser.portfolioUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skillsController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final skills = _skillsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    try {
      await ref.read(authRepositoryProvider).updateStudentProfile(
            uid: widget.appUser.uid,
            displayName: _nameController.text.trim(),
            skills: skills,
            portfolioUrl:
                _portfolioController.text.trim().isEmpty ? null : _portfolioController.text.trim(),
          );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.marginMobile,
        AppSpacing.lg,
        AppSpacing.marginMobile,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Edit Profile', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Full name'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _skillsController,
            decoration: const InputDecoration(
              labelText: 'Skills',
              hintText: 'Comma-separated, e.g. Flutter, UI Design',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _portfolioController,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Portfolio URL (optional)',
              hintText: 'https://yourportfolio.com',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(label: 'Save', isLoading: _saving, onPressed: _save),
        ],
      ),
    );
  }
}

class _EditStartupProfileSheet extends ConsumerStatefulWidget {
  const _EditStartupProfileSheet({required this.startup});

  final Startup startup;

  @override
  ConsumerState<_EditStartupProfileSheet> createState() => _EditStartupProfileSheetState();
}

class _EditStartupProfileSheetState extends ConsumerState<_EditStartupProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _websiteController;
  late String _category;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.startup.name);
    _descriptionController = TextEditingController(text: widget.startup.description);
    _websiteController = TextEditingController(text: widget.startup.website ?? '');
    _category = startupCategories.contains(widget.startup.category)
        ? widget.startup.category
        : startupCategories.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(startupRepositoryProvider).updateStartup(
            startupId: widget.startup.id,
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _category,
            website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
          );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.marginMobile,
        AppSpacing.lg,
        AppSpacing.marginMobile,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Edit Profile', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Startup name'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: _category,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Category'),
            items: startupCategories
                .map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: (value) => setState(() => _category = value ?? startupCategories.first),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _websiteController,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Website (optional)',
              hintText: 'https://...',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(label: 'Save', isLoading: _saving, onPressed: _save),
        ],
      ),
    );
  }
}
