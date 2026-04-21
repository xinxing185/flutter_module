import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../app/app_router.dart';
import '../core/app_navigator.dart';

class NativeBridge {
  NativeBridge._();

  static const MethodChannel _channel = MethodChannel(
    'com.example.flutter_module/native_bridge',
  );

  static Future<void> init() {
    _channel.setMethodCallHandler(_handleNativeCall);
    return Future<void>.value();
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
        final Map<String, dynamic> args = call.arguments is Map
            ? Map<String, dynamic>.from(call.arguments as Map)
            : <String, dynamic>{};
        final String route = args['route'] as String? ?? AppRoutes.portInfo;
        final bool withContainer = args['withContainer'] as bool? ?? false;
        final Map<String, dynamic> params = args['params'] is Map
            ? Map<String, dynamic>.from(args['params'] as Map)
            : <String, dynamic>{};

        await AppNavigator.push<void>(
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
