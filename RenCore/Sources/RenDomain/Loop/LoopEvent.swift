import Foundation

/// One thing the person did, recorded at the moment they did it.
///
/// History is an append-only log of immutable events (02 §3.1): the nest, each layer's
/// contents and — later — forecast evidence are all *derived* from it, and nothing derived
/// is stored as the record.
///
/// This is the minimal version. 02 §3.1's typed payloads (`MAActivity` / `BAActivity`, with
/// duration, reps and meal tier) and the `sowedBy` link that carries the recursion arrive
/// with the phase that needs them; the buttons are placeholders for now, so `label` stands
/// in for a payload.
public struct LoopEvent: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let occurredAt: Date
    public let kind: LayerKind
    /// Which placeholder action produced it. A payload replaces this later.
    public let label: String

    public init(id: UUID = UUID(), occurredAt: Date = Date(), kind: LayerKind, label: String) {
        self.id = id
        self.occurredAt = occurredAt
        self.kind = kind
        self.label = label
    }
}
