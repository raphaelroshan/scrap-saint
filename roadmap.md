# Scrap Saint roadmap

## Current direction — 2026-09-18

This section supersedes the historical implementation sequence below. The current 0.6 preview includes ten weapons, ten Evolutions, seven Gifts, four Blessings, three frames, a branching three-site expedition, and the illustrated main menu. See [runtime status](docs/runtime_status.md) for implemented behavior and verification. Earlier roster counts and failed-policy reports describe their original builds.

User decisions remain authoritative: the Saint manifests through repairs freely given; main-mode shops offer relics; recovery comes from drops and optional work; destination repairs are optional. Preserve the current gameplay and chapter systems. Commit and push completed validated changes.

### Visual decision: manifested relics

Keep the current playable Saint sprite unchanged for this phase. Weapons manifest as recognizable objects and attack effects near the Saint or at their authoritative attack origins. Brief manifestations appear, perform the attack and fade; persistent orbiting or area effects remain visible for their active lifetime. Warm brass and restrained cream light connect the relics to the remembered service of discarded tools.

Defer the proposed attachment-arm rig, mount sockets and character-sprite replacement. The character and weapon concept boards remain references, not implementation requirements. Existing targeting, damage, attack cadence, hitboxes and evolution rules remain simulation-owned; visual appearance must not delay or duplicate an attack.

### Ordered visual work

| Order | Work | Completion gate |
|---|---|---|
| 1 — complete | Manifested Nailer and Mercy Rail on the unchanged Saint | Distinct rivet mechanism, recoil and line resolve; Mercy Rail visibly unfolds longer guides and uses its existing attack geometry. Verified normal and reduced effects, moving/facing changes, event timing and unchanged simulation outcomes. |
| 2 — next | Manifested Bell, Cable and Foundry Censer | Bell body and hammer precede readable arcs; clamp/reel accompany the tether; Censer vessel accompanies its low smoke field. Preserve each relic's silhouette and existing behavior. |
| 3 | Four-weapon overlap and remaining relic families | Stress-test simultaneous attacks at the actual gameplay camera. Saint position, nearby enemies and threat cues remain visible. Persistent gears/halos follow their existing lifetimes; short attacks clean up promptly. |
| 4 | Workshop Level 1 presentation and pacing review | Test the complete opening level at normal speed with uncoached players; use findings to tune clarity and pacing before expanding art coverage. |

No character rig, new weapons or balance changes are prerequisites for step 1. Require real Godot captures with build/viewport/seed provenance and event/state regression checks for each runtime slice. Concept boards alone do not satisfy these gates.

Exactly one next task: manifest Bell, Cable and Foundry Censer with the same event-driven boundary and actual-camera capture gate.

## 1. Roadmap purpose and current truth

A playable Godot prototype now spans the First Shift loop. See [runtime status](docs/runtime_status.md) for implemented subsets, verification results and deferred mechanics. The accepted launch scope is in the [Early Access delivery plan](docs/early_access_plan.md). Human playtesting and creative-vertical approval remain outstanding.

**Current user decisions (P16) supersede conflicting earlier requirements below:** free movement with optional repairs is the main game; relay defence remains a development comparison. Manual Foreman interruption was removed. The workshop has a following camera and minimap, ten base weapons, six ordinary enemy families, seven run-local Gifts and ten visible Evolutions. Every Evolution and Gift is optional, no Confluence is enabled, and encounters must support unevolved builds. Runtime cadence is eight 70-second waves with seven shops. The detailed milestone plan below is retained as the original design baseline, not a claim that every planned mechanic is implemented.

This roadmap turns the canonical systems design in [`docs/progression_map_weapons_metagame.md`](docs/progression_map_weapons_metagame.md) into an implementation sequence. The current audit and system-resolution plan is in [`docs/improvement_plan_2026-09-15.md`](docs/improvement_plan_2026-09-15.md). Future weapon, merge, evolution, and Gift proposals are in [`docs/weapons_merges_traits_expansion.md`](docs/weapons_merges_traits_expansion.md); they are design records, not enabled runtime content. It is the operating plan for Astra and other development agents. The target is not a collection of isolated mechanics. The target is a compact, understandable, replayable vertical slice called **The First Shift**.

> **First-slice promise:** the player chooses a Blessing, enters a compact industrial workshop, moves and auto-attacks with optional repair rewards, makes meaningful workshop decisions, reaches the visible Mercy Rail evolution, defeats a rule-changing elite and boss, and understands how the Saint’s identity changed.

