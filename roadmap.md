# Scrap Saint roadmap

## Current truth

The repository begins as a design, content, and contract foundation. No runtime or gameplay screenshot should be claimed until the Godot shell and first slice are implemented and captured honestly.

## Phase 0 — Direction and contracts

**Status:** Foundation planned.

Complete the Astra game bible, story/acts, art direction, gameplay contract, shop/Blessing contract, stable-ID content schemas, and validation tooling. Freeze the first-slice boundaries before adding broad campaign content.

**Gate:** all content IDs, commands, recipes, Blessings, objectives, enemy questions, and evidence requirements are explicit.

### Canonical systems design lock

The implementation-ready systems direction is documented in [`docs/progression_map_weapons_metagame.md`](docs/progression_map_weapons_metagame.md). Treat it as the canonical extension of the gameplay and shop contracts. The first slice is a nine-minute authored run with six pressure beats, five shop windows, the Collapsed Workshop route topology, a live repair relay, Memory Crane, Foreman Engine, and a guaranteed Mercy Rail path. The document also defines the first 15-item catalogue, the six-role deterministic offer generator, economy targets, permanent-versus-run-local boundaries, and anti-friction invariants.

These values are implementation targets rather than final balance. Agents must validate them with deterministic traces and real captures, and must not copy reference-game timings or map rules without evidence.

## Phase 1 — Deterministic workshop/combat proof

Implement SC-01 through SC-04: Godot shell, deterministic seed harness, movement, one arena, three base weapons, three enemy families, repair relay, and fixed update trace.

**Gate:** the player can move, attack, receive damage, repair an objective, and reproduce the same state from the same seed.

## Phase 2 — Shop and doctrine proof

Implement SC-05 through SC-07: Scrap, Relic Shards, six shop offers, buying, selling, dismantling, reserve, rerolls, repair, and three Blessings.

**Gate:** the player can make a meaningful immediate-survival versus future-evolution choice and can explain how the chosen Blessing changes the shop.

## Phase 3 — Evolution and boss proof

Implement SC-08 through SC-10: ranks, Saint’s Rivet, Mercy Rail, Great Toll, Memory Crane, Foreman Engine, one memory scene, and causal Results.

**Gate:** a complete 8–10 minute run exists from menu to Results, with at least one visible evolution and one boss that changes the rules.

## Phase 4 — Creative vertical

Add the first polished arena, final temporary art kit, coherent UI, three complete Blessings, five to seven weapons, four evolutions, six enemy families, two elites, two bosses, three objective variants, sound pass, accessibility pass, and real screenshot evidence.

**Gate:** the game communicates its identity in a short capture, the evolution moment feels premium, and two Blessings produce genuinely different viable builds.

## Phase 5 — Act I breadth

Build The First Shift, Contested Districts entry, and the first faction choice. Add Brass Choir and Red Foundry as compact enemy/Blessing families, one rival Saint, and two route choices.

**Gate:** a 30–45 minute first campaign segment has meaningful decisions, replayable builds, and state-aware narrative consequences.

## Phase 6 — Acts II–IV

Expand Memory Works, faction conflicts, First Engine routes, endings, additional arenas, Blessings, relics, bosses, and memory scenes only after the creative vertical has stable retention and evidence.

**Gate:** content expansion changes decisions rather than only adding more enemies and damage numbers.

## Phase 7 — Early Access candidate

Stabilise saves, controller and scaling accessibility, onboarding, difficulty, achievements, settings, performance, telemetry that respects privacy, content breadth, failure recovery, and release packaging. Perform repeated autonomous QA loops and targeted human review when available, without fabricating either.

**Gate:** stable first campaign, multiple viable doctrines, reproducible bugs, clear limitations, and a release candidate that does not rely on technical tests alone for quality claims.

## Permanent anti-scope rules

Do not add multiplayer, procedural open worlds, a large dialogue system, a full faction diplomacy simulator, a squad, deep inventory grids, or more than two run currencies before Phase 4 passes. Do not add a new content family unless it creates a new player question. Do not add a boss that is only more health. Do not add an evolution that only increases damage.

## Agent operating rhythm

Every meaningful implementation slice follows:

```text
Read bible and contract
→ state one player-facing objective
→ implement bounded authoritative slice
→ run deterministic tests
→ capture real build state
→ inspect and score evidence
→ record limitation
→ state exactly one next task
```

The repository should grow through complete vertical slices, not disconnected systems. If a feature cannot be tested deterministically or shown clearly in a screenshot, it is not ready to expand.
