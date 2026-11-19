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
        for id in ["ios-mock-A", "ios-mock-B"] {
            let button = UIButton(type: .system)
            button.setTitle("Open Flutter · " + id, for: .normal)
            button.accessibilityIdentifier = id
            button.addTarget(self, action: #selector(openDevice(_:)), for: .touchUpInside)
            menu.addArrangedSubview(button)
        }
        let fail = UIButton(type: .system)
        fail.setTitle("Test Flutter error and retry", for: .normal)
        fail.accessibilityIdentifier = "open-error"
        fail.addTarget(self, action: #selector(openFailure), for: .touchUpInside)
        menu.addArrangedSubview(fail)
        let portInfo = UIButton(type: .system)
        portInfo.setTitle("Open mainPage", for: .normal)
        portInfo.addTarget(self, action: #selector(openPortInfo), for: .touchUpInside)
        menu.addArrangedSubview(portInfo)
        let mainPage = UIButton(type: .system)
        mainPage.setTitle("Open errorPage", for: .normal)
        mainPage.addTarget(self, action: #selector(openMainPage), for: .touchUpInside)
        menu.addArrangedSubview(mainPage)
        view.addSubview(menu)
        NSLayoutConstraint.activate([
            menu.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            menu.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            menu.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            menu.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }

    @objc private func openDevice(_ button: UIButton) {
        guard let id = button.accessibilityIdentifier else { return }
        openDevicePage(id)
    }

    @objc private func openFailure() { openDevicePage("ios-mock-A", failOnce: true) }

    private func openDevicePage(_ id: String, failOnce: Bool = false) {
        flutterModule?.openFlutterPage("portSettings", arguments: [
            "source": "ios mock",
            "enableNotification": true,
            "device": [
                "device_version": "ios-mock",
                "device_id": id,
                "device_cloud_id": NSNull(),
                "device_cloud_bind_type": 0,
                "device_mac": "00:00:00:00:00:01",
                "device_name": id,
                "device_host": "mock",
                "device_mode": 0,
                "device_workmode": "router",
                "device_model": "iOS Mock",
                "device_rom": "mock",
                "device_hardware": "1.0",
                "device_msg_though_by_sys": false
            ]
        ], failOnce: failOnce)
    }

    @objc private func openPortInfo() {
        flutterModule?.openFlutterPage("portInfo", arguments: ["source": "ios demo"])
    }

    @objc private func openMainPage() {
        flutterModule?.openFlutterPage("mainPage", arguments: ["data": "main data"])
    }
}