Current evidence: 129 Godot assertions pass; main-mode automated full runs record 11/12 wins. One Mourner run fails on wave five, so the all-win balance gate remains failed. See runtime status for evidence and limitations.

## 2. Canonical product and systems lock

The first implementation must preserve the following decisions.

| Area | Canonical decision | Boundary |
|---|---|---|
| Run shape | Nine-minute authored run with six pressure beats, five shop windows, one elite, one boss, and one visible evolution. | Do not begin with an endless or fully procedural mode. |
| Objective | Survive industrial machines and defeat the Foreman; repairs offer optional rewards. | Do not restore mandatory relay defence or manual boss interruption. |
| Arena | The Collapsed Workshop, a compact route-bearing arena with three entry edges, a relay bowl, salvage lane, hazard lane, and workshop alcove. | Every traversable pocket must have two exits. |
| Currency | Scrap and Relic Shards only. | Do not add a third run currency. |
| Doctrine | Blessings define broad run direction and shop bias. | A Blessing must not hard-lock a build. |
| Assembly | Weapons, ranks, catalysts, reserve, shop services, and visible recipes. | Do not introduce a deep inventory grid. |
| Evolution | Rank 3 Nailer plus Saint’s Rivet produces Mercy Rail. | The transformation must change geometry, targeting, and repair interaction, not only damage. |
| Authority | Fixed-timestep deterministic simulation owns all outcomes. | Presentation may not award damage, repair, purchases, or evolution. |
| Persistence | Frames, Blessings, discoveries, memories, catalysts, services, arenas, and transparent difficulty modifiers persist. | Early metagame must not be permanent damage and health inflation. |
| Quality evidence | Every meaningful slice needs deterministic tests, a real capture, exact build/viewport/seed provenance, a visual critique, and one limitation. | A validator result or static mockup is not a gameplay pass. |

All timing, price, economy, and topology values are initial implementation targets. Agents must tune them from deterministic traces and real captures rather than treating them as immutable balance facts.

## 3. Dependency graph

The runtime must be built in this order:

```text
SC-01 deterministic shell and replay
  ↓
SC-02 Saint movement and Collapsed Workshop
  ↓
SC-03 base combat and enemy questions
  ↓
SC-04 relay damage and repair objective
  ↓
SC-05 Scrap and Relic Shards
  ↓
SC-06 six-offer workshop
  ↓
SC-07 Blessings and fulfilment
  ↓
SC-08 ranks, catalysts, and Mercy Rail
  ↓
SC-09 Memory Crane and Foreman Engine
  ↓
SC-10 Results, memory, and route choice
  ↓
Creative vertical and Act I breadth
```

An agent may work ahead on data definitions or test fixtures, but it must not present a later system as playable until its dependencies are real and verified. Every implementation task must be a bounded packet with exactly one player-facing objective.

## 4. Phase 0 — Direction, contracts, and data lock

**Status:** design foundation complete; runtime not started.

### Objective

Make the product promise, simulation boundary, content vocabulary, and evidence standard unambiguous before runtime work begins.

### Existing deliverables

- [`docs/astra_game_bible.md`](docs/astra_game_bible.md) defines the product promise, story, tone, visual identity, and non-goals.
- [`docs/story_and_acts.md`](docs/story_and_acts.md) defines the Pilgrimage of Repairs and Saint Built Wrong narrative structure.
- [`design/gameplay_contract.md`](design/gameplay_contract.md) defines deterministic simulation ownership and command boundaries.
- [`design/shop_and_blessings.md`](design/shop_and_blessings.md) defines currencies, offers, shop actions, Blessings, and recipe states.
- [`docs/progression_map_weapons_metagame.md`](docs/progression_map_weapons_metagame.md) defines the run, map, weapons, economy, metagame, failure rules, and acceptance gates.
- Stable-ID content files define the first-slice weapons, Blessings, enemies, bosses, and evolutions.
- `scripts/validate_content.py` validates the current content contracts.

### Phase 0 gate

The gate is complete when all of the following remain true:

1. Every first-slice content record has a stable ID and deterministic references.
2. Every enemy has a target preference, telegraph, counter family, and failure explanation.
3. Every shop action has a command, success event, rejection reason, and deterministic test case.
4. Every evolution has a visible before/after behaviour change.
5. Every runtime task identifies its authoritative owner and presentation boundary.
6. The content validator passes.
7. The next task is SC-01 and no agent claims a playable build exists.

## 5. Phase 1 — Deterministic workshop and combat proof

