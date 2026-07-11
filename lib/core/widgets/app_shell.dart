import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_providers.dart';
import '../../features/auth/app_user.dart';
import '../../features/home/home_screen.dart';
import '../../features/opportunities/discovery_screen.dart';
import '../../features/opportunities/post_opportunity_screen.dart';
import '../../features/profile/profile_screen.dart';

/// Persistent bottom-nav shell. Students see Home/Discover/Profile;
/// startup reps see Home/Post/Profile instead of Discover.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final appUser = ref.watch(currentAppUserProvider).valueOrNull;
    final isStartup = appUser?.role == UserRole.startup;

    final tabs = isStartup
        ? const [HomeScreen(), PostOpportunityScreen(), ProfileScreen()]
        : const [HomeScreen(), DiscoveryScreen(), ProfileScreen()];

    final destinations = [
      const NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
      isStartup
          ? const NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'Post')
          : const NavigationDestination(icon: Icon(Icons.search_outlined), label: 'Discover'),
      const NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
    ];

    if (_index >= tabs.length) _index = 0;

    return Scaffold(
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: destinations,
      ),
    );
  }
}
