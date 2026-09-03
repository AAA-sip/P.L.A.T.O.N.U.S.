import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_request.dart';
import '../models/person_info.dart';
import '../models/week_schedule.dart';
import '../models/nearest_schedule.dart';
import 'platonus_client.dart';

class AuthRepository extends ChangeNotifier {
  final _client = PlatonusClient();
  String? _token;
  PersonInfo? _profile;
  WeekScheduleResponse? _schedule;
  NearestScheduleResponse? _nearest;
  bool _loading = false;
  String? error;

  String? get token => _token;
  bool get isLoggedIn => _token != null;
  bool get loading => _loading;
  PersonInfo? get profile => _profile;
  WeekScheduleResponse? get schedule => _schedule;
  NearestScheduleResponse? get nearest => _nearest;

  Future<bool> tryRestore() async {
    final sp = await SharedPreferences.getInstance();
    _token = sp.getString('auth_token');
    if (_token != null) {
      notifyListeners();
      await refreshProfile();
      return true;
    }
    return false;
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
    } catch (_) {}
  }

  Future<void> loadSchedule({
    required int year,
    required int semester,
    required int week,
  }) async {
    if (_token == null) return;
    _loading = true;
    notifyListeners();
    try {
      _schedule = await _client.weekSchedule(
        _token!,
        year: year,
        semester: semester,
        week: week,
      );
    } catch (_) {}
    _loading = false;
    notifyListeners();
  }

  Future<void> loadNearest() async {
    if (_token == null) return;
    try {
      _nearest = await _client.nearestSchedule(_token!);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> signOut() async {
    _token = null;
    _profile = null;
    _schedule = null;
    _nearest = null;
    final sp = await SharedPreferences.getInstance();
    await sp.remove('auth_token');
    notifyListeners();
  }
}
