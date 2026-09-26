import Foundation

/// The nest's proportions, kept in config rather than in a view (01 §11).
///
/// 01 §3 decides the ratio by experiment, so the point of this type is that the ratio can
/// change without recompiling. It holds only what the nest needs; the run and growth
/// parameters in 01 §11 arrive with the phases that use them.
public struct Tunables: Codable, Equatable, Sendable {
    public var nest: Nest

    public init(nest: Nest) {
        self.nest = nest
    }

    public struct Nest: Codable, Equatable, Sendable {
        /// Layer *areas*, outermost first. 9 : 4 : 1 is the current draft; 01 §3 asks to
        /// compare 9 : 3 : 1, which is self-similar and so looks the same at every moment
        /// of a growth cycle.
        public var layerAreaRatios: [Double]

        /// How far an inner box is held off its parent's anchored corner, as a fraction of
        /// the parent's side.
        ///
        /// Every box is **suspended** — it touches none of its parent's edges (00 §2.5).
        /// The gap on the two edges away from the corner comes free from the size
        /// difference; this is the gap on the two edges *at* the corner, which would
        /// otherwise be zero. Tested on device 2026-09-25: boxes sharing the corner read as
        /// rubbing against each other rather than suspended.
        public var floatingGapRatio: Double

        public init(layerAreaRatios: [Double], floatingGapRatio: Double) {
            self.layerAreaRatios = layerAreaRatios
            self.floatingGapRatio = floatingGapRatio
        }

        /// Side lengths as fractions of the outermost side.
        ///
        /// Areas are squares, so a side ratio is the square root of an area ratio. This is
        /// the easy thing to get wrong: 9 : 4 : 1 gives sides 1, 0.67, 0.33 — the core is a
        /// *third* of the outer box, not a ninth.
        public var sideRatios: [Double] {
            guard let largest = layerAreaRatios.first, largest > 0 else { return [] }
            return layerAreaRatios.map { ($0 / largest).squareRoot() }
        }
    }

    public enum Invalid: Error, Equatable, CustomStringConvertible {
        case layerCountMismatch(got: Int, expected: Int)
        case ratiosNotDescending([Double])
        case nonPositiveRatio([Double])
        case floatingGapOutOfRange(Double)

        public var description: String {
            switch self {
            case let .layerCountMismatch(got, expected):
                return "layerAreaRatios has \(got) entries; the viewport shows \(expected) layers (02 §3.2)"
            case let .ratiosNotDescending(r):
                return "layerAreaRatios must be strictly descending, outermost first: \(r)"
            case let .nonPositiveRatio(r):
                return "layerAreaRatios must all be > 0: \(r)"
            case let .floatingGapOutOfRange(v):
                return "floatingGapRatio must be > 0 so boxes never touch, and < 0.25, got \(v)"
            }
        }
    }

    /// Checked at load rather than trusted: a bad config file is a build defect, and failing
    /// loudly beats laying out a nest from nonsense.
    public func validate() throws {
        let expected = 3   // 02 §3.2 ViewportPolicy.maxVisibleLayers
        guard nest.layerAreaRatios.count == expected else {
            throw Invalid.layerCountMismatch(got: nest.layerAreaRatios.count, expected: expected)
        }
        guard nest.layerAreaRatios.allSatisfy({ $0 > 0 }) else {
            throw Invalid.nonPositiveRatio(nest.layerAreaRatios)
        }
        guard zip(nest.layerAreaRatios, nest.layerAreaRatios.dropFirst()).allSatisfy({ $0 > $1 }) else {
            throw Invalid.ratiosNotDescending(nest.layerAreaRatios)
        }
        // Zero is rejected rather than merely discouraged: a zero gap is the shared-corner
        // layout that failed on device, so the type refuses to express it at all.
        guard nest.floatingGapRatio > 0, nest.floatingGapRatio < 0.25 else {
            throw Invalid.floatingGapOutOfRange(nest.floatingGapRatio)
        }
    }

    /// The draft in 01 §11.
    public static let draft = Tunables(
        nest: Nest(layerAreaRatios: [9, 4, 1], floatingGapRatio: 0.05)
    )
}
