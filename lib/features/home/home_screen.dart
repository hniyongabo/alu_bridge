import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../auth/application/auth_providers.dart';
import '../auth/domain/app_user.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUserAsync = ref.watch(currentAppUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ALU Bridge'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: appUserAsync.when(
        data: (appUser) {
          if (appUser == null) {
            return const Center(child: Text('No profile found.'));
          }
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${appUser.displayName} 👋',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Signed in as ${appUser.email}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                Chip(label: Text(appUser.role.value.toUpperCase())),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () => context.push('/startups'),
                  child: const Text('Browse ALU Startups'),
                ),
                if (appUser.role == UserRole.startup) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.push('/opportunities/mine'),
                    child: const Text('My Opportunities'),
                  ),
                ],
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
