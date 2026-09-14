# Scrap Saint — Improvement Plan and Design Resolution Backlog

**Date:** 2026-09-15  
**Status:** design and execution plan; runtime implementation has not started.  
**Audience:** Astra, gameplay programmers, content designers, technical artists, QA agents, and future collaborators.

## Executive summary

Scrap Saint has a strong product identity and a well-developed design foundation. The repository now explains the intended fantasy, shop structure, Blessings, deterministic simulation boundary, first arena, weapon evolution, metagame, and evidence standard. The main risk is no longer a lack of ideas. The main risk is **design drift during implementation**.

The repository is currently a private documentation and content-contract project. It contains no `project.godot`, no Godot runtime, no executable simulation, no real gameplay captures, and no deterministic runtime tests. The content validator passes, but it validates only a narrow structural contract. It does not establish that combat, shops, maps, evolution, or presentation work in a real build.

The correct next step is therefore not to add more lore or a large content catalogue. The correct next step is to **resolve the remaining system decisions, reconcile the data with the first-slice scope, and then implement the smallest complete playable loop**.

The recommended product direction is:

> **Scrap Saint is a short, authored repair pilgrimage in which the player moves through a compact industrial arena, automatically operates a small set of strange relic weapons, chooses between immediate survival and future transformation in a deterministic workshop, and visibly becomes a different kind of machine.**

The improvement plan has four priorities:

1. **P0 — Reconcile contracts and freeze the runtime vocabulary.** Resolve scope mismatches, normalize tags and statuses, define the runtime schema, and remove ambiguity between the nine-minute first slice and the longer release target.
2. **P1 — Build the first playable loop.** Implement deterministic shell, movement, one relay arena, three weapons, three enemy questions, one shop, three Blessings, and Mercy Rail.
3. **P2 — Make the loop strategically deep.** Add traits, clearer shop decisions, enemy composition, route selection, additional evolutions, and objective variants only after the first loop is playable and captured.
4. **P3 — Make it commercially legible.** Add authored arenas, presentation quality, onboarding, narrative consequences, accessibility, progression breadth, and replayable challenge structure.

The immediate implementation packet should be a short **P0 contract-reconciliation task**, followed by **SC-01 — Godot shell and deterministic harness**. The repository should not add broad runtime content before those two gates pass.

## 1. Repository audit: current truth

### 1.1 What is already strong

The project has several durable advantages.

| Strength | Why it matters |
|---|---|
| Distinctive product identity | The Saint is a maintenance automaton with a repair, memory, and self-determination fantasy rather than a generic combat robot [1]. |
| Clear run-level doctrine | Blessings give the player a broad direction while preserving shop agency [2]. |
| Strong transformation hook | Named evolutions are required to change geometry, targeting, objective interaction, or resource behaviour [1] [3]. |
| Deterministic architecture | The simulation is explicitly authoritative over movement, combat, currencies, shop rolls, objectives, saves, and replays [4]. |
| Good evidence discipline | The repository distinguishes content validation from real gameplay evidence and prohibits fabricated captures [1] [5]. |
| Compact first slice | The nine-minute First Shift is small enough to implement and inspect before campaign breadth [3]. |
| Narrative fit | Repairs, relics, Blessings, and memories all support the Saint Built Wrong arc [6]. |
| Strong art direction | The chunky repaired-industrial diorama, restrained palette, and silhouette rules provide a coherent temporary and final visual target [7]. |

### 1.2 Current implementation truth

The updated repository is still a design and contract foundation.

| Finding | Evidence | Consequence |
|---|---|---|
| No Godot runtime exists | No `project.godot` or runtime source is present in the repository tree. | No gameplay claim can be made. SC-01 is still the first runtime task. |
| No autonomous runtime loop exists in this repository | `README.md` references `scripts/agent_iteration.sh` and `tools/validate_iteration_report.py`, but those files are not present in the repository tree. | The standard agent loop must be added or the README must be corrected before runtime QA. |
| No deterministic runtime tests exist yet | `tests/README.md` describes the intended suite, but there are no executable Godot tests or golden traces. | Acceptance tests are specifications, not passes. |
| Content validation is structural | `scripts/validate_content.py` checks IDs, references, basic fields, and counts. | It does not validate damage semantics, timing, tag vocabulary, economy, map topology, or evolution behaviour. |
| Content is broader than the first runtime slice | The item file contains seven weapons and four catalysts; the enemy file contains five normal enemies plus Memory Crane; the boss file contains three bosses. | The design pool is useful, but implementation scope must be explicitly separated from the authored catalogue. |
| No arena data file exists | The Collapsed Workshop is specified in prose, but no stable-ID map schema or map content file exists. | Map implementation would otherwise bury topology and balance in scene code. |
| No traits or buff catalogue exists | The gameplay contract mentions companions, terrain tools, rituals, and passive traits, but no stable-ID content schema defines them. | The trait layer must be resolved before adding content or it will become ad hoc stat inflation. |

### 1.3 Internal inconsistencies that must be resolved before runtime work

These inconsistencies are not fatal. They are normal for a design foundation. They become expensive if they remain unresolved while agents begin coding.

