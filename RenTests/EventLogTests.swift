import UIKit
import XCTest
import RenDomain
@testable import Ren

final class EventLogTests: XCTestCase {

    func testStartsEmpty() {
        let log = EventLog()
        XCTAssertTrue(log.events.isEmpty)
        XCTAssertEqual(log.count(for: .ma), 0)
        XCTAssertEqual(log.count(for: .ba), 0)
    }

    /// Append-only, in order: the log is the record everything else is derived from
    /// (02 §3.1), so insertion order is the history.
    func testAppendsInOrder() {
        let log = EventLog()
        log.append(LoopEvent(kind: .ma, label: "Meal"))
        log.append(LoopEvent(kind: .ba, label: "Write 忍"))
        log.append(LoopEvent(kind: .ma, label: "Workout"))

        XCTAssertEqual(log.events.map(\.label), ["Meal", "Write 忍", "Workout"])
    }

    /// Counts are derived on read, never stored — so the same log can be asked a different
    /// question later without a migration.
    func testCountsArePerModeAndDerived() {
        let log = EventLog()
        log.append(LoopEvent(kind: .ma, label: "Meal"))
        log.append(LoopEvent(kind: .ma, label: "Workout"))
        log.append(LoopEvent(kind: .ba, label: "Recite"))

        XCTAssertEqual(log.count(for: .ma), 2)
        XCTAssertEqual(log.count(for: .ba), 1)
        XCTAssertEqual(log.events(for: .ba).map(\.label), ["Recite"])
        XCTAssertEqual(log.events.count, 3, "filtering must not remove anything from the log")
    }

    /// Two identical taps are two events. Nothing de-duplicates, because the log records
    /// what happened rather than a state.
    func testRepeatingTheSameActionRecordsSeparateEvents() {
        let log = EventLog()
        log.append(LoopEvent(kind: .ma, label: "Meal"))
        log.append(LoopEvent(kind: .ma, label: "Meal"))

        XCTAssertEqual(log.count(for: .ma), 2)
        XCTAssertNotEqual(log.events[0].id, log.events[1].id)
    }

    /// Every placeholder button must name a symbol that actually resolves on the minimum
    /// deployment target — a bad SF Symbol name renders as nothing at all, silently.
    func testEveryPlaceholderActionSymbolResolves() {
        for kind in LayerKind.allCases {
            for action in PlaceholderAction.all(for: kind) {
                XCTAssertNotNil(UIImage(systemName: action.symbolName),
                                "\(action.symbolName) does not resolve")
            }
        }
    }

    func testEachModeOffersThreeActions() {
        for kind in LayerKind.allCases {
            XCTAssertEqual(PlaceholderAction.all(for: kind).count, 3, "01 §8: about 3 actions")
        }
    }
}
