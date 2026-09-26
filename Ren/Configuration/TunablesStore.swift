import Foundation
import RenDomain

/// Loads `tunables.json` (01 §11) from the bundle, validating it rather than trusting it.
///
/// A malformed or absent tunables file is a *build* defect, not a user state, so it
/// fails loudly in debug and falls back to the documented drafts in release rather than
/// laying out a nest from nonsense.
enum TunablesStore {
    static let resourceName = "tunables"

    enum LoadError: Error, CustomStringConvertible {
        case missingResource
        case decodingFailed(Error)
        case invalid(Error)

        var description: String {
            switch self {
            case .missingResource:
                return "\(resourceName).json is not in the bundle — check project.yml resources"
            case let .decodingFailed(error):
                return "\(resourceName).json does not match Tunables: \(error)"
            case let .invalid(error):
                return "\(resourceName).json decoded but is invalid: \(error)"
            }
        }
    }

    static func load(from bundle: Bundle = .main) throws -> Tunables {
        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw LoadError.missingResource
        }
        let tunables: Tunables
        do {
            tunables = try JSONDecoder().decode(Tunables.self, from: Data(contentsOf: url))
        } catch {
            throw LoadError.decodingFailed(error)
        }
        do {
            try tunables.validate()
        } catch {
            throw LoadError.invalid(error)
        }
        return tunables
    }

    static func loadOrDraft(from bundle: Bundle = .main) -> Tunables {
        do {
            return try load(from: bundle)
        } catch {
            assertionFailure("\(error)")
            return .draft
        }
    }
}
