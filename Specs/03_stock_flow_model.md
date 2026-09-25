# 03 PRD: Stock-and-Flow Model — Girth, Demand, Capacity, and the Lag
*Version 0.2 (draft) - Created 2026-09-25, updated 2026-09-25*

> **Status**: conceptual model from the 2026-09-25 brainstorm (Marcus's hand sketch
> of one tub with a demand line, a capacity line, and input / capacity / output
> trays). Framed in Donella Meadows' stock-and-flow terms. Builds on `00_concept.md`
> §1 (the three loops) and `01_main_ui.md` §1 (the seed sown at the win). Where
> this doc and 01 disagree about screen layout, nothing is decided yet — see §7.
>
> v0.2 folds in a literature pass on lag lengths (§9, §10). One finding changed the
> model: hunger does **not** rise right after a run. The immediate pull is reward,
> not hunger, and hunger compensation arrives weeks later in some people (§4).

## 1. Why this model

Short-sightedness is one of the major reasons for relapse, and the design treats it
as the main thing to defend against. A person judges an action by what it does in
the next few hours or days. For the actions that matter here, that is exactly the
window where the cost has arrived and the benefit has not.

A stock-and-flow picture makes this visible: a stock changes only through its
flows, and some flows arrive late. The app's job is to show the late flows *while
they are still in transit*, so the person stops judging an action by its first day.

## 2. The stock: waist girth

The tub is **waist girth**, not body weight.

- Girth tracks the fat that matters (abdominal) more directly than weight.
- It does not punish building muscle, which a scale does, and building muscle is
  what strength training is for (§4).
- It does not swing day to day with water and food in the gut.

The goal is still to drain the tub. This is not a body-acceptance exercise
(00 §1, guiding principle). Girth is the slowest thing in the model: visceral fat
reductions from exercise are reported at around 12 weeks (§9). It is also noisy to
measure, so the cadence is weekly and the method fixed.

## 3. The two lines and the gap

Inside the tub are two lines:

| Line | Meaning |
|---|---|
| **Demand** (upper) | How strongly the person is being pulled toward food. Two different pulls feed it (below). |
| **Capacity** (lower) | How much of that pull the person can absorb without a lapse: fitness, sleep, grounding skill. |

**The gap between them is relapse risk.** The larger the gap, the more likely a
relapse. The gap is derived from what has been logged; it is never shown as a number
or a score (01 §7).

### Demand has two pulls, on different clocks

| Pull | What it is | Clock |
|---|---|---|
| **Reward pull** | Wanting a treat as a reward: "I earned it." Driven by framing and context, not by the stomach. | Fast: the same day, especially the next eating decision. |
| **Hunger** | Physical appetite, including the body's compensation for energy spent. | Slow: builds over weeks, and only in some people. |

The two can move in opposite directions at the same moment. Right after a hard run,
hunger is *suppressed* while the reward pull is *raised*. One demand line folds
both together on screen, but the model keeps them apart, because they have
different clocks and different fixes.

Under both sits a slow **baseline**: the learned reward wiring itself. Each craving
acted on strengthens it; each one ridden out weakens it (the mirror between a lapse
and 忍, §4).

## 4. What moves the lines: the v1 activity set

*Decision (2026-09-25). This is the v1 activity set; anything not listed here is
dropped (see "Dropped" below). Directions are **hypotheses** anchored where possible
in the literature (§9, §10), and each is to be tested against the person's own log.*

