import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';

import 'app/my_app.dart';
import 'bridge/native_bridge.dart';
import 'core/app_lifecycle_observer.dart';

/// flutter_boost 要求使用自定义 Binding 管理容器生命周期。
class CustomFlutterBinding extends WidgetsFlutterBinding
    with BoostFlutterBinding {}

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  PageVisibilityBinding.instance.addGlobalObserver(AppLifecycleObserver());
  CustomFlutterBinding();
  await NativeBridge.init();
  runApp(const MyApp());
}
