# 00 PRD: Weight-Loss Feedback-Loop Companion
*Version 0.2 (draft) - Created 2026-09-22, updated 2026-09-25*

> **Status**: the product-level record. Originally a brainstorm migrated from
> `bebekim/empatheating` (where it started inside an unrelated Flask counseling-app
> codebase, because that is where the session happened to be running).
>
> This doc is doc `00` in this repo's numbered `Specs/`. `01_main_ui.md` carries the
> UI decisions and `02_architecture.md` is the v1 Spec written against this doc.
> Several sections below have since been refined or superseded by those two; each
> says so inline. Where they disagree with this doc, **the later-numbered doc
> wins** and this one should be corrected to match.

## 1. Problem Statement

Losing weight requires fighting two (really three) interacting feedback mechanisms at
once, not one:

1. **Energy regulation** — hunger, fatigue, and appetite responding to energy
   availability and body-weight change. NIDDK describes this as the body's own
   "feedback control" of calorie intake: weight loss can *increase* appetite through a
   response that opposes further loss.
2. **Learned reward and relief** — cues, routines, stress, and anticipated pleasure
   driving a craving for a *particular* food, distinct from physical hunger even
   though the two often arrive together.
3. **Deliberate control** — goals, rules, and self-evaluation ("I shouldn't eat, I
   already ruined today"), which can itself intensify the other two when applied too
   rigidly (an aggressive correction can produce oscillation: restrict, rebound,
   stricter restriction).

Calorie counters and most fitness apps instrument only the first of these (what was
eaten, what was burned). None of them connect a person's own intervention — a workout,
a restriction — to the compensating response it produces in the hours that follow, at
the moment that connection would actually be useful.

### Guiding principle

This is neither a body-positivity app (accept the current state, drop the weight-loss
goal) nor a pure calorie-counting app (chase the goal, ignore the wiring). The goal is
real. So is the reward circuitry that years of dieting, restriction, or reward-seeking
may have already wired into the person. The product's job is to manage the second in
service of the first — not deny the wiring exists, and not let managing it quietly
become the goal in place of the one the person actually has.

### Terminology: MA / BA

Shorthand used throughout the rest of this doc and the design canvas:

- **MA (metabolic adaptation)** — the physical action set: aerobic and anaerobic
  exercise, meal logging (a photo-based, non-calorie-counting classifier is one
  candidate approach — see the Jev/laya note in the design canvas), and low-friction
  exercise preparation (for example, setting out shoes or changing into gym shorts).
  Maps to "Energy regulation" above.
- **BA (brain addiction)** — the craving-response set: naming the emotion/urge,
  and the grounding toolkit in section 3 (calligraphy, self-affirming statements,
  photos of loved ones). Maps to "Learned reward and relief" above.

In the recursive-growth interface test (design canvas), MA and BA are **interwoven,
not permanently ranked**: an MA action (a workout or logged meal) may sow a BA craving
seed, and a BA response in turn may reveal or sow the next MA layer. The recursive
MA→BA→MA→BA structure in section 2.6 is the governing model — like the seed of the
opposite state in a yin-yang symbol, or two strands of a double helix — rather than a
one-way hierarchy. A given view may give its currently expanded MA layer more surface
area because physical/metabolic tracking has more legitimate ongoing content at that
moment; when BA is the active layer, the relationship reverses. This local size choice
does not mean one feature matters more. BA controls must nevertheless remain reachable
with less navigation than the urge takes to escalate.

## 2. Product Concept

### 2.1 One experience, two lenses

The person having the experience is one continuous thing; the physical view (activity,
meals, recovery) and the experiential view (hunger, urge, mood) are two lenses on the
*same* event, not two apps. The interface should never force a choice between "fitness
app" and "counseling app" — switching lenses should preserve the event's place in time
and its relationship to what came before and after.

### 2.2 Anticipation over logging: a forecast for each layer

> **Refined by 01 §2.** The semicircular arc below became the *top edge of each
> layer* once the nest became rounded rectangles (01 §8) — same idea, different
> geometry. The three neutral domain states live in 02 §3.4; the four rim
> treatments and the rule mapping one onto the other are in 01 §2. The severity
> vocabulary below ("yellow watch", "red wildfire") is UI-facing language only and
> deliberately does not appear in the domain.

The most useful moment is often *before* a familiar difficult window, not after food
has been logged. Each currently visible MA or BA layer can carry the same compact,
semicircular weather-style forecast: a calm/clear state, a yellow watch, or a red
wildfire-style warning. The arc communicates an anticipated condition, not a score,
diagnosis, or prediction of failure; its accessible text must name the layer and the
observed pattern behind it.

- **MA forecast — low energy / exercise friction.** For example: “Yellow watch: low
  energy has preceded skipped movement on 3 of your last 4 comparable days.” The
  forecast can offer a small preparation choice—set out shoes, change into gym shorts,
  select a short workout, or save a personal reminder or verse to revisit. These are
  ways to reduce friction or support a transition, not evidence that the person will
  exercise or that the prompt caused an outcome.
- **BA forecast — anticipated craving / relief-seeking.** For example: “Yellow watch:
  strong evening cravings followed hard workouts on 3 of your last 4 comparable days.”
  It can invite the person to make what may be coming easier to meet: choose a
  distraction or grounding activity, queue a verse or reminder, or prepare a
  calligraphy or photo option (the simple-game idea is out of scope for v1 — see
  §2.6). The offer stays optional and nonjudgmental;
  it does not assume the coming sensation is a craving rather than hunger.

Forecasts surface patterns from the person's own history rather than generic warnings,
explain their basis, and invite correction (“does today feel similar?”). The visual
severity must be calibrated to the available evidence and remain able to say “not
enough history” rather than infer risk from a weak pattern. Testing must establish
whether the warning metaphor helps preparation without creating alarm or undercutting
a win; its presence alone does not establish that any suggested action helps.

### 2.3 Where the seed is sown (resolved — see 01 §1)

> **Resolved by 01 §1.** Both, split by channel: the seed appears *visually and
> wordlessly* inside the MA layer at the moment of the win, so the achievement is
> not undercut, and the forecast *speaks* later, near the anticipated window. The
> open question below is kept for the reasoning that produced that answer.

The taijitu (yin-yang symbol)'s dot — a seed of the opposite state already present at
the peak of one state, like the summer solstice being the exact moment daylight starts
shrinking again — reframes *when* the product should speak up. Section 2.2's forecast
waits until close to the anticipated difficult window (mid-evening, before the usual
9pm hunger). A sharper reading: the seed for the rebound is sown at the moment of the
positive action itself — the workout — not sometime later during the drift toward it.

This is an open question, not a settled decision: should the awareness moment move to
sit alongside the win itself ("nice work — heads up, this kind of effort tends to sow
tonight's craving too," right at 6:30pm) instead of, or in addition to, the later
forecast? Speaking up at the peak risks undercutting the achievement; speaking up only
later risks feeling like a disconnected, separate warning. This needs testing against
how it actually lands, not just design intuition.

### 2.4 Visual language exploration

> **Superseded for layout by 01 §8**, which replaced the nested-boxes, "dive" and
> side-rail drafts with the status / nest / selectables screen. The canvas link
> below is kept as a record of the exploration; per §2.5 the canvas itself was
> abandoned as a prototyping tool.

Several concrete visual approaches for making the interlocked, delayed nature of these
loops legible — a shared timeline with two interwoven strands, a lens-shifting slider
between "what I did" and "what I experienced," a phone-scaled seesaw/tug-of-war for the
balancing (opposes) vs. reinforcing (compounds) distinction, and reference causal-loop
diagrams (the "Fixes that Fail" archetype) applied to this exact scenario — are sketched
in a shared design canvas: https://claude.ai/artifact/NBq66bho1w6AQze3JhFcDJ

### 2.5 Interface test: findings so far

A recursive-growth prototype (an active MA layer reveals a BA seed, which can in turn
reveal the next MA layer, per 2.3 and 2.6) was built and hand-tested in the design
canvas above. The canvas tool itself proved too cumbersome to keep testing
feel/interaction in — further hands-on iteration on this specific interaction is
moving to a different prototyping setup. What came out of the exercise before that,
as durable requirements rather than tool-specific output:

- **Cap nesting at 3 layers, not 4.** An early version showed a third, smaller seed
  forming inside the BA seed once it grew (recursion continuing indefinitely).
  Feedback: this reads as "the next threat is already coming," which is stressful
  rather than clarifying. Stop at outer/MA/BA — three layers, no visible fourth.
- **The seed must read as floating, not flush.** A small inset alone (~14px) was not
  visually convincing as "suspended" at phone scale — it needs an unambiguous cue
  (e.g. a soft shadow under it) so "not touching either edge" is legible at a glance,
  not something you have to measure to notice.
  *Partly superseded by 01 §8:* with the nest anchored at a bottom corner, the boxes
  **share that corner** and float clear on their other two edges, keeping the shadow
  cue. Floating is preserved where it carries meaning; the corner is shared where
  thumb reach and the turnover animation need it.
- ~~**Each layer needs room for ~3 quick-access actions**~~ — **superseded by
  01 §8.** The finding was that ~3 actions per layer collides with the ~44pt
  touch-target minimum once a layer is the nested seed: on the SE-class floor the
  core box is about 114pt across, and three 44pt targets plus spacing need ~132pt.
  01 §8 resolves it by moving the actions **out of the boxes** into a selectables
  row at the bottom of the screen. Tapping a box only *selects* it, and a 114pt
  target is comfortable for that. What survives is the underlying rule: neither
  mode is permanently the larger one.
- ~~**A layer too small for its 3 actions needs a preview state**~~ — **superseded
  by 01 §8** for the same reason. The 3 rising indicators existed to stand in for
  buttons a small layer could not host; with no buttons inside any box, there is
  nothing to preview. (Worth keeping in mind if a box ever hosts controls again.)

### 2.6 Data model: recursive and unbounded; display: capped at 3

The "3 layers, not 4" finding in 2.5 is a display rule, not a data-model rule — the
underlying MA→BA→MA→BA cycle is genuinely recursive and should stay unbounded (every
workout really can sow another seed, indefinitely). The recursion belongs in the type;
the cap belongs to whatever reads it. Sketched in Lisp to make the separation concrete:

```lisp
;; --- the type: genuinely recursive, no ceiling ---

(defstruct node
  kind        ; 'MA or 'BA
  activities  ; this layer's activity set
  child)      ; another NODE, or NIL — nothing here stops it from going deep

(defparameter *ma-activities*
  '(:aerobic      (running cycling walking)
    :anaerobic    (strength-training hiit)
    :meal-log     (photo-capture manual-entry)
    :exercise-prep (set-out-shoes change-into-gym-shorts
                    choose-short-workout revisit-saved-reminder-or-verse)))

(defparameter *ba-activities*
  '(:name-emotion   (tag-feeling)
    :record-context (time place person situational-awareness)
    :distraction    (:ren-calligraphy (write "忍" :repeat n)
                      :simple-game     (puzzle match-3)   ; out of scope for v1 — see below
                      :photo-recall    (loved-ones-gallery)   ; placeholder
                      :recite-verse    (user-saved-quotes))))

;; SOW is the actual recursive generator: given a node, produce what it sows.
;; Nothing bounds how many times you can call this.
(defun sow (node)
  (make-node
    :kind       (if (eq (node-kind node) 'MA) 'BA 'MA)
    :activities (if (eq (node-kind node) 'MA) *ba-activities* *ma-activities*)
    :child      node))

;; the chain grows exactly as far as real events keep happening —
;; every day's MA wraps yesterday's whole history
(defparameter *history*
  (sow (sow (sow (make-node :kind 'MA :activities *ma-activities* :child nil)))))
;; MA(BA(MA(BA(MA(...)))))  — as deep as life has actually gone


;; --- the view: same structure, but it stops looking past depth 3 ---

(defun render (node depth &optional (max-depth 3))
  (cond
    ((null node) nil)
    ((>= depth max-depth) nil)             ; hard stop — no stub, no "..." hint
    (t (list (node-kind node)
             (node-activities node)
             (render (node-child node) (1+ depth) max-depth)))))

(render *history* 0)
;; (MA <activities> (BA <activities> (MA <activities> nil)))
;; — three real layers; everything deeper exists in *history* but render never touches it
```

> **Two notes on the activity lists above.**
>
> `:simple-game` is **out of scope for v1.** 02 §5 invariant 5 requires every plugin
> manifest to be plain data that is never executed or interpreted as code, and a
> puzzle or match-3 is code, not a manifest. It would need either a fourth
> content-type renderer built into the app or the third-party-code security posture
> that 02 §1 defers. The other three distraction techniques are data and ship in v1.
>
> `:name-emotion` is a **domain BA activity, not a plugin** — as listed here, and as
> fixed in 02 §3.1. It is always available at a BA moment and cannot be installed or
> uninstalled, so it can never be missing. Only the `:distraction` techniques are
> plugins. (01 §6 briefly listed it as a plugin; that was wrong and is corrected.)

Deliberate choice: the depth cutoff in `render` returns `nil`, not a `:truncated` marker
or a "more coming" stub — 2.5's feedback was that even a *hint* of a next layer forming
felt stressful, so the render function shouldn't leak that hint either. It just stops.

This mirrors a pattern already used in `bebekim/empatheating`: that repo's
`Specs/07-session-lifecycle-managed-eval.md` describes `UserLifecycleAssociation`
counters that accumulate evidence over unbounded history without ever rendering the
whole tree — they count and surface, they don't nest. Same idea here: `sow` is the
accumulator, `render` is the viewport, and "3" is a property of the viewport, never
of the history. (That file lives in the other repo, not this one — referenced here as
prior art, not a local dependency.)

## 3. Feature: In-the-Moment Distraction & Grounding Toolkit

### 3.1 Why

Not every urge should be resisted (sometimes eating is the correct response to real
hunger), and not every urge should be acted on immediately (a craving that would pass
on its own is not the same signal as hunger). What's missing between "log it" and "eat
it" is something to *do* while a craving is being sorted out — a short bridge activity
that neither suppresses the urge (risking the reinforcing rebound described in 2.2)
nor immediately resolves it with food.

### 3.2 Candidate techniques

A small, user-curated library of grounding activities, offered at the moment a
craving is anticipated (via the forecast) or reported as active:

- **Calligraphy / repeated handwriting** — e.g. writing the character 忍 (참을 인,
  "endure/patience") by hand, repeatedly. A tactile, slow, culturally-rooted delay
  technique; the physical act of writing occupies the hands and attention for the
  span a craving typically takes to crest and ease.
- **Reciting self-reinforcing statements and quotes** — a personal, user-authored set
  of affirmations or quotes recited (aloud or silently) as a grounding anchor, rather
  than app-generated generic copy.
- **Looking at photographs of loved ones** *(placeholder — likely to be replaced;
  a picture-puzzle variant was floated as one alternative)* — a small, user-curated
  photo set surfaced as an emotional-grounding cue.

All three share a shape: user-supplied content (not stock copy or stock imagery),
low friction to start, and no implicit judgment about whether the person "should" be
resisting anything.

### 3.3 Design constraints

- **Not a resistance mechanism.** Frame as "something to do while this passes," not
  "don't give in" — an app organized around resisting every urge risks strengthening
  the very struggle it's meant to ease (see the "Fixes that Fail" / rebound risk in the
  design canvas above).
- **User-curated, not prescribed.** The library's content (which quotes, which photos)
  is supplied by the user, not authored by the app.
- **Reversible, not diagnostic.** Using or skipping the toolkit is not logged as a
  success or failure state.
- Where this eventually needs a home in the data model, `bebekim/empatheating`'s
  `Specs/07-session-lifecycle-managed-eval.md` sketches a lifecycle-event pattern
  (e.g. an `intervention_candidate:grounding_activity` event kind) that's worth
  reusing the *shape* of here, even though that file and its event kinds don't exist
  in this repo — this needs its own Spec once the interaction design is settled.

### 3.4 Open questions

- ~~Does the toolkit surface inside a counseling session?~~ Dropped: "counseling
  session" was an `empatheating` concept with no analogue in this app. In ren-app the
  toolkit surfaces from the BA layer's selectables row (01 §8), and 02 §4's
  `GetGroundingOffer` guarantees the moment is never empty.
- Is the photo/quote library authored ahead of time (a setup step) or built up
  organically as the person uses the app?
- How do we tell, later, whether a grounding activity helped — without turning it
  into another thing to feel judged by?

### 3.5 Architecture direction: grounding techniques as installable plugins

Rather than a fixed, hardcoded list of three techniques, the toolkit should be an
**installable-plugin model**: a small catalog a person can browse and enable from,
so the active set is "what works for them," not what shipped in v1. This also
resolves 3.2's "photos of loved ones (placeholder)" mechanically — swapping or
adding a technique becomes a data change to the catalog, not a code change.

The domain/application/infrastructure breakdown below was originally sketched against
`bebekim/empatheating`'s Flask/SQLAlchemy clean-architecture layering, as a way to talk
concretely about the shape of the thing (an entity, a repository, use cases, a data-only
catalog) without yet having this repo's actual architecture to write against. Read it as
a translation exercise, not a literal plan for this codebase — the concepts (data-driven
catalog, install/enable per user, a hard security boundary around third-party code)
should carry over to whatever this repo's real layering turns out to be; the specific
class names and file paths below should not.

**Domain-equivalent concepts**:
- A `GroundingPlugin` entity — id, name, description, content type (an enum:
  text prompt, image gallery, writing canvas, audio, external link — **v1 ships
  only the first three; see 02 §3.3**), estimated
  duration, and a manifest — the plugin's actual content (quotes, the character to
  write, a photo-source reference) kept as plain data, not code.
