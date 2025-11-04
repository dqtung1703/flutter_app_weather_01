import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/routing/app_go_router.dart';
import 'core/config/firebase_env.dart';
import 'core/di/app_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: FirebaseEnv.apiKey,
      appId: FirebaseEnv.appId,
      messagingSenderId: FirebaseEnv.messagingSenderId,
      projectId: FirebaseEnv.projectId,
      authDomain: FirebaseEnv.authDomain,
      storageBucket: FirebaseEnv.storageBucket,
      measurementId: FirebaseEnv.measurementId,
    ),
  );
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: AppGoRouter.router);
  }
}
