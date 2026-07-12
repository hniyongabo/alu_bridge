import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../startups/startup_providers.dart';
import 'opportunity_providers.dart';
import 'opportunity.dart';

class PostOpportunityScreen extends ConsumerStatefulWidget {
  const PostOpportunityScreen({super.key});

  @override
  ConsumerState<PostOpportunityScreen> createState() => _PostOpportunityScreenState();
}

class _PostOpportunityScreenState extends ConsumerState<PostOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _commitmentController = TextEditingController();
  final _locationController = TextEditingController();
  final _skillsController = TextEditingController();
  OpportunityType _type = OpportunityType.internship;
  String _category = opportunityCategories.first;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _commitmentController.dispose();
    _locationController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final startup = ref.read(currentUserStartupProvider).valueOrNull;
    if (startup == null || !startup.isVerified) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    final skills = _skillsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    try {
      await ref.read(opportunityRepositoryProvider).createOpportunity(
            startupId: startup.id,
            startupName: startup.name,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            type: _type,
            category: _category,
            commitment: _commitmentController.text.trim(),
            location: _locationController.text.trim(),
            skillsRequired: skills,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opportunity published')),
        );
        _formKey.currentState!.reset();
        _titleController.clear();
        _descriptionController.clear();
        _commitmentController.clear();
        _locationController.clear();
        _skillsController.clear();
      }
    } catch (e) {
      setState(() => _error = 'Could not post: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final startupAsync = ref.watch(currentUserStartupProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Post an Opportunity')),
      body: SafeArea(
        child: startupAsync.when(
          data: (startup) {
            if (startup == null) {
              return const Center(child: Text('You need a startup profile first.'));
            }
            if (!startup.isVerified) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.hourglass_top_outlined,
                        size: 48, color: AppColors.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text(
                      'Your startup is still pending admin verification. '
                      'You can post opportunities once ${startup.name} is verified.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginMobile,
                AppSpacing.lg,
                AppSpacing.marginMobile,
                AppSpacing.lg,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Dashboard',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: AppColors.onSurfaceVariant)),
                        const Icon(Icons.chevron_right, size: 16, color: AppColors.onSurfaceVariant),
                        Text(
                          'Post Opportunity',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Launch New Talent Search',
                        style: Theme.of(context).textTheme.displayLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      "Connect your venture with ALU's top-tier student community.",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionHeader(number: '1', title: 'Core Details'),
                          const SizedBox(height: AppSpacing.lg),
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Opportunity Title',
                              hintText: 'e.g. Product Design Intern',
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: startup.name,
                                  readOnly: true,
                                  decoration: const InputDecoration(labelText: 'Venture Name'),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: DropdownButtonFormField<OpportunityType>(
                                  initialValue: _type,
                                  isExpanded: true,
                                  decoration: const InputDecoration(labelText: 'Type'),
                                  items: OpportunityType.values
                                      .map((t) => DropdownMenuItem(
                                            value: t,
                                            child: Text(t.label, overflow: TextOverflow.ellipsis),
                                          ))
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _type = v ?? OpportunityType.internship),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionHeader(number: '2', title: 'Role & Requirements'),
                          const SizedBox(height: AppSpacing.lg),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              labelText: 'Role Description',
                              hintText:
                                  'Detail the responsibilities, expectations, and day-to-day activities...',
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Enter a description' : null,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          DropdownButtonFormField<String>(
                            initialValue: _category,
                            isExpanded: true,
                            decoration: const InputDecoration(labelText: 'Skill Category'),
                            items: opportunityCategories
                                .map((c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c, overflow: TextOverflow.ellipsis),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _category = v ?? opportunityCategories.first),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          TextFormField(
                            controller: _skillsController,
                            decoration: const InputDecoration(
                              labelText: 'Required Skills',
                              hintText: 'Comma-separated, e.g. Flutter, Dart, Figma',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionHeader(number: '3', title: 'Compensation & Logistics'),
                          const SizedBox(height: AppSpacing.lg),
                          TextFormField(
                            controller: _commitmentController,
                            decoration: const InputDecoration(
                              labelText: 'Compensation & Commitment',
                              hintText: 'e.g. Paid, Part-time, 8-10 hrs/week',
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Enter a commitment' : null,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          TextFormField(
                            controller: _locationController,
                            decoration: const InputDecoration(
                              labelText: 'Location',
                              hintText: 'e.g. On-campus, Kigali or Remote',
                              prefixIcon: Icon(Icons.location_on_outlined),
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Enter a location' : null,
                          ),
                        ],
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(_error!, style: const TextStyle(color: AppColors.error)),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    AppCard(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.bolt, color: AppColors.tertiary),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'This opportunity will be visible to eligible ALU students.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(color: AppColors.onSurfaceVariant),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          PrimaryButton(
                            label: 'Publish Opportunity',
                            isLoading: _submitting,
                            onPressed: _submit,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.number, required this.title});

  final String number;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
