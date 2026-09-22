import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'services/auth_repository.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final auth = AuthRepository();
  await auth.tryRestore();
  final router = createRouter(auth);
  runApp(
    ChangeNotifierProvider.value(
      value: auth,
      child: App(router: router),
    ),
  );
}
