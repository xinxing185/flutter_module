# Flutter Module 生产可落地目录重构方案（Feature 分层）

> 适用对象：当前 `flutter_module`（Add-to-App + flutter_boost）工程。  
> 目标：从 demo/原型结构平滑演进到可维护、可协作、可测试的生产结构。

---

## 1. 重构目标

- **按业务 feature 拆分**：避免 `main.dart` 持续膨胀。
- **分层清晰**：UI、状态管理、领域逻辑、数据访问边界明确。
- **便于 Add-to-App 集成**：路由、容器、Native 参数适配集中治理。
- **可测试**：domain/data 层可单测，UI 可 widget 测试。
- **可渐进迁移**：允许“边开发边迁移”，不要求一次性重写。

---

## 2. 推荐目录结构（Feature-first + Layered）

```txt
lib/
  app/
    app.dart                      # App 根组件（MaterialApp / FlutterBoostApp 组装）
    bootstrap.dart                # 启动编排（binding、observer、全局依赖初始化）
    router/
      app_routes.dart             # 路由名常量
      app_route_factory.dart      # FlutterBoost routeFactory
      native_route_adapter.dart   # Native 参数/协议适配
    lifecycle/
      app_lifecycle_observer.dart # 页面可见性、前后台监听
    theme/
      app_theme.dart
    di/
      service_locator.dart        # 依赖注入（GetIt/Riverpod ProviderScope）

  core/
    constants/
      env.dart
      keys.dart
    errors/
      app_exception.dart
      failure.dart
    network/
      api_client.dart
      dio_interceptors.dart
    logging/
      logger.dart
    utils/
      immersive_helper.dart
      debounce.dart
      extensions.dart
    widgets/
      app_loading.dart
      app_error_view.dart

  features/
    port_info/
      presentation/
        pages/
          port_info_page.dart
        widgets/
          port_info_header.dart
        state/
          port_info_controller.dart
          port_info_state.dart
      domain/
        entities/
          port_info.dart
        repositories/
          port_repository.dart      # 抽象接口
        usecases/
          get_port_info.dart
      data/
        models/
          port_info_model.dart
        datasources/
          port_remote_ds.dart
          port_local_ds.dart
        repositories/
          port_repository_impl.dart

    port_settings/
      presentation/
        pages/
          port_settings_page.dart
        widgets/
          setting_switch_tile.dart
          custom_image_switch.dart
        state/
          port_settings_controller.dart
          port_settings_state.dart
      domain/
        entities/
          port_setting.dart
        repositories/
          settings_repository.dart
        usecases/
          get_settings.dart
          update_setting.dart
      data/
        models/
          port_setting_model.dart
        datasources/
          settings_remote_ds.dart
          settings_local_ds.dart
        repositories/
          settings_repository_impl.dart

  l10n/
    arb/
      app_zh.arb
      app_en.arb

  main.dart                        # 仅保留入口，调用 app/bootstrap
```

---

## 3. 分层职责边界（落地标准）

### 3.1 presentation 层

- 包含页面、组件、状态管理（Bloc/Cubit、Riverpod、Notifier 均可）。
- **禁止直接依赖 Dio/SQLite**；只能调 `usecase` 或 `repository 抽象`。
- 允许处理交互态：loading、empty、error、toast。

### 3.2 domain 层

- 包含实体（Entity）、仓库接口（Repository）、用例（UseCase）。
- **纯 Dart 逻辑**，不依赖 Flutter UI。
- 可单元测试覆盖核心业务规则。

### 3.3 data 层

- 包含 model、datasource、repository impl。
- 负责 DTO <-> Entity 映射、缓存策略、异常转换。
- 对外只暴露 domain 约定的 repository 行为。

---

## 4. 路由重构建议（兼容 flutter_boost）

### 4.1 路由常量统一

在 `app/router/app_routes.dart` 中维护：

- `AppRoutes.portInfo = 'portInfo'`
- `AppRoutes.portSettings = 'portSettings'`

