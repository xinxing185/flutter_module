import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';

import 'app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget _appBuilder(Widget home) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: home,
      builder: (_, __) => home,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlutterBoostApp(
      AppRouter.routeFactory,
      appBuilder: _appBuilder,
      initialRoute: AppRoutes.portInfo,
    );
  }
}
