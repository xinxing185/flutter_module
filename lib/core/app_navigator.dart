import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_boost/flutter_boost.dart';

/// 全局导航入口。
class AppNavigator {
  AppNavigator._();

  static Future<T?> push<T extends Object?>(
    String routeName, {
    Map<String, dynamic>? arguments,
    bool withContainer = false,
  }) {
    return BoostNavigator.instance.push<T?>(
      routeName,
      arguments: arguments,
      withContainer: withContainer,
    );
  }

  static Future<T?> pushWithContainer<T extends Object?>(
    String routeName, {
    Map<String, dynamic>? arguments,
  }) {
    return push<T>(routeName, arguments: arguments, withContainer: true);
  }

  static Future<T?> pushReplacement<T extends Object?>(
    String routeName, {
    Map<String, dynamic>? arguments,
    bool withContainer = false,
  }) {
    return BoostNavigator.instance.pushReplacement<T?>(
      routeName,
      arguments: arguments,
      withContainer: withContainer,
    );
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
    final NavigatorState navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop<T>(result);
      return;
    }

    await popBoost<T>(result: result);
  }

  static Future<bool> popBoost<T extends Object?>({T? result}) {
    return BoostNavigator.instance.pop<T>(result);
  }
}
