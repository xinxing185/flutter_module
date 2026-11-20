import Flutter
import Foundation

public struct HostUiConfig {
    public let localeTag: String
    public let fontScale: Double?
    public let highContrast: Bool
    public let colorMode: String

    public init(localeTag: String, fontScale: Double?, highContrast: Bool, colorMode: String) {
        self.localeTag = localeTag
        self.fontScale = fontScale
        self.highContrast = highContrast
        self.colorMode = colorMode
    }

    fileprivate var channelValue: [String: Any] {
        [
            "localeTag": localeTag,
            "fontScale": fontScale.map { $0 as Any } ?? NSNull(),
            "highContrast": highContrast,
            "colorMode": colorMode
        ]
    }
}

final class NativeBridgePlugin {
    func register(on messenger: FlutterBinaryMessenger, readHostUiConfig: @escaping () -> HostUiConfig) {
        let channel = FlutterMethodChannel(name: "com.example.flutter_module/native_bridge",
                                           binaryMessenger: messenger)
        channel.setMethodCallHandler { call, reply in
            switch call.method {
            case "getHostUiConfig":
                reply(readHostUiConfig().channelValue)
            case "onFlutterRouteReady":
                NSLog("NativeBridgePlugin method=%@ arguments=%@", call.method, String(describing: call.arguments))
                reply("onFlutterRouteReady received")
            default:
                reply(FlutterMethodNotImplemented)
            }
        }
    }
}
