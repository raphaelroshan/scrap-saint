# Implementation packets — First Shift prototype

## P06 — 5× development speed
- Objective: traverse combat five times faster while retaining normal shop/pause interaction.
- Owner: runtime driver submits five unchanged fixed simulation steps per physics frame; simulation rules and saves remain unchanged.
- Files: game/main.gd, Play Scrap Saint 5x Dev.cmd, tests/test_dev_speed.gd, README.md.
- Preserve: default 1× launcher, deterministic tick behavior, events from every substep, stop at shop/Results boundaries.
- Acceptance: five-step batch equals five ordinary steps; pause/shop advance zero ticks; wave transition stops batch; default speed is one.
- Capture: title/combat speed indicator, actual 1280×800 Godot render, engine/build provenance in development evidence.
- Limitation: full 5× speed depends on machine throughput and is unsuitable for judging normal combat feel.
- Exactly one next task: playtest the development launcher through a shop transition.

## P01 — executable scope
- Objective: consistent rules for every offered build.
- Owner: content data, no gameplay mutations.
- Files: content/slices/first_shift.json, scripts/validate_content.py, docs/first_vertical_slice.md, design/shop_and_blessings.md, roadmap.md.
- Preserve: five weapons, four catalysts, three doctrines, one evolution; shared encounters.
- Acceptance: enabled IDs resolve, counts match, unsupported content stays outside the runtime pool.
- Evidence: content validation; viewport not applicable.
- Limitation: balance and feel are unproven.
- Next task: P02, deterministic shell.

## P02 — deterministic shell
- Objective: boot, start, move, pause and restart reproducibly.
- Owner: game/simulation.gd consumes commands; game/main.gd maps input and presents snapshots/events.
- Files: project.godot, game/main.tscn, game/simulation.gd, game/main.gd, tests/test_simulation.gd.
- Preserve: stable IDs and explicit simulation authority; no campaign.
- Acceptance: identical commands yield identical hashes; pause freezes; reset repeats; movement clamped.
- Capture: menu and movement at 1280x800, pinned Godot 4.5.1, seed and build recorded.
- Limitation: subsequent systems arrive through P03–P05.
- Next task: P03, combat and relay.

## P03 — combat and relay
- Objective: fight and repair with readable weapon consequences.
- Owner: simulation owns targets, damage, timers, progress and pickups; renderer/audio consume events.
- Files: game/simulation.gd, game/main.gd, game/sound.gd, content/slices/first_shift.json, tests/test_simulation.gd.
- Preserve: encounters independent of weapon acquisition; no imaginary hit responses.
- Acceptance: attacks damage once, repair persists, target order stable, defeat and pickups authoritative.
- Capture: RELAY_REPAIR_WAVE with three geometries and enemy telegraphs.
- Limitation: procedural prototype art and synthesized sound.
- Next task: P04, workshop and builds.

## P04 — workshop and builds
- Objective: choose a doctrine and assemble visibly different weapons.
- Owner: simulation validates purchases, ranks, reserve, rerolls and evolution.
- Files: game/simulation.gd, game/main.gd, content/slices/first_shift.json, tests/test_simulation.gd.
- Preserve: four active slots, one reserve, two currencies, optional Mercy Rail.
- Acceptance: reject overspend without mutation, full-capacity combine works, reload preserves offers, evolution consumes correct ingredients.
- Capture: SHOP_MERCY_RAIL_PATH and MERCY_RAIL_EVOLUTION from commands.
- Limitation: numerical tuning requires human testing.
- Next task: P05, complete run and verification.

## P05 — complete run
- Objective: reach a boss and meaningful Results with any supported build.
- Owner: simulation schedules waves, elite and Foreman; UI displays outcomes and settings.
- Files: game/simulation.gd, game/main.gd, tests/test_simulation.gd, scripts/agent_iteration.ps1, scripts/agent_iteration.sh, tools/validate_iteration_report.py, README.md, docs/runtime_status.md.
- Preserve: no evolution-specific encounter schedule, no campaign expansion.
- Acceptance: no-evolution elite fallback; win/lose; save roundtrip; multi-doctrine full-run smoke; runtime captures reviewed.
- Capture: menu, combat, shop, evolution, boss, Results with build/viewport provenance.
- Limitation: autonomous verification does not establish human enjoyment.
- Next task: human playtest of the shared arena and build feedback.

