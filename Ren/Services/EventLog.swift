import Foundation
import Observation
import RenDomain

/// The append-only log (02 §3.1), in memory for now.
///
/// Append-only is not a detail to add later — it is the property everything else is
/// derived from, so it is enforced here from the first commit: there is no update, no
/// delete, and no way to reach the storage except by appending. SwiftData persistence sits
/// behind `LoopEventRepository` in a later phase and does not change this shape.
@Observable
final class EventLog {
    private(set) var events: [LoopEvent] = []

    func append(_ event: LoopEvent) {
        events.append(event)
    }

    /// Events belonging to one mode. Derived on read, never stored.
    func events(for kind: LayerKind) -> [LoopEvent] {
        events.filter { $0.kind == kind }
    }

    func count(for kind: LayerKind) -> Int {
        events(for: kind).count
    }
}
