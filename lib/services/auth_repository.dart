import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_request.dart';
import '../models/person_info.dart';
import '../models/week_schedule.dart';
import '../models/nearest_schedule.dart';
import '../models/student_task.dart';
import '../models/journal.dart';
import '../models/subject_detail.dart';
import 'platonus_client.dart';

class AuthRepository extends ChangeNotifier {
  final _client = PlatonusClient();
  String? _token;
  PersonInfo? _profile;
  WeekScheduleResponse? _schedule;
  NearestScheduleResponse? _nearest;
  StudentTasksResponse? _tasks;
  JournalDetail? _journal;
  SubjectDetail? _subjectDetail;
  bool _loading = false;
  bool _offline = false;
  String? error;

  String? get token => _token;
  bool get isLoggedIn => _token != null;
  bool get loading => _loading;
  bool get offline => _offline;
  PersonInfo? get profile => _profile;
  WeekScheduleResponse? get schedule => _schedule;
  NearestScheduleResponse? get nearest => _nearest;
  StudentTasksResponse? get tasks => _tasks;
  JournalDetail? get journal => _journal;
  SubjectDetail? get subjectDetail => _subjectDetail;

  Future<void> _saveCache(String key, String data) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('cache_$key', data);
  }

  Future<String?> _readCache(String key) async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString('cache_$key');
  }

  Future<bool> tryRestore() async {
    final sp = await SharedPreferences.getInstance();
    _token = sp.getString('auth_token');
    if (_token == null) return false;
    await _client.init();
    try {
      _profile = await _client.personInfo(_token!);
      notifyListeners();
      return true;
    } on PlatonusAuthException {
      _token = null;
      await sp.remove('auth_token');
      return false;
    } catch (_) {
      notifyListeners();
      return true;
    }
  }

  void _notifyDeferred() {
    Future.microtask(notifyListeners);
  }

  Future<String?> signIn(String login, String password) async {
    _loading = true;
    error = null;
    notifyListeners();

    try {
      final req = LoginRequest(
        icNumber: login,
        login: login,
        password: password,
      );
      await _client.init();
      final resp = await _client.login(req);

      if (resp.isInvalid) {
        _loading = false;
        notifyListeners();
        return resp.message ?? 'Неверные данные';
      }

      _token = resp.authToken;
      final sp = await SharedPreferences.getInstance();
      await sp.setString('auth_token', _token!);
      _loading = false;
      notifyListeners();

      await refreshProfile();
      return null;
    } on PlatonusAuthException catch (e) {
      _loading = false;
      error = e.message;
      notifyListeners();
      return e.message;
    } catch (e) {
      _loading = false;
      error = e.toString();
      notifyListeners();
      return 'Ошибка сети: $e';
    }
  }

  Future<void> refreshProfile() async {
    if (_token == null) return;
    try {
      _profile = await _client.personInfo(_token!);
      notifyListeners();
    } on PlatonusAuthException {
      await _sessionExpired();
    } catch (_) {}
  }

  Future<void> _sessionExpired() async {
    error = 'Сессия истекла, войдите заново';
    _loading = false;
    await signOut();
  }

  Future<void> loadSchedule({
    required int year,
    required int semester,
    required int week,
  }) async {
    if (_token == null) return;
    _loading = true;
    error = null;
    _notifyDeferred();
    try {
      _schedule = await _client.weekSchedule(
        _token!,
        year: year,
        semester: semester,
        week: week,
      );
      _loading = false;
      _offline = false;
      notifyListeners();
      await _saveCache(
          'schedule_$year-$semester-$week', jsonEncode(_schedule!.toJson()));
    } on PlatonusAuthException {
      await _sessionExpired();
    } catch (_) {
      final cached = await _readCache('schedule_$year-$semester-$week');
      if (cached != null) {
        _schedule = WeekScheduleResponse.fromJson(
            jsonDecode(cached) as Map<String, dynamic>);
        _offline = true;
      }
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadNearest() async {
    if (_token == null) return;
    _loading = true;
    error = null;
    _notifyDeferred();
    try {
      _nearest = await _client.nearestSchedule(_token!);
      _loading = false;
      notifyListeners();
      await _saveCache('nearest', jsonEncode(_nearest!.toJson()));
    } on PlatonusAuthException {
      await _sessionExpired();
    } catch (_) {
      final cached = await _readCache('nearest');
      if (cached != null) {
        _nearest = NearestScheduleResponse.fromJson(
            jsonDecode(cached) as Map<String, dynamic>);
        _offline = true;
        _loading = false;
        notifyListeners();
        return;
      }
      _loading = false;
      notifyListeners();
    }
  }

  String _fmt(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$day-$m-${d.year}';
  }

  Future<String?> loadTasks({int? year, int? semester}) async {
    if (_token == null) return null;
    final now = DateTime.now();
    final y = year ?? (now.month >= 9 ? now.year : now.year - 1);
    final s = semester ?? (now.month >= 9 || now.month <= 1 ? 1 : 2);
    final start = s == 1 ? _fmt(DateTime(y, 9, 1)) : _fmt(DateTime(y + 1, 2, 1));
    final end = s == 1 ? _fmt(DateTime(y + 1, 1, 31)) : _fmt(DateTime(y + 1, 6, 30));
    _loading = true;
    error = null;
    _notifyDeferred();
    try {
      _tasks = await _client.studentTasks(
        _token!,
        year: y,
        semester: s,
        startDate: start,
        endDate: end,
      );
      _loading = false;
      error = null;
      notifyListeners();
      await _saveCache(
          'tasks_$y-$s', jsonEncode(_tasks!.toJson()));
      return null;
    } on PlatonusAuthException catch (e) {
      error = e.message;
      await _sessionExpired();
      return e.message;
    } catch (e) {
      _loading = false;
      error = e.toString();
      final cached = await _readCache('tasks_$y-$s');
      if (cached != null) {
        _tasks = StudentTasksResponse.fromJson(
            jsonDecode(cached) as Map<String, dynamic>);
        _offline = true;
      }
      notifyListeners();
      return 'Ошибка сети: $e';
    }
  }

  Future<SubjectDetail?> loadSubjectDetail(
    JournalSubject subject, {
    required int year,
    required int semester,
  }) async {
    final id = _token != null ? _profile?.studentId : null;
    if (_token == null || id == null) return null;
    try {
      _subjectDetail = await _client.subjectDetail(
        _token!,
        studentId: id,
        subjectId: subject.subjectID,
        year: year,
        semester: semester,
        queryId: subject.queryID,
      );
      notifyListeners();
      return _subjectDetail;
    } on PlatonusAuthException {
      await _sessionExpired();
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<JournalDetail?> loadJournal({
    required int year,
    required int semester,
  }) async {
    final id = _profile?.studentId;
    if (_token == null || id == null) return null;
    _loading = true;
    error = null;
    _notifyDeferred();
    try {
      _journal = await _client.journal(
        _token!,
        studentId: id,
        year: year,
        semester: semester,
      );
      _loading = false;
      _offline = false;
      notifyListeners();
      await _saveCache(
          'journal_$year-$semester', jsonEncode(_journal!.toListJson()));
      return _journal;
    } on PlatonusAuthException catch (e) {
      error = e.message;
      await _sessionExpired();
      return null;
    } catch (e) {
      final cached = await _readCache('journal_$year-$semester');
      if (cached != null) {
        _journal = JournalDetail.fromJson(
            (jsonDecode(cached) as List).whereType<Map<String, dynamic>>().toList());
        _offline = true;
        _loading = false;
        notifyListeners();
        return _journal;
      }
      _loading = false;
      error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> signOut() async {
    _token = null;
    _profile = null;
    _schedule = null;
    _nearest = null;
    _tasks = null;
    _journal = null;
    _subjectDetail = null;
    final sp = await SharedPreferences.getInstance();
    await sp.remove('auth_token');
    notifyListeners();
  }
}
