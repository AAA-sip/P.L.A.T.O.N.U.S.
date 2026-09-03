class LoginResponse {
  final String? authToken;
  final String? refreshToken;
  final String? loginStatus;
  final String? sid;
  final String? message;

  LoginResponse({
    this.authToken,
    this.refreshToken,
    this.loginStatus,
    this.sid,
    this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> j) => LoginResponse(
        authToken: j['auth_token'] as String?,
        refreshToken: j['refresh_token'] as String?,
        loginStatus: j['login_status'] as String?,
        sid: j['sid'] as String?,
        message: j['message'] as String?,
      );

  bool get isInvalid =>
      loginStatus?.toLowerCase() == 'invalid' || authToken == null;
}
