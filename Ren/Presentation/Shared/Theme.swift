import SwiftUI
import RenDomain

/// Colour tokens (02 §8). Every colour comes from here, and every value comes from
/// `Assets.xcassets` — no RGB literal at a use site.
///
/// That indirection is what makes the palette swappable, and it makes dark mode a later
/// *decision* rather than a later rewrite: each colour set already carries a dark
/// appearance.
enum RenTheme {
    /// Page background — the paper.
    static let canvas = Color("RenCanvas")
    /// Text and strokes — the ink.
    static let ink = Color("RenInk")

    /// Layer fills. These carry *identity*, not state: 02 §5 invariant 6 forbids any state
    /// being carried by colour alone, so a layer's forecast state will be encoded by its
    /// rim's thickness and texture rather than by tinting the box.
    static func fill(for kind: LayerKind) -> Color {
        switch kind {
        case .ma: return Color("RenMA")
        case .ba: return Color("RenBA")
        }
    }
}

extension LayerKind {
    /// The physical lens's name for this mode (00 §2.1). The experiential lens's names
    /// arrive with the lens toggle (01 §4).
    var shortName: String {
        switch self {
        case .ma: return "MA"
        case .ba: return "BA"
        }
    }

    var accessibleName: String {
        switch self {
        case .ma: return "Physical"
        case .ba: return "Experiential"
        }
    }
}
