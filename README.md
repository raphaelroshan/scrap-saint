# Scrap Saint

**Scrap Saint** is a single-player arena roguelite set in a devastated machine world. Repairs given freely have left grace in discarded components, causing a small saint to manifest. It carries that care through the ruins while assembling relic weapons and choosing what to repair. See the [sacred origin](docs/saint_of_freely_given_repairs.md).

> **Restore the First Engine—or decide that the world is better without it.**

The project combines short survivor-like runs, a Slime 3K-style relic shop, visible weapon evolutions, and a warm industrial story about repair, purpose, and self-determination. It is not a conventional military mech game. The Saint is a maintenance automaton that treats bells, rivets, cables, manuals, and ruined machines as sacred because they once helped people.

For agent resumption, apply the complete [prompt pack](docs/agent_prompt_pack.md) and read the [current production state](docs/production_state.md) and [QA record](docs/qa_current.md).

## Play the prototype

A standalone Windows preview was verified on 2026-09-25. The local delivery is in `build/releases/scrap-saint-0.6.0-preview-20260925/windows`: extract the ZIP and launch `ScrapSaint.exe` with its PCK beside it. Binaries are local build artifacts, not Git-tracked files. See [verification and limits](docs/qa_current.md).

Open `project.godot` in **Godot 4.5.1** and run the project. In this workspace, double-click **Play Scrap Saint.cmd** to launch using the downloaded portable runtime.

For faster development, use **Play Scrap Saint 5x Dev.cmd**. Combat runs at 5× speed, including movement, weapons, enemies, repair and wave timers. Shops and pause remain stopped. **F6** toggles 1×/5× in this development version; the on-screen badge shows the active speed. The Workshop schedules eight 70-second waves: 9 minutes 20 seconds of scheduled combat, or 1 minute 52 seconds at 5×, excluding shops; boss defeat can end its wave early. The normal launcher remains 1×. CLI equivalent: `godot --path . -- --dev-speed=5`.

- **Optional repairs is the main game.** The 5x development launcher retains the relay-defence comparison toggle. New runs use the displayed seed; change it on the title screen. Existing saves retain their mode.
- WASD or arrows: move; weapons attack automatically. In Optional repairs, short repairs reward Scrap, healing or a stagger pulse. Machines cannot be destroyed and repairs are never required to win. In Relay defence, stay near the relay to repair it and keep it alive.
- Escape: pause; F5: save; F9: load; M: mute; F3: diagnostic overlay.
- Between waves: buy/combine, sell, store, equip, lock and refresh. All six main-mode cards offer relics; field repair kits and optional work provide recovery. Every weapon gains named behavior at Rank II and Rank III; Evolutions such as Mercy Rail remain optional.
- Defeating the Foreman opens Brass Choir Relay and Rootworks Pump. Their memories open a second choice: Brass leads to Pale Archive or Red Foundry; Rootworks leads to Red Foundry or Null Assembly. The build, economy and Blessing persist through all three sites.
- Controller: left stick movement, standard UI navigation/accept, Start to pause.

See [runtime status](docs/runtime_status.md) for implemented rules, prototype substitutions, and limitations. The enabled slice and balance values live in `content/slices/first_shift.json`.

## Main menu

The six-armed Saint rests beneath the Bodhi tree in the illustrated menu. Choose Continue to restore a saved expedition, or New pilgrimage to choose a frame and Blessing. Settings includes sound, reduced effects, text size, fullscreen, camera motion and movement bindings. How to play and Sacred histories are available before starting; Quit asks for confirmation. Escape or controller Back returns from panels and setup.

The awakening uses two generated preview paintings and a short dissolve. Reduced effects shortens it to 300 ms. See [menu artwork and evidence](docs/task_packets/main_menu_art.md) for provenance and limitations.

## Current canonical direction

The project uses a hybrid of two story variants:

- **The Pilgrimage of Repairs** provides the external structure: the Saint travels from ruined site to ruined site repairing relays, pumps, workshops, and settlements while searching for the First Engine.
- **The Saint Built Wrong** provides the emotional arc: the Saint was assembled from incompatible machines and gradually discovers that identity is something it can build rather than recover.

