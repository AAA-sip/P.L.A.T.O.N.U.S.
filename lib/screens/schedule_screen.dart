import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_repository.dart';
import '../models/week_schedule.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late int _year;
  late int _semester;
  int _week = 1;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.month >= 9 ? now.year : now.year - 1;
    _semester = now.month >= 9 || now.month <= 1 ? 1 : 2;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    if (!mounted) return;
    context.read<AuthRepository>().loadSchedule(
          year: _year,
          semester: _semester,
          week: _week,
        );
  }

  void _onSpin(void Function() update) {
    setState(update);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthRepository>();
    final schedule = auth.schedule;
    final days = schedule?.schedule ?? [];

    return Column(
      children: [
        _controls(),
        Expanded(
          child: auth.loading && schedule == null
              ? const Center(child: CircularProgressIndicator())
              : days.isEmpty
                  ? const Center(child: Text('Нет данных'))
                  : ListView.builder(
                      itemCount: days.length,
                      itemBuilder: (_, i) => _dayCard(days[i]),
                    ),
        ),
      ],
    );
  }

  Widget _controls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _spinField('Неделя', _week, 1, 20, (v) => _onSpin(() => _week = v)),
          const SizedBox(width: 8),
          _spinField('Семестр', _semester, 1, 2, (v) => _onSpin(() => _semester = v)),
          const SizedBox(width: 8),
          _spinField('Год', _year, 2023, 2030, (v) => _onSpin(() => _year = v)),
        ],
      ),
    );
  }

  Widget _spinField(String label, int value, int min, int max, ValueChanged<int> onChanged) {
    return Expanded(
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              iconSize: 18,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28),
              onPressed: value > min ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove),
            ),
            Flexible(
              child: Text(
                '$value',
                style: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              iconSize: 18,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28),
              onPressed: value < max ? () => onChanged(value + 1) : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayCard(RawDay day) {
    final lessons = day.lessons ?? [];
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ExpansionTile(
        title: Text(day.day ?? '—', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(day.date ?? '', style: const TextStyle(fontSize: 13)),
        initiallyExpanded: _isToday(day.date),
        children: lessons.isEmpty
            ? [const Padding(padding: EdgeInsets.all(16), child: Text('Нет пар'))]
            : lessons.map(_lessonTile).toList(),
      ),
    );
  }

  Widget _lessonTile(RawLesson l) {
    return ListTile(
      dense: true,
      title: Text(l.subjectName ?? '—'),
      subtitle: Text([
        if (l.tutorShortName != null) l.tutorShortName,
        if (l.auditory != null) l.auditory,
        if (l.building != null) 'Корпус ${l.building}',
        if (l.groupTypeShortName != null) l.groupTypeShortName,
      ].whereType<String>().join(' · ')),
      trailing: l.time != null ? Text(l.time!, textAlign: TextAlign.center) : null,
    );
  }

  bool _isToday(String? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.contains('${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}');
  }
}