Phase 1 implements SC-01 through SC-04. It is complete only when a player can boot the project, move in the Collapsed Workshop, attack enemies, see the relay threatened, and repair it through an authoritative command.

### SC-01 — Godot shell and deterministic harness

**Player promise:** the Saint can boot a named build, accept a fixed command stream, pause, restart, and reproduce the same simulation state.

**Authoritative owner:** simulation core, seed service, command queue, save state, and replay harness.

**Required work:**

- Create the Godot 4.4.1 project shell and boot scene.
- Add fixed 60 Hz simulation updates.
- Add versioned seed input and a dedicated combat/shop RNG separation.
- Add command queue, command rejection results, state snapshots, and state hashes.
- Add pause, restart, deterministic save/load, and a minimal debug overlay.
- Display build ID, commit, seed, viewport, scaling mode, simulation tick, and state hash.
- Add a first menu path that enters the Workshop/Combat proof without pretending to be a finished title screen.

**Deterministic acceptance tests:**

1. Seed `104729` and an identical command stream produce byte-identical checkpoint hashes at ticks 0, 60, 120, and 180.
2. Seeds `104729` and `104730` diverge at a documented checkpoint under the same command stream.
3. Pausing for 120 wall-clock frames does not advance simulation time, RNG cursors, or state hash.
4. Save at tick 90, reload, and continue produces the same event IDs and final hash as uninterrupted execution.
5. An invalid command returns a stable rejection reason and does not mutate state or advance an RNG cursor.

**Evidence gate:** real running-shell capture showing the menu or boot state, build ID, seed, viewport, tick, and commit. Static UI is not sufficient.

**Non-goals:** combat polish, procedural arenas, broad content, final art, audio pass, or permanent progression.

### SC-02 — Saint movement and Collapsed Workshop

**Player promise:** the Saint can move through the first arena, remain inside its bounds, reach the relay, and understand where repair and threats occur.

**Authoritative owner:** movement, collision bounds, arena data, route validation, relay position, and camera framing inputs.

**Required work:**

- Implement the 20-by-14 logical-metre Collapsed Workshop.
- Place the relay bowl, west salvage lane, north crane lane, east furnace lane, and south workshop alcove.
- Add West Conveyor, North Crane, and East Furnace entry-edge IDs.
- Add a continuous outer loop and two machine obstructions that do not create dead ends.
- Add the relay repair zone with a visible 2.5-metre radius and authoritative interaction pulse.
- Add the shop alcove as a safe decision space without hidden free healing.
- Add three-second hazard markers and one-second warning pulses as data-driven timings.
- Add topology validation that rejects any traversable pocket with fewer than two exits.
- Add camera framing and gameplay zoom that preserve the relay, Saint, and threat lanes in one readable view.

**Deterministic acceptance tests:**

1. A fixed 600-tick movement stream reproduces Saint position, velocity, relay structure, and objective progress at ticks 0, 120, 300, and 600.
2. Movement input is clamped to the defined maximum and has no diagonal speed exploit.
3. The Saint cannot cross any arena boundary.
4. Repair outside the zone returns `INVALID_TARGET`; repair inside the zone changes progress only through an authoritative `REPAIRED` event.
5. The topology validator confirms two exits per pocket, reachability of all three entry edges, and a route to the relay that does not require the shop alcove.
6. Resetting twice with the same seed reproduces obstacle positions, entry edges, relay state, and Saint start position.

**Evidence gate:** gameplay capture showing the Saint, relay structure/progress, repair ring, three entry edges, gameplay zoom, seed, and viewport.

**Non-goals:** dynamic map generation, route nodes beyond the first arena, combat balance, or final environmental art.

### SC-03 — Base combat and enemy questions

**Player promise:** three automatic relic weapons and three enemy families interact clearly and deterministically.

**Authoritative owner:** targeting, attack scheduling, collision/effect resolution, enemy state, status duration, damage, stagger, defeat, and event trace.

**Required work:**

- Implement Nailer of Small Mercies, Bell of the Last Shift, and Procession Gear.
- Implement Rivet Hounds, Scrap Mites, and Choir Drones.
- Implement nearest-target, objective-attacker, radial, and orbit target rules.
- Implement the first visible statuses: `MARKED`, `RUNG`, `QUIETED`, and `WITNESSED`.
- Give each enemy a stable entry rule, target preference, telegraph, counter family, and readable defeat state.
- Add combat trace events with source, target or area, effect, amount, duration, and stable event ID.
- Keep ordinary weapons automatic, while allowing later objective and elite interactions to create deliberate positioning questions.

