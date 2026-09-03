import 'package:flutter_dotenv/flutter_dotenv.dart';

class PlatonusConfig {
  static String get platonusUrl => dotenv.get('PLATONUS_URL');
  static String get backendUrl => dotenv.get('BACKEND_URL');

  static String get userAgent => dotenv.get('PLATONUS_USER_AGENT');

  static String get _origin => dotenv.get('PLATONUS_ORIGIN');
  static String get _referer => dotenv.get('PLATONUS_REFERER');
  static String get _appId => dotenv.get('PLATONUS_APP_ID');

  static Map<String, String> platonusHeaders({String? token}) {
    final h = <String, String>{
      'Accept': 'application/json, text/plain, */*',
      'Connection': 'keep-alive',
      'User-Agent': userAgent,
      'Origin': _origin,
      'Referer': _referer,
      'X-Requested-With': _appId,
      'sec-ch-ua-platform': '"Android"',
      'sec-ch-ua-mobile': '?1',
      'Sec-Fetch-Site': 'cross-site',
      'Sec-Fetch-Mode': 'cors',
      'Sec-Fetch-Dest': 'empty',
    };
    if (token != null && token.isNotEmpty) {
      h['token'] = token;
    }
    return h;
  }
}
