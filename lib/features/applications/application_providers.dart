import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'application_repository.dart';
import 'student_application.dart';

final applicationRepositoryProvider =
    Provider<ApplicationRepository>((ref) => ApplicationRepository());

final myApplicationsProvider = StreamProvider<List<StudentApplication>>((ref) {
  final uid = ref.watch(authStateChangesProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(applicationRepositoryProvider).watchMyApplications(uid);
});

final applicantsForStartupProvider =
    StreamProvider.family<List<StudentApplication>, String>((ref, startupId) {
  return ref.watch(applicationRepositoryProvider).watchApplicationsForStartup(startupId);
});

final hasAppliedProvider = StreamProvider.family<bool, String>((ref, opportunityId) {
  final uid = ref.watch(authStateChangesProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(false);
  return ref.watch(applicationRepositoryProvider).watchHasApplied(uid, opportunityId);
});

class ApplicationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> updateStatus(String applicationId, ApplicationStatus status) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return ref.read(applicationRepositoryProvider).updateStatus(applicationId, status);
    });
  }
}

final applicationControllerProvider =
    AsyncNotifierProvider<ApplicationController, void>(ApplicationController.new);