The player moves through compact arenas, fights automatic waves of hostile machines, collects Scrap and Relic Shards, visits the relic shop, chooses or deepens Blessings, completes repairs or protection objectives, evolves weapons and skills, and defeats a rule-changing elite or boss.

## Recommended Astra onboarding sequence

Astra should read the repository in this order before editing:

1. [`docs/astra_game_bible.md`](docs/astra_game_bible.md) for the product promise, plot, tone, non-goals, design vocabulary, and permanent boundaries.
2. [`AGENTS.md`](AGENTS.md) for implementation rules, authoritative simulation ownership, task-packet requirements, and evidence standards.
3. [`docs/story_and_acts.md`](docs/story_and_acts.md) for the campaign arc, act structure, factions, characters, objectives, and bosses.
4. [`design/gameplay_contract.md`](design/gameplay_contract.md) for deterministic combat, movement, objectives, statuses, shop, Blessings, evolutions, saves, and presentation boundaries.
5. [`design/shop_and_blessings.md`](design/shop_and_blessings.md) for the run economy, shop offers, controlled randomness, Blessing roles, and evolution support.
6. [`docs/progression_map_weapons_metagame.md`](docs/progression_map_weapons_metagame.md) for the researched run pacing, arena topology, route graph, weapon catalogue, shop guarantees, metagame separation, failure rules, and first implementation milestones.
7. [`docs/improvement_plan_2026-09-15.md`](docs/improvement_plan_2026-09-15.md) for the current repository audit, unresolved design decisions, weapon/Gift/shop/map/enemy recommendations, and prioritized execution packets.
8. [`docs/agent_completion_prompt.md`](docs/agent_completion_prompt.md) for the persistent lead-agent personality, decision authority, execution method, quality gates, and definition of complete.
9. [`docs/weapons_merges_traits_expansion.md`](docs/weapons_merges_traits_expansion.md) for proposed weapons, Combine/Evolution/Confluence boundaries, future evolutions, Gifts, trait acquisition, and the staged implementation packets.
10. [`docs/art_direction.md`](docs/art_direction.md) for silhouettes, materials, palette, effects, audio, asset sourcing, and visual quality constraints.
11. [`docs/first_vertical_slice.md`](docs/first_vertical_slice.md) and [`roadmap.md`](roadmap.md) for the dependency-ordered implementation sequence.
12. Read only the smallest relevant source, content, and test files after stating the one player-facing objective.

Every implementation request should be converted into one bounded task packet containing the player promise, authoritative owner, exact files, deterministic acceptance tests, non-goals, screenshot/build provenance, remaining limitation, and exactly one next task.

## The player-facing loop

```text
Choose a Saint frame and Blessing
→ enter a compact industrial zone
→ move and auto-attack
→ protect or repair a local objective
→ collect Scrap and Relic Shards
→ visit the relic shop
→ buy, sell, combine, reserve, repair, or reroll
→ deepen a Blessing or pursue an evolution
→ survive an elite or boss
→ reveal a memory and choose the next route
→ cross another authored road and finish at a terminal memory
```

A Blessing is a broad run doctrine. The shop provides specific weapons, catalysts, passives, and services. A Blessing should bias the shop and guarantee a starting direction, but it must never hard-lock the run.

The first Blessings are **The Workshop Gospel** for repair and repeated mechanisms, **The Bell Ward** for witness and control, **The Procession** for orbiting relics and escort defence, **The Quiet Order** for silence and precision, **The Salvage Rite** for Scrap and dismantling, and **The Mourner** for spirits and conversion.

## Weapon evolution

Weapons use relic + mechanism + doctrine identity. Examples include the **Nailer of Small Mercies**, **Bell of the Last Shift**, **Procession Gear**, **Candle-Nailer**, **Cable of Contrition**, **Hymn Coil**, and **Altar Mortar**.

The first visible evolution is:

```text
Nailer of Small Mercies Rank 3 + Saint’s Rivet → Mercy Rail
```

The transformation must change attack geometry, target rules, area control, objective interaction, or resource behaviour—not only increase damage. The shop shows missing ingredients and previews the result. The first ten recipes are discoverable in-game and do not require an external wiki.

## Scope and quality bar

