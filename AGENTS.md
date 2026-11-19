# AGENTS.md

## Context

This Flutter Module is embedded into the native Android app at `../CloudApp` (module: `module_flutter`) using `flutter_boost` v4.6.5 for hybrid Flutter-Native navigation.

## Rules

- **Navigation**: Always use `AppNavigator` (`lib/core/app_navigator.dart`) for all push/pop/replacement. Never call `Navigator` directly.
- **Routes**: Define route names in `AppRoutes` (`lib/app/app_router.dart`). Register new pages in `AppRouter._routerMap`.
- **Native routes**: Route names starting with `native/` are automatically delegated to the native side. Use `AppNavigator.openNative()` for these.
- **Native communication**: Use `NativeBridge` (`lib/bridge/native_bridge.dart`) for Flutter↔Native MethodChannel communication.
- **Page lifecycle**: Each feature page should call `NativeBridge.sendRouteReady()` in `initState()` to notify the native side.
- **Lifecycle observer**: Global lifecycle logging is handled by `AppLifecycleObserver` — do not add duplicate global observers.
- **Legacy code**: `lib/main_back.dart` is pre-refactoring code. Do not modify or import from it.

## Build

- `flutter pub get` to install dependencies
- Build as part of the host Android app at `../CloudApp` — this module is not run standalone