- A plugin-repository abstraction: list available, get one, list a user's installed
  set, install, uninstall.

**Application-equivalent concepts**:
- List-available-plugins (the "store" listing).
- Install / uninstall.
- Get-grounding-offer(user) — called at the BA seed moment; returns the user's
  installed set, falling back to a small default set for a user who hasn't installed
  anything yet (so the moment is never empty).

**Infrastructure-equivalent concepts**:
- Per-user install records.
- A built-in plugin catalog as **data** (not one class/type per technique) — this is
  what makes "swap the photo placeholder later" a content edit instead of a code
  change or redeploy.
- Browse/install/uninstall surfaces, plus a render path per content type (a small,
  fixed set of app-owned renderers — not one per plugin).

**Security constraint, stated up front so "store" doesn't drift into unreviewed
code execution**: v1's store is a catalog of manifests (plain data — text, image
references, config), rendered by the app's own fixed set of content-type
renderers. It is **not** a surface for installing arbitrary third-party code —
that would be a real code-execution risk and a different, much larger security
posture (the specific risk named for the Flask sketch was XSS; the iOS-equivalent
risk — arbitrary code or unreviewed native content running in-process — needs its
own threat model once this repo has a real architecture). A genuine open marketplace
where others author plugins is a distinct later phase that needs its own Spec and a
security review before any third-party-authored logic (as opposed to data) executes
or renders.

**Phasing**:
1. Convert the existing three techniques into manifest-driven built-in plugins.
   No install/uninstall yet — proves the contract, stays low-risk.
2. Per-user install/enable from the built-in catalog — real personalization,
   still fully vetted, curated content only.
3. An actual store surface (and, if ever, external plugin submission) — its own
   Spec, security-reviewed before any non-data plugin content is allowed.

## 4. Status

The product-level record, and no longer exploration-only: `01_main_ui.md` carries
the UI decisions taken since, and `02_architecture.md` is the v1 Spec written
against this doc. Sections refined or superseded by those two are marked inline.

This repo (`ren-app`) is the actual native iOS build target. The document originated
in `bebekim/empatheating`, a Flask counseling app, which hosted only the brainstorm and
a throwaway interaction prototype (design canvas, §2.4/§2.5) — never the product itself.
§3.5's architecture sketch and the `Specs/07-session-lifecycle-managed-eval.md`
references in §2.6/§3.3 point at that other repo's conventions and files as prior art;
they are not files that exist in `ren-app` and not an iOS build plan. Treat them as
illustrative until this repo has its own domain/application layers to architect against.

Interactive prototyping of the seed-growth interface (§2.5) is continuing outside any
canvas. This doc is the durable record — update it as findings land.
