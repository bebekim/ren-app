# Spec 01: v1 Architecture
*Version 0.1 (draft) - Created 2026-09-24*

> **Status**: draft for review. Implements the architectural direction of
> `PRD_weight_loss_feedback_loops.md` (§2.6 data model, §3.5 plugin model) for the
> native iOS build. No code exists yet; this Spec is written against an empty repo,
> not as a migration of an existing prototype.

## 1. Scope

In scope for v1:

- The MA/BA loop as an append-only event log, and the capped three-layer home view
  derived from it (PRD §2.5, §2.6).
- The BA grounding toolkit as manifest-driven built-in plugins (PRD §3.2, §3.5).
- A local, evidence-based forecast (PRD §2.2).

Out of scope until separately scheduled, and deliberately absent from the source tree:

- A remote or curated online plugin catalog.
- Any integration with `bebekim/empatheating` (sync, API client).
- Any integration with `dosets-ios` (handoff, shared data). "Socialising" as an MA
  activity is not in the PRD and needs a product decision there first.
- Third-party-authored plugins of any kind.

## 2. Module layout

One repository. The app target holds everything framework-bound; a local Swift
package holds the domain and use cases so the compiler enforces the dependency
direction.

```text
ren-app/
├── Ren.xcodeproj
├── Ren/                                # app target
│   ├── RenApp.swift
│   ├── CompositionRoot.swift           # the only place concrete types are wired
│   ├── Persistence/                    # SwiftData implementations of the ports
│   │   ├── SwiftDataLoopEventRepository.swift
│   │   └── SwiftDataPluginInstallationRepository.swift   # phase 3
│   ├── Catalog/
│   │   ├── BundledPluginCatalogRepository.swift
│   │   └── grounding-catalog.json
│   └── Presentation/
│       ├── Home/                       # MainView, LayerCanvasView, ForecastRimView, HomeViewModel
│       ├── Grounding/                  # one renderer per ContentType
│       └── Shared/
│
└── RenCore/                            # local Swift package, same repo
    ├── Package.swift
    ├── Sources/RenDomain/              # Foundation only
    │   ├── Loop/
    │   ├── Activities/
    │   ├── Grounding/
    │   ├── Forecast/
    │   └── Ports/
    ├── Sources/RenApplication/         # use cases; depends on RenDomain only
    └── Tests/                          # run with `swift test`, no simulator needed
```

### 2.1 Dependency rules

| Module           | May import                                   |
|------------------|----------------------------------------------|
| `RenDomain`      | Foundation                                   |
| `RenApplication` | Foundation, `RenDomain`                      |
| `Ren` (app)      | anything, including SwiftUI, SwiftData, both packages |

These are declared in `Package.swift`; a violating `import` fails the build. There
is no separate `Infrastructure` module in v1. `Ren/Persistence` and `Ren/Catalog`
play that role until there is more behind the ports than SwiftData and a bundled
JSON file.

## 3. Domain

### 3.1 Loop events: the source of truth

History is an append-only log of immutable events. The recursive home-screen nest,
each layer's contents, and forecast evidence are all derived from it; nothing
derived is stored as the record.

```swift
public struct LoopEvent: Identifiable, Equatable {
    public let id: UUID
    public let occurredAt: Date
    public let sowedBy: LoopEvent.ID?   // the MA event that sowed this BA layer, or nil
    public let body: Body

    public enum Body: Equatable {
        case ma(MAActivity)
        case ba(BAActivity)
    }

    public var layerKind: LayerKind { ... }   // derived from body; never stored separately
}
```

- **`sowedBy` carries the recursion.** PRD §2.6's `sow` is "this MA produced this
  BA". A flat, time-ordered list cannot reconstruct that nest without a guessed
  rule, so the link is recorded when the event is.
- **Payloads are typed.** No untyped dictionary or JSON blob in the domain.
- **Only loop events go in the log.** UI telemetry (forecast shown, screen
  viewed) is not a loop event and is not stored here.

`MAActivity` covers aerobic, anaerobic, and meal log (PRD §1 terminology).
`BAActivity` covers emotion naming, context recording, and grounding used. Emotion
naming is a domain activity, not a plugin.

### 3.2 Viewport: the three-layer cap

```swift
public struct ViewportPolicy {
    public static let maxVisibleLayers = 3
    public func snapshot(from history: [LoopEvent]) -> HomeSnapshot
}
```

- The cap is a property of `ViewportPolicy`, never of the log (PRD §2.6).
- Beyond the cap the snapshot simply ends: no truncation marker, no "more" stub,
  no hint of a fourth layer (PRD §2.5).
- A turnover is a new snapshot derived from a longer history. Nothing is deleted
  or rewritten.

### 3.3 Grounding plugins

The plugin contract applies to BA grounding techniques only. MA activities are not
plugins.

