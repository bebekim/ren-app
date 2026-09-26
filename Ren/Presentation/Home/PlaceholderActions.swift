import Foundation
import RenDomain

/// The ~3 actions a layer offers (01 §8 zone 3).
///
/// Placeholders: tapping one records an event and nothing else. The real MA set carries
/// duration and reps, and the real BA set comes from the grounding catalogue — both later.
struct PlaceholderAction: Identifiable, Hashable {
    let id: String
    let title: String
    let symbolName: String

    static let ma: [PlaceholderAction] = [
        .init(id: "ma.meal", title: "Meal", symbolName: "camera"),
        .init(id: "ma.workout", title: "Workout", symbolName: "figure.run"),
        .init(id: "ma.prep", title: "Prep", symbolName: "shoeprints.fill"),
    ]

    static let ba: [PlaceholderAction] = [
        .init(id: "ba.write", title: "Write 忍", symbolName: "pencil.and.scribble"),
        .init(id: "ba.name", title: "Name it", symbolName: "text.bubble"),
        .init(id: "ba.recite", title: "Recite", symbolName: "text.quote"),
    ]

    static func all(for kind: LayerKind) -> [PlaceholderAction] {
        switch kind {
        case .ma: return ma
        case .ba: return ba
        }
    }
}
