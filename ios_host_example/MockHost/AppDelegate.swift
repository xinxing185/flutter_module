import UIKit
import CudyFlutter

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private var flutter: FlutterModuleHelper?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions options: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let home = HelloWorldViewController()
        let navigation = UINavigationController(rootViewController: home)
        navigation.setNavigationBarHidden(true, animated: false)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigation
        self.window = window
        window.makeKeyAndVisible()
        let flutter = FlutterModuleHelper(
            application: application,
            navigation: navigation,
            readHostUiConfig: { [weak navigation] in
                let traits = navigation?.visibleViewController?.traitCollection ?? navigation?.traitCollection
                return HostUiConfig(
                    localeTag: Locale.preferredLanguages.first ?? "en",
                    // Flutter 按系统 Dynamic Type 缩放，MockHost 没有独立字号设置。
                    fontScale: nil,
                    highContrast: traits?.accessibilityContrast == .high,
                    colorMode: traits?.userInterfaceStyle == .dark ? "dark" : "light"
                )
            },
            openHostRoute: AppRouter.open
        )
        self.flutter = flutter
        home.flutterModule = flutter
        return true
    }
}
