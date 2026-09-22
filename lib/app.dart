import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'services/auth_repository.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/qr_screen.dart';
import 'screens/profile_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthRepository auth) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home/schedule',
    refreshListenable: auth,
    redirect: (context, state) {
      final loggedIn = auth.isLoggedIn;
      final onLogin = state.matchedLocation == '/login';
      if (!loggedIn && !onLogin) return '/login';
      if (loggedIn && onLogin) return '/home/schedule';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(path: '/home/schedule', builder: (_, _) => const ScheduleScreen()),
          GoRoute(path: '/home/journal', builder: (_, _) => const JournalScreen()),
          GoRoute(path: '/home/qr', builder: (_, _) => const QrScreen()),
          GoRoute(path: '/home/tasks', builder: (_, _) => const TasksScreen()),
          GoRoute(path: '/home/profile', builder: (_, _) => const ProfileScreen()),
        ],
      ),
    ],
  );
}

class App extends StatelessWidget {
  const App({super.key, required this.router});
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Platonus Helper',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      routerConfig: router,
    );
  }
}
