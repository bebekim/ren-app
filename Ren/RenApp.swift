import SwiftUI
import RenDomain

@main
struct RenApp: App {
    /// The only place concrete types are wired (02 §2).
    private let tunables = TunablesStore.loadOrDraft()

    var body: some Scene {
        WindowGroup {
            MainView(tunables: tunables)
        }
    }
}