| Inconsistency | Current sources | Recommended resolution |
|---|---|---|
| First-slice run length | The game bible targets 15–25 minutes for the eventual run, while the first slice targets 8–10 minutes and the progression document specifies nine minutes [1] [3]. | Keep **nine minutes** as the SC-01–SC-10 acceptance target. Treat 15–25 minutes as a later release target achieved through more route beats, not by slowing the first slice. |
| First-slice weapon count | The first-slice document says five base weapons, while the item catalogue contains seven weapons [3] [8]. | Keep seven as the authored catalogue, implement five in the first playable, and reserve Hymn Coil and Altar Mortar for the creative vertical unless a deterministic test requires them earlier. |
| First-slice enemy count | The first-slice document says three enemy families, while content already defines five normal families plus one elite [3] [9]. | Implement Scrap Mite, Rivet Hound, and Choir Drone in SC-03. Add Rust Pilgrim and Forklift Brute only after the first combat loop is readable. |
| First-slice boss count | The content file defines three bosses, while the first slice requires only Foreman Engine [3] [10]. | Keep Factory Heart and Saint of No Repairs as Act II/III design records. Do not implement them before Foreman Engine is verified. |
| Catalyst cost | The item data prices Saint’s Rivet at two Relic Shards, while the progression recommendation uses one Shard plus eight Scrap [3] [8]. | Adopt **one Relic Shard plus eight Scrap** for the first slice. Add a schema field for mixed costs and update the data. |
| Tag vocabulary | Content uses `control`, `conversion`, `spirit`, `silence`, `beam`, `wrath`, and `ground`; the progression design proposes `LABOUR`, `WITNESS`, `ORBIT`, `QUIET`, `MOURN`, `TETHER`, `PULSE`, `SALVAGE`, `PIERCE`, and `REPAIR` [3] [8]. | Freeze eight player-facing tags for the first runtime: `LABOUR`, `WITNESS`, `ORBIT`, `QUIET`, `MOURN`, `TETHER`, `PULSE`, and `REPAIR`. Treat `PIERCE` as a weapon property rather than a doctrine tag. Map legacy terms explicitly or remove them. |
| Blessing fulfilment | Content uses `required_tags` and `required_count`, while the design requires causal actions such as repairs, witnessing, or remnants [2] [8]. | Replace generic tag counts with three authored action milestones per Blessing. Tags may influence offers, but fulfilment must describe player behaviour. |
| Nailer identity | The base Nailer already has `repair_on_marked_hit`, while Mercy Rail is supposed to introduce a meaningful repair interaction [8]. | Base Nailer should mark and pierce ordinary targets with a small conditional repair effect. Mercy Rail must add lane geometry, objective-attacker priority, and a stronger repair-on-resolution rule. The transformation must remain mechanically obvious. |
| README runtime command | The README references autonomous scripts that are not present in this repository [1]. | Either add the shared runtime QA tools or mark those commands as inherited tooling and link the actual source. Do not leave commands that fail by default. |
| First-slice Blessings | The design names Workshop Gospel, Bell Ward, and Mourner as the first three, while the broader contract lists eight [2]. | Keep three runtime Blessings. Keep the other five as authored expansion records and do not expose them in the first slice UI. |

## 2. Decisions that still need to be figured out

The following questions should be answered before the implementation expands. Each row includes the recommended default so agents have a direction instead of repeatedly reopening the same discussion.

| Decision | Why it matters | Recommended default | Proof required |
|---|---|---|---|
| What is the exact first-run rhythm? | The player must understand the relationship between combat, repair, shop, and transformation. | Nine minutes, six pressure beats, five shop windows, one elite, one boss. | Replay trace with exact phase transitions and a real capture. |
| What does the player actively control? | Pure auto-attack can become passive; too many active abilities break the compact scope. | Direct movement, one repair command, shop commands, one contextual ritual slot later. Weapons remain automatic. | Combat capture showing meaningful positioning without manual aiming. |
| What occupies inventory slots? | Weapons, catalysts, traits, rituals, and reserve rules can create hidden complexity. | Four active weapon slots plus one reserve in the first slice. Catalysts are consumed and do not occupy slots. Traits wait until the first combat loop works. | Buy/combine/reserve tests and a readable loadout panel. |
| What is a trait? | The contract mentions passive traits but does not define their source, slot, or stacking. | A Gift is a run-local support item that changes one rule or adds one interaction. Use two support slots after SC-08. | Data schema, UI preview, stacking tests, and one visible interaction per Gift. |
| How much repair is safe? | If repair is automatic and abundant, the objective loses tension. If it is too scarce, the player feels railroaded. | Repair requires location, time, and exposure. Scrap repairs are limited; weapon-based repair is conditional and forecastable. | Relay structure traces across normal, partial, and failed runs. |
| How does the shop create agency? | Random offers are a major source of frustration in this genre. | Six role-guaranteed offers, one free refresh, one lock, visible recipe path, and two valid threat counters. | Same-state shop replay and affordability traces. |
| What makes Blessings different? | Three Blessings can otherwise become cosmetic starting weapons. | Each changes starting guarantee, shop weighting, unique service, fulfilment actions, and one weakness. | Three complete runs with different offers and viable outcomes. |
| What makes a weapon memorable? | A large catalogue can become shallow numerical variety. | Each weapon must answer one enemy/objective question through geometry and one non-damage verb. | Weapon test matrix and visual capture at gameplay zoom. |
| When is an evolution allowed? | Random mid-combat transformations are hard to understand and test. | Elite reward, boss reward, or altar window only. First Mercy Rail path is guaranteed by Shops 2–4. | Recipe-state and transformation-event tests. |
| How much map variety is needed? | A single repeated arena risks feeling like a prototype; procedural maps add scope too early. | One authored arena for the first slice. Add four authored topology families after the first loop. | Map schema, reachability tests, and route-choice capture. |
| What does permanent progression buy? | Permanent power inflation can hide weak run design and create grind. | Memory Fragments unlock frames, Blessings, catalysts, arenas, memories, and transparent modifiers. No early permanent damage tree. | Unlock tests and a fresh-save comparison. |
| How does narrative affect play? | Long dialogue would interrupt the run; flavour without consequence becomes decoration. | Short objective, shop, boss, memory, and Results beats. Choices alter routes, rewards, and later doctrine availability. | State-aware Results and route replay. |
| What is the commercial visual target? | Temporary art can become permanent if there is no replacement gate. | Chunky industrial diorama with a small curated set of hero assets, readable silhouettes, restrained effects, and tactile audio. | Visual rubric scores and screenshot comparison across milestones. |

These defaults should remain in force unless a playable trace demonstrates a specific failure. The project should not revisit the core premise merely because the runtime is incomplete. The design decision record already establishes that the premise should be reviewed only after a complete captured 8–10 minute run with three Blessings [11].

## 3. Recommended player loop

