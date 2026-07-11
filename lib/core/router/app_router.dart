import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_providers.dart';
import '../../features/auth/data/app_user.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/opportunities/presentation/my_opportunities_screen.dart';
import '../../features/opportunities/presentation/post_opportunity_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/startups/application/startup_providers.dart';
import '../../features/startups/presentation/create_startup_screen.dart';
import '../../features/startups/presentation/startups_list_screen.dart';
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
    ],
  );
});