**Deterministic acceptance tests:**

1. Fixed enemy positions and seed produce a golden trace with identical attack IDs, target IDs, damage, statuses, and defeat order.
2. Nailer selects the nearest eligible target and switches to an objective attacker when the content rule requires it.
3. Bell applies `RUNG` or `WITNESSED` only through an authoritative effect event.
4. Procession Gear produces identical orbit geometry, hit order, and cooldown across repeated runs.
5. Presentation-only damage events do not change authoritative health.
6. Enemy telegraphs precede their damaging event by the authored warning duration.

**Evidence gate:** real combat capture with all three enemy families or a clearly scoped subset, plus a trace excerpt. Particles alone do not prove combat authority.

**Non-goals:** evolution, shop, boss logic, enemy count spectacle, or permanent upgrades.

### SC-04 — Relay damage and repair objective

**Player promise:** the player can see why the relay is threatened, contest attackers, repair damage, and recover from a costly partial state.

**Authoritative owner:** relay structure, repair progress, enemy objective targeting, repair commands, failure thresholds, and objective rewards.

**Required work:**

- Start the relay at 70% structure.
- Prevent lethal relay damage before the first shop window.
- Add warning state, threatened state, damaged state, and destroyed state.
- Make Rivet Hounds the first explicit relay attackers.
- Add repair progress, repair pulses, repair-zone contesting, and phase caps.
- Add partial-success outcomes where the relay survives with reduced structure.
- Record objective damage source, attacker, timing, and player response.
- Add a visible objective HUD with structure, repair progress, current threat, and next threat forecast placeholder.

**Deterministic acceptance tests:**

1. Relay damage is applied only by an authoritative enemy or hazard event.
2. The first combat beat cannot destroy the relay.
3. A repair command outside the zone is rejected without state mutation.
4. A repair command inside the zone creates progress and a `REPAIRED` event.
5. The same seed and command stream reproduce relay structure and repair progress.
6. Results distinguish Saint defeat, relay destruction, and partial relay success.

**Evidence gate:** capture showing the relay under threat, a repair interaction, objective HUD, and a real transition into a partial or recovered state.

**Phase 1 gate:** the player can move, attack, receive damage, observe a relay threat, repair the relay, restart, and reproduce the same result from the same seed.

## 6. Phase 2 — Economy, workshop, and doctrine proof

Phase 2 implements SC-05 through SC-07. It is complete only when a player can make an immediate-survival versus future-evolution decision and explain how the chosen Blessing changes the shop without hard-locking the run.

### SC-05 — Scrap and Relic Shards

**Player promise:** every reward has a clear source and the player can decide whether to spend now, save for an evolution, or accept a repair trade-off.

**Authoritative owner:** pickup generation, collection, currency totals, wave rewards, objective rewards, elite rewards, and transaction history.

**Required work:**

- Add Scrap from ordinary enemies, destructibles, wave completion, and objective milestones.
- Add Relic Shards from elites, objectives, bosses, and shrine-like authored events.
- Keep combat RNG and shop RNG on separate streams.
- Add deterministic pickup positions and collection rules.
- Add a transaction history showing source, amount, and spend category.
- Add economy telemetry for each run so balance can be tuned from traces rather than memory.

**Initial targets:** 80–120 Scrap, 3–5 Relic Shards, and at least five meaningful spending decisions in the first run. These are tuning targets, not completion claims.

**Deterministic acceptance tests:**

1. Pickup positions, amounts, and collection order reproduce from seed and command stream.
2. Scrap and Shard totals match a golden trace.
3. The same reward is not granted twice after reload or repeated collection.
4. Currency rejection reasons are stable and do not consume RNG.
5. A 70%-pickup trace can afford one Rank 1 improvement, one repair/service, and one catalyst component before the elite.

**Evidence gate:** real capture of a pickup, currency counter, reward source, and transaction history.

### SC-06 — Six-offer relic workshop

**Player promise:** every workshop visit presents understandable choices that address the current build, the visible evolution, and the next threat.

**Authoritative owner:** offer generation, prices, locking, rerolls, purchases, selling, dismantling, reserve, repair services, and transaction results.

**Required work:**