```swift
public struct GroundingPlugin: Identifiable {
    public let id: String            // namespaced and stable, e.g. "ren.calligraphy"
    public let version: Int
    public let name: String
    public let summary: String
    public let contentType: ContentType
    public let estimatedDuration: Duration
    public let manifest: Manifest    // plain data; never code
}

public enum ContentType {
    case textPrompt       // reciting self-authored statements and quotes
    case writingCanvas    // calligraphy, e.g. 忍
    case imageGallery     // user-curated photos (placeholder technique, PRD §3.2)
}
```

- The app owns one renderer per `ContentType`. Adding a technique is a catalog
  data change; adding a content type is a code change and a review.
- Manifest content that the user authors (quotes, photos) belongs to the user and
  survives uninstalling the plugin that displays it.
- A `grounding used` event stores a display snapshot (name, content type) so past
  history stays readable after the plugin is uninstalled or changed.

### 3.4 Forecast

```swift
public struct Forecast {
    public let layerKind: LayerKind
    public let state: State
    public let evidence: Evidence       // e.g. matching: 3, of: 4, window: evenings after hard workouts
    public let generatedAt: Date

    public enum State { case insufficientHistory, noPattern, patternNoticed }
}
```

- **Evidence is reported as counts, not a confidence score.** A few local data
  points do not support a probability, and "3 of the last 4 evenings" is what
  PRD §2.2 says to show.
- **State names are neutral.** No `warning`, `risk`, or `failure`. The name tends
  to leak into UI copy (PRD §2.2: never frame the moment as an oncoming failure).
- **Insufficient history is a first-class result.** No pattern is shown without
  evidence behind it.
- A forecast being shown, or an offered action being taken, is never recorded as
  proof that it changed an outcome.

### 3.5 Ports

```swift
public protocol LoopEventRepository {
    func append(_ event: LoopEvent) throws
    func events(since: Date?) throws -> [LoopEvent]
}

public protocol PluginCatalogRepository {
    func availablePlugins() throws -> [GroundingPlugin]
}

public protocol PluginInstallationRepository {   // implemented in phase 3
    func installedPluginIDs() throws -> Set<GroundingPlugin.ID>
    func install(_ id: GroundingPlugin.ID) throws
    func uninstall(_ id: GroundingPlugin.ID) throws
}
```

## 4. Application

| Use case            | Does                                                                 |
|---------------------|----------------------------------------------------------------------|
| `RecordActivity`    | Appends an MA or BA event (setting `sowedBy`), then calls `BuildForecast` with that event. |
| `LoadHomeSnapshot`  | Reads the log and returns `ViewportPolicy.snapshot`.                 |
| `GetGroundingOffer` | Returns the installed plugins, or the built-in defaults if none are installed, so the BA moment is never empty (PRD §3.5). |
| `BuildForecast`     | Takes an optional triggering event. Home load calls it without one; `RecordActivity` calls it right after an MA event. |

`BuildForecast` accepting a triggering event keeps PRD §2.3 (speak up at the
workout vs. later in the evening) a presentation decision rather than something
the architecture settles in advance.

## 5. Invariants

These come from PRD §3.3 ("reversible, not diagnostic"). The module layout cannot
enforce them, so they are checked in code review and, where possible, in tests.

1. **No streaks, scores, or success/failure states.** No type or field in any
   module counts consecutive days or grades a day.
2. **Using a grounding technique is recorded; not using one is not.** There is no
   `abandonedAt`, `skipped`, or `completed: false`.
3. **Uninstalling removes a plugin from future offers only.** Past events stay
   intact and readable.
4. **Deleting user-authored content is a separate, explicit user action**, never a
   side effect of uninstalling.
5. **Plugin manifests are data.** Nothing in a manifest is executed or interpreted
   as markup, script, or code.

## 6. Phasing

Follows PRD §3.5: prove the manifest-to-renderer contract before personalising it.

1. **Loop.** `RenCore` package, `LoopEvent`, `ViewportPolicy`, `RecordActivity`,
   `LoadHomeSnapshot`, SwiftData persistence, home view. Tests cover snapshot
   derivation at depths 0 through 5 and the three-layer cap.
2. **Built-in grounding.** `grounding-catalog.json` with the three PRD §3.2
   techniques, `BundledPluginCatalogRepository`, the three renderers,
   `GetGroundingOffer` returning the full built-in set. No install or uninstall.
3. **Install and enable.** `PluginInstallationRepository`, a catalog browse screen,
   default-set fallback.
4. **Forecast.** `BuildForecast` against local evidence, `ForecastRimView`.

Forecasting comes last because it needs real history to be worth testing, and
phases 1 to 3 are what produce that history.

## 7. Open questions

- **Minimum iOS version.** SwiftData requires iOS 17. Confirm that is acceptable.
- **When a layer starts.** Does every MA event sow a new BA layer, or only some
  (e.g. a workout but not a meal log)? This decides when `sowedBy` is set.
- **Where user-authored content lives.** Quotes and photo references could live in
  the plugin manifest (per install) or in a separate user-content store shared
  across plugins. The second makes invariant 4 simpler.
- **Photo storage.** References to Photos library assets vs. copies inside the
  app's container, which affects privacy and what survives the user deleting a
  photo.
