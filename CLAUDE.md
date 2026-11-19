# CLAUDE.md

## Project Overview

Flutter Module (add-to-app) embedded into a native Android app at `../CloudApp` via the `flutter_boost` (v4.6.5) hybrid navigation framework.

## Architecture

```
lib/
├── main.dart                          # Entry point: Binding, LifecycleObserver, NativeBridge init
├── main_back.dart                     # Legacy entry point (pre-refactoring backup)
├── app/
│   ├── my_app.dart                    # FlutterBoostApp container
│   └── app_router.dart               # Route table + route factory
├── core/
│   ├── app_navigator.dart             # Unified navigation (wraps BoostNavigator)
│   ├── app_lifecycle_observer.dart    # Page visibility listener
│   └── immersive_status_bar.dart      # Immersive status bar helper
├── bridge/
│   └── native_bridge.dart            # MethodChannel: Flutter ↔ Native
├── features/
│   └── port/
│       ├── port_info_page.dart        # Port info screen
│       └── port_settings_page.dart    # Port settings screen
├── common/pages/
│   └── unknown_route_page.dart        # Fallback for unmatched routes
├── widget/
│   └── custom_switch.dart             # Custom animated switch
└── plugin/
    └── SystemUtil.dart               # System-level MethodChannel calls
```

## Key Patterns

### Routing
- `AppRouter.routeFactory` maps route names to page builders via `FlutterBoostRouteFactory`
- Routes in `AppRoutes`: `root`, `unknown`, `portInfo`, `portSettings`
- Routes prefixed with `native/` are delegated to the native side (recognized by `_isNativeRoute`)
- Unmatched non-native routes fall back to `UnknownRoutePage`

### Navigation
- Always use `AppNavigator` (not `Navigator` directly) for push/pop/replacement
- `AppNavigator.openNative()` for opening native screens
- `AppNavigator.pop()` tries `Navigator.pop` first, then falls back to `BoostNavigator.pop`

### Native Communication
- Primary channel: `com.example.flutter_module/native_bridge`
- `NativeBridge.init()` registers `_handleNativeCall` for incoming calls
- `NativeBridge.sendRouteReady()` notifies native when a Flutter page is ready
- System-level calls via `SystemUtils` on channel `cudy.test`

### Lifecycle
- `AppLifecycleObserver` (GlobalPageVisibilityObserver) logs page push/pop/show/hide/foreground/background events
- Registered in `main.dart` before app startup

### Status Bar
- `ImmersiveHelper` singleton manages immersive status bar styling
- Listens to `AppLifecycleState` to re-apply on resume

## File Notes

- `lib/main_back.dart` is the pre-refactoring version — do not use it, keep for reference only
- `docs/feature_refactor_plan.md` documents the refactoring plan
