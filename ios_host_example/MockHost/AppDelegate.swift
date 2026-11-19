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
        let flutter = FlutterModuleHelper(application: application, navigation: navigation)
        self.flutter = flutter
        home.flutterModule = flutter
        return true
    }
}
