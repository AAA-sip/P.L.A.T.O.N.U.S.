import 'package:dio/dio.dart';
import '../config.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/person_info.dart';
import '../models/week_schedule.dart';
import '../models/nearest_schedule.dart';
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

  Options _opts(String? token) => Options(
        headers: PlatonusConfig.platonusHeaders(token: token),
      );

  Future<LoginResponse> login(LoginRequest req) async {
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
}
