import XCTest
import CoreGraphics
import RenDomain
@testable import Ren

/// Tests for the layout policy 02 §6 phase 0 requires to exist before any screen does.
/// These run in the simulator, but nothing here touches SwiftUI — the policy is pure.
final class ScreenLayoutTests: XCTestCase {

    private let accuracy: CGFloat = 0.01

    // MARK: - The design floor

    /// 02 §8: iPhone SE 2nd/3rd gen, 375 × 667pt. At default type the nest is bounded by
    /// width, not height — so the four zones do fit on the floor device.
    func testSEFloorIsWidthBoundAtDefaultType() {
        let layout = ScreenLayout(.seFloor)
        XCTAssertEqual(layout.nestSide, 343, accuracy: accuracy, "375 minus two 16pt gutters")
        XCTAssertFalse(layout.isHeightConstrained)
    }

    /// The zones must tile the safe content area without overlapping or escaping it.
    func testZonesTileTheContentAreaWithoutOverlapping() {
        let layout = ScreenLayout(.seFloor)
        let zones = layout.zones
        let content = layout.content

        for (name, rect) in [("topBar", zones.topBar), ("status", zones.status),
                             ("nest", zones.nest), ("selectables", zones.selectables)] {
            XCTAssertTrue(content.contains(rect), "\(name) \(rect) escapes content \(content)")
        }
        XCTAssertEqual(zones.topBar.maxY, zones.status.minY, accuracy: accuracy)
        XCTAssertEqual(zones.status.maxY, zones.nest.minY, accuracy: accuracy)
        XCTAssertEqual(zones.nest.maxY + ScreenLayout.zoneSpacing, zones.selectables.minY,
                       accuracy: accuracy, "the nest does not rub the button row")
        XCTAssertEqual(zones.selectables.maxY, content.maxY, accuracy: accuracy)
    }

    /// The reason safe-area insets are an input and not a constant: the SE has a home
    /// button and no bottom inset, every modern iPhone has ~34pt plus a swipe-up gesture.
    /// Anything anchored to the bottom must stay out of it (02 §8).
    func testBottomSafeAreaIsNeverIntrudedOn() {
        var input = ScreenLayout.Input(size: CGSize(width: 393, height: 852))
        input.safeArea = .homeIndicator
        let zones = ScreenLayout(input).zones
        let bottomLimit = 852 - ScreenLayout.SafeArea.homeIndicator.bottom
        XCTAssertLessThanOrEqual(zones.selectables.maxY, bottomLimit + accuracy)
        XCTAssertLessThanOrEqual(zones.nest.maxY, bottomLimit + accuracy)
    }

    /// A layout sized in absolute points for the floor would leave a larger screen looking
    /// empty (02 §8), so the nest must scale with the space available.
    func testNestScalesWithScreenWidth() {
        var bigger = ScreenLayout.Input(size: CGSize(width: 393, height: 852))
        bigger.safeArea = .homeIndicator
        XCTAssertGreaterThan(ScreenLayout(bigger).nestSide, ScreenLayout(.seFloor).nestSide)
    }

    // MARK: - The shared corner

    /// 00 §2.5, confirmed on device 2026-09-25: every box must read as *suspended*, touching
    /// none of its parent's edges. An earlier version shared the anchored corner, which is
    /// flush on two edges, and read as boxes rubbing together.
    func testEveryInnerLayerIsSuspendedOnAllFourEdges() {
        let frames = ScreenLayout(.seFloor).layerFrames
        XCTAssertEqual(frames.count, 3)
        for (outer, inner) in zip(frames, frames.dropFirst()) {
            XCTAssertGreaterThan(inner.minY, outer.minY, "clear of the top edge")
            XCTAssertLessThan(inner.maxY, outer.maxY, "clear of the bottom edge")
            XCTAssertGreaterThan(inner.minX, outer.minX, "clear of the leading edge")
            XCTAssertLessThan(inner.maxX, outer.maxX, "clear of the trailing edge")
            XCTAssertTrue(outer.contains(inner), "still fully enveloped (01 §8)")
        }
    }

    func testLayersAreSquare() {
        for frame in ScreenLayout(.seFloor).layerFrames {
            XCTAssertEqual(frame.width, frame.height, accuracy: accuracy)
        }
    }

    /// Suspended, but still biased toward the anchored corner — that bias is what keeps the
    /// inner boxes inside thumb reach (01 §8).
    func testInnerLayersStayBiasedTowardTheAnchoredCorner() {
        let frames = ScreenLayout(.seFloor).layerFrames
        for (outer, inner) in zip(frames, frames.dropFirst()) {
            XCTAssertGreaterThan(inner.midX, outer.midX, "right-handed: biased trailing")
            XCTAssertGreaterThan(inner.midY, outer.midY, "biased toward the bottom")
        }
    }