- Display two weapon-bay, two relic-bench, and two service-altar offers.
- Implement the six guaranteed offer roles: current-build improvement, evolution path, new direction, flexible support, threat counter A, and threat counter B/Blessing context.
- Implement buy, sell, dismantle, combine, reserve, repair, reroll, Read the Ledger, and Recast Relic as simulation commands.
- Add one reserve slot and one free refresh.
- Preserve one actionable current-build offer and one visible evolution path on every visit.
- Generate offers from `run_seed`, `shop_visit_index`, `blessing_id`, `forecast_id`, `inventory_signature`, and `reroll_index`.
- Ensure rerolls never alter combat timing, pickup positions, objective state, or route selection.
- Make save reload preserve the offer set and prices.

**Initial price targets:**

| Transaction | Initial target |
|---|---:|
| Rank 1 weapon | 12–16 Scrap |
| Rank 2 weapon or premium service | 20–28 Scrap |
| Saint’s Rivet | 1 Relic Shard + 8 Scrap |
| Ordinary repair pulse | 5 Scrap |
| Full repair service | 1 Relic Shard + 10 Scrap |
| Reserve service | 4 Scrap |
| Ledger reveal | 1 Relic Shard |
| Rerolls | 0 / 2 / 4 / 7 Scrap |

**Deterministic acceptance tests:**

1. Same seed, state, forecast, and shop index produce the same six offer IDs and prices.
2. Reroll changes only offer IDs and reroll cost.
3. Locked offers preserve ID and price across reroll.
4. Reloading a shop does not reroll its offers.
5. Buying, selling, dismantling, and combining produce atomic state transitions.
6. Every rejected action returns a stable reason such as `INSUFFICIENT_SCRAP`, `ACTIVE_SLOTS_FULL`, `RESERVE_FULL`, or `MISSING_INGREDIENT`.
7. The generator replaces an unaffordable or non-actionable mandatory offer with its deterministic fallback.

**Evidence gate:** real capture showing a forecast, six offer roles, a purchase, a rejected command, and a preserved locked offer.

### SC-07 — Blessings and fulfilment

**Player promise:** the chosen Blessing gives the run a recognizable doctrine without forcing one exact build.

**Authoritative owner:** Blessing selection, starting guarantee, offer weights, unique service, fulfilment progress, and reward application.

**Required work:**

- Implement The Workshop Gospel, The Bell Ward, and The Mourner.
- Give each Blessing a starting guarantee, shop bias, unique service, fulfilment condition, reward, and weakness.
- Display fulfilment as three causal steps.
- Apply fulfilment rewards at shop boundaries, not through presentation-only effects.
- Preserve the Mercy Rail guarantee regardless of Blessing choice.
- Record Blessing decisions and fulfilment in replay and Results.

**Deterministic acceptance tests:**

1. Each Blessing produces a distinct starting item or service and a distinct shop weighting.
2. Each Blessing has one visible fulfilment path and one visible reward.
3. Ignoring the Blessing reduces favoured offers but does not make the run invalid.
4. Blessing rewards are applied once at the correct boundary.
5. Identical seed, Blessing, and command stream reproduce the same fulfilment state.

**Evidence gate:** a capture of the Blessing choice, a doctrine-biased shop, a fulfilment step, and the resulting reward.

**Phase 2 gate:** the player can visit the workshop, spend both currencies, reserve or combine items, pursue Mercy Rail, and explain how three Blessings differ.

## 7. Phase 3 — Evolution, elite, boss, and Results proof

Phase 3 implements SC-08 through SC-10. It is complete only when the entire nine-minute loop works from menu to causal Results.

### SC-08 — Ranks, catalysts, and Mercy Rail

**Player promise:** the player can understand, pursue, trigger, and feel the difference of one visible weapon evolution.

**Authoritative owner:** item instances, rank combining, catalyst eligibility, recipe state, trigger window, evolution transaction, and transformation event.

**Required work:**

- Implement Rank 1, Rank 2, and Rank 3.
- Combine two identical same-rank items atomically.
- Implement `UNKNOWN`, `DISCOVERED`, and `READY` recipe states.
- Implement Saint’s Rivet and its cost.
- Guarantee a valid Rank-up/catalyst route by Shops 2–4.
- Trigger evolution only at the elite reward, boss reward, or altar window.
- Replace Nailer with Mercy Rail and record source IDs, catalyst ID, result ID, geometry delta, target-rule delta, objective delta, and resource delta.
- Show before/after attack geometry and explain the relay-repair interaction.
- Keep Great Toll authored but outside the required first evolution gate until Mercy Rail is stable.

**Deterministic acceptance tests:**

