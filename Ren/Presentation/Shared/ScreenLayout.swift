import CoreGraphics
import RenDomain

/// The whole screen's geometry as one pure function (01 §8, 02 §8).
///
/// Deliberately free of SwiftUI so the rules are testable without a simulator, which is
/// the one habit worth keeping from the discarded prototype's `SeedLayout`.
///
/// Three things are *inputs* rather than constants, because each varies in a way that
/// silently breaks a layout tuned on one device:
///
/// - **Safe-area insets.** The SE design floor has a home button and a bottom inset of
///   0; every modern iPhone has a ~34pt inset and a swipe-up gesture that competes with
///   targets near the bottom edge. 01 §8 anchors the nest *and* the selectables row to
///   the bottom, so a constant here looks right on one device and wrong elsewhere.
/// - **Type scale.** `.body` runs roughly 17pt to 53pt across the accessibility sizes.
///   01 §9 writes text *inside* a box whose area is fixed by the nest ratios, so type
///   size changes what fits, not just how it looks.
/// - **Handedness.** 02 §5 invariant 9: the mirrored layout is not a per-screen option.
///   Nothing below names left or right; the anchor is a leading/trailing edge.
struct ScreenLayout {

    // MARK: - Inputs

    /// Insets in layout-relative terms. Leading/trailing rather than left/right so a
    /// mirrored layout needs no special case here.
    struct SafeArea: Equatable {
        var top: CGFloat = 0
        var bottom: CGFloat = 0
        var leading: CGFloat = 0
        var trailing: CGFloat = 0

        static let none = SafeArea()
        /// iPhone SE 2nd/3rd gen: status bar above, home button below, so no bottom inset.
        static let seClass = SafeArea(top: 20, bottom: 0)
        /// A current home-indicator iPhone, for comparison in tests.
        static let homeIndicator = SafeArea(top: 59, bottom: 34)
    }

    /// How much larger than default the user's text is. A plain multiplier rather than
    /// SwiftUI's `DynamicTypeSize`, so this type stays framework-free; the adapter that
    /// maps one to the other lives with the views.
    struct TypeScale: Equatable {
        var multiplier: CGFloat

        static let `default` = TypeScale(multiplier: 1.0)
        /// Roughly `.accessibilityExtraExtraExtraLarge`, the case to design against.
        static let largestAccessibility = TypeScale(multiplier: 3.1)
    }

    struct Input: Equatable {
        var size: CGSize
        var safeArea: SafeArea = .none
        var typeScale: TypeScale = .default
        var handedness: Handedness = .default
        var nest: Tunables.Nest = Tunables.draft.nest

        /// iPhone SE 2nd/3rd gen in portrait — the design floor (02 §8).
        static let seFloor = Input(size: CGSize(width: 375, height: 667), safeArea: .seClass)
    }

    // MARK: - Constants

    /// 01 §8 zone 0 sits in the standard navigation-bar row. Fixed: a nav bar does not
    /// grow with Dynamic Type, its content does.
    static let topBarHeight: CGFloat = 44
    /// HIG minimum touch target, and the floor for a box being tappable to select it.
    static let minimumTapTarget: CGFloat = 44
    /// Size of an in-box action button. Kept at the HIG minimum so the core can host three.
    static let actionTargetSize: CGFloat = 44
    static let sideGutter: CGFloat = 16
    static let selectablesPadding: CGFloat = 12
    /// Status zone height at default type: the forecast sentence plus the run line.
    static let baseStatusHeight: CGFloat = 60
    /// One tally entry — a label and its strokes — at default type (01 §9).
    static let baseEntryLineHeight: CGFloat = 22
    /// Narrower than this and an entry's label has nowhere to go.
    static let baseEntryMinWidth: CGFloat = 80
    /// Breathing room between the nest and the selectables row. Without it the outermost
    /// box rubs against the buttons, which is the same complaint the suspension fixes
    /// between the boxes themselves.
    static let zoneSpacing: CGFloat = 8
    /// Inset of an in-box action button from its box's edge.
    static let actionInset: CGFloat = 8

    // MARK: - Output

    struct Zones: Equatable {
        var topBar: CGRect
        var status: CGRect
        var nest: CGRect
        var selectables: CGRect

        static let empty = Zones(topBar: .zero, status: .zero, nest: .zero, selectables: .zero)
    }