    /// The gap is measured against each parent, so suspension stays visually consistent with
    /// depth instead of collapsing in the innermost box.
    func testSuspensionGapIsProportionalToEachParent() {
        let frames = ScreenLayout(.seFloor).layerFrames
        let ratio = CGFloat(Tunables.draft.nest.floatingGapRatio)
        for (outer, inner) in zip(frames, frames.dropFirst()) {
            XCTAssertEqual(outer.maxX - inner.maxX, outer.width * ratio, accuracy: accuracy)
            XCTAssertEqual(outer.maxY - inner.maxY, outer.height * ratio, accuracy: accuracy)
        }
    }

    /// A zero gap is the layout that failed on device, so the config type refuses it.
    func testZeroGapIsRejectedByValidation() {
        let zeroGap = Tunables(nest: .init(layerAreaRatios: [9, 4, 1], floatingGapRatio: 0))
        XCTAssertThrowsError(try zeroGap.validate())
    }

    /// 9 : 4 : 1 are areas, so the core's side is a third of the outer's, not a ninth.
    func testSidesFollowTheSquareRootOfTheAreaRatios() {
        let frames = ScreenLayout(.seFloor).layerFrames
        XCTAssertEqual(frames[1].width / frames[0].width, 2.0 / 3.0, accuracy: 0.001)
        XCTAssertEqual(frames[2].width / frames[0].width, 1.0 / 3.0, accuracy: 0.001)
        XCTAssertEqual(frames[2].width, 114.33, accuracy: 0.1, "the core on the design floor")
    }

    // MARK: - Mirroring

    /// 02 §5 invariant 9: handedness mirrors placement only, and every screen supports it.
    func testLeftHandedMirrorsPlacementAndPreservesSizes() {
        var left = ScreenLayout.Input.seFloor
        left.handedness = .left
        let rightFrames = ScreenLayout(.seFloor).layerFrames
        let leftFrames = ScreenLayout(left).layerFrames
        let leftNest = ScreenLayout(left).zones.nest

        XCTAssertEqual(leftFrames.count, rightFrames.count)
        for (l, r) in zip(leftFrames, rightFrames) {
            XCTAssertEqual(l.width, r.width, accuracy: accuracy, "sizes are unchanged")
            XCTAssertEqual(l.maxY, r.maxY, accuracy: accuracy, "vertical placement is unchanged")
        }
        XCTAssertEqual(leftFrames[0], leftNest, "the outermost box fills the nest zone")
        for (outer, inner) in zip(leftFrames, leftFrames.dropFirst()) {
            XCTAssertGreaterThan(inner.minX, outer.minX, "left-handed: suspended, not flush")
            XCTAssertLessThan(inner.midX, outer.midX, "left-handed: biased leading")
        }
        XCTAssertNotEqual(leftFrames[2].minX, rightFrames[2].minX, "the core actually moved")
    }

    /// With the inner box suspended the free area is a ring, so all four strips exist in
    /// both handedness modes — there is no longer a side that collapses to nothing.
    func testFreeAreaIsARingInBothHandednessModes() {
        var left = ScreenLayout.Input.seFloor
        left.handedness = .left
        for input in [ScreenLayout.Input.seFloor, left] {
            let rects = ScreenLayout(input).freeRects(forLayerAt: 0)
            XCTAssertEqual(rects.count, 4, "above, below, and both sides")
            for rect in rects {
                XCTAssertGreaterThan(rect.width, 0)
                XCTAssertGreaterThan(rect.height, 0)
            }
        }
    }

    // MARK: - Free area for scribbles

    /// 01 §9: entries go in the part of a box not covered by the box nested inside it.
    func testFreeRectsNeverOverlapTheNestedBox() {
        let layout = ScreenLayout(.seFloor)
        let frames = layout.layerFrames
        for index in 0..<(frames.count - 1) {
            for rect in layout.freeRects(forLayerAt: index) {
                XCTAssertFalse(rect.intersects(frames[index + 1].insetBy(dx: accuracy, dy: accuracy)),
                               "free rect \(rect) overlaps the nested box")
                XCTAssertTrue(frames[index].contains(rect))
            }
        }
    }

    /// The innermost box has nothing inside it, so all of it is free.
    func testInnermostLayerIsEntirelyFree() {
        let layout = ScreenLayout(.seFloor)
        let rects = layout.freeRects(forLayerAt: 2)
        XCTAssertEqual(rects.count, 1)
        XCTAssertEqual(rects[0], layout.layerFrames[2])
    }

    // MARK: - Dynamic Type

