import Foundation

/// PRD §3.5: a grounding technique is a manifest of plain data, rendered by one of a
/// small, fixed set of app-owned renderers. Never executable third-party content.
enum GroundingContentType: String, Codable, CaseIterable {
    case textPrompt
    case imageGallery
    case writingCanvas
}

struct GroundingManifest: Codable, Hashable {
    /// Character to trace, for `writingCanvas`.
    var character: String?
    var repeatCount: Int?
    /// User-authored statements for `textPrompt`. Empty by default: the app does not author them (§3.3).
    var statements: [String]?
    /// Placeholder note for `imageGallery` until the photo source is decided (§3.2).
    var note: String?
}

struct GroundingPlugin: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let summary: String
    let systemImage: String
    let contentType: GroundingContentType
    let estimatedMinutes: Int
    let manifest: GroundingManifest

    var action: LayerAction {
        LayerAction(id: "ba.\(id)", title: name, systemImage: systemImage)
    }
}

/// Phase 1 of §3.5: the built-in techniques, as data. No install/uninstall yet.
struct GroundingCatalog: Codable {
    let plugins: [GroundingPlugin]

    static let resourceName = "grounding-catalog"

    static func loadBuiltIn(bundle: Bundle = .main) throws -> GroundingCatalog {
        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }
        return try JSONDecoder().decode(GroundingCatalog.self, from: Data(contentsOf: url))
    }

    func plugin(forActionId actionId: String) -> GroundingPlugin? {
        plugins.first { $0.action.id == actionId }
    }
}
