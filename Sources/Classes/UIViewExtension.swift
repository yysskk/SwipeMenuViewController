import UIKit

extension UIView {

    var hasSafeAreaInsets: Bool {
        guard #available (iOS 11, *) else { return false }
        return safeAreaInsets != .zero
    }
}