### 3.1 First Shift loop

The first playable should be organized around six questions rather than six arbitrary waves.

| Beat | Player question | Primary system | Required response |
|---|---|---|---|
| Arrival | What am I repairing and what does my Blessing favour? | Blessing selection, relay state, forecast | Choose doctrine and move toward the first pressure lane. |
| Loose parts | Can I move and collect without abandoning the relay? | Movement, automatic attack, Scrap pickups | Clear Scrap Mites and choose whether to detour for salvage. |
| Chargers | Can I protect the relay while building toward an evolution? | Objective attackers, repair zone, Shop 1–2 | Intercept Rivet Hounds and spend on immediate coverage or Rank-up progress. |
| Suppression | Which tool answers the next threat? | Choir Drones, forecast, Shop 3 | Choose control, precision, displacement, or a Blessing service. |
| Elite and transformation | Can I fight a copy of my own build and change it before the final test? | Memory Crane, catalyst, Rank 3, Mercy Rail | Survive the elite, trigger the evolution at the altar, and read the before/after result. |
| Boss and Results | Did I repair, fight, and choose coherently? | Foreman Engine, interrupts, Results, route | Interrupt demolition, preserve the relay, understand the outcome, and choose the next route. |

### 3.2 Pacing recommendation

Use a **short combat window followed by a clear decision window**. The shop should pause combat completely. The player should never be making a purchase while enemy damage continues in the background during the first slice.

The first slice should target the following rhythm:

| Time | State | Intent |
|---:|---|---|
| 00:00–00:30 | Arrival | Establish relay, Saint, Blessing, and first forecast. |
| 00:30–01:30 | Wave A | Teach movement, automatic attack, and collection. |
| 01:30–01:45 | Shop 1 | Offer immediate coverage and first evolution clue. |
| 01:45–02:45 | Wave B | Introduce objective attackers and repair exposure. |
| 02:45–03:00 | Shop 2 | Make the first real survival-versus-evolution decision. |
| 03:00–04:00 | Wave C | Introduce suppression and lane choice. |
| 04:00–04:15 | Shop 3 | Guarantee a viable Rank-up or Mercy ingredient route. |
| 04:15–05:30 | Memory Crane | Test the player’s build and positioning. |
| 05:30–06:20 | Shop and altar | Trigger Mercy Rail in a controlled transformation window. |
| 06:20–07:20 | Final pressure | Test the evolved geometry against mixed threats. |
| 07:20–07:35 | Final shop | Offer one boss-counter option and repair decision. |
| 07:35–08:45 | Foreman Engine | Test movement, interrupts, and relay preservation. |
| 08:45–09:15 | Results | Explain causality, commit rewards, and show two route choices. |

The eventual 15–25 minute run should be achieved by adding a second site or additional authored route beats, not by simply multiplying enemy health or extending empty combat time.

## 4. Weapon system plan

### 4.1 Weapon design rules

Every weapon must satisfy five requirements before it is added to runtime content.

1. It has a distinct attack geometry that reads at gameplay zoom.
2. It answers one enemy or objective question.
3. It has one non-damage verb such as mark, stagger, tether, reveal, repair, consecrate, silence, convert, or redirect.
4. It creates a meaningful rank-up change rather than three copies of the same damage number.
5. Its evolution changes at least two of geometry, target rule, objective interaction, status logic, or resource behaviour.

The first runtime should avoid general-purpose weapons that solve every problem. A good weapon creates a useful gap that another weapon or trait can cover.

### 4.2 First weapon roles

| Weapon | Geometry | Main question | Non-damage verb | Main weakness | Recommended evolution |
|---|---|---|---|---|---|
| **Nailer of Small Mercies** | Short targeted line | Can I focus the correct attacker? | Mark and conditional repair | Weak against swarms and side pressure | **Mercy Rail** |
| **Bell of the Last Shift** | Forward cone or short pulse | Can I interrupt and create space? | Rung/stagger and witness | Weak single-target finish | **The Great Toll** |
| **Procession Gear** | Orbit | Can I survive close pressure while repairing? | Consecrated orbit near the objective | Weak at long range | **The Maintenance Parade** |
| **Candle-Nailer** | Long priority shot | Can I finish a chosen target and preserve its memory? | Mourned remnant | Slow cadence and poor crowd clear | **Candle for the Unreturned** |
| **Cable of Contrition** | Sweep and tether | Can I redirect or delay a charger? | Bound/pull and lane control | Low immediate burst | **Contrition Lattice** |
| **Hymn Coil** | Sustained beam | Can I suppress armour and support actions? | Scoured and Quieted | Requires line discipline | **Quiet Sermon** |
| **Altar Mortar** | Delayed ground seal | Can I deny a route before pressure arrives? | Consecrated zone | Delayed response and weak close defence | **Workshop Benediction** |

The first playable should implement the first three weapons. The first creative vertical should implement the first five. Hymn Coil and Altar Mortar should be introduced only when support, armour, ground denial, and threat forecasts have real runtime consumers.

### 4.3 Rank structure

Ranks should change reliability and interaction in a predictable way.

| Rank | What changes | Example: Nailer |
|---|---|---|
| Rank 1 | Establishes geometry and identity. | Fires at the nearest eligible target and marks it. |
| Rank 2 | Adds a new interaction or improves reliability. | Marked relay attackers receive priority and produce a small repair pulse on defeat. |
| Rank 3 | Enables an evolution and gives a readable pre-evolution peak. | Pierces two targets in a line and exposes the Mercy Rail recipe. |
| Evolved | Changes the combat verb and silhouette. | Mercy Rail becomes a charged lane rail that prioritises objective attackers and repairs the relay when its marked resolution succeeds. |

Combining must remain atomic. A failed combine must not consume items, alter the RNG cursor, or change shop state.

### 4.4 Evolution catalogue

The following recipes are recommended for the first authored content pool. Only Mercy Rail is required for the first playable.

