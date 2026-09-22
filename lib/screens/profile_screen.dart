import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_repository.dart';
import '../models/person_info.dart';
import '../widgets/biometric_switch.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthRepository>();
    final p = auth.profile;

    if (auth.loading && p == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (p == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Профиль не загружен'),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () => auth.refreshProfile(),
              child: const Text('Обновить'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  child: Text(
                    _initials(p),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(height: 12),
                Text(p.name ?? '—', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(p.groupName ?? '', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _infoTile(Icons.badge, 'Student ID', p.studentId?.toString()),
        _infoTile(Icons.school, 'Курс', p.courseNumber?.toString()),
        _infoTile(Icons.star, 'GPA', p.gpa),
        const SizedBox(height: 8),
        const BiometricSwitch(),
      ],
    );
  }

  Widget _infoTile(IconData icon, String label, String? value) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: Text(value ?? '—', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }

  String _initials(PersonInfo p) {
    final parts = [p.lastName, p.firstName].whereType<String>().where((s) => s.isNotEmpty);
    return parts.map((s) => s[0]).join();
  }
}