    let input: Input

    init(_ input: Input) {
        self.input = input
    }

    /// The content rect, inset by the safe area. Resolved to absolute sides here and
    /// nowhere else.
    var content: CGRect {
        let insetLeft = input.handedness == .right ? input.safeArea.leading : input.safeArea.trailing
        let insetRight = input.handedness == .right ? input.safeArea.trailing : input.safeArea.leading
        let rect = CGRect(
            x: insetLeft,
            y: input.safeArea.top,
            width: input.size.width - insetLeft - insetRight,
            height: input.size.height - input.safeArea.top - input.safeArea.bottom
        )
        return rect.width > 0 && rect.height > 0 ? rect : .zero
    }

    private var selectablesHeight: CGFloat {
        Self.minimumTapTarget + 2 * Self.selectablesPadding * input.typeScale.multiplier
    }

    private var minimumStatusHeight: CGFloat {
        Self.baseStatusHeight * input.typeScale.multiplier
    }

    /// The side of the outermost box. Square, so it is bounded by whichever of width or
    /// remaining height runs out first — at default type on every supported iPhone that
    /// is width; at large accessibility sizes the status zone grows and height wins.
    var nestSide: CGFloat {
        let c = content
        guard c != .zero else { return 0 }
        let byWidth = c.width - 2 * Self.sideGutter
        let byHeight = c.height - Self.topBarHeight - selectablesHeight
            - minimumStatusHeight - Self.zoneSpacing
        return max(0, min(byWidth, byHeight))
    }

    /// True when the nest has been squeezed by the status zone rather than by the screen
    /// width — the signal that the layout is running out of vertical room.
    var isHeightConstrained: Bool {
        let c = content
        guard c != .zero else { return false }
        let byWidth = c.width - 2 * Self.sideGutter
        let byHeight = c.height - Self.topBarHeight - selectablesHeight
            - minimumStatusHeight - Self.zoneSpacing
        return byHeight < byWidth
    }

    var zones: Zones {
        let c = content
        let side = nestSide
        guard c != .zero, side > 0 else { return .empty }

        let topBar = CGRect(x: c.minX, y: c.minY, width: c.width, height: Self.topBarHeight)
        let selectables = CGRect(
            x: c.minX, y: c.maxY - selectablesHeight,
            width: c.width, height: selectablesHeight
        )
        // The nest square hugs the anchored edge rather than centring, so the inner
        // boxes stay inside thumb reach even when the square is narrower than the screen.
        let nestX = input.handedness == .right
            ? c.maxX - Self.sideGutter - side
            : c.minX + Self.sideGutter
        let nest = CGRect(x: nestX, y: selectables.minY - Self.zoneSpacing - side,
                          width: side, height: side)
        let status = CGRect(
            x: c.minX + Self.sideGutter, y: topBar.maxY,
            width: c.width - 2 * Self.sideGutter,
            height: max(0, nest.minY - topBar.maxY)
        )
        return Zones(topBar: topBar, status: status, nest: nest, selectables: selectables)
    }

    // MARK: - The nest

    /// The visible layers, outermost first, capped at the three the viewport shows.
    ///
    /// **Every box is suspended: it touches none of its parent's edges** (00 §2.5). Each is
    /// held off its parent's anchored corner by `floatingGapRatio`; the gap on the other two
    /// edges comes free from the size difference. The bias toward the corner is what keeps
    /// the inner boxes inside thumb reach (01 §8) — but bias is all it is, not contact.
    ///
    /// An earlier version had the boxes *share* that corner, which is flush on two edges.
    /// It was tested on device on 2026-09-25 and read as boxes rubbing against each other
    /// rather than nested and suspended, which is the same thing 00 §2.5 found by hand.
    /// The gap is measured against each *parent*, not the outermost box, so the suspension
    /// looks consistent at every level rather than shrinking with depth.
    var layerFrames: [CGRect] {
        let nest = zones.nest
        let ratios = input.nest.sideRatios
        guard nest != .zero, let first = ratios.first, first > 0 else { return [] }

        var frames: [CGRect] = [nest]
        var parent = nest
        for ratio in ratios.dropFirst() {
            let side = nest.width * CGFloat(ratio)
            let gap = parent.width * CGFloat(input.nest.floatingGapRatio)
            let x = input.handedness == .right ? parent.maxX - gap - side : parent.minX + gap
            let frame = CGRect(x: x, y: parent.maxY - gap - side, width: side, height: side)
            frames.append(frame)
            parent = frame
        }
        return frames
    }

