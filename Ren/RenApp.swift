import SwiftUI

@main
struct RenApp: App {
    private let store: LayerStore = {
        // The catalog ships in the bundle; failing to load it is a build defect, not a user state.
        let catalog = (try? GroundingCatalog.loadBuiltIn()) ?? GroundingCatalog(plugins: [])
        assert(!catalog.plugins.isEmpty, "grounding-catalog.json missing from bundle")
        return LayerStore(source: LayerActionSource(grounding: catalog))
    }()

    var body: some Scene {
        WindowGroup {
            MainView(store: store)
        }
    }
}
