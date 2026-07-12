import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../auth/auth_providers.dart';
import '../opportunities/opportunity.dart';
import 'application_providers.dart';
import 'application_repository.dart';

class ApplyOpportunityScreen extends ConsumerStatefulWidget {
  const ApplyOpportunityScreen({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  ConsumerState<ApplyOpportunityScreen> createState() => _ApplyOpportunityScreenState();
}

class _ApplyOpportunityScreenState extends ConsumerState<ApplyOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _motivationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _resumeLinkController = TextEditingController();
  bool _submitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _motivationController.dispose();
    _experienceController.dispose();
    _portfolioController.dispose();
    _resumeLinkController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = ref.read(authStateChangesProvider).valueOrNull?.uid;
    final studentName = ref.read(currentAppUserProvider).valueOrNull?.displayName;
    if (uid == null || studentName == null) return;

    setState(() => _submitting = true);
    try {
      await ref.read(applicationRepositoryProvider).submitApplication(
            studentUid: uid,
            studentName: studentName,
            opportunityId: widget.opportunity.id,
            opportunityTitle: widget.opportunity.title,
            startupId: widget.opportunity.startupId,
            startupName: widget.opportunity.startupName,
            motivation: _motivationController.text.trim(),
            experience: _experienceController.text.trim(),
            portfolioUrl:
                _portfolioController.text.trim().isEmpty ? null : _portfolioController.text.trim(),
            resumeUrl:
                _resumeLinkController.text.trim().isEmpty ? null : _resumeLinkController.text.trim(),
          );
      if (mounted) setState(() => _submitted = true);
    } on ApplicationAlreadyExistsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.opportunity;
    final hasAppliedAsync = ref.watch(hasAppliedProvider(o.id));
    final alreadyApplied = !_submitted && (hasAppliedAsync.valueOrNull ?? false);

    return Scaffold(
      appBar: AppBar(title: const Text('Apply')),
      body: SafeArea(
        child: (_submitted || alreadyApplied)
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.secondary, size: 56),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _submitted ? 'Application Sent!' : 'Already Applied',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _submitted
                            ? 'Your application to ${o.startupName} has been submitted.'
                            : "You've already applied to this opportunity.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Back to Listing'),
                      ),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.marginMobile),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainer,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.secondary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Text('Active Opportunity',
                                          style: Theme.of(context).textTheme.labelSmall),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(o.type.label, style: Theme.of(context).textTheme.labelSmall),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(o.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(color: AppColors.primaryContainer)),
                            const SizedBox(height: AppSpacing.xs),
                            Text(o.startupName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: AppSpacing.md),
                            Text(o.description, style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text('WHY ARE YOU INTERESTED?', style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _motivationController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Tell us what excites you about this role...',
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'This field is required' : null,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text('RELEVANT EXPERIENCE', style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _experienceController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText:
                              'Highlight projects, internships, or coursework that demonstrate your skills...',
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'This field is required' : null,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextFormField(
                        controller: _resumeLinkController,
                        keyboardType: TextInputType.url,
                        decoration: const InputDecoration(
                          labelText: 'Resume/CV Link (Google Drive)',
                          hintText: 'https://drive.google.com/...',
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _portfolioController,
                        keyboardType: TextInputType.url,
                        decoration: const InputDecoration(
                          labelText: 'Portfolio URL (optional)',
                          hintText: 'https://yourportfolio.com',
                          prefixIcon: Icon(Icons.link),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: AppTheme.achievementButtonStyle,
                          onPressed: _submitting ? null : _submit,
                          child: _submitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryContainer,
                                  ),
                                )
                              : const Text('Submit Application'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
