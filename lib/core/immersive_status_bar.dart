import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 沉浸式状态栏工具类
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImmersiveHelper with WidgetsBindingObserver {
  static final ImmersiveHelper _instance = ImmersiveHelper._internal();
  factory ImmersiveHelper() => _instance;
  ImmersiveHelper._internal();

  void setImmersiveStatusBar() {
    print("setImmersiveStatusBar===");
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // 状态栏图标深色
        statusBarBrightness: Brightness.light, // iOS 状态栏背景
        systemNavigationBarColor: Colors.orange,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  /// 在 build 完成后 + 延时强制沉浸式
  void ensureAfterBuild({Duration delay = const Duration(milliseconds: 300)}) {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Future.delayed(delay, () {
    //     setImmersiveStatusBar();
    //   });
    // });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var d in [5000]) {
        Future.delayed(Duration(milliseconds: d), () {
          setImmersiveStatusBar();
        });
      }
    });
  }

  /// 开始监听生命周期
  void startObserve() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// 停止监听生命周期
  void stopObserve() {
    WidgetsBinding.instance.removeObserver(this);
  }

  /// 生命周期回调
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("didChangeAppLifecycleState $state");
    if (state == AppLifecycleState.resumed) {
      setImmersiveStatusBar();
    }
  }

  /// 静态方法，简化调用
  static void ensure(BuildContext context) {
    final helper = ImmersiveHelper();
    helper.startObserve();
    helper.ensureAfterBuild();
  }
}

