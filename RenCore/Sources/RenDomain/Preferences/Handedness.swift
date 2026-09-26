import Foundation

/// Which bottom corner the nest is anchored to, and therefore which way the whole
/// layout is mirrored (01 §8).
///
/// iOS has no system handedness setting to read, so this is ours to ask for and store.
/// Deliberately *not* modelled as a layout direction: `layoutDirection` would mirror a
/// view tree in one line but also flips text alignment and reading order, which 01 §8
/// forbids — text is never mirrored. See 02 §8.
public enum Handedness: String, Codable, CaseIterable, Sendable {
    case right
    case left

    public static let `default`: Handedness = .right

    /// The horizontal edge the nest and the inner boxes are anchored to.
    public var anchorEdge: HorizontalEdge {
        switch self {
        case .right: return .trailing
        case .left: return .leading
        }
    }
}

/// A layout-relative horizontal edge. Resolved to an absolute side only at draw time,
/// so no layout code hardcodes left or right (02 §5 invariant 9).
public enum HorizontalEdge: Sendable {
    case leading
    case trailing
}
