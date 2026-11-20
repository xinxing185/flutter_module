import Flutter
import UIKit
import flutter_boost

/// 宿主持有此对象，传入自己的导航栈即可打开共享 Flutter 页面。
public final class FlutterModuleHelper: NSObject, FlutterBoostDelegate {
    public typealias OpenHostRoute =
        (UINavigationController, String, [AnyHashable: Any], @escaping () -> Void) -> Bool

    private weak var navigation: UINavigationController?
    private let network = NetworkPlugin()
    private let openHostRoute: OpenHostRoute

    public init(application: UIApplication,
                navigation: UINavigationController,
                readHostUiConfig: @escaping () -> HostUiConfig,
                openHostRoute: @escaping OpenHostRoute) {
        self.navigation = navigation
        self.openHostRoute = openHostRoute
        super.init()
        let options = FlutterBoostSetupOptions.createDefault()!
        options.warmUpEngine = false
        FlutterBoost.instance().setup(application, delegate: self, callback: { [weak self] engine in
            guard let engine = engine else { return }
            self?.network.register(on: engine.binaryMessenger)
            NativeBridgePlugin().register(on: engine.binaryMessenger, readHostUiConfig: readHostUiConfig)
        }, options: options)
    }

    public func openFlutterPage(_ route: String, arguments: [String: Any], failOnce: Bool = false) {
        network.failNext = failOnce
        let options = FlutterBoostRouteOptions()
        options.pageName = route
        options.arguments = arguments
        options.opaque = true
        FlutterBoost.instance().open(options)
    }

    public func pushFlutterRoute(_ options: FlutterBoostRouteOptions!) {
        guard let navigation = navigation else {
            options.completion?(false)
            return
        }
        let page = FlutterPageViewController.make(options: options)
        navigation.pushViewController(page, animated: true)
        options.completion?(true)
    }

    public func popRoute(_ options: FlutterBoostRouteOptions!) {
        guard let navigation = navigation,
              let page = navigation.topViewController as? FBFlutterViewContainer,
              page.uniqueIDString() == options.uniqueId else {
            options.completion?(false)
            return
        }
        navigation.popViewController(animated: true)
        options.completion?(true)
    }

    public func pushNativeRoute(_ pageName: String!, arguments: [AnyHashable: Any]!) {
        guard let pageName = pageName else { return }
        // 原生页返回后结束 FlutterBoost 的等待，演示页无需业务返回值。
        let onReturn = {
            FlutterBoost.instance().sendResultToFlutter(withPageName: pageName, arguments: [:])
        }
        guard let navigation = navigation,
              openHostRoute(navigation, pageName, arguments ?? [:], onReturn) else {
            NSLog("FlutterModuleHelper could not open native route %@", pageName)
            onReturn()
            return
        }
    }
}
