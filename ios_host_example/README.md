# iOS Mock 宿主

从 Flutter 模块根目录执行以下命令。需要完整 Xcode、已安装的 iOS Simulator runtime 和 CocoaPods。

```sh
flutter pub get
cd ios_host_example
pod install
open MockHost.xcworkspace
```

如果 Xcode 命令行当前指向 Command Line Tools，在终端中先执行 `export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`。在 Xcode 选择 MockHost Scheme 和一个 iPhone 模拟器后运行。

UIKit 首页保留三个测试入口。

- **Flutter Demo** 打开 `flutterDemo`。点 Open Native Device Details 可通过 `native/deviceDetail` 打开 UIKit 设备详情，返回后回到 Flutter Demo。Open Unknown Flutter Page 用于查看未知路由页。
- **Device API Test** 打开 `deviceApiTest`，与 Flutter Demo 共用模拟设备。可输入任意非空 method 并点 Run。iOS 模拟响应会返回设备 ID、版本和递增的 uptime。
- **Suggestions & Feedback** 打开 `feedback`，用于测试建议与反馈页。

`NetworkPlugin` 在 FlutterBoost 使用的引擎上处理 `cudy.network`，支持 `deviceRequest` 和 `cloudRequest/device/list`，返回 JSON 字符串。可用 Xcode 的 Product → Test 验证原生详情往返、自定义 method 和反馈入口。

`NativeBridgePlugin` 处理 `getHostUiConfig` 和 `onFlutterRouteReady`。MockHost 从首选语言和当前可见页面的 trait 读取语言、高对比度及颜色模式。字号由 Flutter 继续跟随系统 Dynamic Type。

## 文件职责与迁移

- `MockHost/AppDelegate.swift` 创建窗口和原生导航栈，并持有 Flutter 接入对象。
- `MockHost/AppRouter.swift` 处理原生路由，合并设备和额外参数后打开 UIKit 设备详情。
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

flutter = FlutterModuleHelper(
    application: UIApplication.shared,
    navigation: navigationController,
    readHostUiConfig: readHostUiConfig,
    openHostRoute: AppRouter.open
)
flutter?.openFlutterPage("flutterDemo", arguments: ["source": "ios mock", "device": [
    "device_id": "ios-mock-A",
    "device_mode": 0,
    "device_model": "iOS Mock"
]])
```

迁移时将 `readHostUiConfig` 接到宿主的设置来源，将 `AppRouter.open` 换成宿主的页面分发入口。原生页面退出时调用 `onReturn`，用于结束 FlutterBoost 对本次跳转的等待。网络接入正式 iOS 项目时替换包内 NetworkPlugin 的模拟处理逻辑，继续返回相同的 JSON 字符串或 FlutterError。`openFlutterPage` 的 `failOnce` 仅用于 Mock 错误重试测试。

当前 Flutter beta 的构建脚本在空 Dart define 下会报错，因此示例 Target 设置了编码后的 `IOS_MOCK=1`。这是示例宿主构建项，迁移时根据实际 Flutter SDK 验证。

当前 Flutter SDK 与 Boost 4.6.5 组合在默认临时视图预热后出现首次进入黑屏。helper 设置 `warmUpEngine = false`，仍在启动时运行 Dart 引擎，但在真实容器打开时附着视图。初始化发生在原生窗口显示之后。独立重开 Flutter 容器时，XCTest 可能取不到第二次进入的 Flutter 辅助功能节点，因此三个入口的 UI 用例分别启动宿主。
