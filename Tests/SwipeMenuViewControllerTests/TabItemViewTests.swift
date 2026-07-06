import Testing
import UIKit
@testable import SwipeMenuViewController

@MainActor
@Suite("TabItemView")
struct TabItemViewTests {

    @Test("isSelected switches the label between the text and selected colors")
    func selectionTogglesLabelColor() {
        let item = TabItemView(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        item.textColor = .gray
        item.selectedTextColor = .red

        item.isSelected = true
        #expect(item.titleLabel.textColor == item.selectedTextColor)

        item.isSelected = false
        #expect(item.titleLabel.textColor == item.textColor)
    }

    @Test("The label is centered and hosted in the item view")
    func labelIsConfigured() {
        let item = TabItemView(frame: CGRect(x: 0, y: 0, width: 100, height: 44))

        #expect(item.titleLabel.textAlignment == .center)
        #expect(item.titleLabel.superview === item)
    }
}