| Base | Catalyst | Evolution | Behavioural transformation | Release stage |
|---|---|---|---|---|
| Nailer Rank 3 | Saint’s Rivet | **Mercy Rail** | Charged piercing lane; objective-attacker priority; repair on marked resolution. | First playable. |
| Bell Rank 3 | Cracked Bell Clapper | **The Great Toll** | Forward cone becomes radial pulse ring; staggers and marks enemies around the Saint. | Creative vertical. |
| Procession Gear Rank 3 | Pilgrim Spindle | **The Maintenance Parade** | Orbit becomes a moving procession that leaves short Consecrated repair stations. | Creative vertical or Act I. |
| Candle-Nailer Rank 3 | Black Candle | **Candle for the Unreturned** | Priority shot becomes a soul-thread that leaves a controllable Mourned remnant. | Act I. |
| Cable Rank 3 | Blue Wire from the Pump | **Contrition Lattice** | One tether becomes a multi-node lane lattice that redirects chargers. | Act I. |
| Hymn Coil Rank 3 | Quiet Gear | **Quiet Sermon** | Beam creates a moving silence corridor that disables support actions and reveals hidden targets. | Act II. |
| Altar Mortar Rank 3 | Saint’s Rivet or Foundry Seal | **Workshop Benediction** | Ground seal becomes a delayed repair-and-denial altar that trades Scrap for stronger objective protection. | Act II. |
| Any Rank 3 Salvage item | Maintenance Blueprint | **Rebuilt Instrument** | Converts one flexible item into a new role and reveals a route-specific recipe. | Act II; avoid wildcard implementation before recipe UI is stable. |

The first ten recipes should be visible through the Ledger, but the first playable should expose only the first two in the data-driven recipe UI. A broad recipe catalogue without runtime discovery and preview is not useful content.

### 4.5 Weapon test matrix

Before adding a weapon, QA must answer:

| Test | Required result |
|---|---|
| Geometry | Attack shape is visible and distinct at gameplay zoom. |
| Targeting | Target rule is deterministic and explainable. |
| Counter | At least two enemy situations make the weapon useful. |
| Weakness | At least one situation makes another weapon preferable. |
| Objective | Weapon either interacts with the relay or explicitly does not. |
| Rank | Rank 2 adds a new decision or interaction. |
| Evolution | Evolution changes at least two observable behaviours. |
| Economy | The player can pursue it without perfect shop luck. |
| Presentation | Hit, status, and transformation feedback are readable without dense text. |

## 5. Traits, Gifts, buffs, and status design

### 5.1 Resolve the vocabulary first

The repository currently uses several overlapping terms: passive traits, relics, catalysts, Blessings, services, statuses, and effects. The following vocabulary is recommended.

| Term | Meaning | Persists after run? | Slot or location |
|---|---|---:|---|
| **Weapon** | Automatic attack source with geometry and target rule. | No | One of four active weapon slots. |
| **Gift** | Run-local support item that changes one rule or creates one interaction. | No | One of two support slots after the first playable. |
| **Catalyst** | Evolution ingredient or transformation modifier. | No, unless discovered as content | Consumed or attached during evolution; never occupies an active slot. |
| **Blessing** | Run-level doctrine that biases offers and grants one unique service. | The definition persists; the chosen instance is run-local | Chosen before the run. |
| **Status** | Temporary authoritative state on a Saint, enemy, zone, or objective. | No | No inventory slot. |
| **Service** | Shop or altar command that changes state through an explicit transaction. | No | Shop action. |
| **Memory** | Persistent story and progression record. | Yes | Campaign ledger. |

Do not call every passive effect a trait. A player should know whether they are buying a weapon, Gift, catalyst, service, or Blessing.

### 5.2 First Gift families

Gifts should be added only after SC-08 proves weapons and Mercy Rail. The initial Gift set should be small and behaviour-oriented.

| Gift | Family | Effect | Trade-off | Best interaction |
|---|---|---|---|---|
| **Inspection Lens** | Witness | Reveals one hidden elite property and increases target certainty. | Lower Scrap from ordinary pickups. | Bell, Candle-Nailer, Memory Crane. |
| **Spare Hand** | Labour | Repair pulses have a shorter exposure window. | Slower movement while repairing. | Workshop Gospel, relay objectives. |
| **Loose Spring** | Movement | After a repair pulse, gain a short movement burst. | Reduced armour during the burst. | Threshold and Procession builds. |
| **Black Ledger** | Salvage | Dismantling returns one component tag. | Lower direct sell value. | Salvage Rite and recipe pursuit. |
| **Choir Filter** | Quiet | Quieted targets cannot create support fields for a short duration after recovery. | Lower crowd damage. | Hymn Coil and Bell Ward. |
| **Mourner’s Thread** | Mourn | One Mourned remnant lasts longer and can intercept a single hit. | Requires a recent defeat to function. | Candle-Nailer and Mourner. |
| **Brass Fuse** | Pulse | The next staggered target becomes Marked. | Stagger cooldown is slightly longer. | Bell and Mercy Rail. |
| **Tether Spool** | Tether | Bound enemies leave a brief slow line when released. | Reduced pull distance. | Cable and route control. |

Each Gift must modify one rule, not add a large collection of small percentage bonuses. Gifts should be presented as **“what decision does this enable?”** rather than as a rarity ladder.

### 5.3 Buff and status rules

The first status system should be intentionally constrained.

- Every status has a stable ID, duration, stack limit, refresh rule, source event, removal rule, and visible presentation.
- Most statuses should have a maximum of two stacks or no stacking at all.
- A status should either create a decision, explain a counter, or support a transformation. It should not exist only to display a number.
- Buffs on the Saint should be short, named, and causal. Examples include `CONSECRATED`, `INSPECTING`, `OVERLOADED`, and `REPAIRED`.
- Debuffs on enemies should describe behaviour changes. Examples include `MARKED`, `BOUND`, `QUIETED`, `SCOURED`, `RUNG`, and `MOURNED`.
- Do not add critical-hit chance, rarity, luck, cooldown, attack speed, range, armour, dodge, harvesting, and five other generic stats before the first slice has proven the more important verbs.