The current preview implements the first-chapter technical loop; creative acceptance and Early Access readiness remain unverified (see [production state](docs/production_state.md)): three Saint frames, four Blessings, ten base weapons, eight catalysts, seven run-local Gifts, ten visible Evolutions, a Workshop plus five destination sites, seven enemy families, an elite and six bosses. Runs carry their build and economy through a mid-site and one of three terminal objectives, bosses and Memories across four authored route chains. Combine, Evolution, and future Confluence recipes remain separate systems; no Confluence is enabled.

The project is not complete when the content validator passes. Game quality requires a running build, readable combat, visible build transformation, causal Results, exact screenshot provenance, and evidence-led iteration. Technical tests establish simulation correctness; screenshots establish presentation evidence; neither is a substitute for the other.

## Standard agent loop

For every meaningful runtime, UI, audio, or presentation task:

```bash
python3 scripts/validate_content.py
GODOT_BIN=godot bash scripts/agent_iteration.sh
python3 tools/validate_iteration_report.py \
  --bundle artifacts/agent-iteration \
  --require-scored
```

If the Godot project is not yet present, the agent must not claim gameplay execution or fabricate screenshots. It should record the blocked runtime honestly, implement the smallest next slice, and state exactly one next task.

## Repository map

| Path | Purpose |
|---|---|
| [`docs/astra_game_bible.md`](docs/astra_game_bible.md) | Durable product context and Astra handoff. |
| [`docs/story_and_acts.md`](docs/story_and_acts.md) | Plot, acts, factions, characters, objectives, and bosses. |
| [`docs/art_direction.md`](docs/art_direction.md) | Visual, audio, animation, material, and asset direction. |
| [`docs/saint_loading_tableau.md`](docs/saint_loading_tableau.md) | WIP title/loading key art and the eyes-open, cloud-parting transition into the city. |
| [`design/gameplay_contract.md`](design/gameplay_contract.md) | Authoritative simulation and presentation contract. |
| [`design/shop_and_blessings.md`](design/shop_and_blessings.md) | Blessings, shop, currencies, offers, and evolution rules. |
| [`docs/progression_map_weapons_metagame.md`](docs/progression_map_weapons_metagame.md) | Research-backed run pacing, map, weapons, economy, metagame, and acceptance gates. |
| [`docs/improvement_plan_2026-09-15.md`](docs/improvement_plan_2026-09-15.md) | Current audit, unresolved decisions, system recommendations, and prioritized improvement plan. |
| [`docs/agent_completion_prompt.md`](docs/agent_completion_prompt.md) | Paste-ready lead-agent role, production method, quality bar, and completion definition. |
| [`docs/weapons_merges_traits_expansion.md`](docs/weapons_merges_traits_expansion.md) | Proposed weapons, named evolutions, cross-weapon Confluences, Gifts, traits, and staged content packets. |
| [`docs/weapon_evolution_trait_animation_map.md`](docs/weapon_evolution_trait_animation_map.md) | Implemented weapon-to-rank-to-Evolution links, Gift/catalyst interactions, and target attack choreography for all ten relic families. |
| [`docs/confluences_and_alternate_evolution_paths.md`](docs/confluences_and_alternate_evolution_paths.md) | WIP Vows, Boss Imprints, and current-roster Confluence recipes, trade-offs, presentation, and implementation gates. |
| [`docs/first_vertical_slice.md`](docs/first_vertical_slice.md) | Executable first-slice sequence and acceptance evidence. |
| [`roadmap.md`](roadmap.md) | Milestones from contracts to creative vertical and breadth. |
| [`content/`](content/) | Data-driven first-slice catalogues. |
| [`tests/README.md`](tests/README.md) | Deterministic test and evidence plan. |

## Current status

The first Godot prototype is implemented. See [runtime status](docs/runtime_status.md) and [implementation packets](docs/implementation_packets.md). Automated simulation outcomes, rendered visual fixtures, and human playtesting are separate evidence categories. Human playtesting remains outstanding.

## Current integration

The 2026-09-17 integration retains upstream ten weapons and ten Evolutions across the chapter and restores the approved sacred origin, histories ledger, relic-only shop and field repair kits. Destination work grants +3 Scrap per station and is optional: defeat the boss to advance. The ordinary and Evolution ledgers are separate. See [runtime status](docs/runtime_status.md) for current verification; older evidence sections are historical.

Completed changes are committed and pushed to GitHub. Fetch before starting work and preserve local edits before integrating.
