import CoreGraphics

/// Pure geometry for nested layers, kept free of SwiftUI so the PRD §2.5 rules are testable:
/// the seed floats (touches neither edge), and a layer too small for 3 real ≥44pt targets
/// shows a preview instead of cramped buttons.
struct SeedLayout {
    static let minimumTarget: CGFloat = 44
    static let minimumTargetSpacing: CGFloat = 4
    static let actionCount = 3

    /// Child radius as a fraction of its parent's.
    static let childRadiusRatio: CGFloat = 0.60
    /// Downward offset of the child's center, as a fraction of the parent radius.
    static let childOffsetRatio: CGFloat = 0.28
    /// Height of the parent's action row above its center, as a fraction of the parent radius.
    static let actionRowRatio: CGFloat = 0.60

    struct Circle: Equatable {
        let center: CGPoint
        let radius: CGFloat
    }

    static func child(of parent: Circle) -> Circle {
        Circle(
            center: CGPoint(x: parent.center.x, y: parent.center.y + parent.radius * childOffsetRatio),
            radius: parent.radius * childRadiusRatio
        )
    }

    /// Smallest gap between the child's edge and the parent's edge.
    static func floatingGap(parent: Circle, child: Circle) -> CGFloat {
        let dx = child.center.x - parent.center.x
        let dy = child.center.y - parent.center.y
        return parent.radius - (dx * dx + dy * dy).squareRoot() - child.radius
    }

    /// Horizontal distance between neighbouring action centers.
    static func actionSpacing(for circle: Circle) -> CGFloat {
        circle.radius * 0.5
    }

    static func canHostActions(_ circle: Circle) -> Bool {
        actionSpacing(for: circle) >= minimumTarget + minimumTargetSpacing
    }

    /// Where the kind label sits: the band below the nested seed.
    static func labelCenter(for circle: Circle) -> CGPoint {
        CGPoint(x: circle.center.x, y: circle.center.y + circle.radius * 0.94)
    }

    /// Centers for the 3 actions (or their preview indicators — same positions, §2.5).
    static func actionCenters(for circle: Circle) -> [CGPoint] {
        let spacing = actionSpacing(for: circle)
        let y = circle.center.y - circle.radius * actionRowRatio
        return (0..<actionCount).map { index in
            CGPoint(x: circle.center.x + CGFloat(index - 1) * spacing, y: y)
        }
    }

    /// Circles for each visible depth, outermost first.
    static func circles(in size: CGSize, count: Int) -> [Circle] {
        guard count > 0 else { return [] }
        let radius = min(size.width, size.height) / 2 - 2
        var current = Circle(center: CGPoint(x: size.width / 2, y: size.height / 2), radius: radius)
        var result = [current]
        while result.count < count {
            current = child(of: current)
            result.append(current)
        }
        return result
    }
}
