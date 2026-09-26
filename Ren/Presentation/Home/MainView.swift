import SwiftUI
import RenDomain

/// The nest (00 §2.5, 01 §8).
///
/// Actions sit at the three free corners of each box rather than in a row below the nest —
/// tested by hand on 2026-09-25 to get a feel for reach.
///
/// **The innermost box carries status, not actions** (decided 2026-09-25 on device). Three
/// 44pt targets in a ~114pt core left it reading as a button cluster rather than a layer.
/// Status is also the role the core already has in 01 §8 — it is "the next turn, already
/// sown", and what the forecast speaks about is exactly what is coming.
///
/// Deliberately absent: the forecast rim, growth and turnover, the tally scribbles, and
/// persistence.
struct MainView: View {
    @State private var log = EventLog()
    /// Which box is selected. View state only: 02 §5 invariant 8 keeps selection out of the
    /// log, and it is never evidence for anything.
    @State private var selectedDepth = 0

    let tunables: Tunables
    /// Hardcoded for now. It becomes a stored setting when Settings exists (01 §11); the
    /// layout already resolves every edge from it, so that change stays local.
    private let handedness: Handedness = .default

    /// MA outermost, alternating inward — 01 §8's MA–BA–MA.
    private var kinds: [LayerKind] { LayerKind.alternating(from: .ma, count: 3) }

    /// The innermost visible layer: the seed, which carries status instead of actions.
    private var statusDepth: Int { kinds.count - 1 }

    var body: some View {
        GeometryReader { proxy in
            let layout = ScreenLayout(ScreenLayout.Input(
                size: proxy.size,
                safeArea: ScreenLayout.SafeArea(
                    top: proxy.safeAreaInsets.top,
                    bottom: proxy.safeAreaInsets.bottom,
                    leading: proxy.safeAreaInsets.leading,
                    trailing: proxy.safeAreaInsets.trailing
                ),
                handedness: handedness,
                nest: tunables.nest
            ))

            ZStack(alignment: .topLeading) {
                RenTheme.canvas
                ForEach(Array(layout.layerFrames.enumerated()), id: \.offset) { depth, frame in
                    layer(depth: depth, frame: frame, anchors: layout.actionAnchors(forLayerAt: depth))
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .ignoresSafeArea()
    }

    // MARK: - One layer

    /// Each box is suspended — it touches none of its parent's edges (00 §2.5). The shadow is
    /// the floating cue; an inset alone was not convincing at phone scale.
    private func layer(depth: Int, frame: CGRect, anchors: [CGPoint]) -> some View {
        let kind = kinds[depth]
        let isSelected = depth == selectedDepth

        return ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(RenTheme.fill(for: kind).opacity(depth == 0 ? 0.22 : 0.92))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(RenTheme.ink.opacity(isSelected ? 0.55 : 0.12),
                                      lineWidth: isSelected ? 2 : 1)
                }
                .shadow(color: .black.opacity(depth == 0 ? 0 : 0.18), radius: 8, y: 4)
                .frame(width: frame.width, height: frame.height)
                .offset(x: frame.minX, y: frame.minY)
                // A gesture rather than a Button: the action buttons sit on top of this, and
                // nesting buttons makes which one receives the tap ambiguous.
                .onTapGesture { selectedDepth = depth }
                .accessibilityElement()
                .accessibilityLabel("\(kind.accessibleName) layer, \(log.count(for: kind)) recorded")
                .accessibilityAddTraits(isSelected ? [.isSelected] : [])

            if depth == statusDepth {
                status(frame: frame)
            } else {
                tally(kind, depth: depth, frame: frame)
                actions(kind: kind, depth: depth, anchors: anchors)
            }
        }
    }

    /// 01 §8 zone 1's content, living in the seed rather than in a band at the top.
    ///
    /// Only what actually exists is shown. There is no forecast yet (02 §3.4 is a later
    /// phase), so rather than invent one this says the honest first state: with no history
    /// there is no pattern to report. 02 §3.4 makes "insufficient history" a first-class
    /// result for the same reason — a pattern is never shown without evidence behind it.
    private func status(frame: CGRect) -> some View {
        VStack(spacing: 2) {
            if log.events.isEmpty {
                Text("no history")
            } else {
                Text("\(log.count(for: .ma)) MA · \(log.count(for: .ba)) BA")
                    .monospacedDigit()
                Text("no pattern yet")
                    .foregroundStyle(.white.opacity(0.65))
            }
        }
        .font(.caption2)
        .multilineTextAlignment(.center)
        .foregroundStyle(.white.opacity(0.92))
        .padding(6)
        .frame(width: frame.width, height: frame.height)
        .offset(x: frame.minX, y: frame.minY)
        .allowsHitTesting(false)
        .accessibilityElement()
        .accessibilityLabel(log.events.isEmpty
            ? "Status: no history yet"
            : "Status: \(log.count(for: .ma)) physical, \(log.count(for: .ba)) experiential. No pattern yet.")
    }

    /// A count, standing in for 01 §9's tally scribbles. Enough to see that a tap recorded
    /// something; the strokes and 正 grouping come with that section.
    ///
    /// Sits in the top-centre strip between the two upper action buttons. Centring it in the
    /// box put the middle layer's label *behind* the core, where it could not be read.
    private func tally(_ kind: LayerKind, depth: Int, frame: CGRect) -> some View {
        Text(log.count(for: kind) > 0 ? "\(kind.shortName) \(log.count(for: kind))" : kind.shortName)
            .font(.caption.weight(.semibold))
            .monospacedDigit()
            .foregroundStyle(depth == 0 ? RenTheme.ink.opacity(0.8) : .white)
            .frame(width: frame.width, height: frame.height, alignment: .top)
            .padding(.top, ScreenLayout.actionInset + ScreenLayout.actionTargetSize / 2 - 8)
            .offset(x: frame.minX, y: frame.minY)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    // MARK: - Actions, around the box

    /// One button per free corner. Icon only: three labelled buttons per layer across three
    /// layers is nine labels, which buries the nest it is supposed to sit inside.
    private func actions(kind: LayerKind, depth: Int, anchors: [CGPoint]) -> some View {
        let available = PlaceholderAction.all(for: kind)
        return ForEach(Array(zip(available.indices, anchors)), id: \.0) { index, centre in
            let action = available[index]
            Button {
                log.append(LoopEvent(kind: kind, label: action.title))
                selectedDepth = depth
            } label: {
                Image(systemName: action.symbolName)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(RenTheme.ink)
                    .frame(width: ScreenLayout.actionTargetSize,
                           height: ScreenLayout.actionTargetSize)
                    .background(RenTheme.canvas.opacity(0.88), in: Circle())
                    .overlay(Circle().strokeBorder(RenTheme.ink.opacity(0.12), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .offset(x: centre.x - ScreenLayout.actionTargetSize / 2,
                    y: centre.y - ScreenLayout.actionTargetSize / 2)
            .accessibilityLabel("\(action.title), \(kind.accessibleName)")
        }
    }
}

#Preview {
    MainView(tunables: .draft)
}