    /// The concrete trigger for 01 §9's still-open overflow question: on the design floor
    /// at the largest accessibility size, the core box has room for no entries at all.
    /// Recorded as a measurement — what to *do* about it is not decided here.
    func testCoreLosesAllEntryCapacityAtLargestAccessibilitySizeOnTheFloor() {
        XCTAssertGreaterThan(ScreenLayout(.seFloor).entryCapacity(forLayerAt: 2), 0,
                             "the core holds entries at default type")

        var large = ScreenLayout.Input.seFloor
        large.typeScale = .largestAccessibility
        XCTAssertEqual(ScreenLayout(large).entryCapacity(forLayerAt: 2), 0,
                       "and none at the largest accessibility size")
    }

    /// Larger text grows the status zone, which is what eventually squeezes the nest.
    func testLargeTypeMakesTheLayoutHeightBound() {
        var large = ScreenLayout.Input.seFloor
        large.typeScale = .largestAccessibility
        let layout = ScreenLayout(large)
        XCTAssertTrue(layout.isHeightConstrained)
        XCTAssertLessThan(layout.nestSide, ScreenLayout(.seFloor).nestSide)
    }

    func testEveryLayerRemainsSelectableAtEverySupportedTypeSize() {
        for multiplier in [0.85, 1.0, 1.6, 3.1] {
            var input = ScreenLayout.Input.seFloor
            input.typeScale = .init(multiplier: multiplier)
            let layout = ScreenLayout(input)
            for index in 0..<layout.layerFrames.count {
                XCTAssertTrue(layout.isSelectable(layerAt: index),
                              "layer \(index) below the 44pt tap target at scale \(multiplier)")
            }
        }
    }

    /// Why 01 §8 moved the actions out of the boxes: three 44pt targets plus spacing need
    /// ~132pt, and the core is ~114pt on the design floor. Selection fits; buttons never did.
    func testCoreCannotHostThreeTapTargetsWhichIsWhyActionsMovedOut() {
        let core = ScreenLayout(.seFloor).layerFrames[2]
        let threeTargets = 3 * ScreenLayout.minimumTapTarget + 2 * 4
        XCTAssertLessThan(core.width, threeTargets)
        XCTAssertGreaterThanOrEqual(core.width, ScreenLayout.minimumTapTarget)
    }

    // MARK: - Degenerate input

    func testZeroSizedScreenYieldsNothingRatherThanCrashing() {
        let layout = ScreenLayout(ScreenLayout.Input(size: .zero))
        XCTAssertEqual(layout.content, .zero)
        XCTAssertEqual(layout.nestSide, 0)
        XCTAssertEqual(layout.zones, .empty)
        XCTAssertTrue(layout.layerFrames.isEmpty)
        XCTAssertTrue(layout.freeRects(forLayerAt: 0).isEmpty)
        XCTAssertEqual(layout.entryCapacity(forLayerAt: 0), 0)
        XCTAssertFalse(layout.isSelectable(layerAt: 0))
    }

    func testSafeAreaLargerThanTheScreenYieldsNothing() {
        var input = ScreenLayout.Input(size: CGSize(width: 100, height: 100))
        input.safeArea = ScreenLayout.SafeArea(top: 60, bottom: 60)
        XCTAssertEqual(ScreenLayout(input).zones, .empty)
    }

    func testOutOfRangeLayerIndexIsHandled() {
        let layout = ScreenLayout(.seFloor)
        XCTAssertTrue(layout.freeRects(forLayerAt: 99).isEmpty)
        XCTAssertEqual(layout.entryCapacity(forLayerAt: 99), 0)
        XCTAssertFalse(layout.isSelectable(layerAt: -1))
    }
}

/// The shipped tunables file has to actually load, or every layout silently falls back to
/// the drafts (01 §11).
final class TunablesStoreTests: XCTestCase {

    /// `.main` on purpose: these tests are hosted in the app, so `.main` is the app bundle
    /// the resource actually ships in — and it is the same lookup the app itself does.
    func testShippedTunablesFileLoadsAndValidates() throws {
        let tunables = try TunablesStore.load(from: .main)
        XCTAssertNoThrow(try tunables.validate())
    }

    /// Guards against the file and 01 §11's table drifting apart unnoticed.
    func testShippedTunablesMatchTheDocumentedDrafts() throws {
        XCTAssertEqual(try TunablesStore.load(from: .main), .draft)
    }

    /// A missing file must be reported, not silently replaced by the drafts — otherwise a
    /// resource that fell out of the build looks like a working app with wrong numbers.
    func testMissingResourceIsReportedRatherThanSilentlyDefaulted() {
        let bundleWithoutTunables = Bundle(for: XCTestCase.self)
        XCTAssertThrowsError(try TunablesStore.load(from: bundleWithoutTunables)) { error in
            guard case TunablesStore.LoadError.missingResource = error else {
                return XCTFail("expected missingResource, got \(error)")
            }
        }
    }
}

