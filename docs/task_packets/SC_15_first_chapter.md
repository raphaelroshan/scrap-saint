# Task packet: SC-15 — The first pilgrimage branch

## Player-facing objective
Defeat the Foreman, choose Brass Choir Relay or Rootworks Pump, travel there with the same build, complete a route-specific objective and boss encounter, and finish the chapter with a memory that records the choice.

## Authoritative owner
`game/simulation.gd` owns route availability and validation, travel progress, arena selection, carried inventory/economy, destination objective progress, boss completion, memory state, and save/restore. Presentation sends `choose_route`, `advance_travel`, and `accept_memory` commands and renders returned state; it does not advance objectives or award chapter completion.

## Exact files
- `content/chapter/first_chapter.json`
- `content/arenas/brass_choir_relay.json`
- `content/arenas/rootworks_pump.json`
- `game/arena.gd`
- `game/simulation.gd`
- `game/main.gd`
- `tests/test_chapter.gd`
- `tests/capture_chapter.gd`
- `scripts/agent_iteration.sh`
- `docs/runtime_status.md`
- `docs/implementation_packets.md`

## Preserved contracts
Optional repairs remain the main Workshop mode. Movement and combat stay fixed-tick and deterministic. Four active weapons, one reserve, Scrap, Relic Shards, Blessings, shops, combining and evolution retain their existing rules. Route, objective and save outcomes are simulation-authoritative and content uses stable IDs.

## Non-goals
No new weapons, Gifts, Confluences, frames, currencies, dialogue tree, procedural campaign map, permanent stat progression, or replacement of prototype art/audio. The destination encounters intentionally reuse the current enemy families and combat verbs.

## Deterministic acceptance tests
1. Route commands are rejected outside the route window and unknown route IDs do not mutate state.
2. Foreman victory opens exactly two stable route choices rather than ending the expedition.
3. Route selection and travel progression repeat for the same seed and survive save/restore without rerolling.
4. Arrival changes to the selected authored arena while preserving weapons, reserve, catalysts, currencies, doctrine, evolution and accumulated contribution data.
5. Brass Choir has three independently persistent calibration nodes that require local safety; Rootworks has one persistent pump repair that can progress under pressure.
6. Each destination uses its own enemy pool, boss ID, objective requirement, memory and conclusion.
7. Destination boss defeat cannot complete the chapter before its objective; completed objective plus boss opens the correct memory, and accepting it reaches Results.

## Evidence states
Actual Godot 4.5.1 desktop renders at 1280x800: `ROUTE_CHOICE`, `TRAVEL_BRASS`, `BRASS_OBJECTIVE`, `ROOTWORKS_OBJECTIVE`, and `CHAPTER_MEMORY`. Fixture seed 147, explicit fixture label and source/content hashes in the iteration report.

## Remaining limitation
The two destinations are a compact systems-complete chapter proof using procedural geometry and the existing enemy roster; their four-wave balance, moment-to-moment enjoyment and 25–35 minute commercial pacing still require human playtesting.

## Exactly one next task
Run an uncoached full-expedition playtest on both routes at 1x and tune destination wave pressure from observed comprehension and pacing evidence.

## Implemented evidence review

Godot 4.5.1 Compatibility renderer, macOS/Apple M1 Pro, 1280×800, seed 147, scripted deterministic fixtures. Inspected states: `ROUTE_CHOICE`, `TRAVEL_BRASS`, `BRASS_OBJECTIVE`, `ROOTWORKS_OBJECTIVE`, and `CHAPTER_MEMORY`.

- Goal/action clarity: 4/5. Route purpose, cost and carried-state promise are visible; destination headers state the local verb.
- Decision quality: 4/5. The choice changes topology, enemy pool, boss, objective rule and memory rather than only reward text.
- Combat readability/causality: 3/5. Objective rings, completion arcs and Brass `CLEAR THE RING` feedback read in stills; moving boss pressure remains unproven.
- Pacing/agency: 3/5. Travel supplies three concise beats and can be advanced immediately; full 1× expedition pacing is unproven.
- Failure/recovery: 3/5. Boss defeat cannot bypass unfinished work and the existing Results path remains available; route-specific failure explanation needs natural-run review.
- Screen hierarchy/accessibility: 4/5. The world and objective remain primary, route cards fit inside the play column, and actions are keyboard/controller-focusable.
- Identity/game feel: 4/5. Bells, pipework, grafts, repair rings and memory language preserve warm industrial devotion despite procedural placeholders.
- Replay motivation: 4/5. The two routes advertise materially different work and reveal different memories.

Confirmed visual defect corrected during review: the Rootworks route card and button originally overlapped the right loadout rail; both now remain inside the 980-pixel play column. Automated fixtures are not evidence of human enjoyment, comprehension time or final balance.

Natural-policy smoke: seed 147 completed both routes with ordinary income and no fixture health/currency after the Foreman. Workshop Gospel reached the Brass conclusion at 659 simulated seconds; Bell Ward reached the Rootworks conclusion at 655.7 simulated seconds. This proves two executable full-expedition paths, not player enjoyment or final balance.
