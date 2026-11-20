import UIKit
import CudyFlutter

final class HelloWorldViewController: UIViewController {
    var flutterModule: FlutterModuleHelper?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let title = UILabel()
        title.text = "Hello World"
        title.font = .preferredFont(forTextStyle: .largeTitle)
        title.adjustsFontForContentSizeCategory = true
        title.textAlignment = .center
        let menu = UIStackView(arrangedSubviews: [title])
        menu.axis = .vertical
        menu.spacing = 16
        menu.translatesAutoresizingMaskIntoConstraints = false
        let entries = [
            ("Flutter Demo", "open-flutter-demo", #selector(openDemo)),
            ("Device API Test", "open-device-api-test", #selector(openDeviceApiTest)),
            ("Suggestions & Feedback", "open-feedback", #selector(openFeedback))
        ]
        for (title, identifier, action) in entries {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.accessibilityIdentifier = identifier
            button.addTarget(self, action: action, for: .touchUpInside)
            menu.addArrangedSubview(button)
        }
        view.addSubview(menu)
        NSLayoutConstraint.activate([
            menu.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            menu.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            menu.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            menu.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }

    @objc private func openDemo() {
        openDevicePage("flutterDemo", extras: ["source": "ios mock"])
    }

    @objc private func openDeviceApiTest() {
        openDevicePage("deviceApiTest", extras: ["enableNotification": true])
    }

    @objc private func openFeedback() {
        flutterModule?.openFlutterPage("feedback", arguments: [:])
    }

    private func openDevicePage(_ route: String, extras: [String: Any]) {
        var arguments = extras
        arguments["device"] = [
            "device_version": "ios-mock",
            "device_id": "ios-mock-A",
            "device_cloud_id": NSNull(),
            "device_cloud_bind_type": 0,
            "device_mac": "00:00:00:00:00:01",
            "device_name": "ios-mock-A",
            "device_host": "mock",
            "device_mode": 0,
            "device_workmode": "router",
            "device_model": "iOS Mock",
            "device_rom": "mock",
            "device_hardware": "1.0",
            "device_msg_though_by_sys": false
        ]
        flutterModule?.openFlutterPage(route, arguments: arguments)
    }
}
