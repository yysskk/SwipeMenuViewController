import SwiftUI
import SwipeMenuViewController
import UIKit

/// The example's root screen.
///
/// A ``SwipeMenuViewController`` whose pages come from a fixed list of names, with a
/// floating button that presents the live ``OptionsViewController``. Changing an
/// option rebuilds the menu through `SwipeMenuView.reloadData(options:default:)`.
/// A second floating button presents ``SwiftUIMenuView``, the same demo built on
/// the SwiftUI ``SwipeMenu``.
final class MenuViewController: SwipeMenuViewController {

    private let pageTitles = [
        "Bulbasaur", "Caterpie", "Golem", "Jynx",
        "Marshtomp", "Salamence", "Riolu", "Araquanid",
    ]

    private var settings = SwipeMenuSettings()

    private lazy var settingsButton: UIButton = {
        // A prominent Liquid Glass button that floats over the paging content and
        // refracts what scrolls beneath it.
        var configuration = UIButton.Configuration.prominentGlass()
        configuration.image = UIImage(systemName: "gearshape")
        configuration.cornerStyle = .capsule
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        let button = UIButton(
            configuration: configuration,
            primaryAction: UIAction { [weak self] _ in
                self?.presentOptions()
            })
        button.accessibilityLabel = "Options"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var swiftUIButton: UIButton = {
        var configuration = UIButton.Configuration.glass()
        configuration.image = UIImage(systemName: "swift")
        configuration.cornerStyle = .capsule
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        let button = UIButton(
            configuration: configuration,
            primaryAction: UIAction { [weak self] _ in
                self?.presentSwiftUIExample()
            })
        button.accessibilityLabel = "SwiftUI Example"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private static let settingsButtonDiameter: CGFloat = 56

    override func viewDidLoad() {
        for pageTitle in pageTitles {
            addChild(PageViewController(title: pageTitle))
        }

        super.viewDidLoad()

        // The tab bar and content area are transparent, so the container view shows
        // through behind them and in the status-bar inset — give it a backdrop that
        // adapts to light and dark.
        view.backgroundColor = .systemBackground

        // The container sets the menu up with default options; apply ours so the
        // initial appearance matches `settings` (including dark-mode colors).
        swipeMenuView.reloadData(options: settings.makeOptions())
        setUpFloatingButtons()
    }

    // MARK: - SwipeMenuViewDataSource

    override func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        settings.pageCount
    }

    // MARK: - Options

    private func setUpFloatingButtons() {
        view.addSubview(settingsButton)
        view.addSubview(swiftUIButton)
        NSLayoutConstraint.activate([
            settingsButton.widthAnchor.constraint(equalToConstant: Self.settingsButtonDiameter),
            settingsButton.heightAnchor.constraint(equalToConstant: Self.settingsButtonDiameter),
            settingsButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            settingsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            swiftUIButton.widthAnchor.constraint(equalToConstant: Self.settingsButtonDiameter),
            swiftUIButton.heightAnchor.constraint(equalToConstant: Self.settingsButtonDiameter),
            swiftUIButton.centerXAnchor.constraint(equalTo: settingsButton.centerXAnchor),
            swiftUIButton.bottomAnchor.constraint(equalTo: settingsButton.topAnchor, constant: -12),
        ])
    }

    private func presentOptions() {
        let optionsViewController = OptionsViewController(settings: settings)
        optionsViewController.onChange = { [weak self] settings in
            self?.apply(settings)
        }

        let navigationController = UINavigationController(rootViewController: optionsViewController)
        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(navigationController, animated: true)
    }

    private func presentSwiftUIExample() {
        let hostingController = UIHostingController(rootView: SwiftUIMenuView())
        hostingController.modalPresentationStyle = .fullScreen
        present(hostingController, animated: true)
    }

    private func apply(_ settings: SwipeMenuSettings) {
        self.settings = settings
        // Keep the visible page in range if the page count shrank.
        let index = min(max(swipeMenuView.currentIndex, 0), settings.pageCount - 1)
        swipeMenuView.reloadData(options: settings.makeOptions(), default: index)
    }
}