1. Two identical Rank 1 items combine into one Rank 2 item with stable lineage.
2. Failed combine leaves the inventory and RNG cursor unchanged.
3. Nailer Rank 3 plus Saint’s Rivet reaches `READY` in a deterministic first-slice run without perfect pickup collection.
4. Mercy Rail changes geometry, target priority, and relay interaction.
5. The evolution cannot trigger during movement or outside an approved transformation window.
6. The before/after trace and final state reproduce from the same seed and command stream.

**Evidence gate:** a real capture showing the recipe preview, missing ingredient or `READY` state, transformation window, and post-evolution combat/repair behaviour.

### SC-09 — Memory Crane and Foreman Engine

**Player promise:** the elite and boss ask different questions from ordinary enemies and change the rules rather than only adding health.

**Authoritative owner:** elite/boss phases, telegraphs, demolition schedules, copied geometry, summons, interrupts, relay cable state, damage, and rewards.

**Required work:**

- Implement Memory Crane at the elite checkpoint.
- Make Memory Crane copy the player’s last completed evolution, or highest-rank geometry if no evolution exists.
- Implement its demolition sweep and readable spawn telegraph.
- Implement Foreman Engine with three demolition zones, worker-drone summons, and a temporary relay-cable disconnect.
- Require two successful interrupt interactions to defeat the boss.
- Make the first missed demolition recoverable and the third missed demolition lethal or near-lethal according to a documented rule.
- Grant the authored Relic Shard rewards exactly once.

**Deterministic acceptance tests:**

1. Memory Crane copies the same geometry for the same build and seed.
2. Copied geometry is visible in a pre-damage telegraph.
3. Foreman Engine schedules the same demolition sequence under the same replay.
4. Interrupts are authoritative commands with stable rejection reasons.
5. Worker drones, cable disconnect, relay damage, and boss defeat appear in the event trace.
6. Boss defeat is impossible through presentation-only effects or a single damage shortcut.

**Evidence gate:** real elite and boss captures showing telegraphs, at least one interrupt, relay pressure, and the boss rule change.

### SC-10 — Results, memory, and route choice

**Player promise:** the run explains what happened, why the build worked or failed, and what the next pilgrimage choice means.

**Authoritative owner:** result classification, reward commitment, memory unlock, route selection, and run summary state.

**Required work:**

- Add success, failure, and partial-relay result states.
- Record Scrap, Relic Shards, Blessing progress, recipes, evolution, relay structure, damage causes, and boss outcome.
- Classify the primary failure cause as `BUILD_GEOMETRY`, `OBJECTIVE_NEGLECT`, `POSITIONING`, `THREAT_RESPONSE`, `ECONOMY`, or `META_GATE`.
- Show one memory fragment about the Saint’s construction.
- Present two authored route cards: Brass Choir Relay and Rootworks Pump.
- Record route choice as a simulation command, even while future sites remain stubs.
- Allow immediate restart with the same seed or a new seed.

**Deterministic acceptance tests:**

1. Identical runs produce identical Results data and route cards.
2. Result classification derives from simulation events rather than UI heuristics.
3. Rewards are committed once and cannot duplicate after reload.
4. Route choice is present in the replay and changes the next-run setup when implemented.
5. Results name one primary cause and at most one secondary cause.

**Evidence gate:** real capture from menu through Results showing the chosen Blessing, combat, shop decision, Mercy Rail, boss, result classification, memory, and route cards.

**Phase 3 gate:** a new player can complete or fail a full nine-minute run and answer what was repaired, what the threat wanted, why the shop mattered, and how Mercy Rail changed the build.

## 8. Full first-slice completion gate

The First Shift is complete only when all of the following are true:

- A real Godot build boots from a menu or clearly labelled prototype entry.
- The player can choose one of three Blessings.
- The Collapsed Workshop has readable topology and three enemy entry edges.
- The Saint moves, auto-attacks, takes damage, collects Scrap, and repairs the relay.
- The relay can be threatened, partially damaged, repaired, or destroyed.
- Five shop windows present deterministic six-offer layouts.
- Scrap and Relic Shards have distinct uses and clear sources.
- Rank combining, reserve, reroll, rejection reasons, and one visible recipe work.
- Mercy Rail is reachable without perfect play and changes combat plus objective behaviour.
- Memory Crane copies a build-shaped pattern.
- Foreman Engine changes the arena question through demolition and interrupts.
- Results explain the run causally and present a route choice.
- Deterministic tests pass for the implemented systems.
- Real screenshots or a short capture include exact build, commit, Godot version, viewport, scale, seed, tick/state identifier, and visible state.
- Visual critique covers hierarchy, readability, contrast, density, feedback, polish, and limitations.
- The report states exactly one next task.

