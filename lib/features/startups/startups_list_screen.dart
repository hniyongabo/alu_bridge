import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../opportunities/opportunity_providers.dart';
import 'startup_providers.dart';
import 'startup.dart';

class StartupsListScreen extends ConsumerWidget {
  const StartupsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verifiedAsync = ref.watch(verifiedStartupsProvider);
    final ownedAsync = ref.watch(currentUserStartupProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ALU Startups'),
        actions: [
          IconButton(
            tooltip: 'Seed known ALU startups + sample opportunities (dev)',
            icon: const Icon(Icons.cloud_upload_outlined),
            onPressed: () async {
              await ref.read(startupRepositoryProvider).seedKnownStartups();
              await ref.read(opportunityRepositoryProvider).seedSampleOpportunities();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Seeded startups and sample opportunities')),
                );
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ownedAsync.when(
            data: (owned) => owned == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _OwnedStartupStatusCard(startup: owned),
                  ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          verifiedAsync.when(
            data: (startups) {
              if (startups.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Center(
                    child: Text('No verified startups yet. Tap the seed icon to add the known ALU ventures.'),
                  ),
                );
              }
              return Column(
                children: [
                  for (final startup in startups)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _StartupCard(startup: startup),
                    ),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 48),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.only(top: 48),
              child: Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnedStartupStatusCard extends StatelessWidget {
  const _OwnedStartupStatusCard({required this.startup});

  final Startup startup;

  @override
  Widget build(BuildContext context) {
    final verified = startup.isVerified;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: verified ? AppColors.secondary : AppColors.tertiaryFixed,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(startup.name, style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    verified ? 'Verified — you can post opportunities' : 'Pending admin review',
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
    );
  }
}

class _StartupCard extends StatelessWidget {
  const _StartupCard({required this.startup});

  final Startup startup;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified, size: 16, color: AppColors.tertiaryFixedDim),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(startup.name, style: Theme.of(context).textTheme.titleMedium),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    startup.category,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              startup.description,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
