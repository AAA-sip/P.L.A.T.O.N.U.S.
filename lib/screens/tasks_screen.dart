import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_repository.dart';
import '../models/student_task.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthRepository>().loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthRepository>();
    final tasks = auth.tasks?.tasks ?? [];

    if (auth.loading && tasks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (auth.error != null && tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(auth.error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.tonal(onPressed: () => auth.loadTasks(), child: const Text('Повторить')),
          ],
        ),
      );
    }

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Задачи не найдены'),
            const SizedBox(height: 12),
            FilledButton.tonal(onPressed: () => auth.loadTasks(), child: const Text('Обновить')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => auth.loadTasks(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: tasks.length,
        itemBuilder: (_, i) => _taskCard(tasks[i]),
      ),
    );
  }

  Widget _taskCard(StudentTask t) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(child: Text(t.subjectName.isEmpty ? '?' : t.subjectName[0])),
        title: Text(
          t.taskName.isEmpty ? 'Без названия' : t.taskName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (t.subjectName.isNotEmpty) Text(t.subjectName),
            if (t.tutorName.isNotEmpty) Text(t.tutorName, style: const TextStyle(fontSize: 12)),
            if (t.endDate.isNotEmpty) Text('до ${t.endDate}', style: const TextStyle(fontSize: 12)),
          ],
        ),
        isThreeLine: true,
        trailing: t.statusName.isNotEmpty
            ? Text(t.statusName, style: const TextStyle(fontSize: 12))
            : null,
      ),
    );
  }
}