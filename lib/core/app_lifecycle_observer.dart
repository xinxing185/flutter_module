/**
 * @author liu.xinyi
 * @time 2022/1/18 11:36
 * @desc
 */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boost/flutter_boost.dart';

///全局生命周期监听示例
class AppLifecycleObserver with GlobalPageVisibilityObserver {
  @override
  void onBackground(Route route) {
    super.onBackground(route);
    print("AppLifecycleObserver - ${route.settings.name} - onBackground");
  }

  @override
  void onForeground(Route route) {
    super.onForeground(route);
    print("AppLifecycleObserver ${route.settings.name} - onForground");
  }

  @override
  void onPagePush(Route route) {
    super.onPagePush(route);
    print("AppLifecycleObserver - ${route.settings.name}- onPagePush");
  }

  @override
  void onPagePop(Route route) {
    super.onPagePop(route);
    print("AppLifecycleObserver - ${route.settings.name}- onPagePop");
  }

  @override
  void onPageHide(Route route) {
    super.onPageHide(route);
    print("AppLifecycleObserver - ${route.settings.name}- onPageHide");
  }

  @override
  void onPageShow(Route route) {
    super.onPageShow(route);
    print("AppLifecycleObserver - ${route.settings.name}- onPageShow");
    void setImmersiveStatusBar() {
      print("setImmersiveStatusBar++++");
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark, // 状态栏图标深色
          statusBarBrightness: Brightness.light, // iOS 状态栏背景
          systemNavigationBarColor: Colors.purple,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
    }
  }
}
