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

## P14 - replayable assembly package
- Objective: choose a close-pressure, priority-control, or repair-roaming weapon, visibly evolve Bell into The Great Toll, and carry up to two Gifts that alter repair risk, threat information, or dismantling decisions.
- Authorization: the owner explicitly requested the researched P14 package after the current roadmap update.
- Owner: content data defines roles, costs, effects and trade-offs; `game/simulation.gd` owns target selection, damage, control, repair progress, Gift slots, economy, evolution eligibility and save state; presentation renders authoritative events and loadout state.
- Files: `content/items/first_slice.json`, `content/slices/first_shift.json`, `game/simulation.gd`, `game/main.gd`, `game/sound.gd`, `scripts/validate_content.py`, `tests/test_assembly.gd`, `tests/test_slice_manifest.py`, `tests/capture_assembly.gd`, `scripts/agent_iteration.sh`, `scripts/agent_iteration.ps1`, `docs/runtime_status.md`, `docs/verification_0_1.md`, `roadmap.md`.
- Preserve: four active weapon slots plus one reserve, two run currencies, deterministic fixed ticks and isolated shop rolls, existing Combine semantics, catalyst-based Evolution semantics, optional repairs, viable unevolved builds and all P12 content. Confluences remain disabled.
- Acceptance: Censer slows close threats and earns only deterministic close-defeat embers; Winch selects a relay attacker before the farthest eligible target and visibly pulls one threat; Halo damages on its rotating contact point and advances a nearby optional machine or repairs the Saint; Bell Rank III plus Cracked Clapper atomically becomes radial Great Toll while failed evolution does not mutate state; two unique Gift slots persist through saves; Spare Hand changes work rate and movement exposure; Inspection Lens reveals the next major property with a deterministic ordinary-Scrap tax; Black Ledger reduces dismantle refund and guarantees a matching temporary shop lead; shop offers, active effects, Results and captures identify weapons, evolutions and Gifts distinctly.
- Capture: Godot 4.5.1, 1280x800, seed 147, fixture-configured states `P14_EXPANSION_A`, `P14_GREAT_TOLL`, and `P14_GIFTS`; inspect all captures and record renderer/build provenance. These are executable fixtures, not human playtests.
- Limitation: deterministic viability and screenshots do not establish whether the expanded pool is enjoyable or correctly weighted for human players.
- Exactly one next task: run uncoached 1x sessions comparing a close-control, route-control and repair-roaming build.

## P12.1 - authored roaming pressure and useful repairs
- Objective: cross the Workshop at 1x under purposeful pressure and choose an optional machine because its visible reward solves an immediate problem.
- Owner: `game/simulation.gd` owns wave profiles, repair state, interruption, rewards, events and metrics; `game/main.gd` only renders those states.
- Files: `content/slices/first_shift.json`, `game/simulation.gd`, `game/main.gd`, `tests/test_optional_repairs.gd`, `tests/run_playthroughs.gd`, `tests/test_roaming_quality.gd`, `docs/runtime_status.md`.
- Preserve: optional repairs, fixed ticks, free movement, automatic attacks, three machines, two currencies and existing arena topology. No new sites, weapons or meta-progression.
- Acceptance: authored primary/support families reproduce by seed; no reward is silently wasted; leaving the ring or taking a hit emits interruption while preserving progress; a repair-seeking policy completes a useful repair; traces report contact and threat-gap metrics.
- Capture: natural policy at 1280x800, seed 104729, Godot 4.5.1, plus clearly labelled machine fixtures.
- Limitation: automated movement establishes reachability and utility, not human enjoyment.
- Exactly one next task: P12.2, isolate Mourner wave-five attrition and validate weapon roles.

