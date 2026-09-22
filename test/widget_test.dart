import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:platonus_client/services/auth_repository.dart';
import 'package:platonus_client/app.dart';

void main() {
  testWidgets('App renders login', (tester) async {
    dotenv.loadFromString(envString: '''
PLATONUS_URL=https://platonus.iitu.edu.kz
BACKEND_URL=https://1050105.xyz
PLATONUS_USER_AGENT=Platonus/1.132.0 (samsung SM-G991B; Android 13)
PLATONUS_ORIGIN=https://dev-m.platonus.kz
PLATONUS_REFERER=https://dev-m.platonus.kz/
PLATONUS_APP_ID=com.platonusstudent
''');
    final auth = AuthRepository();
    final router = createRouter(auth);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: auth,
        child: App(router: router),
      ),
    );
    expect(find.text('Platonus Helper'), findsOneWidget);
  });
}
