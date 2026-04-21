import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';

import '../common/pages/unknown_route_page.dart';
import '../features/port/port_info_page.dart';
import '../features/port/port_settings_page.dart';

class AppRoutes {
  static const String root = '/';
  static const String unknown = 'unknown';
  static const String portInfo = 'portInfo';
  static const String portSettings = 'portSettings';
}

class NativeRoutes {
  static const String test = 'native/test';
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
    AppRoutes.portInfo: (settings, isContainerPage, uniqueId) {
      final Map<String, dynamic> params = _argumentsAsMap(settings.arguments);
      return _materialRoute(
        settings,
        (_) => PortInfoPage(source: params['source'] as String? ?? 'native'),
      );
    },
    AppRoutes.portSettings: (settings, isContainerPage, uniqueId) {
      final Map<String, dynamic> params = _argumentsAsMap(settings.arguments);
      return _materialRoute(
        settings,
        (_) => PortSettingsPage(
          enableNotification: params['enableNotification'] as bool? ?? false,
        ),
      );
    },
  };

  static Route<dynamic>? routeFactory(
    RouteSettings settings,
    bool isContainerPage,
    String? uniqueId,
  ) {
    final FlutterBoostRouteFactory? routeFactory = _routerMap[settings.name];
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
    return MaterialPageRoute<dynamic>(settings: settings, builder: builder);
  }
}
