import XCTest
@testable import Ren

final class SeedLayoutTests: XCTestCase {
    /// Canvas widths for the narrowest and widest current iPhones, minus 16pt gutters.
    private let canvasSizes = [CGSize(width: 343, height: 600), CGSize(width: 408, height: 700)]

    func testNestedLayersFloatWithoutTouchingParentEdge() {
        for size in canvasSizes {
            let circles = SeedLayout.circles(in: size, count: 3)
            for (parent, child) in zip(circles, circles.dropFirst()) {
                XCTAssertGreaterThan(SeedLayout.floatingGap(parent: parent, child: child), 12, "size \(size)")
            }
        }
    }

    func testActiveAndFirstNestedLayerHostThreeRealTargets() {
        for size in canvasSizes {
            let circles = SeedLayout.circles(in: size, count: 3)
            XCTAssertTrue(SeedLayout.canHostActions(circles[0]), "size \(size)")
            XCTAssertTrue(SeedLayout.canHostActions(circles[1]), "size \(size)")
            XCTAssertLessThan(circles[1].radius, circles[0].radius)
        }
    }

    func testThirdLayerFallsBackToPreview() {
        for size in canvasSizes {
            XCTAssertFalse(SeedLayout.canHostActions(SeedLayout.circles(in: size, count: 3)[2]), "size \(size)")
        }
    }

    func testActionsStayInsideTheirLayerAndClearTheNestedSeed() {
        for size in canvasSizes {
            let circles = SeedLayout.circles(in: size, count: 3)
            for (parent, child) in zip(circles, circles.dropFirst()) {
                let childTop = child.center.y - child.radius
                for point in SeedLayout.actionCenters(for: parent) {
                    XCTAssertLessThan(point.y + SeedLayout.minimumTarget / 2, childTop, "size \(size)")
                    let dx = point.x - parent.center.x, dy = point.y - parent.center.y
                    XCTAssertLessThanOrEqual((dx * dx + dy * dy).squareRoot() + SeedLayout.minimumTarget / 2, parent.radius, "size \(size)")
                }
            }
        }
    }

    func testBuiltInCatalogDecodesThreeDataOnlyPlugins() throws {
        let catalog = try GroundingCatalog.loadBuiltIn(bundle: Bundle(for: LayerStore.self))

        XCTAssertEqual(catalog.plugins.map(\.id), ["ren-calligraphy", "recite-verse", "photo-recall"])
        XCTAssertEqual(catalog.plugins.first?.manifest.character, "忍")
        XCTAssertEqual(catalog.plugins[1].manifest.statements, [], "statements are user-authored, not shipped")
    }
}
