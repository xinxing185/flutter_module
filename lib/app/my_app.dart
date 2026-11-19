import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boost/flutter_boost.dart';

import '../bridge/native_bridge.dart';
import '../core/app_lifecycle_observer.dart';
import '../l10n/generated/app_localizations.dart';
import 'app_router.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // 对齐 Android 宿主的 blue_btn 和 gray_f5f6。
  static const _mainBlue = Color(0xFF008CFF);
  static const _pageBackground = Color(0xFFF5F6FA);
  static final _theme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _mainBlue,
      primary: _mainBlue,
      onPrimary: Colors.white,
    ),
    scaffoldBackgroundColor: _pageBackground,
    appBarTheme: const AppBarThemeData(
      backgroundColor: _pageBackground,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
    ),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        ...const PageTransitionsTheme().builders,
        TargetPlatform.android: const _AndroidPageTransitionsBuilder(),
      },
    ),
  );

  late final AppLifecycleObserver _observer;
  HostUiConfig? _hostConfig;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _observer = AppLifecycleObserver(onVisible: _refreshHostConfig);
    PageVisibilityBinding.instance.addGlobalObserver(_observer);
  }

  @override
  void dispose() {
    PageVisibilityBinding.instance.removeGlobalObserver(_observer);
    super.dispose();
  }

  Future<void> _refreshHostConfig() async {
    final requestId = ++_requestId;
    try {
      final config = await NativeBridge.getHostUiConfig();
      // 容器切换和回前台可能连续触发，只接受最后一次读取结果。
      if (mounted && requestId == _requestId && config != _hostConfig) {
        setState(() => _hostConfig = config);
      }
    } on MissingPluginException {
      // 兼容未接入配置协议的宿主，使用 Flutter 平台默认值。
    } on PlatformException catch (error) {
      // 旧版 iOS 示例用错误码 22 表示未实现的方法。
      if (error.code != '22') {
        debugPrint('getHostUiConfig failed: ${error.code}');
      }
    }
  }

  Locale? _hostLocale(String? tag) {
    if (tag == null || tag.isEmpty || tag == 'und') return null;
    final parts = tag.split('-');
    final subtags = parts.skip(1);
    final script = subtags
        .where((part) => RegExp(r'^[A-Za-z]{4}$').hasMatch(part))
        .firstOrNull;
    final region = subtags
        .where((part) => RegExp(r'^([A-Za-z]{2}|[0-9]{3})$').hasMatch(part))
        .firstOrNull;
    return Locale.fromSubtags(
      languageCode: parts.first,
      scriptCode: script,
      countryCode: region,
    );
  }

  Widget _appBuilder(Widget home) {
    final config = _hostConfig;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _theme,
      locale: _hostLocale(config?.localeTag),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      themeMode: config?.colorMode == 'light'
          ? ThemeMode.light
          : ThemeMode.system,
      home: home,
      builder: (context, _) {
        final media = MediaQuery.of(context);
        final scale = config?.fontScale;
        return MediaQuery(
          data: media.copyWith(
            textScaler: scale == null
                ? media.textScaler
                : TextScaler.linear(scale),
            highContrast: config?.highContrast ?? media.highContrast,
          ),
          child: home,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlutterBoostApp(
      AppRouter.routeFactory,
      appBuilder: _appBuilder,
      initialRoute: AppRoutes.portInfo,
    );
  }
}

/// 容器内页面向右退出，下面一页保持原位，与 Android 宿主风格一致。
class _AndroidPageTransitionsBuilder extends PageTransitionsBuilder {
  const _AndroidPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: animation.drive(
        Tween(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutQuad)),
      ),
      child: child,
    );
  }
}