A content validator pass alone cannot satisfy this gate.

## 9. Phase 4 — Creative vertical

Only after Phase 3 passes should the project move from functional proof to investment-evaluable presentation.

### Creative vertical objectives

- Replace debug geometry with a coherent temporary art kit that expresses warm industrial devotion.
- Make the Saint, relay, enemies, shop, Blessing symbols, and boss readable at gameplay zoom.
- Add a consistent palette, material language, impact effects, warning shapes, and audio cues.
- Make Mercy Rail’s transformation a premium moment with a clear before/after silhouette.
- Add controller support, screen scaling, readable fonts, pause behaviour, and accessibility settings.
- Improve onboarding so a first-time player understands the relay, forecast, shop roles, and evolution path without external documentation.
- Add three complete Blessings, five to seven working weapons, four working evolutions, six enemy families, two elites, two bosses, and three objective variants only after the first slice is stable.

### Creative vertical gate

The game must communicate its identity in a short capture. Two Blessings must produce genuinely different viable builds. The first evolution must be visually legible without relying on particles alone. A reviewer must be able to identify the relay, Saint, enemy pressure, shop decision, and boss rule from screenshots.

The creative vertical still remains single-player, compact, deterministic, and authored. It is not the point to expand into a campaign before the core loop has a credible presentation.

## 10. Phase 5 — Act I breadth

After the creative vertical is stable, expand the first campaign segment.

### Content sequence

1. **The First Shift:** Collapsed Workshop and the Foreman Engine.
2. **Contested Districts entry:** Brass Choir Relay and Rootworks Pump routes.
3. **First faction choice:** Brass Choir, Red Foundry, or a neutral repair route.
4. **Rival Saint encounter:** one build-shaped challenger with a readable doctrine.
5. **Objective variants:** protect, escort, recover, and hold, each introducing one new player question.
6. **Route consequences:** rewards, threats, memories, and later shop bias change based on authored choices.
7. **Additional Blessings and catalysts:** each adds a distinct service, counter family, or evolution geometry.

### Act I gate

Act I is complete when it provides a 30–45 minute first campaign segment with meaningful route choices, multiple viable doctrines, replayable builds, state-aware narrative consequences, and no content family that exists only to increase enemy health or add more damage numbers.

## 11. Phase 6 — Acts II–IV and endgame structure

Expand Memory Works, faction conflicts, First Engine routes, endings, arenas, Blessings, relics, bosses, and memory scenes only after the creative vertical and Act I demonstrate stable readability.

The campaign should add decisions rather than merely add volume. New arenas must change topology, objective pressure, or route questions. New bosses must change a rule, objective, timing, or spatial condition. New evolutions must alter geometry, target rules, objective interactions, resource behaviour, or another clearly visible verb.

The first Endless Siege or equivalent challenge mode should be deferred until the authored run and campaign routes have strong results data. Endless content must not become the primary balancing target for the first slice.

## 12. Metagame implementation order

Permanent progression is an option and story layer, not a mandatory power treadmill.

| Order | Permanent layer | Initial purpose | Unlock rule |
|---:|---|---|---|
| 1 | Memory Fragments | Connect repairs and choices to the Saint Built Wrong arc. | Authored first-time objectives and route outcomes. |
| 2 | Saint Frames | Change movement, structure, reserve capacity, or starting service. | Mastery or story conditions. |
| 3 | Blessings | Add doctrines, shop biases, services, and fulfilment patterns. | Clear authored discoveries or choices. |
| 4 | Catalysts and recipes | Add transformation verbs and build routes. | Discovery and Ledger milestones. |
| 5 | Arenas and objectives | Expand the pilgrimage’s spatial questions. | Route and mastery conditions. |
| 6 | Transparent difficulty modifiers | Add challenge and replay value without mandatory grind. | Demonstrate the relevant counter skill. |

Every locked item needs a visible `WHY LOCKED` explanation and a preview of its play pattern. The first Mercy Rail run must never require a prior permanent unlock.

Do not implement a permanent stat shop before the creative vertical has proven that run-local assembly is fun. If a later permanent modifier system is added, it must be refundable or otherwise safe to experiment with, and it must not make the base first slice unreadable.

## 13. Balance and tuning workflow

Balance changes must be driven by traces and captures.

For each representative seed, record:

