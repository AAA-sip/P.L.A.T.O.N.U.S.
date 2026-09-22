import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.child});
  final Widget child;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Порядок: расписание, оценки, [QR], задачи, профиль
  int get _tabFromLocation {
    final path = GoRouterState.of(context).uri.path;
    if (path.contains('/journal')) return 1;
    if (path.contains('/qr')) return 2;
    if (path.contains('/tasks')) return 3;
    if (path.contains('/profile')) return 4;
    return 0;
  }

  void _onTap(int i) {
        switch (i) {
      case 0:
        context.go('/home/schedule');
      case 1:
        context.go('/home/journal');
      case 2:
        context.go('/home/qr');
      case 3:
        context.go('/home/tasks');
      case 4:
        context.go('/home/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _tabFromLocation;
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: t,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calendar_today), label: 'Расписание'),
          NavigationDestination(icon: Icon(Icons.grade), label: 'Оценки'),
          NavigationDestination(
            icon: SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: Icon(Icons.qr_code, size: 30),
              ),
            ),
            label: 'QR',
          ),
          NavigationDestination(icon: Icon(Icons.assignment), label: 'Задачи'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }
}
