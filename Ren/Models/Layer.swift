import Foundation

/// MA (metabolic adaptation) or BA (brain addiction) — PRD §1 "Terminology".
enum LayerKind: String, Codable, CaseIterable {
    case ma
    case ba

    var opposite: LayerKind {
        switch self {
        case .ma: return .ba
        case .ba: return .ma
        }
    }

    var displayName: String {
        switch self {
        case .ma: return "MA"
        case .ba: return "BA"
        }
    }
}

/// One quick-access action a layer offers. Plain data; the view owns rendering.
struct LayerAction: Identifiable, Hashable {
    let id: String
    let title: String
    let systemImage: String
}

/// A node in the MA→BA→MA→BA history (PRD §2.6).
///
/// The type is genuinely recursive with no ceiling: every `sow` wraps the whole
/// history so far. Any depth cap belongs to `LayerViewport`, never to this type.
final class LayerNode {
    let kind: LayerKind
    let actions: [LayerAction]
    let child: LayerNode?

    init(kind: LayerKind, actions: [LayerAction], child: LayerNode?) {
        self.kind = kind
        self.actions = actions
        self.child = child
    }

    /// Produces the opposite-kind layer that this one sows, wrapping it.
    func sow(actions: (LayerKind) -> [LayerAction]) -> LayerNode {
        let nextKind = kind.opposite
        return LayerNode(kind: nextKind, actions: actions(nextKind), child: self)
    }

    /// Full history depth. Walks iteratively so deep histories don't recurse the stack.
    var depth: Int {
        var count = 0
        var node: LayerNode? = self
        while let current = node {
            count += 1
            node = current.child
        }
        return count
    }
}

/// A layer as the viewport shows it: its kind, its actions, and how deep it sits.
struct VisibleLayer: Hashable {
    let depth: Int
    let kind: LayerKind
    let actions: [LayerAction]
}

/// The view side of PRD §2.6: same structure, but stops looking past `maxDepth`.
///
/// The cutoff yields nothing — no truncation marker, no "more coming" stub —
/// because PRD §2.5 found that even a hint of a next layer forming reads as stressful.
enum LayerViewport {
    static let maxDepth = 3

    static func visibleLayers(of history: LayerNode?, maxDepth: Int = LayerViewport.maxDepth) -> [VisibleLayer] {
        var layers: [VisibleLayer] = []
        var node = history
        while let current = node, layers.count < maxDepth {
            layers.append(VisibleLayer(depth: layers.count, kind: current.kind, actions: current.actions))
            node = current.child
        }
        return layers
    }
}
