import UIKit

enum AppRouter {
    static let deviceDetail = "native/deviceDetail"

    @discardableResult
    static func open(_ navigation: UINavigationController,
                     _ route: String,
                     _ arguments: [AnyHashable: Any],
                     _ onReturn: @escaping () -> Void = {}) -> Bool {
        switch route {
        case deviceDetail:
            let page = DeviceDetailViewController(arguments: routeArguments(arguments), onReturn: onReturn)
            navigation.pushViewController(page, animated: true)
            return true
        default:
            return false
        }
    }

    private static func routeArguments(_ arguments: [AnyHashable: Any]) -> [String: Any] {
        var fields = arguments["device"] as? [String: Any] ?? [:]
        // 与 Android 一致，顶层定制参数覆盖同名设备字段。
        for (key, value) in arguments {
            if let key = key as? String, key != "device" {
                fields[key] = value
            }
        }
        return fields
    }
}
