class LoginRequest {
  final String icNumber;
  final String iin;
  final String login;
  final String password;

  LoginRequest({
    required this.icNumber,
    this.iin = '',
    required this.login,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'icNumber': icNumber,
        'iin': iin,
        'login': login,
        'password': password,
      };
}
