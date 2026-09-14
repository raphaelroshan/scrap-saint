# Scrap Saint — First playable vertical slice

## Goal

Create a complete 8–10 minute playable called **The First Shift**. The player chooses one of three Blessings, enters a compact industrial arena, protects a repair relay, visits the relic shop, pursues one visible evolution, defeats an elite and the Foreman Engine, and receives one memory fragment about the Saint’s construction.

This slice is successful only when a new player can explain what the Saint is repairing, what the next threat wants, why a shop item matters, and how the evolution changed the build.

The implemented prototype and explicit substitutions are recorded in [runtime_status.md](runtime_status.md). The manifest is the enabled content source of truth. This document also retains longer-term acceptance intentions that are not all satisfied yet.

## Dependency order

### SC-01 — Godot shell and deterministic harness

Create the project shell, boot scene, input map, fixed update policy, seed handling, state hash checkpoints, pause, restart, and minimal debug overlay.

**Acceptance:** the same seed and command stream produce identical checkpoint hashes. The running shell shows build version, seed, viewport, and tick.

### SC-02 — Saint movement and one arena

Implement direct movement, arena bounds, camera framing, one repair relay, three enemy entry edges, and a deterministic arena reset.

**Acceptance:** movement is responsive, bounded, replayable, and visible at gameplay zoom. The relay displays structure and progress.

### SC-03 — Base combat

Implement Nailer of Small Mercies, Bell of the Last Shift, and Procession Gear. Add Rivet Hounds, Scrap Mites, and Choir Drones with deterministic targeting and telegraphs.

**Acceptance:** every hit, stagger, status, damage, and defeat is authoritative and appears in a trace. Presentation never awards damage.

### SC-04 — Repair objective

Implement `REPAIR_RELAY`, repair zones, objective damage, objective progress, and the `repair` command. Add a failure condition if the relay is destroyed.

**Acceptance:** proximity work retains progress. Final victory requires completed repair, a living relay and Saint, and Foreman defeat before the final wave expires.

### SC-05 — Scrap and Relic Shards

Add deterministic pickup generation, collection, currencies, wave rewards, and objective rewards.

**Acceptance:** pickups, currency totals, and rewards reproduce from the same seed and command stream.

### SC-06 — Relic shop

Implement six shop offers, two currencies, purchase, sell, dismantle, repair, reserve, one free refresh, and two paid rerolls. Add command rejection reasons and transaction history.

**Acceptance:** every transaction is reversible through the intended sell/dismantle rules, and a shop reload does not change the offer set.

### SC-07 — Blessings

Implement Workshop Gospel, Bell Ward, and Mourner. Each must guarantee one starting direction, bias offers, provide a unique shop service, and track fulfilment.

**Acceptance:** the three Blessings produce visibly different starting builds and at least one different shop option each.

### SC-08 — Weapon rank and Mercy Rail

Implement same-rank combining, Rank 1/2/3, Saint’s Rivet catalyst, recipe preview, transformation window, Mercy Rail, and before/after event trace.

**Acceptance:** the player can reach Mercy Rail in one deterministic run, understand the ingredients, trigger the transformation, and see a changed attack geometry plus repair effect.

### SC-09 — Elite and boss

Implement Memory Crane and Foreman Engine. Memory Crane copies the player’s last evolution. Foreman Engine schedules demolition zones and summons worker drones.

**Acceptance:** the elite and boss create different questions, have readable telegraphs, and cannot be defeated by a presentation-only effect.

### SC-10 — Memory and Results

Add one post-boss memory fragment, causal result summary, build summary, objective result and evolution reached. State hash, limitations, and the developer next task belong in the separate evidence report.

**Acceptance:** Results explain what worked, what failed, and why the player’s chosen Blessing mattered.

## First-slice content

| Category | Count |
|---|---:|
| Arenas | 1 |
| Saint frames | 1 |
| Blessings | 3 |
| Base weapons | 5 |
| Catalysts | 4 |
| Evolutions | 1 |
| Enemy families | 3 |
| Elite | 1 |
| Boss | 1 |
| Objectives | 1 |
| Shop services | 6 |
| Memory scenes | 1 |

The additional first-slice weapons are Candle-Nailer and Cable of Contrition. The Great Toll is deferred beyond this slice. Mercy Rail is the first optional evolution; completing a run must not require it.

## Evidence requirements

For each vertical-slice milestone, capture:

- Running build identifier and commit.
- Godot version.
- Exact viewport and scaling settings.
- Seed and command/replay identifier.
- Visible state name.
- Screenshot or short capture of the real running state.
- Deterministic test result.
- Visual critique with all required rubric rows.
- Remaining limitation.
- Exactly one next task.

A content validator result is not a gameplay screenshot. If runtime is unavailable, report `BLOCKED_ENVIRONMENT` or `PLANNED_ONLY` rather than claiming execution.

## Completion gate

The vertical slice is not complete until a player can begin from the menu, choose a Blessing, move through the arena, see enemies attack the repair relay, collect Scrap, use the shop, reach and understand Mercy Rail, defeat the Foreman Engine, and read a causal Results screen. The code must be deterministic and the screenshot evidence must show the intended visual hierarchy.