| Activity | Mode · tray | Demand | Capacity | Why it is in |
|---|---|---|---|---|
| **Run / cycle** | MA · output | Reward pull ↑ same day. Hunger ↓ for about an hour, then normal; compensation ↑ over weeks in some people. | ↑ from days (fitness); girth ↓ over months | The central multi-clock case. HealthKit logs it, so no friction. |
| **Brisk walk** | MA · output | Cravings ↓ during the walk and for at least 10 min after | ↑ weeks, small | Specifically the walk *after a hard run*, at the next eating decision (§6). Best-supported demand reducer in the set. |
| **Strength training** (incl. HIIT) | MA · output | Hunger ↓ briefly (≤1 h), then normal | Strength ↑ within days (neural); muscle ↑ from ~3–4 weeks | Builds muscle, which the girth tub (§2) does not punish. HIIT folds in as a "hard session". |
| **Meal photo → ultra-processed tier** | MA · input | ↑ within days (people eat more); baseline ↑ over weeks (hypothesis) | — | The clearest demand input. One tap, no counting (01 §10). |
| **Meal photo → healthy tier** | MA · input | Reward pull ↑ slightly, a little later (Marcus's hypothesis, untested) | ↑ over months (taste recalibrates) | See "Healthy meals" below. |
| **Sleep** | capacity tray | Short sleep: hunger ↑ after 2 nights | ↑ next day; short sleep: ↓ | The strongest evidence of any item here, and it hits both lines. HealthKit logs it. |
| **Name the emotion** | BA | ↓ now | ↑ weeks (hypothesis) | Cheap, always present at a BA moment (02 §3.1), and it produces the data the forecast needs. |
| **忍 calligraphy** | BA | ↓ now (by analogy with 3-minute visuospatial tasks); baseline ↓ over weeks (hypothesis) | — | Keeps hands and attention busy while the urge crests. Ren's identity; kept as a hypothesis. |
| **Exercise prep** | MA · valve | — | — | Moves no line. It is a **valve**: it opens the flow for the next run by making it frictionless. |

The meal photo's middle tier ("tasty meal", 01 §10) stays a tier, but no line effect
is claimed for it.

### Running has several clocks

Running is the central case, because one action moves things on four clocks:

1. **Reward pull rises the same day.** "I ran, I deserve it." The evidence points to
   framing: after the same walk, people told it was *exercise* served themselves
   about twice as many sweets as people told it was *sightseeing* (Werle 2015).
2. **Hunger is suppressed for about an hour**, then returns to normal. People do not
   eat meaningfully more in the hours after exercise (Schubert 2013).
3. **Hunger compensation builds over weeks, in some people.** Over 12 weeks,
   "compensators" ate more and lost far less than predicted; others did not
   compensate at all (King 2008).
4. **Capacity rises from days; girth falls over months.** Fitness markers move within
   3–10 days, fat use during exercise within 2 weeks, visceral fat at around 12 weeks.

So right after a run the gap is widest on the **reward pull**, not hunger. Someone
who judges running by its first weeks sees the treat they "earned", possibly more
hunger later, and no girth change, and stops. That is short-sightedness (§1) in its
purest form.

This is the mechanism behind 01 §1's seed sown at the win: the BA seed appears
because a hard MA action raises the reward pull immediately.

### Healthy meals

Marcus's hypothesis: a healthy meal raises the reward pull slightly, and a little
later, because it does not feel like adequate compensation. It fills the stomach
without paying off the reward circuit. Capacity rises over the long term.

The literature does not test the first part directly. Day to day, people eat *less*
on unprocessed food (Hall 2019), but that measures intake, not the felt pull, so
the hypothesis is untested rather than refuted. The long-term part has support:
after a lower-sugar diet, sweet foods taste sweeter from the second month (Wise
2016), and preferred saltiness drops over months (Bertino 1982).

If the hypothesis holds, the two MA actions that matter most both **cost now and pay
later**, which is exactly the shape short-sightedness punishes.

### Dropped

Not in v1, as activities or as defaults:

| Dropped | Why |
|---|---|
| Photos of loved ones | The direction is unknown: they may calm, or stir the emotion driving the urge. |
| Reciting statements and quotes | Weak, mixed evidence as a stand-alone technique. |
| Simple game (puzzle, match-3) | Match-3 is itself built on a reward loop: it swaps one compulsion for another. |
| Record context (time, place, person) as an activity | Asking for it *during* a craving is a heavy burden at the worst moment. Time can be derived automatically. |
| Manual meal entry | Slides toward calorie counting, which 01 §10 rules out. Photo only. |
| "Revisit a saved reminder or verse" as exercise prep | A BA technique filed under MA prep. |

Undecided: whether a lapse ("I ate on the urge") is ever logged explicitly. The model
needs it (it raises the baseline, the mirror of 忍), but a "log your failure"
control is the third loop of 00 §1 wired into the UI.

## 5. The lag (the squiggle) — first-class, never implied

*Decision (2026-09-25).*

Every delayed effect is drawn as a **squiggle**: a visible pipe between the action
and what it will eventually move, with the logged work shown **in transit** inside it.
The lag is the part of the model people are blind to, so it is the part the UI must
show most clearly.

The literature gives the model **three kinds of squiggle**, not one:

| Squiggle | From → to | Typical lag (§9) |
|---|---|---|
| Short | Training → capacity | Days to a few weeks |
| Long | Training → girth (the stock) | About 12 weeks |
| Demand-side | Training → hunger compensation | Weeks, only in some people |

Rules:

1. **Nothing lagged is shown as landed early.** A run logged today does not raise
   the capacity line today. It enters the squiggle.
2. **Work in transit is always visible.** "Is this working?" is answered by the pipe:
   the work is there, it has not arrived yet.
3. **The immediate effect and the pending one are shown together at logging time**,
   visually and without words (01 §1): the reward-pull arrow to demand, and the
   squiggle toward capacity. The person sees the cost and the pending benefit at
   the same moment.
4. **Lag lengths are tunables** (§9). The literature gives ranges, not constants, and
   they vary a lot between people. Eventually they should be learned from each
   person's own log.

### The pipe leaks: consistency

Capacity gained is not permanent. When training stops, fitness enzymes decline with a
half-time of roughly 12 days (§9). So one run is not a deposit that stays; capacity
holds only under a steady stream of inputs. This is why consistency matters, and it
is evidence, not a slogan.

The same literature supports 01 §7's tolerance: in habit formation, missing a single
opportunity did not materially set people back (Lally 2010). A miss is a small leak,
not a broken pipe.

### Candidate renderings

Not decided. From the 2026-09-25 brainstorm:

- **Wet-ink tally.** 正 strokes drawn pale and darkening as the work travels.
- **Fighting-game frame data.** Logging a run is the command input (↓↘→ + P). The lag
  is the move's *startup frames*; capacity rising is the *hit landing*; the reward pull
  right after is the *recovery frames*, when the person is open to a counter-hit.
- **Rhythm-game lane.** Each logged run scrolls up a lane toward the capacity line,
  so what lands this week is what went in weeks ago. A skipped week shows as an empty
  slot that will arrive later. Tension: that empty slot is close to a loss display,
  which 01 §7 forbids. It faces forward ("a gap is coming"), not backward ("you
  lost"), but has to be tested.

## 6. The risky window after a run

The gap peaks on the reward pull, the same day as the run. Physical hunger is low for
about the first hour, so a pull in that window is mostly reward, not need. The **next
eating decision after a run** is the risky moment. That is when the forecast rim
(01 §2) should thicken, and when the walk and the BA actions (忍, naming the
emotion) should be one tap away. The window's length is a tunable.

Framing also moves this pull (§8).

## 7. Screen layout (from the sketch) — open

The sketch places one tub in the middle of the screen with three trays of slots,
each ending in a "+" for adding a new kind of item:

- **Input tray** (top, through a faucet): meals and other inputs.
- **Capacity tray** (right side): items acting directly on the capacity line, e.g. sleep.
- **Output tray** (bottom, through a drain): runs and other outputs.

Open: whether this single tub replaces the nest in 01 §8, or becomes one layer of it.

## 8. Copy: describe the wiring, never the person — and never frame a run as work

The compensation urge after exercise is a property of the wiring, not a verdict on
the person. Copy says "after a run, the reward urge peaks", never anything that reads
as "you think you deserve too much". Judgmental copy feeds the third loop in 00 §1
(self-criticism intensifying the other two).

The framing evidence (Werle 2015) adds a second rule: **copy never frames a run as
work that earns something.** No "you burned 400 kcal", no "you earned it". Calling
an activity exercise raised the reward pull that followed it. 01 §1's silence at the
win already fits this.

## 9. Tunables and their evidence anchors (draft)

Added to the config surface in 01 §11. The anchors are ranges from the literature for
typical adults in the cited studies. They are starting points for the experiment, not
settled values or promises to a user.

| Parameter | Evidence anchor | Controls |
|---|---|---|
| `runRewardWindow` | Same day; next eating decision. Hunger itself is suppressed for 0.5–1 h (Dorling 2018). | How long after a run the risky window (§6) stays open. |
| `runCapacityLag` | Fitness enzymes up 20–35% in 3–10 days (Perry 2010; Egan 2013; Spina 1996). Fat use during exercise +36% after 2 weeks (Talanian 2007). | The short squiggle for runs. |
| `girthLag` | Visceral fat reduction reported at ~12 weeks (Vissers 2013). | The long squiggle into the stock. |
| `compensationLag` | Partial intake compensation (~30%) within 2 weeks (Whybrow 2008); marked in some people over 12 weeks (King 2008). | The demand-side squiggle. |
| `strengthCapacityLag` | Strength within days, neural first, through ~4 weeks (Moritani & deVries 1979). Muscle growth plausible at ~3–4 weeks, confirmed at 8–10 weeks; early size gains are partly swelling (DeFreitas 2011; Damas 2016). | The short squiggle for strength training. |
| `detrainingHalfLife` | ~12 days for fitness enzymes; VO₂max −7% in 21 days (Coyle 1984). | How fast landed capacity leaks without new input. |
| `walkCravingWindow` | During a 15-min walk and ≥10 min after (Taylor & Oliver 2009). | How long a walk damps the reward pull. |
| `sleepCapacityLag` | Hunger hormones shift after 2 nights of short sleep (Spiegel 2004); extra sleep cut intake within 2 weeks (Tasali 2022). | When sleep moves the lines. |
| `tasteRecalibrationLag` | Sweetness perception shifts from month 2 (Wise 2016); salt preference over months (Bertino 1982). | The long squiggle for healthy meals. |
| `habitAutomaticity` | Median 66 days, range 18–254 (Lally 2010). | When a repeated action stops needing the prompt. |
| `girthCadence` | — | How often girth is measured. Draft: weekly. |

## 10. Evidence and honesty

- **Short-sightedness** (present bias: weighting immediate rewards over delayed
  ones) is well established in behavioural economics. That it is *the major* cause of
  relapse for Ren's users is this doc's working hypothesis, to be tested.
- **Demand and capacity are not directly measurable.** The lines are derived from
  what the person logs, and they are a picture the person can recognise themselves
  in, not a readout.
- **Individual variation is large everywhere.** Compensation in particular ranges
  from none to most of the energy spent. Population ranges are anchors; the person's
  own log is the target.
- **Werle 2015** is the only direct evidence for the reward pull after exercise.
  Its co-author Brian Wansink later had many papers retracted; this paper is not
  known to be among them, but it should be treated as suggestive until replicated.
- **The BA techniques rest on analogies.** 忍 borrows its support from Tetris-style
  visuospatial tasks (Skorka-Brown 2015), and naming the emotion from lab studies
  with images (Lieberman 2007). Neither has been tested in this form.
- **The healthy-meal reward-pull hypothesis** (§4) is untested.
- **Source quality.** These references were checked against their abstracts and
  published summaries, not read in full. Before any number is quoted in the app,
  the paper should be read.
- **Popular sources** (e.g. the Huberman Lab podcast) are used only as pointers to
  primary research. The Andy Galpin episodes' timelines (strength within days, muscle
  growth at ~4–6 weeks) agree with the studies above. The *Protocols* book (2026) was
  not reviewed, and its landing page lists no references.

### References

Exercise and appetite
- Dorling J, et al. (2018). Acute and chronic effects of exercise on appetite, energy intake, and appetite-related hormones. *Nutrients* 10:1140.
- Schubert MM, et al. (2013). Acute exercise and subsequent energy intake: a meta-analysis. *Appetite* 63:92–104. doi:10.1016/j.appet.2012.12.010
- Broom DR, et al. (2009). Influence of resistance and aerobic exercise on hunger, acylated ghrelin, and peptide YY. doi:10.1152/ajpregu.90706.2008
- King NA, et al. (2008). Individual variability following 12 weeks of supervised exercise. *Int J Obes* 32:177–184. doi:10.1038/sj.ijo.0803712
- Whybrow S, et al. (2008). doi:10.1017/S0007114508968240
- Flack KD, et al. (2018). Energy compensation in response to aerobic exercise training in overweight adults. doi:10.1152/ajpregu.00071.2018
- Werle COC, Wansink B, Payne CR (2015). Is it fun or exercise? The framing of physical activity biases subsequent snacking. *Marketing Letters* 26:691–702. doi:10.1007/s11002-014-9301-6

Training adaptation and detraining
- Egan B, et al. (2013). Time course analysis reveals gene-specific transcript and protein kinetics of adaptation to short-term aerobic exercise training. PMC3771935
- Perry CGR, et al. (2010). Repeated transient mRNA bursts precede increases in transcriptional and mitochondrial proteins. doi:10.1113/jphysiol.2010.199448
- Spina RJ, et al. (1996). Mitochondrial enzymes increase in muscle in response to 7–10 days of cycle exercise. PMID 8806937
- Talanian JL, et al. (2007). Two weeks of high-intensity aerobic interval training increases the capacity for fat oxidation. PMID 17170203
- Vissers D, et al. (2013). The effect of exercise on visceral adipose tissue in overweight adults. *PLOS ONE* 8:e56415. doi:10.1371/journal.pone.0056415
- Moritani T, deVries HA (1979). Neural factors versus hypertrophy in the time course of muscle strength gain. PMID 453338
- DeFreitas JM, et al. (2011). PMID 21409401
- Damas F, et al. (2016). PMID 26280652
- Coyle EF, et al. (1984). PMID 6511559
- Mujika I, Padilla S (2000). Detraining, parts I and II. *Sports Med* 30:79–87, 145–154. doi:10.2165/00007256-200030020-00002

Food, sleep, BA, habits
- Taylor AH, Oliver AJ (2009). Acute effects of brisk walking on urges to eat chocolate. *Appetite* 52:155–160. doi:10.1016/j.appet.2008.09.004
- Ledochowski L, et al. (2015). Acute effects of brisk walking on sugary snack cravings in overweight people. *PLOS ONE* 10:e0119278. doi:10.1371/journal.pone.0119278
- Hall KD, et al. (2019). Ultra-processed diets cause excess calorie intake and weight gain. *Cell Metab* 30:67–77. doi:10.1016/j.cmet.2019.05.008
- Wise PM, et al. (2016). Reduced dietary intake of simple sugars alters perceived sweet taste intensity but not perceived pleasantness. *AJCN* 103:50–60. doi:10.3945/ajcn.115.112300
- Bertino M, et al. (1982). Long-term reduction in dietary sodium alters the taste of salt. *AJCN* 36:1134–1144. doi:10.1093/ajcn/36.6.1134
- Spiegel K, et al. (2004). Sleep curtailment in healthy young men is associated with decreased leptin, elevated ghrelin, and increased hunger. *Ann Intern Med* 141:846–850. doi:10.7326/0003-4819-141-11-200412070-00008
- Tasali E, et al. (2022). Effect of sleep extension on objectively assessed energy intake. *JAMA Intern Med* 182:365–374. doi:10.1001/jamainternmed.2021.8098
- Lieberman MD, et al. (2007). Putting feelings into words. *Psychol Sci* 18:421–428. doi:10.1111/j.1467-9280.2007.01916.x
- Skorka-Brown J, et al. (2015). Playing Tetris decreases drug and other cravings in real world settings. *Addict Behav* 51:165–170. doi:10.1016/j.addbeh.2015.07.020
- Lally P, et al. (2010). How are habits formed. *Eur J Soc Psychol* 40:998–1009. doi:10.1002/ejsp.674

## 11. Open questions

- **What lowers demand?** In the v1 set (§4): the post-run walk (best supported),
  naming the emotion, and 忍. Whether they do so for Ren's users is the first thing
  to test.
- **Should the leak be shown?** Capacity fading without input is real (§5), but
  showing it risks the loss display 01 §7 forbids.
- **Should the two demand pulls be drawn separately**, or stay folded into one line?
- **Does the girth stock appear on screen**, and how, given 01 §7's rule against
  KPIs and scores?
- **Layout**: §7.