Recommended first runtime status interactions:

| Source | Status | Resolution |
|---|---|---|
| Nailer | `MARKED` | The next compatible hit gains objective priority or a defined repair effect. |
| Bell | `RUNG` | Target loses its next movement action or charge window. |
| Cable | `BOUND` | Target is delayed or redirected along a visible line. |
| Hymn later | `QUIETED` | Target cannot create a support field for a defined duration. |
| Mercy Rail | `SCOURED` plus repair resolution | Armour is reduced and a marked objective attacker can restore relay progress. |
| Candle later | `MOURNED` | Defeat leaves a temporary remnant with one defined support action. |

## 6. Blessings and doctrine progression

### 6.1 First three Blessings

The first three Blessings should be mechanically distinct enough that a player can identify the chosen doctrine from the shop and combat behaviour.

| Blessing | Starting direction | Unique service | Three fulfilment actions | Weakness |
|---|---|---|---|---|
| **Workshop Gospel** | Nailer or repair support. | Rebuild one item for a component refund. | Repair two relay segments; complete two repair pulses while contested; buy or combine two Labour items. | Lower burst. |
| **Bell Ward** | Bell or Witness support. | Preview the next elite pressure. | Witness five support machines; stagger three chargers before contact; keep one forecast counter unused until the relevant wave. | Weak single target. |
| **The Mourner** | Candle-Nailer or remnant support. | Preserve one defeated elite remnant. | Create three Mourned remnants; keep one remnant alive through a pressure beat; choose a memory or remnant reward. | Needs defeats to compound. |

The fulfilment reward should change the next decision. It should not be a generic percentage bonus. Examples include an improved service, one temporary support unit, an additional forecast detail, or a protected catalyst offer.

### 6.2 Future Blessings

After the first playable, add Blessings only when they create a new doctrine question.

| Blessing | New question | Signature weapon family |
|---|---|---|
| Quiet Order | Can suppression and precision beat crowd density? | Hymn Coil, Quiet Sermon. |
| Salvage Rite | Is flexibility worth lower immediate defence? | Dismantling, calibration, Rebuilt Instrument. |
| Procession | Can a moving defensive formation protect the relay? | Procession Gear, Maintenance Parade. |
| Red Litany | How much self-risk is acceptable for burst and hazard denial? | Altar Mortar, Fevered effects. |
| Threshold Rite | Can routing and displacement replace raw damage? | Cable, Door, Tether. |

Do not release all eight Blessings at once. Three good doctrines are better than eight shallow starting screens.

## 7. Shop and economy improvement plan

### 7.1 Shop decision structure

The shop should feel like a small workshop with a readable set of jobs, not a slot machine. Every visit should answer three questions:

1. What keeps me alive in the next pressure beat?
2. What advances my current evolution or doctrine?
3. What flexible option protects me if the forecast is wrong?

The six offer roles should remain fixed:

| Role | Purpose | Guarantee |
|---|---|---|
| Current-build improvement | Supports the strongest current plan. | Always actionable. |
| Evolution path | Shows a missing rank, catalyst, or transformation service. | Mercy Rail path is guaranteed by Shops 2–4. |
| New direction | Offers a weapon or Gift outside the current dominant tags. | Prevents one-dimensional runs. |
| Flexible support | Repair, reserve, dismantle, or broad defence. | Supports recovery and experimentation. |
| Forecast counter A | Answers one valid threat family. | Never the only possible answer. |
| Forecast counter B | Answers a second threat family or Blessing-specific angle. | Preserves agency. |

### 7.2 First implementation versus later shop features

The shop contract currently lists many actions. They should not all be implemented at once.

| Shop action | First playable | Creative vertical | Later |
|---|---:|---:|---:|
| Buy | Yes | Yes | Yes |
| Combine | Yes | Yes | Yes |
| One reserve slot | Yes | Yes | Yes |
| One free refresh | Yes | Yes | Yes |
| Paid reroll | Yes, capped at 2/4/7 Scrap | Yes | Tuned by evidence |
| Repair service | Yes | Yes | Yes |
| Sell | Minimal version | Yes | Yes |
| Dismantle | Minimal version | Yes | Yes |
| Read the Ledger | Recipe preview only | Yes | Expanded discoveries |
| Recast Relic | No | Optional | After catalyst variety exists |
| Blessing deepening | One authored service | Yes | Expanded doctrine system |

### 7.3 Economy targets

Use the following as initial targets, not promises:

- 80–120 Scrap across a normal nine-minute run.
- 3–5 Relic Shards across objective, elite, and boss rewards.
- One Rank 1 improvement, one repair/service, and one catalyst component before the elite for a player who collects roughly 70% of pickups.
- Mercy Rail achievable without perfect collection or repeated rerolling.
- At least five meaningful spending decisions.
- No shop visit in which every offer is unaffordable or irrelevant.

The first economy test should simulate three player profiles:

| Profile | Behaviour | Expected outcome |
|---|---|---|
| Survival player | Buys immediate coverage and repairs early. | Can reach the boss with a coherent non-evolved build and a recoverable relay. |
| Evolution player | Saves for Rank 3 and Saint’s Rivet. | Can reach Mercy Rail through the protected offer path. |
| Explorer player | Buys one off-doctrine item and uses reserve/dismantle. | Can form a viable hybrid build without being punished by dead offers. |

### 7.4 Economy failures to avoid

Do not use a hidden pity timer. Do not make the first evolution require a rare random drop. Do not add multiple shard types. Do not make rerolling the dominant skill. Do not let permanent progression determine whether the first objective is survivable. Do not hide the price or transaction consequence behind flavour text.

## 8. Map and route design

### 8.1 First arena: Collapsed Workshop

The first arena should be authored as a small route-bearing diorama rather than a featureless square.

