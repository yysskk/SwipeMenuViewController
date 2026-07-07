import UIKit

/// A form that edits a ``SwipeMenuSettings`` and reports every change back through
/// ``onChange`` so the menu behind it can update live.
///
/// The controller is presented inside a `UINavigationController` sheet. It owns a
/// working copy of the settings; each control mutates that copy and calls
/// ``onChange``, and **Reset** restores the defaults.
final class OptionsViewController: UIViewController {

    /// Called whenever the settings change, including on **Reset**.
    var onChange: ((SwipeMenuSettings) -> Void)?

    private var settings: SwipeMenuSettings

    private let pageCountStepper = UIStepper()
    private let pageCountValueLabel = UILabel()
    private let styleControl = UISegmentedControl(items: ["Flexible", "Segmented"])
    private let decorationControl = UISegmentedControl(items: ["Underline", "Circle", "None"])
    private let adjustWidthSwitch = UISwitch()
    private let itemWidthSlider = UISlider()
    private let itemWidthValueLabel = UILabel()
    private let tabMarginSlider = UISlider()
    private let tabMarginValueLabel = UILabel()
    private let contentScrollSwitch = UISwitch()

    /// Hidden when the segmented style is active (it always fills the width).
    private var adjustWidthRow: UIView!
    /// Hidden when tabs auto-size or the segmented style is active.
    private var itemWidthRow: UIView!

    /// Creates the editor seeded with `settings`.
    /// - Parameter settings: The settings to start from.
    init(settings: SwipeMenuSettings) {
        self.settings = settings
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Options"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .done,
            primaryAction: UIAction { [weak self] _ in self?.dismiss(animated: true) }
        )
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Reset",
            primaryAction: UIAction { [weak self] _ in self?.reset() }
        )

        setUpLayout()
        setUpActions()
        updateControls()
    }

    // MARK: - Layout

    private func setUpLayout() {
        pageCountStepper.minimumValue = Double(SwipeMenuSettings.minimumPageCount)
        pageCountStepper.stepValue = 1
        itemWidthSlider.minimumValue = 80
        itemWidthSlider.maximumValue = 300
        tabMarginSlider.minimumValue = 0
        tabMarginSlider.maximumValue = 20

        adjustWidthRow = makeToggleRow(title: "Adjust tab width to fit", toggle: adjustWidthSwitch)
        itemWidthRow = makeSliderRow(title: "Tab width", valueLabel: itemWidthValueLabel, slider: itemWidthSlider)

        let rows: [UIView] = [
            makeStepperRow(title: "Pages", valueLabel: pageCountValueLabel, stepper: pageCountStepper),
            makeSegmentedRow(title: "Style", control: styleControl),
            makeSegmentedRow(title: "Tab decoration", control: decorationControl),
            adjustWidthRow,
            itemWidthRow,
            makeSliderRow(title: "Tab margin", valueLabel: tabMarginValueLabel, slider: tabMarginSlider),
            makeToggleRow(title: "Swipe between pages", toggle: contentScrollSwitch),
        ]

        let contentStack = UIStackView(arrangedSubviews: rows)
        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.directionalLayoutMargins = .init(top: 24, leading: 20, bottom: 24, trailing: 20)
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])
    }

    // MARK: - Actions

    private func setUpActions() {
        pageCountStepper.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                settings.pageCount = Int(pageCountStepper.value)
                pageCountValueLabel.text = "\(settings.pageCount)"
                notifyChange()
            }, for: .valueChanged)

        styleControl.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                settings.setStyle(styleControl.selectedSegmentIndex == 0 ? .flexible : .segmented)
                updateControls()
                notifyChange()
            }, for: .valueChanged)

        decorationControl.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                settings.tabDecoration = SwipeMenuSettings.TabDecoration.allCases[decorationControl.selectedSegmentIndex]
                notifyChange()
            }, for: .valueChanged)

        adjustWidthSwitch.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                settings.adjustsItemWidthToFit = adjustWidthSwitch.isOn
                updateControls()
                notifyChange()
            }, for: .valueChanged)

        itemWidthSlider.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                settings.itemWidth = CGFloat(itemWidthSlider.value)
                itemWidthValueLabel.text = Self.format(settings.itemWidth)
            }, for: .valueChanged)
        itemWidthSlider.addAction(UIAction { [weak self] _ in self?.notifyChange() }, for: [.touchUpInside, .touchUpOutside])

        tabMarginSlider.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                settings.tabMargin = CGFloat(tabMarginSlider.value)
                tabMarginValueLabel.text = Self.format(settings.tabMargin)
            }, for: .valueChanged)
        tabMarginSlider.addAction(UIAction { [weak self] _ in self?.notifyChange() }, for: [.touchUpInside, .touchUpOutside])

        contentScrollSwitch.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                settings.isContentScrollEnabled = contentScrollSwitch.isOn
                notifyChange()
            }, for: .valueChanged)
    }

    private func reset() {
        settings = SwipeMenuSettings()
        updateControls()
        notifyChange()
    }

    private func notifyChange() {
        onChange?(settings)
    }

    /// Pushes every value from ``settings`` into the controls and refreshes which
    /// rows are visible.
    private func updateControls() {
        pageCountStepper.maximumValue = Double(settings.maximumPageCount)
        pageCountStepper.value = Double(settings.pageCount)
        pageCountValueLabel.text = "\(settings.pageCount)"

        styleControl.selectedSegmentIndex = settings.style == .flexible ? 0 : 1
        decorationControl.selectedSegmentIndex = SwipeMenuSettings.TabDecoration.allCases.firstIndex(of: settings.tabDecoration) ?? 0

        adjustWidthSwitch.isOn = settings.adjustsItemWidthToFit
        itemWidthSlider.value = Float(settings.itemWidth)
        itemWidthValueLabel.text = Self.format(settings.itemWidth)

        tabMarginSlider.value = Float(settings.tabMargin)
        tabMarginValueLabel.text = Self.format(settings.tabMargin)

        contentScrollSwitch.isOn = settings.isContentScrollEnabled

        adjustWidthRow.isHidden = settings.style == .segmented
        itemWidthRow.isHidden = settings.style == .segmented || settings.adjustsItemWidthToFit
    }

    private static func format(_ value: CGFloat) -> String {
        String(format: "%.0f", Double(value))
    }

    // MARK: - Row builders

    private func makeStepperRow(title: String, valueLabel: UILabel, stepper: UIStepper) -> UIStackView {
        configureValueLabel(valueLabel)
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)
        let row = UIStackView(arrangedSubviews: [makeTitleLabel(title), valueLabel, stepper])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center
        return row
    }

    private func makeToggleRow(title: String, toggle: UISwitch) -> UIStackView {
        let row = UIStackView(arrangedSubviews: [makeTitleLabel(title), toggle])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center
        return row
    }

    private func makeSegmentedRow(title: String, control: UISegmentedControl) -> UIStackView {
        let row = UIStackView(arrangedSubviews: [makeTitleLabel(title), control])
        row.axis = .vertical
        row.spacing = 8
        return row
    }

    private func makeSliderRow(title: String, valueLabel: UILabel, slider: UISlider) -> UIStackView {
        configureValueLabel(valueLabel)
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)
        let header = UIStackView(arrangedSubviews: [makeTitleLabel(title), valueLabel])
        header.axis = .horizontal
        header.spacing = 12
        let row = UIStackView(arrangedSubviews: [header, slider])
        row.axis = .vertical
        row.spacing = 8
        return row
    }

    private func makeTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .label
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }

    private func configureValueLabel(_ label: UILabel) {
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .right
    }
}
