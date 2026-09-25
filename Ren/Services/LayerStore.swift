import Foundation
import Observation

/// Supplies each layer's ~3 quick-access actions (PRD §2.5).
struct LayerActionSource {
    let grounding: GroundingCatalog

    static let maActions: [LayerAction] = [
        LayerAction(id: "ma.meal-photo", title: "Log meal", systemImage: "camera"),
        LayerAction(id: "ma.short-workout", title: "Short workout", systemImage: "figure.walk"),
        LayerAction(id: "ma.exercise-prep", title: "Set out shoes", systemImage: "shoe"),
    ]

    func actions(for kind: LayerKind) -> [LayerAction] {
        switch kind {
        case .ma: return Self.maActions
        case .ba: return grounding.plugins.map(\.action)
        }
    }
}

/// In-memory history for the shell. Persistence is deliberately out of scope for now.
@Observable
final class LayerStore {
    private(set) var history: LayerNode
    let source: LayerActionSource

    init(source: LayerActionSource, history: LayerNode? = nil) {
        self.source = source
        self.history = history ?? LayerNode(kind: .ma, actions: source.actions(for: .ma), child: nil)
    }

    var visibleLayers: [VisibleLayer] {
        LayerViewport.visibleLayers(of: history)
    }

    /// Completing an action on the active layer sows the opposite layer, which becomes active.
    func completeActiveAction() {
        history = history.sow(actions: source.actions(for:))
    }
}
