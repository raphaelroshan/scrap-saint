# Task packet: Frontier-style expedition map

## Player-facing objective

After defeating the Foreman, inspect a compact authored pilgrimage graph, accept one visible assignment, and resolve every roadside encounter or service stop before reaching the selected site, with the road's costs, risks, news, and consequences visible and remembered at Results.

## Authoritative owner

`content/chapter/first_chapter.json` owns stable site, edge, road-node, option, consequence, and terminal-route IDs. `game/simulation.gd` owns assignment availability/acceptance, route payment, road progress, option validation, Scrap/structure consequences, history, save migration, and result evidence. Presentation may preview a destination and send `choose_route` or `choose_road_option`; it may not skip nodes or apply consequences.

## Scope

### Files expected to change

- `content/chapter/first_chapter.json`
- `game/simulation.gd`
- `game/main.gd`
- `scripts/validate_content.py`
- `scripts/agent_iteration.sh`
- `tests/test_expedition_map.gd`
- `tests/test_chapter.gd`
- `tests/test_ui.gd`
- `tests/test_flow_input.gd`
- `tests/test_save_flow.gd`
- `tests/run_playthroughs.gd`
- `tests/run_assembly_playthroughs.gd`
- `tests/capture_chapter.gd`
- `tests/capture_core_quality.gd`
- `tests/capture_expedition_map.gd`

### Preserved contracts and non-goals

- Preserve fixed-tick combat, current Workshop/Brass Choir/Rootworks encounters, build/economy carry-over, and stable route IDs.
- Preserve exact terminal IDs `route.pale_archive`, `route.red_foundry`, `route.null_assembly` and site IDs `site.pale_archive`, `site.red_foundry`, `site.null_assembly` as data extension points; Red Foundry is shared by the Brass and Rootworks branches.
- Do not implement terminal arenas, bosses, weapons, Gifts, evolutions, procedural generation, a free-roaming open world, or a new currency.
- Do not let presentation mutate road outcomes or bypass authored in-between areas.

## Deterministic acceptance

- [x] Same seed and command stream produce identical road history and checkpoint hashes.
- [x] Unknown routes/options, unaffordable choices, and `advance_travel` bypass attempts return stable rejection reasons without mutation.
- [x] Both current assignments expose cost, risk, news, authored intermediate nodes, and stable graph endpoints.
- [x] Every accepted route requires each intermediate node to resolve in order before arrival.
- [x] Merchant/service choices always include an affordable continuation and apply only authored consequences.
- [x] Save/restore is exact before acceptance and at every road node; version 1/2 saves migrate deterministically.
- [x] Road structure/Scrap changes, flags, and selected assignment survive arrival and appear in Results.
- [x] Keyboard/controller focus can preview, confirm, and resolve both route paths.
- [x] Content IDs, graph references, option references, and consequence fields validate.

## Visual evidence

- State names: `EXPEDITION_MAP_AVAILABLE`, `BRASS_ROAD_ENCOUNTER`, `BRASS_ROADSIDE_SERVICE`, `ROOTWORKS_ROAD_ENCOUNTER`, `EXPEDITION_MAP_ACCEPTED`.
- Build/commit: `0.2.1-preview`, working tree based on `6e7ea13cc18a40d4b74c8e7a319600f23db2b8b7`; exact source/content hashes recorded in provenance.
- Godot version: `4.5.1.stable.official.f62fdbde1`, Compatibility renderer on Apple M1 Pro.
- Viewport/scaling: 1280x800, 1.0 UI scale.
- Seed/replay ID: seed 147, deterministic scripted fixture.
- Capture path: `artifacts/agent-iteration/screenshots/` and iteration manifest.
- Visual rubric result: 43/50. All five map/road captures were inspected; rubric and evidence validator passed. Fixtures are not human-play evidence.

## Remaining limitation

The second-tier sites remain graph-visible authored extension points until their parallel chapter arenas and encounter content land; automated paths cannot prove human comprehension, pacing, or enjoyment.

## Exactly one next task

Integrate the Pale Archive, Red Foundry, and Null Assembly route content into the stable graph and run an uncoached three-site expedition playtest.
