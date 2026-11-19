import flutter_boost

/// 独立容器由 FlutterBoost 管理引擎附着与页面生命周期。
enum FlutterPageViewController {
    static func make(options: FlutterBoostRouteOptions) -> FBFlutterViewContainer {
        // 直接调用 Boost 的 init，确保绑定 setup 创建并注册插件的共享引擎。
        let page = FBFlutterViewContainer()!
        page.setName(options.pageName, uniqueId: options.uniqueId,
                     params: options.arguments, opaque: options.opaque)
        return page
    }
}