| Area | Function | Risk | Visual anchor |
|---|---|---|---|
| Relay bowl | Primary repair and defence space. | Enemies can contest repair. | Tall relay mast with visible structure bands. |
| West salvage lane | Optional Scrap detour. | Time away from relay. | Bins, loose bolts, and a broken sorting arm. |
| North crane lane | Elite and support pressure route. | Narrow line and copied attack risk. | Hanging crane and marked floor track. |
| East furnace lane | Hazard and burst route. | Warning strip and temporary heat. | Red furnace doors and steam vents. |
| South workshop alcove | Shop and Blessing decision space. | No hidden combat shortcut. | Altar, ledger, and sorting bench. |

Map rules:

- Every traversable pocket has at least two exits.
- All three enemy entry edges are reachable without passing through the shop.
- The relay zone is safer but not invulnerable.
- Hazard markers use yellow telegraph, red warning, then effect.
- Salvage is five to eight seconds from the relay by the outer loop.
- The camera keeps the Saint, relay, and immediate threat direction readable.
- Obstacles provide route choices but never create a dead-end trap.

### 8.2 Map data schema

Create a stable-ID map file before implementing scenes. A first map record should contain:

```text
ArenaDefinition {
  id,
  logical_size,
  pockets,
  exits,
  entry_edges,
  objective_id,
  repair_zone,
  salvage_nodes,
  hazard_strips,
  shop_alcove,
  camera_bounds,
  route_reward_profile,
  topology_rules
}
```

The topology validator should test reachability, two-exit pockets, entry-edge access, relay access, and shop independence. Scene layout should render this data rather than becoming the hidden source of truth.

### 8.3 Future authored map families

Add one map family at a time. Each map must introduce a new spatial question.

| Map | New spatial question | New objective or pressure |
|---|---|---|
| Collapsed Workshop | Can I route between relay, salvage, and shop? | Repair relay. |
| Rootworks Pump | Can I defend a moving repair front? | Repair several pump nodes. |
| Brass Choir Relay | Can I choose between signal timing and safe movement? | Hold signal windows. |
| Red Foundry | Can I cross hazard lanes without losing economy? | Protect a cooling sequence. |
| Pale Archive | Can I identify the correct copy and preserve memory? | Recover an archive record. |
| Null Assembly | Can I fight while Blessing services are temporarily suppressed? | Destroy an erasure engine. |

Do not generate procedural layouts until these authored families prove that topology changes decisions rather than merely changing decoration.

## 9. Enemy and encounter plan

### 9.1 Enemy design rule

An enemy is a question, not a bag of health. Every enemy must define:

- Role.
- Target preference.
- Telegraph.
- Movement or attack rule.
- Counter families.
- Failure explanation.
- Loot or objective consequence.
- Visual silhouette and sound cue.

### 9.2 First encounter roster

| Enemy | Role | What it asks | Counter families | Priority |
|---|---|---|---|---:|
| **Scrap Mite** | Pickup-denial swarm | Will the player collect safely or clear space first? | Area, orbit, burst. | SC-03. |
| **Rivet Hound** | Relay charger | Can the player intercept an objective attacker? | Control, pulse, precision. | SC-03. |
| **Choir Drone** | Support and suppression | Can the player interrupt a field before it changes the fight? | Witness, precision, displacement. | SC-03. |
| **Rust Pilgrim** | Armoured repair support | Can the player break a protected support chain? | Scour, silence, focused damage. | Creative vertical. |
| **Forklift Brute** | Displacer and obstacle threat | Can the player preserve route geometry under pressure? | Tether, ground, movement. | Creative vertical. |
| **Memory Crane** | Elite copy | Can the player fight its own chosen geometry? | Hybrid, witness, mobility. | SC-09. |

### 9.3 Encounter composition

Do not introduce all enemies as isolated tutorials. Use authored combinations that create a single readable question.

| Encounter | Composition | Intended question |
|---|---|---|
| Loose parts | Scrap Mites only | Can I move and collect? |
| First charger | Scrap Mites plus one Rivet Hound | What do I abandon to intercept the relay threat? |
| Suppression lane | Rivet Hounds plus one Choir Drone | Can I reach the support unit before the charge lands? |
| Repair escort | Rust Pilgrim plus Scrap Mites | Do I focus the healer or clear the swarm? |
| Route collapse | Forklift Brute plus Hounds | Can I preserve exits and protect the relay? |
| Elite pressure | Memory Crane plus one support pair | Can I counter the copy without losing the objective? |

Every new enemy should be introduced first in a controlled composition, then in a mixed composition. Spawn density should not be the primary difficulty slider until individual questions are readable.

### 9.4 Boss plan

The first boss is the Foreman Engine. It should have three readable phases:

1. **Schedule:** telegraph three demolition zones and make the player choose where to stand.
2. **Workers:** summon worker drones that target the relay and create a priority conflict.
3. **Collapse:** shrink safe floor while opening a repair or interrupt window.

The boss should be defeatable through a combination of damage and two successful interrupts. The player should be able to recover from the first missed schedule. Three missed schedules should create a severe relay state or failure according to a visible rule.

Factory Heart and Saint of No Repairs should remain future bosses until the first boss has proven that rule-changing encounters are readable.

## 10. Progression and metagame plan

### 10.1 Run-local progression

Run-local decisions should remain the main source of power and expression.

| Layer | Function |
|---|---|
| Starting Blessing | Establishes doctrine and first direction. |
| Weapons | Determine attack geometry and combat verbs. |
| Ranks | Improve reliability and unlock evolution. |
| Gifts | Add a small support rule or interaction. |
| Catalysts | Enable a named transformation. |
| Shop services | Repair, reserve, reveal, dismantle, or deepen the current plan. |
| Objective state | Creates the cost of ignoring or pursuing the repair goal. |
| Route result | Determines the next authored pressure and reward. |

### 10.2 Permanent progression

Use Memory Fragments as the first persistent currency or record. Memory Fragments should unlock content rather than buy raw power.

Recommended order:

1. Additional Saint frames with movement or structure trade-offs.
2. Additional Blessings with new shop verbs.
3. Catalysts and visible recipes.
4. Arenas and objective types.
5. Memory scenes and route branches.
6. Transparent difficulty modifiers.

