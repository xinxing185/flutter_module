import 'package:flutter/widgets.dart';
import 'package:flutter_boost/flutter_boost.dart';

/**
 * @author zhangxinxing
 * @desc  全局导航
 */
class AppNavigator{
  /**
   * 打开新的页面
   */
  static Future<T?> pushNative<T extends Object?>(
      String routeName, {
        Map<String, dynamic>? arguments,
      }) {
    return BoostNavigator.instance.push(routeName, arguments: arguments);
  }
  /**
   * 打开新的页面
   */
  static Future<T?> push<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    String name=routeName;
    // if (!routeName.startsWith("jys")) {
    //   name = routeName.toLowerCase();
    // }
    return Navigator.of( context).pushNamed(name,
        arguments: arguments);
  }

  /**
   * 替换的方式打开新的页面，
   */
  static Future<T> pushReplacement<T extends Object>(String routeName,
      {Map<String, dynamic>? arguments, bool withContainer = false}) async {
    // BoostNavigator.instance.push("");
    String name = routeName;
    return BoostNavigator.instance.pushReplacement(
      name,
      arguments: arguments,
      withContainer: withContainer,
    );
  }

  /**
   * 打开新的页面，使用新容器
   */
  static Future<T> pushWithContainer<T extends Object>(String name,
      {Map<String, dynamic>? arguments}) async {
    return BoostNavigator.instance.push(
      name,
      arguments: arguments,
      withContainer: true,
    );
  }
}
