# ren-app

Native iOS app for the weight-loss feedback-loop companion described in
[`Specs/00_concept.md`](Specs/00_concept.md).

## Build & test

The Xcode project is generated from `project.yml` with [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```bash
xcodegen generate
xcodebuild test -project ren-app.xcodeproj -scheme Ren \
  -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath .derivedData
```

## Specs

- `Specs/00_concept.md` — product concept (PRD).
- `Specs/01_main_ui.md` — UI decisions (PRD).
- `Specs/02_architecture.md` — v1 architecture (Spec).

Docs are numbered `NN_name.md`; the number is the doc id and cross-references use
`NN §x.y`.

## Layout

> The tree below is the throwaway interaction prototype, superseded by
> `Specs/02_architecture.md`. It is being replaced, not extended.


- `Ren/Models` — `LayerNode` (unbounded MA/BA history, 00 §2.6), `LayerViewport` (display cap of 3),
  `GroundingPlugin` (data-only technique manifests, 00 §3.5).
- `Ren/Services` — `LayerStore` (in-memory history; no persistence yet).
- `Ren/Views` — `SeedLayout` (pure geometry for the 00 §2.5 rules), canvas, activity sheet.
- `Ren/Resources/grounding-catalog.json` — built-in grounding techniques, as data.
