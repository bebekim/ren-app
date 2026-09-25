# 02 Spec: v1 Architecture
*Version 0.2 (draft) - Created 2026-09-24, updated 2026-09-25*

> **Status**: draft for review. Implements the architectural direction of
> `00_concept.md` (00 §2.6 data model, 00 §3.5 plugin model) and the UI decisions in
> `01_main_ui.md`, for the native iOS build.
>
> `03_stock_flow_model.md` (the demand/capacity model, lag tunables and the v1
> activity set) is **not yet architected here**. Its effect on this Spec is listed in
> §7 rather than decided.
>
> A throwaway interaction prototype exists in `Ren/` — an in-memory `LayerNode`
> history, circular layers, per-layer action buttons, no persistence. It predates
> this Spec and diverges from it (circles not rounded rectangles, actions inside
> boxes rather than a selectables row, `LayerViewport` not `ViewportPolicy`, no
> event log). **It is being replaced, not migrated.** This Spec is written as a
> fresh build; the prototype's only lasting contributions are the findings recorded
> in 00 §2.5 and the shape of `SeedLayout` as pure, testable geometry.

## 1. Scope

In scope for v1:

- The MA/BA loop as an append-only event log, and the capped three-layer home view
  derived from it (00 §2.5, 00 §2.6).
- The BA grounding toolkit as manifest-driven built-in plugins (00 §3.2, §3.5).
- A local, evidence-based forecast (00 §2.2), and the derived run (01 §7).
- iPhone, portrait only. See §8 for the device floor.

Out of scope until separately scheduled, and deliberately absent from the source tree:

- A remote or curated online plugin catalog.
- Any integration with `bebekim/empatheating` (sync, API client).
- Any integration with `dosets-ios` (handoff, shared data). "Socialising" as an MA
  activity is not in 00 and needs a product decision there first.
- Third-party-authored plugins of any kind.
- **Game-type grounding techniques.** 00 §2.6's `:simple-game` cannot be a data
  manifest (invariant 5), so it would need either a fourth renderer or the
  third-party-code posture deferred above.
