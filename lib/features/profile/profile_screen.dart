import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/primary_button.dart';
import '../auth/app_user.dart';
import '../auth/auth_providers.dart';
import '../startups/startup.dart';
import '../startups/startup_providers.dart';

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
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primaryContainer,
                  child: Text(
                    appUser.displayName.isNotEmpty ? appUser.displayName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(appUser.displayName, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  appUser.email,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.sm),
                Chip(label: Text(appUser.role.value.toUpperCase())),
                const SizedBox(height: AppSpacing.lg),
                if (appUser.role == UserRole.startup)
                  _StartupProfileSection(appUser: appUser)
                else
                  _StudentProfileSection(appUser: appUser),
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton.icon(
                  onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
                  icon: const Icon(Icons.logout_outlined),
                  label: const Text('Sign Out'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _StudentProfileSection extends StatelessWidget {
  const _StudentProfileSection({required this.appUser});

  final AppUser appUser;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                Chip(label: Text(skill), backgroundColor: AppColors.surfaceContainer),
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
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => _EditStudentProfileSheet(appUser: appUser),
          ),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit Profile'),
        ),
      ],
    );
  }
}

class _StartupProfileSection extends ConsumerWidget {
  const _StartupProfileSection({required this.appUser});

  final AppUser appUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupAsync = ref.watch(currentUserStartupProvider);

    return startupAsync.when(
      data: (startup) {
        if (startup == null) {
          return const Text('No startup profile found.');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (startup.isVerified) ...[
                  const Icon(Icons.verified, size: 16, color: AppColors.tertiaryFixedDim),
                  const SizedBox(width: 4),
                ],
                Text(startup.name, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            Text(
              startup.category,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.outline),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(startup.description, style: Theme.of(context).textTheme.bodyMedium),
            if (startup.website?.isNotEmpty ?? false) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                startup.website!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondary),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => _EditStartupProfileSheet(startup: startup),
              ),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Profile'),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('Error: $error'),
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
