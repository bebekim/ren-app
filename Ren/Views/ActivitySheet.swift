import SwiftUI

/// Opened from any layer action. BA actions render their grounding plugin via one of
/// the fixed content-type renderers (§3.5); MA actions are placeholders for now.
struct ActivitySheet: View {
    let action: LayerAction
    let plugin: GroundingPlugin?
    /// Only the active (outermost) layer sows the next layer when finished.
    let sowsNextLayer: Bool
    var onFinish: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let plugin {
                    Text(plugin.summary)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    GroundingRenderer(plugin: plugin)
                } else {
                    ContentUnavailableView(
                        action.title,
                        systemImage: action.systemImage,
                        description: Text("Not built yet.")
                    )
                }
                Spacer(minLength: 0)
            }
            .padding()
            .navigationTitle(action.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                if sowsNextLayer {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            onFinish()
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

private struct GroundingRenderer: View {
    let plugin: GroundingPlugin

    var body: some View {
        switch plugin.contentType {
        case .writingCanvas:
            WritingCanvas(guide: plugin.manifest.character ?? "")
        case .textPrompt:
            let statements = plugin.manifest.statements ?? []
            if statements.isEmpty {
                ContentUnavailableView(
                    "No statements yet",
                    systemImage: "text.quote",
                    description: Text("These are yours to write — adding them comes in a later build.")
                )
            } else {
                ForEach(statements, id: \.self) { Text($0).font(.title3) }
            }
        case .imageGallery:
            ContentUnavailableView(
                "Photos",
                systemImage: "photo.on.rectangle",
                description: Text(plugin.manifest.note ?? "")
            )
        }
    }
}

/// Minimal finger-ink canvas over a faint guide character.
private struct WritingCanvas: View {
    let guide: String
    @State private var strokes: [[CGPoint]] = []

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16).fill(RenTheme.canvas)
                Text(guide)
                    .font(.system(size: 220, weight: .regular, design: .serif))
                    .foregroundStyle(RenTheme.ink.opacity(0.08))
                    .accessibilityHidden(true)
                Canvas { context, _ in
                    for stroke in strokes where stroke.count > 1 {
                        var path = Path()
                        path.addLines(stroke)
                        context.stroke(path, with: .color(RenTheme.ink), style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round))
                    }
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if value.translation == .zero { strokes.append([]) }
                        strokes[strokes.count - 1].append(value.location)
                    }
            )
            .accessibilityLabel("Writing area for \(guide)")

            Button("Clear") { strokes.removeAll() }
                .disabled(strokes.isEmpty)
        }
    }
}