The first permanent systems should include refunds or safe experimentation where appropriate. Do not add a permanent damage, health, or reroll tree before the creative vertical demonstrates that run-local assembly is satisfying.

### 10.3 Unlock conditions

Use three clear condition families:

| Condition | Example | Reward |
|---|---|---|
| Mastery | Defeat Foreman Engine with at least 60% relay structure. | Repair-oriented Gift or service. |
| Discovery | Complete a hybrid-tag run and read the Ledger. | Catalyst or recipe. |
| Choice | Choose Brass Choir over Rootworks. | Blessing, route, or memory branch. |

Every locked item should explain why it is locked and preview its play pattern. Do not require a permanent unlock to make the first Mercy Rail run viable.

## 11. Narrative and flavour improvement plan

The story foundation is strong, but implementation should make the narrative affect decisions without turning combat into a dialogue game.

### First vertical narrative beats

| Moment | Content | Mechanical consequence |
|---|---|---|
| Boot | Damaged instruction: `RESTORE THE FIRST ENGINE`. | Establishes objective and mystery. |
| Blessing choice | Three short doctrine statements. | Starting item, shop bias, and service. |
| Shop flavour | One item history line and one practical description. | Helps explain why the offer matters. |
| Memory Crane | It copies the Saint because it has recorded the Saint’s pattern. | Elite mechanic reinforces identity theme. |
| Foreman introduction | The machine treats demolition as proper maintenance. | Boss rule reinforces industrial absurdity. |
| Results memory | One fragment reveals the Saint’s mixed construction. | Unlocks memory or route information. |

Each event should be data-driven with stable ID, condition, choice, consequence, and short presentation payload. No branching dialogue system is required for the first slice.

## 12. Presentation and commercial-quality plan

### 12.1 Visual hierarchy

The most important frame in the game should show, in this order:

1. Saint silhouette and current weapon geometry.
2. Immediate enemy direction and telegraph.
3. Relay structure and repair progress.
4. Active status and objective consequence.
5. Scrap, Relic Shards, Blessing, and current forecast.
6. Atmospheric machinery and story detail.

The background should remain subordinate to the combat layer. The art direction already specifies a warm-cool industrial palette, repaired materials, restrained brightness, and physical weapon cues [7].

### 12.2 Asset priority

Do not commission the whole world first. Invest in the assets visible in the most important gameplay and store-facing frames.

| Priority | Asset group | Why |
|---:|---|---|
| P0 | Saint base silhouette, relay, Scrap Mite, Rivet Hound, Choir Drone | Defines whether the game reads at all. |
| P0 | Nailer, Bell, Procession Gear, Mercy Rail effects | Defines the transformation hook. |
| P0 | Shop panel, Blessing icons, forecast panel, objective HUD | Defines decision clarity. |
| P1 | Memory Crane and Foreman Engine | Defines boss quality and investment value. |
| P1 | Workshop floor, salvage lane, furnace lane, crane lane | Defines map identity. |
| P2 | Additional enemies, route landmarks, memory scenes | Adds breadth after the core frame works. |
| P3 | Background world, faction props, campaign decoration | Adds polish after the slice is credible. |

Every asset needs provenance, license status, temporary/final classification, scene usage, and known mismatch as required by the repository rules [7] [12].

### 12.3 Audio and game feel

The first audio pass should prioritize causal feedback:

- Nailer: dry metal snap and short recoil.
- Bell: physical strike and resonance tail.
- Cable: tension groan and whip release.
- Repair: welding crackle, click, and upward confirmation tone.
- Objective damage: low warning tone and visible structure change.
- Evolution: a short mechanical reconfiguration cue with a distinct signature tone.
- Boss phase: concise title hit and warning pulse.

Audio should not become a decorative layer that masks event causality. Every important simulation event should have a corresponding visual or audio cue.

## 13. QA and telemetry plan

### 13.1 Expand the validator before adding broad content

The current validator should be extended in stages.

| Validator stage | New checks |
|---|---|
| P0 | Tag vocabulary, first-slice scope flags, mixed cost fields, Blessing action milestones, map ID references, and required counter families. |
| P1 | Weapon geometry IDs, target rules, status definitions, evolution deltas, and enemy telegraph data. |
| P2 | Shop role guarantees, price bands, fallback offers, route previews, and economy source budgets. |
| P3 | Objective state transitions, boss phase contracts, narrative event references, and asset provenance records. |

The validator must remain a content check. It must not report gameplay pass when only JSON is valid.

### 13.2 Runtime test layers

When the Godot project exists, implement four test layers.

| Layer | Purpose | Examples |
|---|---|---|
| Pure simulation tests | Verify state transitions without rendering. | Movement clamp, damage, repair, status expiry, combine, shop purchase. |
| Golden replay tests | Verify deterministic seed and command behaviour. | Checkpoint hashes and first divergent event. |
| Content integration tests | Verify data-driven composition. | Forecast counter availability, evolution route, boss reward. |
| Capture smoke tests | Verify real presentation states. | Blessing select, relay pressure, shop, Mercy Rail, boss phase, Results. |

### 13.3 Required metrics

For each representative seed and player profile, record:

- Time to first threat.
- Relay structure at each shop boundary.
- Scrap and Relic Shard sources and spends.
- Shop purchase, reroll, lock, sell, dismantle, and rejection events.
- Time spent away from the relay.
- Weapon ranks and evolution timing.
- Enemy defeat duration and attack frequency.
- Elite and boss interrupt success.
- Failure classification.
- First divergent replay event if a test fails.

Use these metrics to tune readability and causality before damage numbers.

## 14. Prioritized execution roadmap

### P0 — Contract reconciliation packet

**Player-facing objective:** none; make the implementation contracts internally consistent before runtime work starts.

**Required work:**

