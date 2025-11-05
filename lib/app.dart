import 'package:flutter/material.dart';
import 'package:my_app/core/presentation/theme/app_theme.dart';
import 'package:my_app/core/routing/app_go_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Clean Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,

      // Nếu bạn muốn dùng Material3 hoặc cấu hình riêng cho Bottom Nav thì bỏ comment phía dưới:
      // theme: ThemeData(
      //   useMaterial3: true,
      //   colorSchemeSeed: Colors.blue,
      //   bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      //     backgroundColor: Colors.black,
      //     selectedItemColor: Colors.amber,
      //     unselectedItemColor: Colors.white70,
      //     selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
      //   ),
      // ),
      routerConfig: AppGoRouter.router,
      // Không cần initialRoute hay onGenerateRoute nếu đã dùng GoRouter và routerConfig
    );
  }
}
