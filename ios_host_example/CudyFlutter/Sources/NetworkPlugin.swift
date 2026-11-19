import Flutter
import Foundation

/// 与 NativeBridgePlugin 并列，当前使用模拟响应验证网络 Channel。
final class NetworkPlugin {
    static let devices = ["ios-mock-A", "ios-mock-B"]
    // 仅供 Demo 验证错误展示和重试：下一次设备请求失败后自动重置。
    var failNext = false
    private var uptime = 0

    func register(on messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(name: "cudy.network", binaryMessenger: messenger)
        channel.setMethodCallHandler { [self] call, reply in
            let args = call.arguments as? [String: Any]
            let payload: Any
            switch call.method {
            case "deviceRequest":
                guard let device = args?["device"] as? [String: Any],
                      let id = device["device_id"] as? String, Self.devices.contains(id),
                      args?["method"] as? String == "mesh.get_clients" else {
                    reply(FlutterError(code: "INVALID_ARGUMENT", message: "Expected mock device and system.info", details: nil))
                    return
                }
                if failNext {
                    failNext = false
                    reply(FlutterError(code: "DEVICE_REQUEST_FAILED", message: "Simulated device error", details: -1))
                    return
                }
                uptime += 1
                payload = ["revision": "ios-mock", "device": id, "uptime": uptime] as [String: Any]
            case "cloudRequest":
                guard args?["path"] as? String == "device/list" else {
                    reply(FlutterError(code: "INVALID_ARGUMENT", message: "Expected device/list", details: nil))
                    return
                }
                payload = Self.devices.map { ["devid": $0] }
            default:
                reply(FlutterMethodNotImplemented)
                return
            }
            do {
                let data = try JSONSerialization.data(withJSONObject: payload)
                reply(String(decoding: data, as: UTF8.self))
            } catch {
                reply(FlutterError(code: "INVALID_RESPONSE", message: error.localizedDescription, details: nil))
            }
        }
    }
}