## P12.2 - Mourner viability and weapon-role evidence
- Objective: every Blessing reaches the Foreman through a coherent non-evolution route, while each weapon keeps a legible strength and weakness.
- Owner: content data owns role tuning; simulation owns targeting, damage attribution, enemy damage sources and failure classification; policies only issue movement/shop commands.
- Files: `content/slices/first_shift.json`, `game/simulation.gd`, `tests/test_variety.gd`, `tests/run_playthroughs.gd`, `tests/test_roaming_quality.gd`, `docs/runtime_status.md`.
- Preserve: no blanket doctrine damage multiplier, no Mercy requirement, and no attempt to make every weapon solve every matchup.
- Acceptance: seed 104729 exposes its first causal damage spike; 12/12 standard runs complete; each doctrine has a non-evolution win; controlled role checks prove the seven geometries' intended target access and preserved weakness.
- Capture: same-seed combat states for all three Blessings at 1280x800, classified as natural or fixture.
- Limitation: deterministic policies cannot rank subjective weapon satisfaction.
- Exactly one next task: P12.3, make workshop roles affordable, non-redundant and doctrine-specific.

## P12.3 - actionable workshop and distinct services
- Objective: every visit offers an affordable current improvement, a future path, a forecast response and a doctrine service whose effect is visibly different.
- Owner: simulation owns offer construction, affordability, forecast facts and service effects; presentation explains offer purpose without changing shop state.
- Files: `content/slices/first_shift.json`, `game/simulation.gd`, `game/main.gd`, `tests/test_shop.gd`, `tests/run_playthroughs.gd`, `docs/runtime_status.md`.
- Preserve: six offer roles, one free refresh, four active plus one reserve, deterministic local shop hash and hybrid builds.
- Acceptance: at least one offer is actionable at normal funds; calibration never duplicates another calibration card; forecast names the authored next pressure and counters; all doctrine services change different authoritative state.
- Capture: three seeded service shops at 1280x800, Godot 4.5.1, explicitly fixture-labelled.
- Limitation: human price sensitivity remains unmeasured.
- Exactly one next task: P12.4, strengthen Memory Crane and Foreman movement/priority questions.

## P12.4 - readable elite and Foreman phases
- Objective: the elite and Foreman ask readable movement and target-priority questions without Mercy Rail or a manual interrupt.
- Owner: simulation owns phase, routed hazard destinations, worker targets and damage; presentation renders phase intent and safe-lane cues.
- Files: `content/slices/first_shift.json`, `game/simulation.gd`, `game/main.gd`, `tests/test_variety.gd`, `tests/test_roaming_quality.gd`, `docs/runtime_status.md`.
- Preserve: automatic combat, optional repairs, no manual interrupt and no presentation-authored damage.
- Acceptance: telegraphs precede damage; boss phases use distinct hazard counts/routes; workers are identifiable in traces; evolved and non-evolved policies can win.
- Capture: Foreman phase fixtures and one natural boss approach at 1280x800, Godot 4.5.1.
- Limitation: motion readability still requires a human 1x session.
- Exactly one next task: P12.5, make Results explain causes and suggest one grounded experiment.

## P12.5 - causal Results and replay cue
- Objective: understand what caused the outcome, which relic mattered, which repairs were chosen, and one useful next experiment.
- Owner: simulation owns damage, kills, economy, repair, Blessing, evolution and failure classification; Results renders the authoritative summary.
- Files: `game/simulation.gd`, `game/main.gd`, `tests/test_simulation.gd`, `tests/test_roaming_quality.gd`, `docs/runtime_status.md`.
- Preserve: immediate same-seed restart, concise memory text and no campaign/dialogue expansion.
- Acceptance: success and failure summaries differ from recorded events; primary cause uses the stable cause vocabulary; weapon contribution, repair reward, worst damage wave, fulfilment and evolution route are present; save/replay retains metrics.
- Capture: one natural win and one deterministic failure Results at 1280x800, Godot 4.5.1.
- Limitation: the route preview is a narrative stub until chapter routing exists.
- Exactly one next task: conduct a focused uncoached human 1x playtest of the complete P12 gate.
