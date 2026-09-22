import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_repository.dart';
import '../models/journal.dart';
import '../models/subject_detail.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  late int _year;
  late int _semester;

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
    context.read<AuthRepository>().loadJournal(year: _year, semester: _semester);
  }

  void _onSpin(void Function() update) {
    setState(update);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthRepository>();
    final subjects = auth.journal?.subjects ?? [];

    return Column(
      children: [
        _controls(),
        Expanded(
          child: auth.loading && subjects.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : auth.error != null && subjects.isEmpty
                  ? Center(
                      child: FilledButton.tonal(
                        onPressed: _load,
                        child: const Text('Повторить'),
                      ),
                    )
                  : subjects.isEmpty
                      ? const Center(child: Text('Оценки не найдены'))
                      : RefreshIndicator(
                          onRefresh: () async => _load(),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: subjects.length,
                            itemBuilder: (_, i) => _subjectCard(subjects[i]),
                          ),
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

  Widget _subjectCard(JournalSubject s) {
    final first = s.exams.isEmpty ? '?' : s.exams.first.mark.isEmpty ? '0' : s.exams.first.mark[0];
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(child: Text(first)),
        title: Text(s.subjectName, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (s.tutorList.isNotEmpty)
              Text(s.tutorList, style: const TextStyle(fontSize: 12)),
            Wrap(
              spacing: 8,
              children: s.exams
                  .map((e) => Text('${e.name}: ${e.mark}', style: const TextStyle(fontSize: 12)))
                  .toList(),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: Text(s.totalMark, style: const TextStyle(fontWeight: FontWeight.w700)),
        onTap: () => _openDetail(s),
      ),
    );
  }

  Future<void> _openDetail(JournalSubject s) async {
    final auth = context.read<AuthRepository>();
    final detail = await auth.loadSubjectDetail(s, year: _year, semester: _semester);
    if (!mounted) return;
    if (detail == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Детали не загрузились')));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _SubjectDetailScreen(detail: detail, title: s.subjectName),
    ));
  }
}

class _SubjectDetailScreen extends StatelessWidget {
  const _SubjectDetailScreen({required this.detail, required this.title});
  final SubjectDetail detail;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: detail.marks.isEmpty && detail.groups.isEmpty
          ? const Center(child: Text('Нет данных'))
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                if (detail.groups.isNotEmpty) ...[
                  const Text('Группы', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...detail.groups.map((g) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.people),
                        title: Text(g.name),
                        subtitle: Text(g.tutorFullName),
                      )),
                ],
                if (detail.marks.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Оценки', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...detail.marks.map((m) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.grade),
                        title: Text(m.markName),
                        subtitle: Text(m.date),
                        trailing: Text(_type(m.markType)),
                      )),
                ],
              ],
            ),
    );
  }

  String _type(int t) => switch (t) { 2 => 'Текущая', 3 => 'Итоговая', _ => 'Тип $t' };
}