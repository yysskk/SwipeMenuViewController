
import UIKit
import SwipeMenuViewController

class PopupViewController: UIViewController {

    var options = SwipeMenuViewOptions()
    var reloadClosure: (() -> Swift.Void)!

    @IBOutlet weak var styleSegmentedControl: UISegmentedControl!
    @IBOutlet weak var adjustTabItemSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tabItemViewWidthSlider: UISlider!
    @IBOutlet weak var tabAdditionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var contentScrolEnabledSegmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        switch options.tabView.style {
        case .flexible:
            styleSegmentedControl.selectedSegmentIndex = 0
        case .segmented:
            styleSegmentedControl.selectedSegmentIndex = 1
        }

        if options.tabView.isAdjustItemViewWidth {
            adjustTabItemSegmentedControl.selectedSegmentIndex = 0
        } else {
            adjustTabItemSegmentedControl.selectedSegmentIndex = 1
        }

        tabItemViewWidthSlider.value = Float(options.tabView.itemView.width)
        
        switch options.tabView.addition {
        case .underline:
            tabAdditionSegmentedControl.selectedSegmentIndex = 0
        case .none:
            tabAdditionSegmentedControl.selectedSegmentIndex = 1
        }

        if options.contentScrollView.isScrollEnabled {
            contentScrolEnabledSegmentedControl.selectedSegmentIndex = 0
        } else {
            contentScrolEnabledSegmentedControl.selectedSegmentIndex = 1
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
        }

        dismiss(animated: true, completion: reloadClosure)
    }

    @IBAction func resetOptions(_ sender: UIButton) {
        if let vc = self.presentingViewController as? ViewController {
            vc.options = SwipeMenuViewOptions()
        }

        dismiss(animated: true, completion: reloadClosure)
    }

    @IBAction func changeStyle(_ sender: UISegmentedControl) {

        switch sender.selectedSegmentIndex {
        case 0:
            options.tabView.style = .flexible
        case 1:
            options.tabView.style = .segmented
        default:
            break
        }
    }

    @IBAction func changeAdjustTabItemWidthEnabled(_ sender: UISegmentedControl) {

        switch sender.selectedSegmentIndex {
        case 0:
            options.tabView.isAdjustItemViewWidth = true
        case 1:
            options.tabView.isAdjustItemViewWidth = false
        default:
            break
        }
    }

    @IBAction func changeTabItemWidthSlider(_ sender: UISlider) {
        options.tabView.itemView.width = CGFloat(sender.value)
    }

    @IBAction func changeTabAddition(_ sender: UISegmentedControl) {

        switch sender.selectedSegmentIndex {
        case 0:
            options.tabView.addition = .underline
        case 1:
            options.tabView.addition = .none
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
}
