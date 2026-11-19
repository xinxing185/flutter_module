import Flutter
import Foundation

final class NativeBridgePlugin {
    func register(on messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(name: "com.example.flutter_module/native_bridge",
                                           binaryMessenger: messenger)
        channel.setMethodCallHandler { call, reply in
            NSLog("NativeBridgePlugin method=%@ arguments=%@", call.method, String(describing: call.arguments))
            if call.method == "onFlutterRouteReady" {
                reply("onFlutterRouteReady received")
            } else {
                reply(FlutterError(code: "22", message: "error call 2", details: nil))
            }
        }
    }
}
