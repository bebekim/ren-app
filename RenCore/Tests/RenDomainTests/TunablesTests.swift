import XCTest
@testable import RenDomain

final class TunablesTests: XCTestCase {

    /// The mistake this guards against: reading 9 : 4 : 1 as *side* lengths. They are
    /// areas, which is what makes the core a third of the outer box rather than a ninth.
    func testSideRatiosAreSquareRootsOfAreaRatios() {
        let sides = Tunables.draft.nest.sideRatios
        XCTAssertEqual(sides, [1.0, 2.0 / 3.0, 1.0 / 3.0].map { $0 }, accuracy: 0.0001)
    }

    /// 01 §3 asks to compare 9 : 3 : 1, whose side step is constant (√3) and which
    /// therefore looks the same at every moment of a growth cycle.
    func testSelfSimilarAlternativeHasAConstantSideStep() {
        let sides = Tunables.Nest(layerAreaRatios: [9, 3, 1], floatingGapRatio: 0.05).sideRatios
        XCTAssertEqual(sides[0] / sides[1], sides[1] / sides[2], accuracy: 0.0001)
        XCTAssertEqual(sides[0] / sides[1], 3.0.squareRoot(), accuracy: 0.0001)
    }

    func testDraftRatiosAreNotSelfSimilar() {
        let sides = Tunables.draft.nest.sideRatios
        XCTAssertNotEqual(sides[0] / sides[1], sides[1] / sides[2], accuracy: 0.0001)
    }

    func testDraftIsValid() {
        XCTAssertNoThrow(try Tunables.draft.validate())
    }

    func testLayerCountMustMatchTheViewportCap() {
        assertInvalid([9, 4], .layerCountMismatch(got: 2, expected: 3))
    }

    func testRatiosMustDescendOutermostFirst() {
        assertInvalid([1, 4, 9], .ratiosNotDescending([1, 4, 9]))
    }

    func testRatiosMustBePositive() {
        assertInvalid([9, 4, 0], .nonPositiveRatio([9, 4, 0]))
    }

    func testEmptyRatiosYieldNoSidesRatherThanCrashing() {
        XCTAssertTrue(Tunables.Nest(layerAreaRatios: [], floatingGapRatio: 0.05).sideRatios.isEmpty)
    }

    func testRoundTripsThroughJSON() throws {
        let data = try JSONEncoder().encode(Tunables.draft)
        XCTAssertEqual(try JSONDecoder().decode(Tunables.self, from: data), .draft)
    }

    private func assertInvalid(
        _ ratios: [Double], _ expected: Tunables.Invalid,
        file: StaticString = #filePath, line: UInt = #line
    ) {
        do {
            try Tunables(nest: .init(layerAreaRatios: ratios, floatingGapRatio: 0.05)).validate()
            XCTFail("expected \(expected)", file: file, line: line)
        } catch let error as Tunables.Invalid {
            XCTAssertEqual(error, expected, file: file, line: line)
        } catch {
            XCTFail("unexpected \(error)", file: file, line: line)
        }
    }
}

final class HandednessTests: XCTestCase {

    /// 02 §5 invariant 9: nothing hardcodes left or right. Handedness resolves to a
    /// layout-relative edge, and the absolute side is decided only at draw time.
    func testHandednessResolvesToALayoutRelativeEdge() {
        XCTAssertEqual(Handedness.right.anchorEdge, .trailing)
        XCTAssertEqual(Handedness.left.anchorEdge, .leading)
        XCTAssertEqual(Handedness.default, .right)
    }
}

private func XCTAssertEqual(
    _ lhs: [Double], _ rhs: [Double], accuracy: Double,
    file: StaticString = #filePath, line: UInt = #line
) {
    XCTAssertEqual(lhs.count, rhs.count, file: file, line: line)
    for (a, b) in zip(lhs, rhs) {
        XCTAssertEqual(a, b, accuracy: accuracy, file: file, line: line)
    }
}

final class LayerKindTests: XCTestCase {

    /// 01 §8's nest is MA–BA–MA: alternating outward, so outer and core are the same mode.
    func testAlternatesOutwardFromTheStartingMode() {
        XCTAssertEqual(LayerKind.alternating(from: .ma, count: 3), [.ma, .ba, .ma])
        XCTAssertEqual(LayerKind.alternating(from: .ba, count: 3), [.ba, .ma, .ba])
    }

    func testAlternatingHandlesDegenerateCounts() {
        XCTAssertTrue(LayerKind.alternating(from: .ma, count: 0).isEmpty)
        XCTAssertTrue(LayerKind.alternating(from: .ma, count: -1).isEmpty)
    }

    /// Neither mode is permanently ranked (00 §1), so opposite must be symmetric.
    func testOppositeIsSymmetric() {
        for kind in LayerKind.allCases {
            XCTAssertEqual(kind.opposite.opposite, kind)
            XCTAssertNotEqual(kind.opposite, kind)
        }
    }
}

final class SuspensionGapTests: XCTestCase {

    /// 00 §2.5 and the 2026-09-25 device test: boxes must never touch, so a zero gap is a
    /// validation failure rather than a discouraged value.
    func testZeroGapIsRejected() {
        assertGapRejected(0)
    }

    func testNegativeGapIsRejected() {
        assertGapRejected(-0.1)
    }

    /// A gap at or above a quarter of the parent would start competing with the size
    /// difference that already separates the boxes.
    func testExcessiveGapIsRejected() {
        assertGapRejected(0.25)
    }

    func testDraftGapIsSmallButNonZero() {
        XCTAssertGreaterThan(Tunables.draft.nest.floatingGapRatio, 0)
        XCTAssertLessThan(Tunables.draft.nest.floatingGapRatio, 0.1)
    }

    private func assertGapRejected(_ gap: Double, file: StaticString = #filePath, line: UInt = #line) {
        let tunables = Tunables(nest: .init(layerAreaRatios: [9, 4, 1], floatingGapRatio: gap))
        do {
            try tunables.validate()
            XCTFail("gap \(gap) should be rejected", file: file, line: line)
        } catch let error as Tunables.Invalid {
            XCTAssertEqual(error, .floatingGapOutOfRange(gap), file: file, line: line)
        } catch {
            XCTFail("unexpected \(error)", file: file, line: line)
        }
    }
}
