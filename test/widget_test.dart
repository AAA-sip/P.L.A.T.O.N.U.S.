import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:platonus_client/services/auth_repository.dart';
import 'package:platonus_client/app.dart';

void main() {
  testWidgets('App renders login', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthRepository(),
        child: const App(),
      ),
    );
    expect(find.text('Platonus Helper'), findsOneWidget);
  });
}
