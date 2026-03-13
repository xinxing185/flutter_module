import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boost/flutter_boost.dart';

import 'core/app_lifecycle_observer.dart';

/// flutter_boost 要求使用自定义 Binding 管理容器生命周期。
class CustomFlutterBinding extends WidgetsFlutterBinding
    with
        BoostFlutterBinding {}

class AppRoutes {
  static const String root = '/';
  static const String portInfo = 'portInfo';
  static const String portSettings = 'portSettings';
}

class NativeBridge {
  NativeBridge._();

  static const MethodChannel _channel =
      MethodChannel('com.example.flutter_module/native_bridge');

  static Future<void> init() async {
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  static Future<void> sendRouteReady(String route) async {
    try {
      await _channel.invokeMethod<void>('onFlutterRouteReady', {
        'route': route,
      });
    } catch (error) {
      debugPrint('sendRouteReady error: $error');
    }
  }

  static Future<dynamic> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'openFlutterRoute':
        final args = (call.arguments is Map)
            ? Map<String, dynamic>.from(call.arguments as Map)
            : <String, dynamic>{};
        final String route = (args['route'] as String?) ?? AppRoutes.portInfo;
        final bool withContainer = (args['withContainer'] as bool?) ?? false;
        final Map<String, dynamic> params =
            (args['params'] is Map<String, dynamic>)
                ? Map<String, dynamic>.from(args['params'] as Map<String, dynamic>)
                : <String, dynamic>{};

        await BoostNavigator.instance.push(
          route,
          arguments: params,
          withContainer: withContainer,
        );
        return {'success': true};
      default:
        throw PlatformException(
          code: 'UNIMPLEMENTED',
          message: 'Method ${call.method} is not implemented.',
        );
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PageVisibilityBinding.instance.addGlobalObserver(AppLifecycleObserver());
  CustomFlutterBinding();
  await NativeBridge.init();
  runApp(const MyApp());
}


Future<void> _handleBack(BuildContext context) async {
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
    return;
  }
  await BoostNavigator.instance.pop();
}

PreferredSizeWidget _buildBackAppBar(
  BuildContext context, {
  required String title,
}) {
  return AppBar(
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () {
        _handleBack(context);
      },
    ),
    title: Text(title),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Route<dynamic>? _routeFactory(
    RouteSettings settings,
    bool isContainerPage,
    String? uniqueId,
  ) {
    final Object? args = settings.arguments;
    final Map<String, dynamic> params =
        args is Map ? Map<String, dynamic>.from(args) : <String, dynamic>{};

    switch (settings.name) {
      case AppRoutes.root:
      case AppRoutes.portInfo:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => PortInfoPage(
            source: params['source'] as String? ?? 'native',
          ),
        );
      case AppRoutes.portSettings:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => PortSettingsPage(
            enableNotification:
                params['enableNotification'] as bool? ?? false,
          ),
        );
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => UnknownRoutePage(routeName: settings.name ?? ''),
        );
    }
  }

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
      _routeFactory,
      appBuilder: _appBuilder,
      initialRoute: AppRoutes.portInfo,
    );
  }
}

class PortInfoPage extends StatefulWidget {
  const PortInfoPage({super.key, required this.source});

  final String source;

  @override
  State<PortInfoPage> createState() => _PortInfoPageState();
}

class _PortInfoPageState extends State<PortInfoPage> {
  @override
  void initState() {
    super.initState();
    NativeBridge.sendRouteReady(AppRoutes.portInfo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBackAppBar(context, title: 'Flutter Boost Module'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Source: ${widget.source}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                BoostNavigator.instance.push(
                  AppRoutes.portSettings,
                  arguments: <String, dynamic>{'enableNotification': true},
                );
              },
              child: const Text('Open Port Settings'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await NativeBridge.sendRouteReady(AppRoutes.portInfo);
              },
              child: const Text('Call Native MethodChannel'),
            ),
          ],
        ),
      ),
    );
  }
}

class PortSettingsPage extends StatefulWidget {
  const PortSettingsPage({super.key, required this.enableNotification});

  final bool enableNotification;

  @override
  State<PortSettingsPage> createState() => _PortSettingsPageState();
}

class _PortSettingsPageState extends State<PortSettingsPage> {
  late bool _enableNotification;

  @override
  void initState() {
    super.initState();
    _enableNotification = widget.enableNotification;
    NativeBridge.sendRouteReady(AppRoutes.portSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBackAppBar(context, title: 'Port Settings'),
      body: SwitchListTile(
        title: const Text('Enable Notification'),
        value: _enableNotification,
        onChanged: (value) {
          setState(() {
            _enableNotification = value;
          });
        },
      ),
    );
  }
}

class UnknownRoutePage extends StatelessWidget {
  const UnknownRoutePage({super.key, required this.routeName});

  final String routeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBackAppBar(context, title: 'Unknown Route'),
      body: Center(child: Text('No page for route: $routeName')),
    );
  }
}