- Time to first threat.
- Relay structure at each shop boundary.
- Scrap earned and spent by category.
- Relic Shards earned and spent.
- Shop purchases, rerolls, locks, and rejected commands.
- Weapon ranks and evolution timing.
- Enemy density and defeat duration.
- Time spent away from the relay.
- Elite and boss interrupt success.
- Failure classification.

Tune in this order:

1. **Readability:** the player can identify the threat, route, objective, and response.
2. **Causality:** the player can understand why structure, health, or currency changed.
3. **Viability:** the player has at least two valid responses to each forecasted pressure.
4. **Economy:** a normal run can pursue an evolution without perfect collection.
5. **Difficulty:** failures are caused by choices or execution rather than hidden gates.
6. **Pacing:** shops, elite, evolution, boss, and Results arrive before attention drops.
7. **Presentation:** only after the above are stable should effects and content breadth be expanded.

Do not balance by making enemies into health sponges. Prefer changed entry mixes, telegraphs, hazards, objective trade-offs, and boss schedules.

## 14. Autonomous QA and evidence protocol

Every meaningful runtime, UI, audio, content, or presentation change follows this loop:

```text
Read the bible, contract, and relevant task packet
→ state one player-facing objective
→ implement the smallest authoritative slice
→ run content validation and deterministic tests
→ run the autonomous iteration/capture loop when a Godot build exists
→ inspect the real capture
→ score visual evidence
→ record exact build, commit, Godot version, viewport, scaling, seed, and state
→ state one limitation
→ state exactly one next task
```

The minimum report for a completed runtime slice contains:

| Field | Required content |
|---|---|
| Build provenance | Commit, build ID, Godot version, platform, viewport, scaling mode. |
| Simulation provenance | Seed, replay/command identifier, tick or state hash. |
| Player state | Visible objective, weapons, Blessing, currencies, relay structure, threat. |
| Test result | Deterministic tests and content validator output. |
| Visual evidence | Real screenshot or capture from the running build. |
| Critique | Hierarchy, readability, contrast, density, feedback, polish, and limitation. |
| Honesty state | `PASS`, `FAIL`, `TIMEOUT_PARTIAL`, `BLOCKED_ENVIRONMENT`, or `INVALID_EVIDENCE`. |
| Next task | Exactly one bounded follow-up. |

If Godot or capture is unavailable, classify the task as `BLOCKED_ENVIRONMENT` or `PLANNED_ONLY`. Never replace missing gameplay evidence with a generated status image or a scenario manifest.

## 15. Permanent anti-scope rules

Before the creative vertical passes, do not add:

- Multiplayer, co-op, PvP, networking, or shared simulation.
- A procedural open world or freeform exploration map.
- A deep backpack or equipment grid.
- More than the two run currencies.
- A broad dialogue tree or full faction diplomacy simulator.
- Squad management or real-time party control.
- A permanent damage and health inflation tree as the primary progression.
- Hidden tag puzzles that require external guides.
- A shop whose best outcome depends on unlimited rerolls or rare random drops.
- More than one required visible evolution in the first slice.
- Bosses that are only health sponges or untelegraphed one-hit failures.
- New content families that do not introduce a new player question.

The project is allowed to be small. It is not allowed to be vague, unreadable, or falsely presented as complete.

## 16. Agent task-packet template

Every future implementation request should begin with a packet in this shape:

```markdown
# Task packet: SC-XX — [bounded objective]

## Player-facing objective
[One sentence describing what the player can now do or understand.]

## Authoritative owner
[Simulation subsystem, command boundary, and state/events affected.]

## Exact files
[Files to create or modify.]

## Preserved contracts
[Canon, currencies, Blessing rules, deterministic rules, and presentation boundary.]

## Non-goals
[Adjacent systems explicitly deferred.]

## Deterministic acceptance tests
[Numbered tests with seeds, commands, checkpoints, and rejection reasons.]

## Evidence states
[Real gameplay states to capture, with build/viewport/seed provenance.]

## Remaining limitation
[Known limitation after this task.]

## Exactly one next task
[The next dependency-ordered packet.]
```

## 17. Immediate next task
The next task is **uncoached 1× comparison of the original three-Gift pool with the P16 seven-Gift pool**. Measure whether players understand Honest Scale before buying, notice Spring/Filter/Fuse activation in motion, and encounter any low-value support offers despite compatibility filtering. Do not add Confluences or another progression layer until those shop-decision results are recorded. Use [implementation packets](docs/implementation_packets.md) and [runtime status](docs/runtime_status.md) to distinguish implemented subsets from the original milestone specifications.
