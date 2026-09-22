import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import '../config.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/person_info.dart';
import '../models/week_schedule.dart';
import '../models/nearest_schedule.dart';
import '../models/student_task.dart';
import '../models/journal.dart';
import '../models/subject_detail.dart';
import 'logging_interceptor.dart';

class PlatonusAuthException implements Exception {
  final String message;
  PlatonusAuthException(this.message);
  @override
  String toString() => message;
}

class PlatonusClient {
  final _dio = Dio(BaseOptions(
    baseUrl: PlatonusConfig.platonusUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    sendTimeout: const Duration(seconds: 20),
    validateStatus: (_) => true,
  ))..interceptors.add(LoggingInterceptor());

  bool _cookiesReady = false;

  Future<void> _ensureCookies() async {
    if (_cookiesReady) return;
    final dir = await getApplicationSupportDirectory();
    _dio.interceptors.add(CookieManager(PersistCookieJar(
      storage: FileStorage('${dir.path}/platonus_cookies'),
    )));
    _cookiesReady = true;
  }

  Future<void> init() => _ensureCookies();

  Options _opts(String? token) => Options(
        headers: PlatonusConfig.platonusHeaders(token: token),
      );

  Future<LoginResponse> login(LoginRequest req) async {
    await _ensureCookies();
    final resp = await _dio.post(
      '/rest/api/mobile/authentication/login?language=1&lang=1',
      data: req.toJson(),
      options: _opts(null),
    );

    if (resp.statusCode == 401 || resp.statusCode == 403) {
      throw PlatonusAuthException('Неверный логин или пароль (${resp.statusCode})');
    }

    final body = resp.data;
    if (body is String) {
      throw PlatonusAuthException('Ошибка сервера (${resp.statusCode})');
    }
    if (body is! Map<String, dynamic>) {
      throw PlatonusAuthException('Неожиданный ответ сервера');
    }

    return LoginResponse.fromJson(body);
  }

  Future<PersonInfo?> personInfo(String token) async {
    final resp = await _dio.get(
      '/rest/mobile/personInfo/ru?lang=1',
      options: _opts(token),
    );
    if (resp.statusCode == 401 || resp.statusCode == 403) {
      throw PlatonusAuthException('Токен истёк');
    }
    final data = resp.data;
    if (data is Map<String, dynamic>) {
      return PersonInfo.fromJson(data);
    }
    return null;
  }

  Future<WeekScheduleResponse> weekSchedule(
    String token, {
    required int year,
    required int semester,
    required int week,
  }) async {
    final resp = await _dio.get(
      '/rest/mobile/schedule/student/$year/$semester/$week?lang=1',
      options: _opts(token),
    );
    if (resp.statusCode == 401 || resp.statusCode == 403) {
      throw PlatonusAuthException('Токен истёк');
    }
    return WeekScheduleResponse.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<NearestScheduleResponse?> nearestSchedule(String token) async {
    final resp = await _dio.get(
      '/rest/mobile/schedule/student/nearest-schedule?lang=1',
      options: _opts(token),
    );
    if (resp.statusCode == 401 || resp.statusCode == 403) {
      throw PlatonusAuthException('Токен истёк');
    }
    final data = resp.data;
    if (data is Map<String, dynamic>) {
      return NearestScheduleResponse.fromJson(data);
    }
    return null;
  }

  Future<StudentTasksResponse> studentTasks(
    String token, {
    int year = 0,
    int semester = 0,
    String startDate = '',
    String endDate = '',
  }) async {
    final resp = await _dio.post(
      '/rest/assignments/studentTasks/1',
      data: {
        'term': semester,
        'year': year,
        'subjectID': -1,
        'studyGroupID': -1,
        'tutorID': -1,
        'disciplineID': -1,
        'countInPart': 20,
        'partNumber': 0,
        'startDate': startDate,
        'endDate': endDate,
        'recipientStatus': -1,
      },
      options: _opts(token),
    );
    _throwIfUnathorized(resp);
    return StudentTasksResponse.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<JournalDetail> journal(
    String token, {
    required int studentId,
    required int year,
    required int semester,
  }) async {
    final resp = await _dio.get(
      '/journal/$year/$semester/$studentId',
      options: _opts(token),
    );
    _throwIfUnathorized(resp);
    return JournalDetail.fromJson(resp.data as List<dynamic>);
  }

  Future<SubjectDetail> subjectDetail(
    String token, {
    required int studentId,
    required int subjectId,
    required int year,
    required int semester,
    required int queryId,
  }) async {
    final resp = await _dio.get(
      '/subject/$year/$semester/$subjectId/$studentId',
      queryParameters: {'queryID': queryId},
      options: _opts(token),
    );
    _throwIfUnathorized(resp);
    return SubjectDetail.fromJson(resp.data as List<dynamic>);
  }

  void _throwIfUnathorized(Response resp) {
    if (resp.statusCode == 401 || resp.statusCode == 403) {
      throw PlatonusAuthException('Токен истёк (${resp.statusCode})');
    }
  }
}
