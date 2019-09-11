import UIKit
import SwipeMenuViewController

class PopupViewController: UIViewController {

    var options = SwipeMenuViewOptions() {
        didSet {
            if tabMarginLabel != nil {
                tabMarginLabel.text = "Tab Margin: \(String(format: "%.0f", Float(options.tabView.margin)))"
            }

            if tabItemViewWidthLabel != nil {
                tabItemViewWidthLabel.text = "Tab Item Width: \(String(format: "%.0f", Float(options.tabView.itemView.width)))"
            }
        }
    }
    var dataCount: Int = 0 {
        didSet {
            if dataCountLabel != nil {
                dataCountLabel.text = "Page Number: \(dataCount)"
            }

            if dataCountStepper != nil {
                dataCountStepper.value = Double(dataCount)
            }
        }
    }

    var reloadClosure: (() -> Swift.Void)!

    @IBOutlet weak var dataCountLabel: UILabel!
    @IBOutlet weak var dataCountStepper: UIStepper!
    @IBOutlet weak var tabMarginLabel: UILabel!
    @IBOutlet weak var tabMarginSlider: UISlider!
    @IBOutlet weak var styleSegmentedControl: UISegmentedControl!
    @IBOutlet weak var adjustTabItemLabel: UILabel!
    @IBOutlet weak var adjustTabItemSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tabItemViewWidthLabel: UILabel!
    @IBOutlet weak var tabItemViewWidthSlider: UISlider!
    @IBOutlet weak var tabAdditionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var contentScrolEnabledSegmentedControl: UISegmentedControl!
    @IBOutlet weak var languageDirectionSegmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        dataCountLabel.text = "Page Number: \(dataCount)"

        tabMarginLabel.text = "Tab Margin: \(String(format: "%.0f", Float(options.tabView.margin)))"
        tabMarginSlider.setValue(Float(options.tabView.margin), animated: false)

        dataCountStepper.value = Double(dataCount)

        switch options.tabView.style {
        case .flexible:
            styleSegmentedControl.selectedSegmentIndex = 0
            dataCountStepper.maximumValue = 8
        case .segmented:
            styleSegmentedControl.selectedSegmentIndex = 1
            dataCountStepper.maximumValue = 4
        }

        if options.tabView.needsAdjustItemViewWidth {
            adjustTabItemSegmentedControl.selectedSegmentIndex = 0
        } else {
            adjustTabItemSegmentedControl.selectedSegmentIndex = 1
        }

        adjustTabItemLabel.isHidden = options.tabView.style == .segmented
        adjustTabItemSegmentedControl.isHidden = options.tabView.style == .segmented

        tabItemViewWidthLabel.isHidden = options.tabView.needsAdjustItemViewWidth || options.tabView.style == .segmented
        tabItemViewWidthSlider.isHidden = options.tabView.needsAdjustItemViewWidth || options.tabView.style == .segmented

        tabItemViewWidthSlider.value = Float(options.tabView.itemView.width)
        tabItemViewWidthLabel.text = "Tab Item Width: \(String(format: "%.0f", Float(options.tabView.itemView.width)))"

        switch options.tabView.addition {
        case .underline:
            tabAdditionSegmentedControl.selectedSegmentIndex = 0
        case .circle:
            tabAdditionSegmentedControl.selectedSegmentIndex = 1
        case .none:
            tabAdditionSegmentedControl.selectedSegmentIndex = 2
        }

        if options.contentScrollView.isScrollEnabled {
            contentScrolEnabledSegmentedControl.selectedSegmentIndex = 0
        } else {
            contentScrolEnabledSegmentedControl.selectedSegmentIndex = 1
        }
        
        if options.isLanguageRTL {
            languageDirectionSegmentedControl.selectedSegmentIndex = 1
        } else {
            languageDirectionSegmentedControl.selectedSegmentIndex = 0
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch: UITouch in touches {
            let tag = touch.view!.tag
            if tag == 1 {
                dismiss(animated: true, completion: nil)
            }
        }
    }

    @IBAction func changeOptions(_ sender: UIButton) {
        if let vc = self.presentingViewController as? ViewController {
            vc.options = options
            vc.dataCount = dataCount
        }

        dismiss(animated: true, completion: reloadClosure)
    }

    @IBAction func resetOptions(_ sender: UIButton) {
        if let vc = self.presentingViewController as? ViewController {
            vc.options = SwipeMenuViewOptions()
            vc.dataCount = 5
        }

        dismiss(animated: true, completion: reloadClosure)
    }

    @IBAction func changeDataCount(_ sender: UIStepper) {
        dataCount = Int(sender.value)
    }

    @IBAction func changeTabMargin(_ sender: UISlider) {
        options.tabView.margin = CGFloat(sender.value)
    }

    @IBAction func changeStyle(_ sender: UISegmentedControl) {

        switch sender.selectedSegmentIndex {
        case 0:
            options.tabView.style = .flexible
            dataCountStepper.maximumValue = 8
        case 1:
            options.tabView.style = .segmented
            dataCountStepper.maximumValue = 4
            if dataCount > 4 {
                dataCount = 4
            }
        default:
            break
        }

        adjustTabItemLabel.isHidden = options.tabView.style == .segmented
        adjustTabItemSegmentedControl.isHidden = options.tabView.style == .segmented

        tabItemViewWidthLabel.isHidden = options.tabView.needsAdjustItemViewWidth || options.tabView.style == .segmented
        tabItemViewWidthSlider.isHidden = options.tabView.needsAdjustItemViewWidth || options.tabView.style == .segmented
    }

    @IBAction func changeAdjustTabItemWidthEnabled(_ sender: UISegmentedControl) {

        switch sender.selectedSegmentIndex {
        case 0:
            options.tabView.needsAdjustItemViewWidth = true
        case 1:
            options.tabView.needsAdjustItemViewWidth = false
        default:
            break
        }

        tabItemViewWidthLabel.isHidden = options.tabView.needsAdjustItemViewWidth || options.tabView.style == .segmented
        tabItemViewWidthSlider.isHidden = options.tabView.needsAdjustItemViewWidth || options.tabView.style == .segmented
    }

    @IBAction func changeTabItemWidthSlider(_ sender: UISlider) {
        options.tabView.itemView.width = CGFloat(sender.value)
    }

    @IBAction func changeTabAddition(_ sender: UISegmentedControl) {

        switch sender.selectedSegmentIndex {
        case 0:
            options.tabView.addition = .underline
            options.tabView.itemView.selectedTextColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        case 1:
            options.tabView.addition = .circle
            options.tabView.itemView.selectedTextColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        case 2:
            options.tabView.addition = .none
            options.tabView.itemView.selectedTextColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        default:
            break
        }
    }

    @IBAction func changeContentScrollEnabled(_ sender: UISegmentedControl) {

        switch sender.selectedSegmentIndex {
        case 0:
            options.contentScrollView.isScrollEnabled = true
        case 1:
            options.contentScrollView.isScrollEnabled = false
        default:
            break
        }
    }
   
    @IBAction func changeLanguageDirection(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            options.isLanguageRTL = false
        case 1:
            options.isLanguageRTL = true
        default:
            break
        }
    }
}
