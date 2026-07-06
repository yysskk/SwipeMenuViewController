import Testing
import UIKit
@testable import SwipeMenuViewController

@MainActor
@Suite("UIEdgeInsets extension")
struct UIEdgeInsetsExtensionTests {

    @Test("init(horizontal:vertical:) mirrors each value onto both edges")
    func symmetricInit() {
        let insets = UIEdgeInsets(horizontal: 8, vertical: 4)

        #expect(insets.left == 8)
        #expect(insets.right == 8)
        #expect(insets.top == 4)
        #expect(insets.bottom == 4)
    }

    @Test("horizontal and vertical sum their paired edges")
    func pairedSums() {
        let insets = UIEdgeInsets(top: 1, left: 2, bottom: 3, right: 4)

        #expect(insets.horizontal == 6)   // left + right
        #expect(insets.vertical == 4)     // top + bottom
    }

    @Test("zero insets have zero sums")
    func zeroInsets() {
        let insets = UIEdgeInsets.zero

        #expect(insets.horizontal == 0)
        #expect(insets.vertical == 0)
    }
}