避免散落字符串（如 `mainPage` / `simplePage`）导致重构风险。

### 4.2 RouteFactory 收口

由 `app_route_factory.dart` 统一映射：

- routeName -> page builder
- arguments 解析、判空、默认值
- 未匹配页面兜底（404/错误页）

### 4.3 Native 协议适配

新增 `native_route_adapter.dart`：

- 统一解析 Native 传参（Map -> typed params）
- 处理字段兼容（历史 key、空值、类型错误）
- 统一上报参数异常日志

---

## 5. 状态管理建议（生产建议）

可选其一并坚持：

- **Riverpod**：轻量、测试友好、依赖图明确。
- **Bloc/Cubit**：事件流可追踪，团队协作稳定。

落地标准：

- 页面状态定义为密封类（idle/loading/success/error）。
- 禁止在 widget 内拼装业务逻辑；逻辑下沉到 controller/usecase。

---

## 6. 渐进式迁移步骤（不会阻塞业务）

### 阶段 A（1 天）- 搭骨架

1. 新建 `app/ core/ features/` 目录。
2. 复制当前 `MainPage/SimplePage/CustomImageSwitch` 到对应 feature。
3. `main.dart` 保留入口，改为调用 `bootstrap.dart`。

### 阶段 B（1~2 天）- 路由收口

1. 抽离 `routerMap` 到 `app_route_factory.dart`。
2. 引入 `app_routes.dart` 常量化。
3. `AppNavigator` 改为依赖路由常量，保留兼容 API。

### 阶段 C（2~3 天）- 领域与数据抽象

1. 为设置页创建 `domain` 接口和 usecase。
2. 当前先使用 `fake/local datasource`，后续平滑接真实接口。
3. 补充 domain/data 单测。

### 阶段 D（持续）- 工程治理

1. 接入 lint 规则（import_order、avoid_print）。
2. 替换 `print` 为 `logger`。
3. 增加 CI：`flutter analyze` + `flutter test`。

---

## 7. 当前项目的“就地映射”建议

- `lib/main.dart`
  - 拆成：
    - `app/bootstrap.dart`
    - `app/app.dart`
    - `features/port_info/presentation/pages/port_info_page.dart`
    - `features/port_settings/presentation/pages/port_settings_page.dart`
- `lib/widget/custom_switch.dart`
  - 移到 `features/port_settings/presentation/widgets/custom_image_switch.dart`
- `lib/core/app_navigator.dart`
  - 保留在 `app/router/`（更符合职责）
- `lib/core/immersive_status_bar.dart`
  - 迁移到 `core/utils/immersive_helper.dart`
- `lib/core/app_lifecycle_observer.dart`
  - 迁移到 `app/lifecycle/`

---

## 8. DoD（完成定义）

完成重构后，至少满足：

- [ ] `main.dart` 行数 < 60。
- [ ] 每个 feature 至少具备 `presentation/domain/data` 三层目录。
- [ ] 所有路由名来自 `app_routes.dart` 常量。
- [ ] 无业务逻辑散落在 Widget build 内。
- [ ] 关键功能具备最小测试：
  - [ ] `flutter analyze` 通过
  - [ ] 至少 2 个 domain 单测
  - [ ] 至少 1 个 widget 测试

---

## 9. 命名规范（建议）

- 页面：`xxx_page.dart`
- 组件：`xxx_widget.dart` / `xxx_tile.dart`
- 状态：`xxx_state.dart`
- 控制器：`xxx_controller.dart`
- 用例：`verb_xxx.dart`（如 `get_port_info.dart`）
- 仓库实现：`xxx_repository_impl.dart`

---

## 10. 风险与规避

- **风险：一次性迁移过大导致回归**
  - 规避：按 feature 渐进迁移，保留兼容路由。
- **风险：状态管理混用导致复杂度上升**
  - 规避：选定一种方案并在 ADR 中固化。
- **风险：Native 参数变更影响 Flutter 页面**
  - 规避：统一 native adapter + 参数 schema 校验。
