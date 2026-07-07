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

    @Test("isSelected switches the label between the base and selected fonts")
    func selectionTogglesLabelFont() {
        let item = TabItemView(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        item.font = .systemFont(ofSize: 14)
        item.selectedFont = .boldSystemFont(ofSize: 20)

        item.isSelected = true
        #expect(item.titleLabel.font == item.selectedFont)

        item.isSelected = false
        #expect(item.titleLabel.font == item.font)
    }

    @Test("Assigning font updates the label only while unselected")
    func fontAssignmentRespectsSelection() {
        let item = TabItemView(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        let base = UIFont.systemFont(ofSize: 14)
        let selected = UIFont.boldSystemFont(ofSize: 20)

        // While unselected, the base font drives the label and the selected font does not.
        item.font = base
        item.selectedFont = selected
        #expect(item.titleLabel.font == base)

        // While selected, the selected font drives the label and the base font does not.
        item.isSelected = true
        item.selectedFont = selected
        #expect(item.titleLabel.font == selected)
        item.font = base
        #expect(item.titleLabel.font == selected)
    }

    @Test("The label is centered and hosted in the item view")
    func labelIsConfigured() {
        let item = TabItemView(frame: CGRect(x: 0, y: 0, width: 100, height: 44))

        #expect(item.titleLabel.textAlignment == .center)
        #expect(item.titleLabel.superview === item)
    }
}
