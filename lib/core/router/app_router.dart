import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_providers.dart';
import '../../features/auth/app_user.dart';
import '../../features/applications/applicants_screen.dart';
import '../../features/applications/apply_opportunity_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/opportunities/opportunity.dart';
import '../../features/opportunities/my_opportunities_screen.dart';
import '../../features/opportunities/post_opportunity_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/startups/startup_providers.dart';
import '../../features/startups/create_startup_screen.dart';
import '../../features/startups/startups_list_screen.dart';
import '../widgets/app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  final appUserAsync = ref.watch(currentAppUserProvider);
  final ownedStartupAsync = ref.watch(currentUserStartupProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final goingToAuth = loc == '/login' || loc == '/signup';
      final goingToSplash = loc == '/';
      final goingToCreateStartup = loc == '/startup/create';

      if (authState.isLoading) {
        return goingToSplash ? null : '/';
      }

      final isLoggedIn = authState.valueOrNull != null;

      if (!isLoggedIn) {
        return goingToAuth ? null : '/login';
      }

      if (goingToAuth || goingToSplash) {
        return '/home';
      }

      final appUser = appUserAsync.valueOrNull;
      if (appUser?.role == UserRole.startup &&
          !ownedStartupAsync.isLoading &&
          ownedStartupAsync.valueOrNull == null &&
          !goingToCreateStartup) {
        return '/startup/create';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
      GoRoute(path: '/home', builder: (context, state) => const AppShell()),
      GoRoute(
        path: '/startup/create',
        builder: (context, state) => const CreateStartupScreen(),
      ),
      GoRoute(path: '/startups', builder: (context, state) => const StartupsListScreen()),
      GoRoute(
        path: '/opportunities/mine',
        builder: (context, state) => const MyOpportunitiesScreen(),
      ),
      GoRoute(
        path: '/opportunities/post',
        builder: (context, state) => const PostOpportunityScreen(),
      ),
      GoRoute(
        path: '/opportunities/:id/apply',
        builder: (context, state) =>
            ApplyOpportunityScreen(opportunity: state.extra as Opportunity),
      ),
      GoRoute(path: '/applicants', builder: (context, state) => const ApplicantsScreen()),
    ],
  );
});
