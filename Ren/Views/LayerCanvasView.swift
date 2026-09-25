import SwiftUI

enum RenTheme {
    static let canvas = Color(red: 0.97, green: 0.95, blue: 0.91)
    static let ink = Color(red: 0.12, green: 0.11, blue: 0.10)
    static let ma = Color(red: 0.31, green: 0.47, blue: 0.43)
    static let ba = Color(red: 0.78, green: 0.55, blue: 0.36)

    static func fill(for kind: LayerKind) -> Color {
        kind == .ma ? ma : ba
    }
}

/// Nested MA/BA layers, outermost = active. Display capped by `LayerViewport` (§2.6).
struct LayerCanvasView: View {
    let layers: [VisibleLayer]
    var onAction: (VisibleLayer, LayerAction) -> Void

    var body: some View {
        GeometryReader { proxy in
            let circles = SeedLayout.circles(in: proxy.size, count: layers.count)
            ZStack {
                ForEach(Array(zip(layers, circles)), id: \.0.depth) { layer, circle in
                    LayerDisc(layer: layer, circle: circle, onAction: onAction)
                }
            }
        }
    }
}

private struct LayerDisc: View {
    let layer: VisibleLayer
    let circle: SeedLayout.Circle
    var onAction: (VisibleLayer, LayerAction) -> Void

    var body: some View {
        let hostsActions = SeedLayout.canHostActions(circle)
        let centers = SeedLayout.actionCenters(for: circle)
        ZStack {
            Circle()
                .fill(RenTheme.fill(for: layer.kind).opacity(layer.depth == 0 ? 0.22 : 0.9))
                .overlay(Circle().stroke(RenTheme.fill(for: layer.kind), lineWidth: 1.5))
                // Soft shadow on nested layers: the seed must read as floating, not flush (§2.5).
                .shadow(color: .black.opacity(layer.depth == 0 ? 0 : 0.22), radius: 10, y: 6)
                .frame(width: circle.radius * 2, height: circle.radius * 2)
                .position(circle.center)
                .accessibilityElement()
                .accessibilityLabel("\(layer.kind.displayName) layer")

            Text(layer.kind.displayName)
                .font(.caption.weight(.semibold))
                .foregroundStyle(layer.depth == 0 ? RenTheme.ink.opacity(0.6) : .white.opacity(0.85))
                .position(SeedLayout.labelCenter(for: circle))
                .accessibilityHidden(true)

            if hostsActions {
                ForEach(Array(zip(layer.actions.prefix(SeedLayout.actionCount), centers)), id: \.0.id) { action, point in
                    Button {
                        onAction(layer, action)
                    } label: {
                        Image(systemName: action.systemImage)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(RenTheme.ink)
                            .frame(width: SeedLayout.minimumTarget, height: SeedLayout.minimumTarget)
                            .background(Circle().fill(.white.opacity(0.92)))
                    }
                    .buttonStyle(.plain)
                    .position(point)
                    .accessibilityLabel("\(layer.kind.displayName): \(action.title)")
                }
            } else {
                PreviewIndicators(centers: centers)
            }
        }
    }
}

/// §2.5: a layer too small for its actions shows 3 rising indicators in the
/// positions the real buttons will occupy, so preview and controls read as continuous.
private struct PreviewIndicators: View {
    let centers: [CGPoint]
    @State private var risen = false

    var body: some View {
        ForEach(centers.indices, id: \.self) { index in
            Capsule()
                .fill(.white.opacity(0.85))
                .frame(width: 6, height: 12)
                .offset(y: risen ? -4 : 4)
                .animation(
                    .easeInOut(duration: 1.1).repeatForever().delay(Double(index) * 0.18),
                    value: risen
                )
                .position(centers[index])
        }
        .accessibilityHidden(true)
        .onAppear { risen = true }
    }
}