    /// Where a layer's tally scribbles can be written: its own area minus the box suspended
    /// inside it (01 §9).
    ///
    /// Now that the inner box touches no edge, the free area is a *ring* rather than an
    /// L-shape, returned as the up-to-four rectangles that compose it.
    func freeRects(forLayerAt index: Int) -> [CGRect] {
        let frames = layerFrames
        guard frames.indices.contains(index) else { return [] }
        let outer = frames[index]
        guard frames.indices.contains(index + 1) else { return [outer] }
        let inner = frames[index + 1]

        let above = CGRect(x: outer.minX, y: outer.minY,
                           width: outer.width, height: inner.minY - outer.minY)
        let below = CGRect(x: outer.minX, y: inner.maxY,
                           width: outer.width, height: outer.maxY - inner.maxY)
        let leadingSide = CGRect(x: outer.minX, y: inner.minY,
                                 width: inner.minX - outer.minX, height: inner.height)
        let trailingSide = CGRect(x: inner.maxX, y: inner.minY,
                                  width: outer.maxX - inner.maxX, height: inner.height)

        return [above, below, leadingSide, trailingSide].filter { $0.width > 0 && $0.height > 0 }
    }

    /// How many tally entries fit in a layer's free area at the current type size.
    ///
    /// A *measurement*, not a policy: what to do when entries outgrow the space is still
    /// open (01 §9, 02 §7) — smaller writing, a summary line, or tap to open. This is
    /// what that decision will be made against, and it is what makes the question
    /// concrete rather than theoretical, because it already returns 0 for the core box at
    /// the largest accessibility sizes on the SE floor.
    func entryCapacity(forLayerAt index: Int) -> Int {
        let lineHeight = Self.baseEntryLineHeight * input.typeScale.multiplier
        let minWidth = Self.baseEntryMinWidth * input.typeScale.multiplier
        guard lineHeight > 0 else { return 0 }
        return freeRects(forLayerAt: index)
            .filter { $0.width >= minWidth }
            .reduce(0) { $0 + Int(($1.height / lineHeight).rounded(.down)) }
    }

    /// Centres for a layer's action buttons, placed **around** its free ring — one at each
    /// corner the box nested inside it does not occupy (00 §2.5's "~3 actions per layer").
    ///
    /// Corners rather than a row, which is what makes this fit at all. Three 44pt targets in
    /// a row need ~132pt and the core is ~114pt on the design floor — that mismatch is why
    /// 01 §8 moved actions out to a bottom row. At corners the same three targets need only
    /// ~88pt, so every layer can host its own actions after all.
    ///
    /// The inner box sits at the anchored bottom corner, so the three free corners are both
    /// top corners plus the bottom one away from the anchor.
    func actionAnchors(forLayerAt index: Int) -> [CGPoint] {
        let frames = layerFrames
        guard frames.indices.contains(index) else { return [] }
        let box = frames[index]
        let inset = Self.actionTargetSize / 2 + Self.actionInset
        // Too small to host them without the two top buttons colliding.
        guard box.width >= Self.actionTargetSize * 2, box.height >= Self.actionTargetSize * 2 else {
            return []
        }
        let leading = box.minX + inset
        let trailing = box.maxX - inset
        let top = box.minY + inset
        let bottom = box.maxY - inset
        let freeBottomX = input.handedness == .right ? leading : trailing
        return [
            CGPoint(x: leading, y: top),
            CGPoint(x: trailing, y: top),
            CGPoint(x: freeBottomX, y: bottom),
        ]
    }

    /// Whether a box is a reliable target for the tap that selects it (01 §8).
    ///
    /// Note this asks only about *selection*. The prototype put three 44pt action buttons
    /// inside each box, which the core cannot host at any supported size — 01 §8 resolved
    /// that by moving actions out to the selectables row.
    func isSelectable(layerAt index: Int) -> Bool {
        let frames = layerFrames
        guard frames.indices.contains(index) else { return false }
        return frames[index].width >= Self.minimumTapTarget
    }
}
