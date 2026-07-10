import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../startups/application/startup_providers.dart';
import '../application/opportunity_providers.dart';
import '../data/opportunity.dart';

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
      if (mounted) Navigator.of(context).pop();
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
                    const Icon(Icons.hourglass_top_outlined, size: 48, color: AppColors.onSurfaceVariant),
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
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Description'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Enter a description' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<OpportunityType>(
                      initialValue: _type,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: OpportunityType.values
                          .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                          .toList(),
                      onChanged: (v) => setState(() => _type = v ?? OpportunityType.internship),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: opportunityCategories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _category = v ?? opportunityCategories.first),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _commitmentController,
                      decoration: const InputDecoration(
                        labelText: 'Commitment',
                        hintText: 'e.g. Part-time, 8-10 hrs/week',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Enter a commitment' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        hintText: 'e.g. On-campus, Kigali or Remote',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a location' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _skillsController,
                      decoration: const InputDecoration(
                        labelText: 'Skills required',
                        hintText: 'Comma-separated, e.g. Flutter, Dart, Figma',
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(_error!, style: const TextStyle(color: AppColors.error)),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        child: _submitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Post Opportunity'),
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
