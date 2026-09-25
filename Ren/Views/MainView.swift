import SwiftUI

struct MainView: View {
    @State var store: LayerStore
    @State private var presented: PresentedAction?

    private struct PresentedAction: Identifiable {
        let layer: VisibleLayer
        let action: LayerAction
        var id: String { "\(layer.depth).\(action.id)" }
    }

    var body: some View {
        VStack(spacing: 8) {
            Text("Ren 忍")
                .font(.title2.weight(.semibold))
                .foregroundStyle(RenTheme.ink)
            Text("Finishing an action on the outer layer sows the next one.")
                .font(.footnote)
                .foregroundStyle(RenTheme.ink.opacity(0.6))
            LayerCanvasView(layers: store.visibleLayers) { layer, action in
                presented = PresentedAction(layer: layer, action: action)
            }
            .animation(.spring(duration: 0.5), value: store.visibleLayers)
        }
        .padding(.top, 12)
        .padding(.horizontal, 16)
        .background(RenTheme.canvas.ignoresSafeArea())
        .sheet(item: $presented) { item in
            ActivitySheet(
                action: item.action,
                plugin: store.source.grounding.plugin(forActionId: item.action.id),
                sowsNextLayer: item.layer.depth == 0,
                onFinish: { store.completeActiveAction() }
            )
        }
    }
}