- Add explicit `scope_stage` fields to content records: `first_playable`, `creative_vertical`, or `future`.
- Normalize first-slice tags and counter families.
- Add mixed Scrap plus Relic Shard cost support.
- Convert Blessing fulfilment to authored action milestones.
- Add map data schema and Collapsed Workshop content record.
- Add Gift schema without exposing Gifts in the first playable UI.
- Define the authoritative loadout schema: four weapon slots, one reserve, and future two Gift slots.
- Reconcile the README runtime QA commands with actual repository files.
- Extend the validator to detect the current scope and vocabulary mismatches.

**Acceptance:** content validator passes; all first-slice counts match the runtime scope; no runtime task needs to infer terms from prose.

**Evidence:** validator output and a contract-diff report. No gameplay capture is expected.

### P1 — SC-01: deterministic shell and harness

Build the Godot 4.4.1 shell, fixed 60 Hz simulation, seed, command queue, pause/restart, save/load, state hashes, and a real boot capture. Do not add combat or final art.

### P2 — SC-02: movement and Collapsed Workshop

Implement the arena data, topology validation, camera framing, Saint movement, relay marker, repair zone, entry edges, and a real movement capture.

### P3 — SC-03: three weapons and three enemy questions

Implement Nailer, Bell, Procession Gear, Scrap Mites, Rivet Hounds, Choir Drones, target rules, statuses, telegraphs, and golden traces.

### P4 — SC-04: repair objective

Implement relay structure, repair progress, objective damage, partial success, failure conditions, and objective HUD. Add the first complete combat/repair capture.

### P5 — SC-05: Scrap and Relic Shards

Implement deterministic pickups, rewards, sources, collection, transaction history, and economy telemetry. Validate survival, evolution, and explorer economy profiles.

### P6 — SC-06: minimum complete shop

Implement six role-guaranteed offers, buy, combine, reserve, repair, one free refresh, capped rerolls, rejection reasons, and save-stable offers. Defer Recast Relic and complex dismantling until the basic loop is clear.

### P7 — SC-07: three Blessings

Implement Workshop Gospel, Bell Ward, and Mourner with distinct services and authored action fulfilment. Capture three doctrine-biased shop states.

### P8 — SC-08: ranks and Mercy Rail

Implement Rank 1–3, atomic combines, recipe states, Saint’s Rivet, transformation window, Mercy Rail, and before/after evidence. This is the first major quality gate.

### P9 — SC-09: Memory Crane and Foreman Engine

Implement the copy elite, demolition boss, worker drones, interrupts, phase telegraphs, objective pressure, and exact rewards.

### P10 — SC-10: Results and route choice

Implement causal Results, failure classification, memory fragment, route cards, reward commitment, and restart. The First Shift is now a complete playable loop.

### P11 — Creative vertical

Add temporary/final art kit, UI polish, audio pass, accessibility, onboarding, five weapons, four evolutions, five normal enemies, two elites, two bosses, and three objective variants only after the nine-minute loop is stable.

### P12 — Act I breadth

Add Brass Choir, Rootworks, Red Foundry, Pale Archive, one rival Saint, route consequences, additional Blessings, and authored side events. Each addition must create a new player question.

## 15. Definition of done for each improvement

An improvement is not complete because its data file exists or its code compiles. It is complete when:

1. The player-facing objective is stated in one sentence.
2. The authoritative owner and command boundary are explicit.
3. The content has stable IDs and references.
4. Valid and invalid commands are tested.
5. Same seed and command stream reproduce the same state where relevant.
6. Save/load and replay behaviour are covered where relevant.
7. The real runtime state is captured with commit, build, Godot version, viewport, scaling, seed, and state name.
8. The visual result is critiqued for hierarchy, readability, contrast, density, feedback, and polish.
9. One limitation is recorded honestly.
10. Exactly one next task is named.

## 16. Immediate next task

The next task is **P0 — reconcile the content and runtime contracts**. It should not create a playable scene. It should make the first-slice scope, tag vocabulary, Blessing fulfilment, mixed currency costs, map schema, Gift schema, and runtime QA commands internally consistent.

Once P0 passes, the next task is **SC-01 — create the Godot shell and deterministic harness**. The first runtime task must produce a real bootable build and honest capture before combat, shop, or campaign content is expanded.

## References

[1]: https://github.com/raphaelroshan/scrap-saint/blob/main/docs/astra_game_bible.md "Scrap Saint Astra game bible"
[2]: https://github.com/raphaelroshan/scrap-saint/blob/main/design/shop_and_blessings.md "Scrap Saint shop and Blessings contract"
[3]: https://github.com/raphaelroshan/scrap-saint/blob/main/docs/progression_map_weapons_metagame.md "Scrap Saint progression, map, weapons, and metagame design"
[4]: https://github.com/raphaelroshan/scrap-saint/blob/main/design/gameplay_contract.md "Scrap Saint gameplay contract"
[5]: https://github.com/raphaelroshan/scrap-saint/blob/main/tests/README.md "Scrap Saint tests and evidence plan"
[6]: https://github.com/raphaelroshan/scrap-saint/blob/main/docs/story_and_acts.md "Scrap Saint story and acts"
[7]: https://github.com/raphaelroshan/scrap-saint/blob/main/docs/art_direction.md "Scrap Saint art and feel direction"
[8]: https://github.com/raphaelroshan/scrap-saint/blob/main/content/items/first_slice.json "Scrap Saint first-slice item catalogue"
[9]: https://github.com/raphaelroshan/scrap-saint/blob/main/content/enemies/first_slice.json "Scrap Saint first-slice enemy catalogue"
[10]: https://github.com/raphaelroshan/scrap-saint/blob/main/content/bosses/first_slice.json "Scrap Saint first-slice boss catalogue"
[11]: https://github.com/raphaelroshan/scrap-saint/blob/main/docs/design_decision.md "Scrap Saint design decision record"
[12]: https://github.com/raphaelroshan/scrap-saint/blob/main/docs/agent_task_template.md "Scrap Saint agent task template"

*Prepared by Manus AI from the current private repository state and its existing design contracts. No runtime gameplay was claimed in this plan.*
