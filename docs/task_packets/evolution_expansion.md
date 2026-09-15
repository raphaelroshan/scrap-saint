# Task packet: P14.1 — Eight visible Evolutions

## Player-facing objective

The player can discover, assemble and immediately recognise eight optional named Evolutions whose geometry and utility create different build decisions.

## Authoritative owner

`game/simulation.gd` owns recipe eligibility, catalyst consumption, per-weapon Evolution identity, targeting, hit/control/objective/resource effects, save restoration and event traces. The `evolve` command is the only transformation boundary. Content files own stable recipes, catalysts and balance. Presentation renders the recipe ledger and authoritative attack/evolution events.

## Exact files

- `content/items/first_slice.json`
- `content/slices/first_shift.json`
- `game/simulation.gd`
- `game/main.gd`
- `game/sound.gd`
- `scripts/validate_content.py`
- `tests/test_evolutions.gd`
- `tests/run_evolution_playthroughs.gd`
- `tests/capture_evolutions.gd`
- `tests/test_slice_manifest.py`
- `tests/test_ui.gd`
- `tests/README.md`
- `scripts/agent_iteration.sh`
- `scripts/agent_iteration.ps1`
- `docs/runtime_status.md`
- `docs/verification_0_1.md`

## Preserved contracts

- Four active weapons plus one reserve, Scrap and Relic Shards only.
- Combine remains identical same-rank assembly; Evolution remains Rank III plus one catalyst.
- Every Evolution is optional and unevolved builds remain viable.
- Multiple Evolutions coexist without one shared boolean determining behavior.
- Memory Crane continues to copy Mercy Rail specifically.
- Fixed-tick authority, deterministic shop RNG, chapter carryover and version-2 saves remain intact.
- No Confluence is enabled.

## Enabled recipes and behavioral changes

1. `evolution.mercy_rail`: Saint's Rivet; priority line becomes a long major-repair rail.
2. `evolution.great_toll`: Cracked Bell Clapper; forward cone becomes radial marked displacement.
3. `evolution.ashen_benediction`: Black Candle; Saint-centred smoke becomes an offset Mourn zone that seeks damaged work and yields seeking motes.
4. `evolution.long_hand`: Blue Wire from the Pump; single-target Winch becomes a wide routed tether corridor that binds and pulls multiple threats.
5. `evolution.halo_of_repairs`: Saint's Rivet; one contact point becomes a dual-ring circuit that chains objective repair back to Saint structure.
6. `evolution.candle_unreturned`: Mourner's Wick; one execution shot becomes three weakest-target seekers whose kills send visible motes toward the Saint.
7. `evolution.quiet_sermon`: Folded Maintenance Blueprint; a thin damage beam becomes a wider silence lane that delays support actions.
8. `evolution.workshop_benediction`: Saint's Rivet; cluster-only Mortar gains a consecrated objective shot when no threat occupies its range.

## Non-goals

- No Confluences, new weapons, Gifts, Blessings, enemies, routes, map geometry or currencies.
- No campaign unlock rebalance or claim that eight recipes are human-balanced.
- No route-map file changes.

## Deterministic acceptance tests

1. The manifest and catalogue expose exactly eight unique recipes; every base and catalyst resolves and no Confluence is present.
2. Failed Evolution commands preserve inventory, currencies, RNG and time; successful commands consume exactly one named catalyst and record exactly one per-weapon Evolution ID.
3. All six new Evolutions demonstrate their authored geometry plus control, objective or resource change in fixed-position fixtures.
4. All eight can coexist in arbitrary acquisition order without suppressing another recipe; Mercy Rail remains the only Memory Crane rail-copy identity.
5. Save/restore preserves each transformed weapon and produces the same next attack events.
6. Seeded shop visits expose every catalyst and recipe path; acquisition uses public buy/combine/evolve commands.
7. Controlled-start Evolution policies complete the Workshop and both destination routes; existing normal-economy matrices remain green.

## Evidence states

- `EVOLUTION_LEDGER`: configured Workshop, seed 147, all eight recipes and readiness states visible.
- `EVOLVED_GEOMETRIES_A`: configured combat fixture, seed 147, Ashen Benediction, The Long Hand and Halo of Repairs.
- `EVOLVED_GEOMETRIES_B`: configured combat fixture, seed 147, Candle for the Unreturned, Quiet Sermon and Workshop Benediction.
- Godot 4.5.1, 1280×800, compatibility renderer; fixtures are labelled and are not human playtests.

## Remaining limitation

Automated viability and configured renderer evidence cannot establish human comprehension, effect density or relative Evolution desirability at 1×.

## Exactly one next task

Run uncoached 1× sessions comparing all eight Evolution decisions and tune recipe pacing and overlapping effects from observed choices.