- **Out-of-app surfaces** — widgets, Live Activities, Lock Screen, Dynamic Island,
  App Intents, and local notifications (01 §5's open "out-of-app urge path").
  One consequence is not deferrable, and §8 covers it: an extension runs in a
  separate process and cannot read the app container's store, so the SwiftData
  store is placed in an **app group from the start**. That costs a few lines now
  and is a data migration later.
- iPad, landscape, and multiple scenes.

## 2. Module layout

One repository. The app target holds everything framework-bound; a local Swift
package holds the domain and use cases so the compiler enforces the dependency
direction.

```text
ren-app/
├── project.yml                         # XcodeGen; ren-app.xcodeproj is generated, not edited
├── Ren/                                # app target
│   ├── RenApp.swift
│   ├── CompositionRoot.swift           # the only place concrete types are wired
│   ├── Persistence/                    # SwiftData implementations of the ports
│   │   ├── SwiftDataLoopEventRepository.swift
│   │   ├── LoopEventRecord.swift       # @Model mirror + mapping to/from LoopEvent
│   │   └── SwiftDataPluginInstallationRepository.swift   # phase 3
│   ├── Preferences/                    # @AppStorage-backed PreferencesRepository
│   ├── Catalog/
│   │   ├── BundledPluginCatalogRepository.swift
│   │   └── grounding-catalog.json
│   ├── Resources/
│   │   └── tunables.json               # 01 §11; one file, no constants in views
│   ├── Assets.xcassets/                # colour sets with light/dark appearances (§8)
│   └── Presentation/
│       ├── Home/                       # MainView, NestView, ForecastRimView, StatusView, SelectablesView
│       ├── Grounding/                  # one renderer per ContentType
│       ├── Settings/                   # handedness, tally style (01 §11)
│       ├── Store/                      # plugin catalog browse — phase 3
│       └── Shared/                     # Handedness, Layout, Theme, ForecastRimStyle
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
is no separate `Infrastructure` module in v1. `Ren/Persistence`, `Ren/Preferences`
and `Ren/Catalog` play that role until there is more behind the ports than
SwiftData, `@AppStorage` and a bundled JSON file.

**Presentation state.** Views observe an `@Observable` store directly; there is no
separate `ViewModel` layer. iOS 17's Observation makes one redundant here, and the
use cases in `RenApplication` already hold the logic a view model would otherwise
accumulate. This is a decision, not an omission — the alternative was considered
and rejected, so `HomeViewModel` should not appear.

**The Xcode project is generated.** `ren-app.xcodeproj` is XcodeGen output; adding
the `RenCore` package or a new folder means editing `project.yml` and re-running
`xcodegen generate`, never editing the project file.

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

- **`sowedBy` carries the recursion.** 00 §2.6's `sow` is "this MA produced this
  BA". A flat, time-ordered list cannot reconstruct that nest without a guessed
  rule, so the link is recorded when the event is.
- **Payloads are typed.** No untyped dictionary or JSON blob in the domain.
- **Only loop events go in the log.** UI telemetry (forecast shown, screen
  viewed) is not a loop event and is not stored here.

`MAActivity` covers aerobic, anaerobic, exercise prep, and meal log (00 §1
terminology). `BAActivity` covers emotion naming and grounding used. Emotion naming
is a domain activity, not a plugin (00 §2.6). Context recording was dropped as an
activity (03 §4). Time comes from `occurredAt`, so nothing is lost.

**Payloads carry what the UI derives from, and nothing pre-aggregated.** Two things
in 01 are rendered from MA payloads, so the payloads must hold their inputs:

- **Tally scribbles** (01 §9) are drawn as one stroke per `strokeUnit` — draft: 10
  minutes or 10 reps. So an aerobic event carries its duration and an anaerobic
  event its rep count. The *stroke count is never stored*; it is derived at render
  time, because `strokeUnit` is a tunable (01 §11) and changing it must re-render
  history rather than invalidate it.
- **Meal tier** (01 §10) — one of three tiers, chosen by the person, stored on the
  meal-log payload. It is a description of the food, never a grade of the person,
  and it carries no numeric value, so nothing can sum or average it.

Neither daily totals nor run length is ever a stored field. Both are derived
(§3.4).

### 3.2 Viewport: the three-layer cap

```swift
public struct ViewportPolicy {
    public static let maxVisibleLayers = 3
    public func snapshot(from history: [LoopEvent]) -> HomeSnapshot
}
```

- The cap is a property of `ViewportPolicy`, never of the log (00 §2.6).
- Beyond the cap the snapshot simply ends: no truncation marker, no "more" stub,
  no hint of a fourth layer (00 §2.5).
- A turnover is a new snapshot derived from a longer history. Nothing is deleted
  or rewritten.

### 3.3 Grounding plugins

The plugin contract applies to BA grounding techniques only. MA activities are not
plugins.

The three content types below are **the v1 subset** of the five sketched in
00 §3.5 (audio and external link are not built). Adding a technique is a catalog
data change; adding a content type is a code change and a review.

```swift
public struct GroundingPlugin: Identifiable {
    public let id: String            // namespaced and stable, e.g. "ren.calligraphy"
    public let version: Int
    public let name: String
    public let summary: String
    public let contentType: ContentType
    public let estimatedMinutes: Int   // not Duration: Duration's Codable form is a
                                       // seconds/attoseconds pair, unreadable in a
                                       // hand-edited catalog. Map at the boundary if
                                       // a Duration is wanted.
    public let symbolName: String      // SF Symbol; see the availability note below
    public let manifest: Manifest      // plain data; never code
}

public enum ContentType {
    case textPrompt       // reciting self-authored statements and quotes
    case writingCanvas    // calligraphy, e.g. 忍
    case imageGallery     // user-curated photos (placeholder technique, 00 §3.2)
}
```

- The app owns one renderer per `ContentType`.
- **`symbolName` is data, so it can be wrong.** SF Symbols have OS-version
  availability, and a catalog entry naming a symbol the running OS lacks renders
  nothing. The catalog repository resolves each name at load, substitutes a
  documented fallback symbol when resolution fails, and a test asserts every
  shipped name resolves on the minimum deployment target.
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
  00 §2.2 says to show.
- **State names are neutral.** No `warning`, `risk`, or `failure`. The name tends
  to leak into UI copy (00 §2.2: never frame the moment as an oncoming failure).
- **Insufficient history is a first-class result.** No pattern is shown without
  evidence behind it.
- A forecast being shown, or an offered action being taken, is never recorded as
  proof that it changed an outcome.
- **Three states, four rims.** 01 §2 renders four rim treatments. The domain does
  not grade severity, so the watch/wildfire split is derived in presentation from
  evidence strength against a tunable threshold. One value object in
  `Presentation/Shared/ForecastRimStyle` owns that whole mapping — thickness,
  pattern, colour token, the words in the status zone, and the accessibility label —
  so no renderer invents a phrasing or a severity of its own, and the "never colour
  alone, never motion alone" rule (invariant 6) is checkable in one place.

#### The run

01 §7's run is the same shape as a forecast: a pattern observed over the same log,
never shown without evidence, with no failure state.

```swift
public enum RunState: Equatable {
    case none                                   // nothing to show
    case emerging(days: Int)                    // below the display threshold
    case established(days: Int, tolerated: Int)
}
```

- **No `broken`, no zero, no all-time best.** A just-interrupted run and a
  brand-new user both produce `.none`, and the UI renders nothing for it. That
  indistinguishability is the design, not a shortcut.
- **Never stored.** `RunState` is derived on read. There is no counter to reset, so
  a break destroys nothing — this is what makes 01 §7's asymmetry enforceable
  rather than aspirational.
- **MA only.** BA events are invisible to the run, because if they counted, *not*
  grounding would break one — which 00 §3.3 forbids.
- Tolerance, window, and display threshold are tunables (01 §11), not constants.

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

/// User settings (01 §11): handedness, tally style. Not loop events, never in the log.
public protocol PreferencesRepository {
    var handedness: Handedness { get set }
    var tallyStyle: TallyStyle { get set }
}
```

Preferences are deliberately a separate port from the log. They are not history,
they are not derived from history, and nothing about them belongs in an
append-only record of what the person did. The app-target implementation is
`@AppStorage`-backed.

## 4. Application

| Use case            | Does                                                                 |
|---------------------|----------------------------------------------------------------------|
| `RecordActivity`    | Appends an MA or BA event (setting `sowedBy`), then calls `BuildForecast` with that event. |
| `LoadHomeSnapshot`  | Reads the log and returns `ViewportPolicy.snapshot`.                 |
| `GetGroundingOffer` | Returns the installed plugins, or the built-in defaults if none are installed, so the BA moment is never empty (00 §3.5). |
| `BuildForecast`     | Takes an optional triggering event. Home load calls it without one; `RecordActivity` calls it right after an MA event. |
| `ObserveRun`        | Derives `RunState` from MA events in the log (01 §7). Reads tunables for threshold, tolerance and window. Stores nothing. |

`BuildForecast` accepting a triggering event keeps 00 §2.3 (speak up at the
workout vs. later in the evening) a presentation decision rather than something
the architecture settles in advance.

## 5. Invariants

These come from 00 §3.3 ("reversible, not diagnostic"). The module layout cannot
enforce them, so they are checked in code review and, where possible, in tests.

1. **Runs are observed, not scored.** A run of MA-active days may be *derived* from
   the log and shown once it passes the display threshold; no run length is ever
   stored. There is no zero state, no broken state, no notification on
   interruption, and no all-time best. A run below the threshold and a run just
   interrupted are indistinguishable from no history at all. Nothing grades a day,
   and BA activity never feeds a run. *(Replaces the earlier blanket "no streaks",
   which conflicted with 01 §7; the protection it offered is preserved above.)*
2. **Using a grounding technique is recorded; not using one is not.** There is no
   `abandonedAt`, `skipped`, or `completed: false`.
3. **Uninstalling removes a plugin from future offers only.** Past events stay
   intact and readable.
4. **Deleting user-authored content is a separate, explicit user action**, never a
   side effect of uninstalling.
5. **Plugin manifests are data.** Nothing in a manifest is executed or interpreted
   as markup, script, or code.
6. **No state is carried by colour alone, and none by motion alone.** Every forecast
   state stays distinguishable with colour removed (colour blindness) and with
   motion removed (Reduce Motion). Both channels can be absent for the same person
   at the same time, so thickness and texture must separate all four rim
   treatments on their own (01 §2).
7. **Dismissing a grounding sheet is not an event.** A sheet is dismissible by
   drag, so nothing may be appended from `onDisappear`. Only the explicit
   completion path appends — otherwise invariant 2 breaks silently.
8. **Selection and lens are ephemeral.** Which box is selected (01 §8) and which
   lens is active (01 §4) are view state. Neither enters the log, and neither is
   evidence for a forecast.
9. **Every screen supports the mirrored layout.** Handedness is not a per-screen
   option (01 §8). Layout is expressed in leading/trailing terms that resolve
   against the setting; text is never mirrored.

## 6. Phasing

Follows 00 §3.5: prove the manifest-to-renderer contract before personalising it.

0. **Shell.** `project.yml` gains the `RenCore` package; `tunables.json` and the
   colour sets land; `Handedness` and the layout policy exist before any screen
   does. These are cheap now and structural later (invariant 9, §8).
1. **Loop.** `RenCore` package, `LoopEvent`, `ViewportPolicy`, `RecordActivity`,
   `LoadHomeSnapshot`, SwiftData persistence, home view. Tests cover snapshot
   derivation at depths 0 through 5 and the three-layer cap.

   Includes **mapping `LoopEvent` to a SwiftData record**, which is not a
   one-liner: `Body` is an enum with associated values, so even where SwiftData
   stores it as a composite attribute it cannot be filtered or sorted on in a
   `#Predicate`. `LoopEventRecord` therefore carries `layerKind` and `occurredAt` as
   queryable columns alongside the payload. Verify the composite-attribute
   behaviour on the iOS 17 minimum before committing to it.
2. **Built-in grounding.** `grounding-catalog.json` with the three 00 §3.2
   techniques, `BundledPluginCatalogRepository`, the three renderers,
   `GetGroundingOffer` returning the full built-in set. No install or uninstall.
3. **Install and enable.** `PluginInstallationRepository`, a catalog browse screen,
   default-set fallback.
4. **Forecast and run.** `BuildForecast` against local evidence, `ObserveRun`,
   `ForecastRimStyle`, `ForecastRimView`.

Forecasting comes last because it needs real history to be worth testing, and
phases 1 to 3 are what produce that history. The run is in the same phase for the
same reason, and because both read the same log through the same shape of query.

## 7. Open questions

- ~~**Minimum iOS version.**~~ **Resolved (2026-09-25): iOS 17.** SwiftData requires
  it, `project.yml` already targets it, and the device floor (§8) runs it. Because
  SwiftData sits behind `LoopEventRepository`, revisiting the persistence choice
  later stays cheap.
- **When a layer starts.** Does every MA event sow a new BA layer, or only some
  (e.g. a workout but not a meal log)? This decides when `sowedBy` is set. 03 §4
  suggests an answer: the events that raise demand (hard workouts, the
  ultra-processed meal tier) sow; the ones that lower it (the walk) may not.
- **Where user-authored content lives.** Quotes and photo references could live in
  the plugin manifest (per install) or in a separate user-content store shared
  across plugins. The second makes invariant 4 simpler.
- **Photo storage.** *Leaning:* `PhotosPicker`, with the chosen images copied into
  the app container. That needs no photo-library permission string, survives the
  person deleting the original, and makes invariant 4 enforceable because the copy
  is ours to delete on explicit request. Confirm before building the
  `imageGallery` renderer.
- **Overflow in a box's free area.** 01 §9 leaves open what happens when scribbles
  outgrow the space — smaller writing, a summary line, or tap to open. §8 makes
  this pressing rather than theoretical: it is reached on the device floor at large
  type sizes, not only in edge cases.
- **Renderers for dropped techniques.** Reciting and photos were dropped from v1
  (03 §4), leaving 忍 as the only built-in plugin. `textPrompt` and `imageGallery`
  (§3.3) and the phase 2 plan (§6) still assume three. Either keep them for future
  catalog entries, or cut them and add them back when a technique needs them. The
  two questions above about user-authored content and photo storage only matter if
  they are kept. The code still ships both: `grounding-catalog.json` has
  `recite-verse` and `photo-recall`, and `PlaceholderActions.swift` has a Recite
  action.
- **What 03 adds to the domain.** None of this is architected yet:
  - **Sleep** (03 §4's capacity tray) is neither MA nor BA, so it has no event kind.
  - **Waist girth** measurements (03 §2) need an event kind of their own.
  - **HealthKit.** 03 assumes runs and sleep arrive from HealthKit. That is a new
    read-only data source, a permission prompt, and a port. It is absent from §1's
    scope.
  - **The lines and lags** (03 §3, §5) would be derived from the log, like the run
    and the forecast. The lag tunables (03 §9) join `tunables.json`.
- **Same mode twice.** 01 §8: outer and core are the same mode (MA–BA–MA). Whether
  selecting the core offers the same actions as the outer or "next time" actions
  changes what `GetGroundingOffer` and the MA action source are asked for.

## 8. Platform and device constraints

*Decided 2026-09-25. These are architectural because each one is an input to a
layout or storage decision, not a styling choice made per screen.*

**iPhone only, portrait only, iOS 17 minimum.** No iPad layout, no landscape, one
scene. `Info.plist` must be narrowed to portrait-only — the current prototype
declares all four iPad orientations, promising a layout that does not exist.

**Design floor: iPhone SE 2nd/3rd gen, 375 × 667pt.** Both run iOS 17 and 18.
Height binds harder than width: four stacked zones (01 §8) share ~647pt on an SE
against ~830pt on a current iPhone.

**Safe-area insets are a layout input, not a constant.** The SE has a home button
and a bottom inset of 0; every modern iPhone has the home indicator, a ~34pt bottom
inset, and a swipe-up gesture that competes with targets near the bottom edge.
Since 01 §8 anchors both the nest and the selectables row to the bottom, the layout
policy takes insets as a parameter and the views use `safeAreaInset`. A constant
here looks correct on the development device and wrong everywhere else.

**Handedness is an environment value, not a layout direction.** `layoutDirection`
would mirror the tree in one line but also flips text alignment and reading order,
which 01 §8 forbids. So a `Handedness` value in the environment drives
leading/trailing resolution instead, and text is never mirrored. iOS has no system
handedness setting to read, so it is ours to ask for. Open: how handedness composes
with a genuinely right-to-left locale, if the app is ever localized.

**Dynamic Type is a structural input.** Semantic fonts only; no `.system(size:)`
for content. `.body` runs from 17pt to roughly 53pt across the accessibility
sizes — about 3×. The layout policy therefore takes the type size as an input
alongside the size and insets, because 01 §9 writes text *inside* a box whose area
is fixed by the nest ratios. The SE floor at a large accessibility size is the
case to design against, and it is what makes the overflow question in §7 real.

**Colours are tokens, never literals.** Colour sets in `Assets.xcassets`, referenced
by name; no RGB at a use site. This is what makes the palette swappable, and it is
also what makes dark mode a later decision rather than a later rewrite. Open:
whether the paper-and-ink palette gets a dark appearance or the app declares itself
light-only — the latter is possible but discouraged by HIG.

**The nest is sized proportionally, never in absolute points.** Ratios come from
`tunables.json` (01 §11) so the growth experiment can be swept without
recompiling, and so a layout tuned at 375pt does not leave a larger screen looking
empty.