/// The in-box action anchors (00 §2.5's "~3 actions per layer", placed around the free ring).
final class ActionAnchorTests: XCTestCase {

    private let accuracy: CGFloat = 0.01

    /// The point of corners over a row: three 44pt targets in a row need ~132pt and the core
    /// is ~114pt on the design floor. At corners they need only ~88pt, so every layer fits.
    func testEveryLayerIncludingTheCoreHostsThreeAnchors() {
        let layout = ScreenLayout(.seFloor)
        for depth in 0..<layout.layerFrames.count {
            XCTAssertEqual(layout.actionAnchors(forLayerAt: depth).count, 3, "layer \(depth)")
        }
        XCTAssertLessThan(layout.layerFrames[2].width, 3 * ScreenLayout.actionTargetSize,
                          "a row of three would not have fit")
    }

    /// A 44pt button centred on each anchor must sit entirely inside its own box.
    func testAnchoredButtonsFitInsideTheirBox() {
        let layout = ScreenLayout(.seFloor)
        let half = ScreenLayout.actionTargetSize / 2
        for depth in 0..<layout.layerFrames.count {
            let box = layout.layerFrames[depth]
            for centre in layout.actionAnchors(forLayerAt: depth) {
                let target = CGRect(x: centre.x - half, y: centre.y - half,
                                    width: ScreenLayout.actionTargetSize,
                                    height: ScreenLayout.actionTargetSize)
                XCTAssertTrue(box.insetBy(dx: -accuracy, dy: -accuracy).contains(target),
                              "layer \(depth) button \(target) escapes \(box)")
            }
        }
    }

    /// Anchors go where the nested box is not, so a button never sits on top of an inner layer.
    func testAnchorsAvoidTheNestedBox() {
        let layout = ScreenLayout(.seFloor)
        let frames = layout.layerFrames
        let half = ScreenLayout.actionTargetSize / 2
        for depth in 0..<(frames.count - 1) {
            for centre in layout.actionAnchors(forLayerAt: depth) {
                let target = CGRect(x: centre.x - half, y: centre.y - half,
                                    width: ScreenLayout.actionTargetSize,
                                    height: ScreenLayout.actionTargetSize)
                XCTAssertFalse(target.intersects(frames[depth + 1]),
                               "layer \(depth) button overlaps the box nested inside it")
            }
        }
    }

    /// The two top anchors must not collide with each other.
    func testTopAnchorsDoNotOverlap() {
        let layout = ScreenLayout(.seFloor)
        for depth in 0..<layout.layerFrames.count {
            let anchors = layout.actionAnchors(forLayerAt: depth)
            guard anchors.count == 3 else { continue }
            XCTAssertGreaterThanOrEqual(anchors[1].x - anchors[0].x, ScreenLayout.actionTargetSize,
                                        "layer \(depth) top buttons overlap")
        }
    }

    /// 02 §5 invariant 9: the free bottom corner is the one away from the anchor, so it
    /// mirrors with handedness.
    func testFreeBottomCornerMirrorsWithHandedness() {
        var left = ScreenLayout.Input.seFloor
        left.handedness = .left
        let rightAnchors = ScreenLayout(.seFloor).actionAnchors(forLayerAt: 0)
        let leftAnchors = ScreenLayout(left).actionAnchors(forLayerAt: 0)
        let rightBox = ScreenLayout(.seFloor).layerFrames[0]
        let leftBox = ScreenLayout(left).layerFrames[0]

        XCTAssertLessThan(rightAnchors[2].x, rightBox.midX, "right-handed: free corner is leading")
        XCTAssertGreaterThan(leftAnchors[2].x, leftBox.midX, "left-handed: free corner is trailing")
    }

    /// A box too small for two side-by-side targets gets none rather than overlapping ones.
    func testTooSmallABoxGetsNoAnchors() {
        var tiny = ScreenLayout.Input(size: CGSize(width: 140, height: 400))
        tiny.nest = .init(layerAreaRatios: [9, 4, 1], floatingGapRatio: 0.05)
        let layout = ScreenLayout(tiny)
        XCTAssertTrue(layout.actionAnchors(forLayerAt: 2).isEmpty,
                      "the core at this width cannot host two 44pt targets side by side")
    }

    func testOutOfRangeIndexYieldsNoAnchors() {
        XCTAssertTrue(ScreenLayout(.seFloor).actionAnchors(forLayerAt: 9).isEmpty)
    }
}
