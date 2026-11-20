import UIKit

final class DeviceDetailViewController: UIViewController {
    private let arguments: [String: Any]
    private var onReturn: (() -> Void)?
    private weak var routeNavigation: UINavigationController?

    init(arguments: [String: Any], onReturn: @escaping () -> Void) {
        self.arguments = arguments
        self.onReturn = onReturn
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let back = UIButton(type: .system)
        back.setTitle("Back", for: .normal)
        back.accessibilityIdentifier = "native-device-detail-back"
        back.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        back.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true

        let title = UILabel()
        title.text = "Native Device Details"
        title.font = .preferredFont(forTextStyle: .title2)
        title.adjustsFontForContentSizeCategory = true
        title.numberOfLines = 0
        title.accessibilityTraits.insert(.header)

        let fields = [
            ("Name", string("device_name")),
            ("ID", string("device_id")),
            ("Model", string("device_model_with_version") ?? string("device_model")),
            ("MAC", string("device_mac")),
            ("Version", string("device_version")),
            ("Host", string("device_host"))
        ]
        let details = fields.compactMap { name, value -> UILabel? in
            guard let value = value else { return nil }
            let label = UILabel()
            label.text = "\(name): \(value)"
            label.font = .preferredFont(forTextStyle: .body)
            label.adjustsFontForContentSizeCategory = true
            label.numberOfLines = 0
            return label
        }
        let stack = UIStackView(arrangedSubviews: [back, title] + details)
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        view.addSubview(scroll)
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -12),
            stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor, constant: -16),
            stack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -32)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        routeNavigation = navigationController
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 被其他页面覆盖时仍在导航栈内，只有确实退出时才结束本次路由。
        guard routeNavigation?.viewControllers.contains(where: { $0 === self }) != true else { return }
        let completion = onReturn
        onReturn = nil
        completion?()
    }

    private func string(_ key: String) -> String? {
        guard let value = arguments[key] as? String, !value.isEmpty else { return nil }
        return value
    }

    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }
}
