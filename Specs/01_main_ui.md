# 01 PRD: UI — Seed, Forecast Rim, and Lens
*Version 0.3 (draft) - Created 2026-09-24, updated 2026-09-25*

> **Status**: UI decisions from the 2026-09-24 brainstorm. Builds on
> `00_concept.md`, which stays the product-level record. Where this doc refines a
> section of 00, it says which one. The architecture that implements these
> decisions is `02_architecture.md`.

## 1. The seed is sown at the win — visually, without words

*Decision. Resolves 00 §2.3 (timing shift).*

When a positive MA action is logged (a workout, a meal), a small BA seed quietly
appears inside the MA layer. There is no copy, no "heads up," and no warning at
that moment, so the achievement is not undercut.

The words come later: the forecast (§2) speaks near the anticipated window. The
visual sows the seed; the forecast tends it. The person learns the link by seeing
the seed appear every time they push hard, not by being told.

03 §4 gives the seed its mechanism: a hard workout raises the *reward pull* the same
day ("I earned it"), even while physical hunger is briefly suppressed. The silence
at the win also fits 03 §8: framing a run as work that earns something is what
raises that pull.

## 2. The forecast lives on the layer's rim

*Decision. Refines 00 §2.2 (semicircular weather-style forecast).*

The forecast is not a separate badge or widget. The top edge of each visible
layer **is** the forecast band. (00 §2.2 describes a semicircular arc; with the
rectangular layers in §8, the same idea runs along each box's top edge.)

| State | Rim treatment |
|---|---|
| Calm / clear | Thin, neutral rim |
| Watch | Thicker, amber rim |
| Warning (wildfire) | Textured rim with slow motion (shimmer), not just stronger red |
| Not enough history | Dotted rim — its own honest state, not a faded warning |

### Four rims, three domain states

`02 §3.4` deliberately keeps the domain states neutral — `insufficientHistory`,
`noPattern`, `patternNoticed` — and refuses to grade severity there, because a
severity name leaks into UI copy. So the watch/wildfire split is a *presentation*
decision, derived from how strong the evidence is:

| Domain state (02 §3.4) | Evidence | Rim |
|---|---|---|
| `insufficientHistory` | — | Dotted |
| `noPattern` | — | Thin, neutral |
| `patternNoticed` | below the wildfire threshold | Thicker, amber |
| `patternNoticed` | at or above the threshold | Textured, slow motion |

The threshold is a tunable (§11), not a fixed rule. One value object owns the
entire mapping — rim thickness, pattern, colour token, the words in the status
zone, and the accessibility label — so no renderer invents its own phrasing or
its own severity judgment.

Constraints carried over from 00 §2.2:
- The rim communicates an anticipated condition, not a score or prediction of failure.
- Accessible text names the layer and the observed pattern behind the state.
- Severity is calibrated to evidence; weak patterns show the dotted rim.

Added here:
- **No state is carried by colour alone.** Thickness and texture also encode it.
- **No state is carried by motion alone.** Under Reduce Motion the shimmer does
  not play, so thickness plus texture must separate all four treatments on their
  own. Dotted / thin / thick / thick-and-textured already do, which makes this
  nearly free to satisfy — but it has to stay true as the rims are refined.

Open: whether the warning state needs red at all, or whether motion and texture
carry the wildfire metaphor with less alarm. Test both.

## 3. Box growth and turnover rate — experiment

*To be decided by experiment (2026-09-24). Supersedes the earlier "seed grows as
the forecast window approaches" decision.*

The boxes grow, and grow into one another: core → middle → outer → leaves.
How fast they grow and how often they turn over will be found by experiment,
not fixed in this PRD.

Variables to test:
- **Cycle length.** How long one full turnover takes, and what drives it:
  clock time, the forecast window, or logged activity.
- **Growth happens at periodic intervals, not in real time** (decided).
  Boxes hold still between ticks and enlarge one step at each tick. The
  interval is to be found by experiment: every hour, every 3 hours, or another
  period.
- **Steps per turnover.** How many growth ticks it takes for the core to reach
  the middle's size, which together with the interval sets the cycle length.
- **Proportions.** 9:4:1 (side 3:2:1) is not self-similar: under continuous
  growth the proportions drift through the cycle. A self-similar ratio (for
  example 9:3:1, side ratio √3) looks the same at every moment of growth.
  With stepped growth, the difference only shows in the in-between steps.
  Compare both.

Test criterion carried over from 00 §2.5: growth must read as "getting
ready," not "something is coming for me."

## 4. The lens toggle lives in the status area

*Decision (2026-09-25), resolving the gesture collision with §8. Implements
00 §2.1 (one experience, two lenses).*

The lens flips labels between "what I did" (physical) and "what I felt"
(experiential). No layer moves or resizes; each keeps its place in time and its
shape. Only the vocabulary changes.

**Tapping a box selects it (§8); it does not flip the lens.** The lens is flipped
by a visible control in the status zone, and it applies to the whole screen
rather than to one layer. Reasons:

- A long-press is invisible until discovered, and it competes with the context
  menu gesture iOS users already expect from a press-and-hold.
- A visible control is reachable by VoiceOver and Switch Control; a long-press on
  a box is awkward for both.
- The lens is a way of reading the whole nest, so a global control matches what
  it actually does. A per-layer lens would let two visible layers disagree about
  which vocabulary they are using.

## 5. Open — not yet decided

- **Out-of-app urge path.** Whether BA actions should also be reachable from
  iOS system surfaces (Lock Screen, Dynamic Island) during a watch window, not only
  from inside the app. Pending discussion.
- **Recursion transition.** Superseded by the corner turnover in §8.

## 6. Grounding plugins — UI notes

The plugin contract (00 §3.5, 02 §3.3) covers **BA grounding techniques only**,
as data-only manifests rendered by the app's own fixed renderers.

| Technique | Kind | UI notes |
|---|---|---|
| 忍 calligraphy | Plugin — `writingCanvas` | Each finished character dissolves as the next one begins. |
| Naming the emotion | **Not a plugin** — a domain BA activity (02 §3.1) | Always present at a BA moment. Cannot be installed or uninstalled, so it can never be missing. |

Reciting statements (`textPrompt`) and photos (`imageGallery`) were dropped from v1 on
2026-09-25 (03 §4).

Naming the emotion was drafted as a plugin because the idea arrived from
`bebekim/empatheating`. It is not one: 00 §2.6 lists `:name-emotion` as a BA
*activity* beside the `:distraction` techniques, and 02 §3.1 makes it part of the
domain. Only the distraction techniques are plugins.

**Socialising is not in v1.** It was sketched as an MA plugin sourced from
`~/repositories/individual/dosets-ios`, but MA activities are not plugins at all
(02 §3.3), dosets-ios is a separate app rather than a manifest, and socialising as
an MA activity does not appear in 00. Per 02 §1 it stays out of scope until 00
carries a product decision for it.

## 7. Progress display: the asymmetric run

*Decision (2026-09-25). Resolves this section's own open question and the
conflict with 02 §5 invariant 1.*

- **In:** daily totals (the tally scribbles, §9) and a *run* of MA-active days.
- **Out:** KPIs, targets-as-scores, scoreboards, leaderboards, all-time bests.

A conventional streak is symmetric: the number that rewards you on the way up
punishes you on the way down, and the punishment arrives exactly when the person
is least able to absorb it. That is 00 §1's third loop — deliberate control
intensifying the other two — wired into the UI. The run keeps the pride and drops
the punishment, through three mechanisms.

**1. Tolerance — a miss pauses the run, it does not break it.** The run counts
active days with a slack allowance: it survives up to `toleranceDays` missed days
in any `toleranceWindow`. One bad day is not an event.

**2. A display threshold, and silence below it.** A run is shown only once it
passes `displayThreshold`. Below that, nothing is shown — no zero, no counter at
one, no "start again today". So after a genuine break the display simply goes
quiet. **A just-interrupted run and a brand-new user look identical.** The person
is never shown as having lost something.

**3. Never stored, only derived.** The run is computed from the log on read
(02 §3.4). There is no counter to reset, so there is nothing to destroy at a
break. This is what makes mechanisms 1 and 2 enforceable rather than aspirational.

The tolerance has outside support: in habit-formation research, missing a single
opportunity did not materially set people back (Lally 2010; see 03 §5).

**MA only.** Runs count MA-active days. BA activity never feeds a run, because if
it did, *not* grounding would break one — exactly what 00 §3.3 forbids.

**No notification on interruption**, and no "you lost your run" copy anywhere.

The run is an encouragement surface layered over an honest record, not a
replacement for it: the tally scribbles (§9) still show what happened day by day,
and a day with no entry simply has no entry. Whether an asymmetric run actually
avoids the rebound is an empirical question; 00 §2.2's testing burden applies here
too. Parameters in §11.

## 8. Screen layout: status, nest, selectables

*Decision. Based on Marcus's hand sketch and follow-up (2026-09-24). Replaces
the earlier "nested boxes", "dive" and side-rail drafts.*

Zones, top to bottom:

0. **Top bar (top-right corner).** Three icons, in this order from the inside
   out: notifications (1), profile (2), hamburger menu (3). The menu sits
   nearest the screen edge and holds Settings and the **plugin store** (the
   catalog in 00 §3.5 and the plugins in §6). The top bar sits in the
   standard navigation-bar row below the status bar and Dynamic Island.
1. **Status (top).** Text status: the forecast in words, the run or daily totals
   (§7), and the lens toggle (§4). This is where the forecast *speaks* (§1).
2. **The nest (middle).** Three rounded rectangles, fully enveloped,
   alternating MA and BA.
3. **Selectables (bottom).** A row of about 3 actions along the bottom of the
   screen.

### The nest

| Layer | Area | Side length | Role |
|---|---|---|---|
| Outer | 9 | 3 | Dominant mode |
| Middle | 4 | 2 | The other mode, held inside it |
| Core (seed) | 1 | 1 | The next turn, already sown |

- **Anchored at a bottom corner, not centred.** The middle and core sit toward
  the bottom-right corner, inside easy thumb reach so the inner boxes are easy
  to tap.
- **Shared corner, floating on the inner edges.** *(Decision 2026-09-25,
  reconciling with 00 §2.5's "the seed must read as floating, not flush".)* The
  three boxes meet at the anchored corner — that corner is the growth origin, so
  turnover reads as growing out of it. On its other two edges each inner box
  floats clear of its parent, with the soft-shadow cue 00 §2.5 found necessary at
  phone scale. Floating is preserved where it carries meaning; the corner is
  shared where the layout needs it.
- **Neither mode wins.** Boxes grow into one another (§3), but neither mode
  grows at the other's expense; the structure turns over rather than tipping.
- **Turnover.** When the loop advances, everything grows out of the corner by one
  level: core → middle, middle → outer, the old outer leaves, and a new core is
  sown at the corner. This replaces the "dive" in §5.
- **Forecast band.** Each layer's top edge carries its forecast state (§2).

### Selectables follow the selection

- By default the selectables belong to the **dominant mode** (the outer box).
- **Tapping an inner box selects it**, and the selectables switch to that
  layer's mode. For example, with MA dominant, tapping the BA middle box shows
  BA actions (忍, name the emotion, …).
- The selected box is marked (stronger outline). Tapping the outer box, or a
  turnover, returns selection to the dominant mode.

**Handedness setting (in Settings, under the hamburger menu).** One switch
mirrors **everything** for left-handers:
- top-bar icons move to the top-left, in mirrored order;
- the nest anchors to the bottom-left corner;
- the selectables row reverses order.

**Text is never mirrored.** Status, scribbles, labels and any text box stay
left-aligned and read left to right in both modes. Only the placement of
controls and boxes mirrors.

Every new screen and component must support the mirrored layout; it is not a
per-screen option.

**Device floor.** iPhone only, portrait only, with iPhone SE 2nd/3rd gen
(375 × 667pt) as the design floor — see 02 §8. Height is the binding constraint,
not width: the four zones share ~647pt on an SE against ~830pt on a current
iPhone, and the status zone is the one that has no fixed size. The nest must be
sized proportionally to the space available, not in absolute points, so it does
not float in empty space on a larger screen.

Open:
- **Single tub vs. nest.** 03 §7 records a hand-sketched alternative: one tub with a
  demand line, a capacity line, and input / capacity / output trays around it.
  Whether it replaces this nest or becomes one layer of it is undecided.
- **Growth.** Rate and proportions are an experiment (§3).
- **Same mode twice.** Outer and core are the same mode (MA–BA–MA). Decide
  whether selecting the core shows the same actions as the outer, or actions
  for "next time" (for example, prep for tomorrow's workout).

## 9. What you do is scribbled into its section

*Decision (2026-09-24).*

Each logged activity is recorded **inside the box of the mode it belongs to**,
as a handwritten-style scribble, not a chart or list. For example, "Run 40 min"
and "Squats 100" are written in the MA box; 忍 sessions in the BA box.

- Each entry is a label plus tally marks, grouped in fives (one stroke per
  unit).
- **Tally style is a setting:** East Asian 正 (five strokes complete a 正) or
  Western five-bar gate (four sticks, the fifth struck across). 正 is the default.
- Draft unit: one stroke per 10 minutes or 10 reps, so a 40-minute run is 4
  strokes and 100 squats is 2 full 正.
- An entry goes into the box that was selected when the action was tapped (§8).
- Entries are written in each box's free area, the part not covered by the box
  nested inside it.
- The scribbles are the daily totals (§7): a record of what happened, not a
  score against a target.

Open:
- **Unit size.** Confirm what one stroke means per activity (Marcus's note:
  "run 40 minutes → records 10 minutes of running"; see below).
- **Overflow.** The core box (area 1) has room for about two entries. Decide
  what happens when a box's free area fills up: smaller writing, a summary line,
  or tap to open the box.
- ~~Turnover~~ — decided below.

**At turnover:** scribbles travel with their box as it grows (core → middle →
outer). When the outermost box turns over it leaves the screen, and its scribbles
leave with it.

Nothing is *saved* at turnover — it was already saved. Each entry is written to
the append-only log at the moment the action is logged (02 §3.1), and the
scribbles are **derived** from that log for the layers currently in the viewport.
Turnover changes what the viewport derives, never what the log holds. The screen
is a view of the record, not the record itself.

Open: as a box grows, whether its scribbles scale up with it or stay the same
size and gain room around them.

## 10. Meal photo check (MA)

*Decision (2026-09-24). Refines the meal action in 00 §1.*

Taking a photo of each meal is a core MA action. There is **no calorie counting**.
After the photo, the person looks at it and checks one of three tiers:

| Tier | Label | Examples |
|---|---|---|
| Top | Healthy eating | Low fat, plant based |
| Middle | Tasty meal | — |
| Bottom | High sugar, highly processed | — |

- One tap after the photo; no portions, macros, or numbers.
- The tiers feed the demand/capacity model in 03 §4: the bottom tier is the clearest
  demand input, and the top tier is hypothesised to cost a little now and pay off
  over months. No line effect is claimed for the middle tier.
- The meal is scribbled into the MA box (§9) with its tier. Each tier has its own
  icon, so the tier is never shown by colour alone.

Open:
- **Who picks the tier.** The person picks it (current draft). Decide whether the
  app ever suggests a tier from the photo, or whether that would feel like being
  judged.
- **Tier wording on screen.** Whether the bottom tier's label stays descriptive
  ("high sugar, highly processed") so it reads as a fact about the food, not a
  verdict on the person.

## 11. Tunables

*Decision (2026-09-25). Everything the design intends to find by experiment lives
in one config surface, not scattered as constants in views.*

Nothing in this table is a settled value. They are here so §3's growth experiment
and §7's run can be swept without recompiling, and so no view hardcodes one.

| Parameter | Draft | Set by | Controls |
|---|---|---|---|
| `layerAreaRatios` | 9 : 4 : 1 | §3 | Nest proportions. 9:3:1 (side √3) is the self-similar alternative to compare. |
| `growthTickInterval` | — | §3 | How long boxes hold still between growth steps. |
| `growthStepsPerTurnover` | — | §3 | Steps for the core to reach the middle's size. |
| `strokeUnit` | 10 min / 10 reps | §9 | What one tally stroke means, per activity. |
| `tallyStyle` | 正 | §9 | 正 or the Western five-bar gate. A user setting, not an experiment. |
| `handedness` | right | §8 | Mirrors the whole layout. A user setting, not an experiment. |
| `displayThreshold` | 3 days | §7 | When a run becomes visible at all. |
| `toleranceDays` | 1 | §7 | Missed days a run survives… |
| `toleranceWindow` | 7 days | §7 | …within this rolling window. |
| `wildfireThreshold` | — | §2 | Where `patternNoticed` stops being amber and becomes textured. |

The lag tunables for the demand/capacity model (`runCapacityLag`, `girthLag` and
the rest) are listed with their evidence anchors in 03 §9 and belong to this same
config surface.

Two of the parameters in the table are user settings rather than experiment variables (`tallyStyle`,
`handedness`); they live in the same config type but are written by Settings, not
by a build configuration. See 02 §3.5 for the preferences port.

Worth testing `displayThreshold` hard. Too low and the run appears and vanishes
constantly, which is its own kind of noise. Too high and nobody ever sees it.
