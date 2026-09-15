# Task packet: SC-17–19 — Act I breadth

## Player-facing objective

Turn the First Pilgrimage from one binary destination choice into a three-site expedition: choose a visible route, resolve every road segment and event, assemble one of eight named Evolutions, complete a distinct terminal objective and boss, and see the consequences in the final Memory and Results.

## Authoritative owner

`game/simulation.gd` owns graph position, travel beats, encounters, merchant transactions, route costs/risks, objective and boss state, Evolution eligibility/effects, saves and Results. `game/main.gd` renders those states and sends explicit commands only. Stable content records own graph, site, encounter, recipe and balance values.

## Exact files

- `content/chapter/first_chapter.json`
- `content/arenas/*.json`
- `content/bosses/first_slice.json`
- `content/items/first_slice.json`
- `content/slices/first_shift.json`
- `content/progression/first_chapter.json`
- `game/simulation.gd`, `game/main.gd`
- `scripts/validate_content.py`, release/iteration scripts as required
- focused chapter, map, Evolution, save, UI and policy tests
- `docs/runtime_status.md`, `README.md`, evidence/task-packet documentation

## Preserved contracts

- Optional repairs and free movement remain the primary game.
- Every encounter and boss remains viable without a specific Evolution.
- Four active weapons, one reserve, two Gifts, Scrap and Relic Shards remain the inventory/economy boundary.
- Combine and Evolution stay separate; no Confluence is enabled.
- Travel never skips an authored in-between beat.
- The simulation is the sole authority and old version-2 saves migrate deterministically.

## Non-goals

- No procedural open world, faction simulation, branching dialogue engine, permanent stat treadmill, extra currency, multiplayer or endless mode.
- No claim of human enjoyment from automated policies or fixture captures.

## Deterministic acceptance tests

- The graph exposes only connected, affordable destinations and records every visited node and choice.
- Workshop → Brass/Rootworks → Pale Archive/Red Foundry/Null Assembly routes save, restore and complete without skipping travel or encounters.
- Road events, merchant purchases and risks mutate state once, reject invalid commands without mutation, and appear in Results.
- Eight total Evolutions are discoverable, atomic, distinct in geometry/targeting/control/objective/resource behaviour, coexist correctly and save exactly.
- Every new site owns its arena, objective, wave profiles, boss phases, Memory and route rewards.
- Normal-economy, frame/Blessing/route and specialist matrices remain green.

## Evidence states

- Expanded pilgrimage map with available, assignment-linked and accepted routes.
- One in-between road event and one merchant decision.
- Each new terminal objective and boss contract.
- At least one capture for each new Evolution family.
- 1280×800, Godot 4.5.1, seed and fixture/natural-policy label visible.

## Remaining limitation

Automated runs and rendered fixtures cannot establish uncoached comprehension, pacing, replay desire or minimum-Windows-hardware frame rate.

## Exactly one next task

Run uncoached 1× three-site expeditions and tune route length, encounter value and terminal-site pressure from observed player decisions.