## P07 — SC-02 Collapsed Workshop
- Objective: move between a readable relay bowl, salvage lane, crane lane, furnace lane and workshop alcove with two ways around solid machinery.
- Owner: data-owned topology; simulation resolves movement, displacement and spawn locations through Arena geometry. Presentation draws that same geometry.
- Files: content/arenas/collapsed_workshop.json, content/slices/first_shift.json, game/arena.gd, game/simulation.gd, game/main.gd, tests/test_arena.gd, tests/run_playthroughs.gd, scripts/agent_iteration.ps1, scripts/agent_iteration.sh, docs/runtime_status.md, docs/verification_0_1.md.
- Preserve: all builds share encounters; automatic weapons retain their geometry and pass over low machinery; no new hazards, economy or pacing changes. Godot stays pinned to 4.5.1.
- Acceptance: obstacle sliding and large displacement cannot tunnel; diagonal input clamps; all entrances reach relay; free-space grid is connected and has no articulation bottleneck; enemy routes reach opposite sides; seeded movement and reload repeat; alcove grants no healing.
- Evidence: six actual 1280x800 runtime fixtures plus topology tests, seed147 and exact source/content hashes.
- Limitation: named furnace/crane lanes establish topology, not new timed hazard mechanics; balance needs human review at 1x.
- Exactly one next task: SC-04 relay threat and repair feedback on the authored layout.

## P08 — SC-04 readable relay pressure
- Objective: identify and interrupt relay attacks, see damage and repairs, and reach the first workshop with every starting doctrine.
- Owner: simulation owns per-enemy strike timers, damage-source records, first-wave backup floor, repair and status; presentation renders those states/events.
- Files: content/slices/first_shift.json, game/simulation.gd, game/main.gd, game/sound.gd, tests/test_relay.gd, tests/run_playthroughs.gd, scripts/agent_iteration.ps1, scripts/agent_iteration.sh, docs/early_access_plan.md, docs/runtime_status.md, docs/verification_0_1.md.
- Preserve: shared encounters and economy, optional evolutions, fixed ticks, existing movement topology; no additional arenas or weapons.
- Acceptance: attacks warn before damage; moving away or stagger cancels windup; cooldown prevents repeated damage; all damage sources obey wave-one floor only; repairs clamp; saves retain windups; starting health is 70%; multi-seed runs record doctrine outcomes and fail if unfinished or lost.
- Evidence: 1280x800 six-state loop plus explicit relay-threat fixture, actual engine and source/content provenance.
- Limitation: scripted policies do not establish human balance or feel.
- Exactly one next task: six-role workshop offers and distinct Blessing services.

## P09 - purposeful workshop choices
- Objective: understand why each offer is present and buy a distinctive next-wave service for the chosen Blessing.
- Owner: simulation owns deterministic offer context, isolated shop RNG, capacity checks and next-wave service effects; UI reads descriptions and roles.
- Files: content/slices/first_shift.json, game/simulation.gd, game/main.gd, tests/test_shop.gd, scripts/agent_iteration.ps1, docs/runtime_status.md, docs/verification_0_1.md.
- Preserve: six slots, existing buy/combine/reserve economy, shared encounters, optional evolution, one free refresh and two paid refreshes.
- Acceptance: rerolls leave combat RNG unchanged; save repeats offers; roles visible; unavailable catalysts/full-rank upgrades get useful fallback; service purchase atomic and once per visit; effects expire at next shop.
- Evidence: actual shop and combat fixture captures at 1280x800; source/content hashes and scored critique.
- Limitation: player preference and economic balance still need human testing.
- Exactly one next task: Foreman interrupt and relay-disconnect interactions.

## P10 - optional repair comparison
- Objective: compare free movement with optional repair rewards against mandatory relay defence on the same arena and seed.
- Owner: simulation stores mode, machine progress, completion and one-time rewards. Presentation selects mode and renders machines and rewards.
- Files: content/slices/first_shift.json, game/simulation.gd, game/main.gd, tests/test_optional_repairs.gd, tests/run_playthroughs.gd, tests/capture_optional.gd, docs/runtime_status.md.
- Preserve: existing relay mode, same arena/spawn schedule and build options, fixed ticks, pause/shop boundaries. No boss disconnect feature before this comparison.
- Acceptance: skip all repairs and still win by surviving/boss; repairs persist and reward once; pause/shop do not progress; save retains mode and rewards; identical mode/seed repeats; old saves remain relay mode.
- Evidence: actual mode selection and machine repair/completion captures at 1280x800 with provenance.
- Limitation: rewards change run economy; automated completion does not establish which mode is more fun.
- Exactly one next task: human A/B playtest of movement freedom and repair motivation at 1x.

