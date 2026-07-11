import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import '../auth/app_user.dart';
import 'startup_repository.dart';
import 'startup.dart';

final startupRepositoryProvider = Provider<StartupRepository>((ref) => StartupRepository());

final verifiedStartupsProvider = StreamProvider<List<Startup>>((ref) {
  return ref.watch(startupRepositoryProvider).watchVerifiedStartups();
});

final pendingStartupsProvider = StreamProvider<List<Startup>>((ref) {
  return ref.watch(startupRepositoryProvider).watchPendingStartups();
});

/// The startup owned by the current user, if any. Only meaningful for users
/// with role == startup; resolves to null otherwise.
final currentUserStartupProvider = StreamProvider<Startup?>((ref) {
  final appUser = ref.watch(currentAppUserProvider).valueOrNull;
  if (appUser == null || appUser.role != UserRole.startup) {
    return Stream.value(null);
  }
  return ref.watch(startupRepositoryProvider).watchStartupForOwner(appUser.uid);
});
