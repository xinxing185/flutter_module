import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';

import '../common/pages/unknown_route_page.dart';
import '../core/device_page_params.dart';
import '../core/device_page_scope.dart';
import '../features/feedback/feedback_page.dart';
import '../features/demo/flutter_demo_page.dart';
import '../features/demo/device_api_test_page.dart';

class AppRoutes {
  static const String root = '/';
  static const String unknown = 'unknown';
  static const String feedback = 'feedback';
  static const String flutterDemo = 'flutterDemo';
  static const String deviceApiTest = 'deviceApiTest';
}

class NativeRoutes {
  static const String test = 'native/test';
  static const String deviceDetail = 'native/deviceDetail';
}

class AppRouter {
  AppRouter._();

  static final Map<String, FlutterBoostRouteFactory> _routerMap = {
    AppRoutes.root: (settings, isContainerPage, uniqueId) {
      return _materialRoute(
        settings,
        (_) => UnknownRoutePage(routeName: settings.name ?? ''),
      );
    },
    AppRoutes.unknown: (settings, isContainerPage, uniqueId) {
      return _materialRoute(
        settings,
        (_) => UnknownRoutePage(routeName: settings.name ?? ''),
      );
    },
    AppRoutes.feedback: (settings, isContainerPage, uniqueId) {
      return _materialRoute(settings, (_) => const FeedbackPage());
    },
    AppRoutes.flutterDemo: (settings, isContainerPage, uniqueId) {
      final Map<String, dynamic> params = _argumentsAsMap(settings.arguments);
      return _materialRoute(
        settings,
        (_) => FlutterDemoPage(source: params['source'] as String? ?? 'native'),
      );
    },
    AppRoutes.deviceApiTest: (settings, isContainerPage, uniqueId) {
      return _materialRoute(settings, (_) => const DeviceApiTestPage());
    },
  };

  static Route<dynamic>? routeFactory(
    RouteSettings settings,
    bool isContainerPage,
    String? uniqueId,
  ) {
    // 旧版 Android 和 iOS 宿主仍可使用原来的路由名。
    final routeName = switch (settings.name) {
      'portInfo' => AppRoutes.flutterDemo,
      'portSettings' => AppRoutes.deviceApiTest,
      final name => name,
    };
    final FlutterBoostRouteFactory? routeFactory = _routerMap[routeName];
    if (routeFactory == null) {
      if (_isNativeRoute(settings.name)) {
        return null;
      }

      return _routerMap[AppRoutes.unknown]!(
        settings,
        isContainerPage,
        uniqueId,
      );
    }
    return routeFactory(settings, isContainerPage, uniqueId);
  }

  static bool _isNativeRoute(String? routeName) {
    return routeName?.startsWith('native') ?? false;
  }

  static Map<String, dynamic> _argumentsAsMap(Object? arguments) {
    return arguments is Map
        ? Map<String, dynamic>.from(arguments)
        : <String, dynamic>{};
  }

  static MaterialPageRoute<dynamic> _materialRoute(
    RouteSettings settings,
    WidgetBuilder builder,
  ) {
    final device = DevicePageParams.fromRouteArguments(settings.arguments);
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: device == null
          ? builder
          : (_) => DevicePageScope(
              device: device,
              child: Builder(builder: builder),
            ),
    );
  }
}