## P11 - main mode and Foreman counterplay
- Objective: play optional repairs as the main game, and choose between evading Foreman demolition or approaching to interrupt it.
- Owner: simulation validates combat/pause/window/range/line-of-access, removes only the interrupted boss's pending hazards and records a brief vulnerability. UI sends interrupt and shows authoritative window/range.
- Files: content/slices/first_shift.json, game/simulation.gd, game/main.gd, tests/test_foreman.gd, tests/capture_foreman.gd, scripts/agent_iteration.ps1, README.md, docs/runtime_status.md, docs/early_access_plan.md.
- Preserve: optional repairs never required; interrupt is optional and supports every build; baseline defence accessible only in dev UI; shared enemy schedule.
- Acceptance: rejected interrupts do not mutate state; valid command cancels only source hazards; exposure expires; save/replay retain state; all baseline full-run policies remain viable without using interrupt.
- Evidence: actual warning, interrupt and exposed-boss fixtures at 1280x800 plus standard loop.
- Limitation: no human test of interrupt risk/reward; no claim of final boss balance.
- Exactly one next task: causal Results showing damage sources, build contribution and optional-repair rewards.

## P12 - larger roaming arena and combat variety
- Objective: roam a substantially larger workshop while discovering distinct automatic weapons and enemy behaviours.
- Authorization: user explicitly requests expanded map, weapon and enemy scope; supersedes the original five-weapon/three-enemy slice cap and rejects P11 manual boss counterplay.
- Owner: arena/content data and simulation own bounds, spawns, geometry and enemy effects. Presentation owns following camera, minimap and distinct silhouettes.
- Files: content/arenas/collapsed_workshop.json, content/slices/first_shift.json, content/items/first_slice.json, content/enemies/first_slice.json, game/simulation.gd, game/main.gd, game/sound.gd, tests/test_variety.gd, tests/test_arena.gd, tests/test_slice_manifest.py, scripts/validate_content.py, scripts/agent_iteration.ps1, docs/runtime_status.md.
- Preserve: free movement, automatic weapons, optional repairs, existing inventory and currencies, deterministic outcomes. Remove interrupt/exposure mechanic and its input prompts.
- Acceptance: expanded bounds/path connectivity; camera cannot mutate state; beam line and blast radius damage; repairer pulse; ranged warning and resolution; heavy displacement; all six enemy types enter wave pool; full-run regressions.
- Evidence: actual enlarged map, new weapon effects and enemy fixtures at 1280x800 with source/content provenance.
- Limitation: wider content and camera pacing require human tuning.
- Exactly one next task: playtest roaming density and weapon/enemy balance.

## SC-15 — compact first-chapter pilgrimage
- Objective: defeat the Foreman, choose a road, travel with the current build, complete a destination-specific objective and boss, and recover a route-specific memory.
- Owner: simulation owns route validation/cost, travel progress, arena loading, carried state, objective progress, boss result, memory, save/restore and completion; UI renders state and sends explicit commands.
- Files: content/chapter/first_chapter.json, two destination arenas, game/arena.gd, game/simulation.gd, game/main.gd, tests/test_chapter.gd, tests/capture_chapter.gd, runtime documentation.
- Preserve: optional-repair Workshop, deterministic fixed ticks, existing build/economy rules, four active slots plus reserve, no presentation-authored outcomes.
- Acceptance: two affordable routes; rejected choices do not mutate; travel and destination saves repeat; complete build carries; Brass and Rootworks objectives differ; boss cannot bypass objective; correct memory reaches Results.
- Evidence: five actual 1280×800 Godot 4.5.1 fixtures under artifacts/chapter plus 30 deterministic chapter checks.
- Limitation: compact four-wave destinations reuse the current roster and need human 1× pacing validation.
- Exactly one next task: uncoached full-expedition testing of both routes at 1×.
