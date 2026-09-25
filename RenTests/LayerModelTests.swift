import XCTest
@testable import Ren

final class LayerModelTests: XCTestCase {
    private func actions(_ kind: LayerKind) -> [LayerAction] {
        (1...3).map { LayerAction(id: "\(kind.rawValue).\($0)", title: "\($0)", systemImage: "circle") }
    }

    private func history(depth: Int) -> LayerNode {
        var node = LayerNode(kind: .ma, actions: actions(.ma), child: nil)
        for _ in 1..<depth { node = node.sow(actions: actions) }
        return node
    }

    func testSowAlternatesKindAndWrapsHistory() {
        let root = LayerNode(kind: .ma, actions: actions(.ma), child: nil)
        let sown = root.sow(actions: actions)

        XCTAssertEqual(sown.kind, .ba)
        XCTAssertEqual(sown.actions.map(\.id), ["ba.1", "ba.2", "ba.3"])
        XCTAssertTrue(sown.child === root)
        XCTAssertEqual(sown.sow(actions: actions).kind, .ma)
    }

    func testHistoryIsUnboundedEvenThoughViewportIsCapped() {
        let deep = history(depth: 500)

        XCTAssertEqual(deep.depth, 500)
        XCTAssertEqual(LayerViewport.visibleLayers(of: deep).count, 3)
    }

    func testViewportShowsNewestThreeOutermostFirstWithNoTruncationMarker() {
        let layers = LayerViewport.visibleLayers(of: history(depth: 4))

        XCTAssertEqual(layers.map(\.depth), [0, 1, 2])
        XCTAssertEqual(layers.map(\.kind), [.ba, .ma, .ba])
        XCTAssertTrue(layers.allSatisfy { $0.actions.count == 3 })
    }

    func testViewportShowsOnlyWhatExistsForShallowHistory() {
        XCTAssertEqual(LayerViewport.visibleLayers(of: nil), [])
        XCTAssertEqual(LayerViewport.visibleLayers(of: history(depth: 1)).map(\.kind), [.ma])
        XCTAssertEqual(LayerViewport.visibleLayers(of: history(depth: 2)).map(\.kind), [.ba, .ma])
    }

    func testViewportIsStatelessAcrossRepeatedCalls() {
        let node = history(depth: 5)

        XCTAssertEqual(LayerViewport.visibleLayers(of: node), LayerViewport.visibleLayers(of: node))
    }

    func testStoreCompletingActiveActionSowsOppositeLayer() throws {
        let catalog = try GroundingCatalog.loadBuiltIn(bundle: Bundle(for: LayerStore.self))
        let store = LayerStore(source: LayerActionSource(grounding: catalog))

        XCTAssertEqual(store.visibleLayers.map(\.kind), [.ma])
        store.completeActiveAction()
        XCTAssertEqual(store.visibleLayers.map(\.kind), [.ba, .ma])
        XCTAssertEqual(store.visibleLayers[0].actions.map(\.id), catalog.plugins.map(\.action.id))
    }
}
