import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../data/application_repository.dart';
import '../data/student_application.dart';

final applicationRepositoryProvider =
    Provider<ApplicationRepository>((ref) => ApplicationRepository());

final myApplicationsProvider = StreamProvider<List<StudentApplication>>((ref) {
  final uid = ref.watch(authStateChangesProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(applicationRepositoryProvider).watchMyApplications(uid);
});
