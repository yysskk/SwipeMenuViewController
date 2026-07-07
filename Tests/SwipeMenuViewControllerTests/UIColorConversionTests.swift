import Testing
import UIKit

@testable import SwipeMenuViewController

@MainActor
@Suite("UIColor conversion", .serialized)
struct UIColorConversionTests {

    /// Extracts the RGBA components of a color for comparison.
    private func rgba(_ color: UIColor) -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }

    private let tolerance: CGFloat = 0.01

    @Test("Grayscale colors interpolate instead of returning nil")
    func grayscaleConvertsToGray() throws {
        // Pre-fix: `.white`/`.black` have 2 cgColor components, so the old
        // implementation returned nil and the tab fade silently broke.
        let result = try #require(UIColor.white.convert(to: .black, multiplier: 0.5))
        let (r, g, b, a) = rgba(result)
        #expect(abs(r - 0.5) < tolerance)
        #expect(abs(g - 0.5) < tolerance)
        #expect(abs(b - 0.5) < tolerance)
        #expect(abs(a - 1.0) < tolerance)
    }

    @Test("Grayscale to RGB and back are both non-nil")
    func grayscaleAndRGBBothDirections() throws {
        let gray = UIColor(white: 0.3, alpha: 1)

        let forward = try #require(gray.convert(to: .red, multiplier: 0.5))
        let (fr, fg, fb, fa) = rgba(forward)
        // Halfway between (0.3, 0.3, 0.3) and (1, 0, 0).
        #expect(abs(fr - 0.65) < tolerance)
        #expect(abs(fg - 0.15) < tolerance)
        #expect(abs(fb - 0.15) < tolerance)
        #expect(abs(fa - 1.0) < tolerance)

        let reverse = try #require(UIColor.red.convert(to: gray, multiplier: 0.5))
        let (rr, rg, rb, ra) = rgba(reverse)
        #expect(abs(rr - 0.65) < tolerance)
        #expect(abs(rg - 0.15) < tolerance)
        #expect(abs(rb - 0.15) < tolerance)
        #expect(abs(ra - 1.0) < tolerance)
    }

    @Test("Red to blue interpolates at 0, 0.5, and 1")
    func redToBlueEndpointsAndMidpoint() throws {
        let atStart = try #require(UIColor.red.convert(to: .blue, multiplier: 0))
        let (sr, sg, sb, sa) = rgba(atStart)
        #expect(abs(sr - 1.0) < tolerance)
        #expect(abs(sg - 0.0) < tolerance)
        #expect(abs(sb - 0.0) < tolerance)
        #expect(abs(sa - 1.0) < tolerance)

        let atMid = try #require(UIColor.red.convert(to: .blue, multiplier: 0.5))
        let (mr, mg, mb, ma) = rgba(atMid)
        #expect(abs(mr - 0.5) < tolerance)
        #expect(abs(mg - 0.0) < tolerance)
        #expect(abs(mb - 0.5) < tolerance)
        #expect(abs(ma - 1.0) < tolerance)

        let atEnd = try #require(UIColor.red.convert(to: .blue, multiplier: 1))
        let (er, eg, eb, ea) = rgba(atEnd)
        #expect(abs(er - 0.0) < tolerance)
        #expect(abs(eg - 0.0) < tolerance)
        #expect(abs(eb - 1.0) < tolerance)
        #expect(abs(ea - 1.0) < tolerance)
    }

    @Test("Multiplier is clamped to 0...1")
    func multiplierIsClamped() throws {
        // multiplier -1 behaves as 0 (returns the from-color).
        let clampedLow = try #require(UIColor.red.convert(to: .blue, multiplier: -1))
        let (lr, lg, lb, la) = rgba(clampedLow)
        #expect(abs(lr - 1.0) < tolerance)
        #expect(abs(lg - 0.0) < tolerance)
        #expect(abs(lb - 0.0) < tolerance)
        #expect(abs(la - 1.0) < tolerance)

        // multiplier 2 behaves as 1 (returns the to-color).
        let clampedHigh = try #require(UIColor.red.convert(to: .blue, multiplier: 2))
        let (hr, hg, hb, ha) = rgba(clampedHigh)
        #expect(abs(hr - 0.0) < tolerance)
        #expect(abs(hg - 0.0) < tolerance)
        #expect(abs(hb - 1.0) < tolerance)
        #expect(abs(ha - 1.0) < tolerance)
    }

    @Test("Alpha interpolates independently of color channels")
    func alphaInterpolates() throws {
        let from = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        let to = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        let result = try #require(from.convert(to: to, multiplier: 0.5))
        let (_, _, _, a) = rgba(result)
        #expect(abs(a - 0.5) < tolerance)
    }
}
