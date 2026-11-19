# iOS Mock 宿主

从 Flutter 模块根目录执行以下命令。需要完整 Xcode、已安装的 iOS Simulator runtime 和 CocoaPods。

```sh
flutter pub get
cd ios_host_example
pod install
open MockHost.xcworkspace
```

如果 Xcode 命令行当前指向 Command Line Tools，在终端中先执行 `export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`。在 Xcode 选择 MockHost Scheme 和一个 iPhone 模拟器后运行。

启动后显示 UIKit 的 Hello World 首页。两个 Open Flutter 按钮通过独立的 `FlutterPageViewController` 打开共享 Dart 路由 `portSettings`。首次加载显示模拟设备 ID、版本和计数，Refresh 会增加 uptime。Flutter 左上角返回按钮回到 Hello World。返回后打开另一台设备可验证参数切换。第三个按钮只让下一次设备请求失败，点 Retry 可恢复。

`NetworkPlugin` 在 FlutterBoost 使用的引擎上处理 `cudy.network`，支持当前 Dart 测试页使用的 `deviceRequest/mesh.get_clients` 和 `cloudRequest/device/list`。返回值为 JSON 字符串。UI 测试覆盖设备请求、刷新、返回、设备切换和错误恢复，可用 Xcode 的 Product → Test 执行。

设备入口额外传 `source: "ios mock"` 和 `enableNotification: true`。Open portInfo 传 `source: "demo page"`；Open mainPage 传 `data: "main data"`。当前共享 Dart 路由表尚未注册 mainPage，因此该按钮会进入现有未知路由页面，与 Android 的同名调用一致。NativeBridgePlugin 在 Xcode 控制台打印 Flutter 方法和参数，onFlutterRouteReady 返回与 Android 相同的确认字符串。

## 文件职责与迁移

- `MockHost/AppDelegate.swift` 创建窗口和原生导航栈，并持有 Flutter 接入对象。
- `MockHost/HelloWorldViewController.swift` 是 UIKit 首页，直接调用统一入口打开 Flutter。
- `CudyFlutter/Sources/FlutterModuleHelper.swift` 是包的公开入口，初始化 FlutterBoost、注册 Channel，并处理原生容器 push/pop。
- `CudyFlutter/Sources/FlutterPageViewController.swift` 是独立 Flutter 容器创建入口。
- 容器创建入口直接创建 Boost 的 `FBFlutterViewContainer`，复用已经注册 Channel 的引擎。
- `CudyFlutter/Sources/NetworkPlugin.swift` 实现当前模拟网络协议，与 `NativeBridgePlugin.swift` 并列。

迁移到已有 iOS 项目时，先按本示例 Podfile 接入共享 Flutter 模块，再添加本地 Pod。CudyFlutter 编译为独立 Swift 模块，源码不需要加入宿主 Target。可整体复制 CudyFlutter 文件夹并调整路径。宿主强持有一个 FlutterModuleHelper，初始化时传入宿主的 UIApplication 与 UINavigationController。已有 SceneDelegate 的应用应在 Scene 创建并显示窗口、导航栈后初始化。

```ruby
target 'YourApp' do
  use_frameworks!
  install_all_flutter_pods(module_path)
  pod 'CudyFlutter', :path => File.join(module_path, 'ios_host_example', 'CudyFlutter')
end
```

```swift
import CudyFlutter

flutter = FlutterModuleHelper(application: UIApplication.shared, navigation: navigationController)
flutter?.openFlutterPage("portSettings", arguments: ["source": "ios mock", "enableNotification": true, "device": [
    "device_id": "ios-mock-A",
    "device_mode": 0,
    "device_model": "iOS Mock"
]])
```

Demo 的 HelloWorldViewController 展示了完整的 13 个设备字段和按钮调用，AppDelegate 仅负责窗口与模块初始化。网络接入正式 iOS 项目时替换包内 NetworkPlugin 的模拟处理逻辑，继续返回相同的 JSON 字符串或 FlutterError。openFlutterPage 的 failOnce 参数仅供当前 Mock 错误重试测试使用。此示例支持 UINavigationController 的 push/pop；需要打开业务原生页面时，在 helper 的 pushNativeRoute 中接入宿主页面映射。

当前 Flutter beta 的构建脚本在空 Dart define 下会报错，因此示例 Target 设置了编码后的 `IOS_MOCK=1`。这是示例宿主构建项，迁移时根据实际 Flutter SDK 验证。

当前 Flutter SDK 与 Boost 4.6.5 组合在默认临时视图预热后出现首次进入黑屏。helper 设置 `warmUpEngine = false`，仍在启动时运行 Dart 引擎，但在真实容器打开时附着视图。初始化发生在原生窗口显示之后。首次加载和刷新已通过 UI 断言；再次进入时截图已显示新设备数据，但 XCTest 未取得辅助功能节点，完整 UI 测试仍未通过。
