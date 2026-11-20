import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_boost/flutter_boost.dart';

import 'device_page_params.dart';

/// 全局导航入口。
class AppNavigator {
  AppNavigator._();

  static Future<T?> push<T extends Object?>(
    String routeName, {
    Map<String, dynamic>? arguments,
    bool withContainer = false,
    bool inheritDevice = true,
  }) {
    return BoostNavigator.instance.push<T?>(
      routeName,
      arguments: _routeArguments(arguments, inheritDevice: inheritDevice),
      withContainer: withContainer,
    );
  }

  static Future<T?> pushWithContainer<T extends Object?>(
    String routeName, {
    Map<String, dynamic>? arguments,
    bool inheritDevice = true,
  }) {
    return push<T>(
      routeName,
      arguments: arguments,
      withContainer: true,
      inheritDevice: inheritDevice,
    );
  }

  static Future<T?> pushReplacement<T extends Object?>(
    String routeName, {
    Map<String, dynamic>? arguments,
    bool withContainer = false,
    bool inheritDevice = true,
  }) {
    return BoostNavigator.instance.pushReplacement<T?>(
      routeName,
      arguments: _routeArguments(arguments, inheritDevice: inheritDevice),
      withContainer: withContainer,
    );
  }

  static Map<String, dynamic>? _routeArguments(
    Map<String, dynamic>? arguments, {
    required bool inheritDevice,
  }) {
    const key = DevicePageParams.argumentKey;
    if (!inheritDevice || (arguments?.containsKey(key) ?? false)) {
      return arguments;
    }

    // 当前路由有设备时才继承，保留 Map 形式以支持跨原生容器传递。
    final device = BoostNavigator.instance.getTopPageInfo()?.arguments?[key];
    if (device is! Map) return arguments;

    return {...?arguments, key: device};
  }

  static void openNative(String routeName, {Map<String, dynamic>? arguments}) {
    assert(
      routeName.startsWith('native'),
      'Native routes should start with "native".',
    );
    unawaited(
      BoostNavigator.instance.push<void>(routeName, arguments: arguments),
    );
  }

  static Future<T?> openNativeForResult<T extends Object?>(
    String routeName, {
    Map<String, dynamic>? arguments,
  }) {
    assert(
      routeName.startsWith('native'),
      'Native routes should start with "native".',
    );
    return BoostNavigator.instance.push<T?>(routeName, arguments: arguments);
  }

  static Future<void> pop<T extends Object?>(
    BuildContext context, {
    T? result,
  }) async {
    // 和 FlutterBoost 的系统返回一样，先让当前路由决定是否消费返回。
    final handled = await Navigator.of(context).maybePop<T>(result);
    if (!handled) {
      await popBoost<T>(result: result);
    }
  }

  static Future<bool> popBoost<T extends Object?>({T? result}) {
    return BoostNavigator.instance.pop<T>(result);
  }
}
