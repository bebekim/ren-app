import Foundation

/// The two interwoven modes (00 §1 terminology).
///
/// Not a hierarchy. 00 §1 is explicit that MA and BA are interwoven and not permanently
/// ranked — like the seed of the opposite state in a taijitu, an MA action may sow a BA
/// layer and a BA response may sow the next MA one. Which one is currently *dominant* is a
/// property of the nest, never of this type.
public enum LayerKind: String, Codable, CaseIterable, Sendable {
    /// Metabolic adaptation — the physical action set.
    case ma
    /// Brain addiction — the craving-response set.
    case ba

    public var opposite: LayerKind {
        switch self {
        case .ma: return .ba
        case .ba: return .ma
        }
    }

    /// Alternating outward from a starting mode, as 01 §8's MA–BA–MA nest does.
    public static func alternating(from start: LayerKind, count: Int) -> [LayerKind] {
        var result: [LayerKind] = []
        var current = start
        for _ in 0..<max(0, count) {
            result.append(current)
            current = current.opposite
        }
        return result
    }
}
