# Scrap Saint

**Scrap Saint** is a single-player evolution-driven arena roguelite about a small devotional machine crossing a ruined industrial world. It repairs broken systems, assembles relic weapons, receives competing blessings, and discovers what kind of machine it has chosen to become.

> **Restore the First Engine—or decide that the world is better without it.**

The project combines short survivor-like runs, a Slime 3K-style relic shop, visible weapon evolutions, and a warm industrial story about repair, purpose, and self-determination. It is not a conventional military mech game. The Saint is a maintenance automaton that treats bells, rivets, cables, manuals, and ruined machines as sacred because they once helped people.

## Play the prototype

Open `project.godot` in **Godot 4.5.1** and run the project. In this workspace, double-click **Play Scrap Saint.cmd** to launch using the downloaded portable runtime.

For faster development, use **Play Scrap Saint 5x Dev.cmd**. Combat runs at 5× speed, including movement, weapons, enemies, repair and wave timers. Shops and pause remain stopped. **F6** toggles 1×/5× in this development version; the on-screen badge shows the active speed. An 8½-minute combat run takes about 1 minute 42 seconds at 5×, excluding shops. The normal launcher remains 1×. CLI equivalent: `godot --path . -- --dev-speed=5`.

- **Optional repairs is the main game.** The 5x development launcher retains the relay-defence comparison toggle. New runs use the displayed seed; change it on the title screen. Existing saves retain their mode.
- WASD or arrows: move; weapons attack automatically. In Optional repairs, short repairs reward Scrap, healing or a stagger pulse. Machines cannot be destroyed and repairs are never required to win. In Relay defence, stay near the relay to repair it and keep it alive.
- Escape: pause; F5: save; F9: load; M: mute; F3: diagnostic overlay.
- Between waves: buy/combine, sell, store, equip, lock and refresh. Every weapon gains named behavior at Rank II and Rank III; Evolutions such as Mercy Rail remain optional.
- Defeating the Foreman opens Brass Choir Relay and Rootworks Pump. Their memories open a second choice: Brass leads to Pale Archive or Red Foundry; Rootworks leads to Red Foundry or Null Assembly. The build, economy and Blessing persist through all three sites.
- Controller: left stick movement, standard UI navigation/accept, Start to pause.

See [runtime status](docs/runtime_status.md) for implemented rules, prototype substitutions, and limitations. The enabled slice and balance values live in `content/slices/first_shift.json`.

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

The current early-access preview is a complete first-chapter vertical: three Saint frames, four Blessings, ten base weapons, eight catalysts, seven run-local Gifts, ten visible Evolutions, a Workshop plus five destination sites, seven enemy families, an elite and six bosses. Runs carry their build and economy through a mid-site and one of three terminal objectives, bosses and Memories across four authored route chains. Combine, Evolution, and future Confluence recipes remain separate systems; no Confluence is enabled.

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
| [`design/gameplay_contract.md`](design/gameplay_contract.md) | Authoritative simulation and presentation contract. |
| [`design/shop_and_blessings.md`](design/shop_and_blessings.md) | Blessings, shop, currencies, offers, and evolution rules. |
| [`docs/progression_map_weapons_metagame.md`](docs/progression_map_weapons_metagame.md) | Research-backed run pacing, map, weapons, economy, metagame, and acceptance gates. |
| [`docs/improvement_plan_2026-09-15.md`](docs/improvement_plan_2026-09-15.md) | Current audit, unresolved decisions, system recommendations, and prioritized improvement plan. |
| [`docs/agent_completion_prompt.md`](docs/agent_completion_prompt.md) | Paste-ready lead-agent role, production method, quality bar, and completion definition. |
| [`docs/weapons_merges_traits_expansion.md`](docs/weapons_merges_traits_expansion.md) | Proposed weapons, named evolutions, cross-weapon Confluences, Gifts, traits, and staged content packets. |
| [`docs/weapon_evolution_trait_animation_map.md`](docs/weapon_evolution_trait_animation_map.md) | Implemented weapon-to-rank-to-Evolution links, Gift/catalyst interactions, and target attack choreography for all ten relic families. |
| [`docs/first_vertical_slice.md`](docs/first_vertical_slice.md) | Executable first-slice sequence and acceptance evidence. |
| [`roadmap.md`](roadmap.md) | Milestones from contracts to creative vertical and breadth. |
| [`content/`](content/) | Data-driven first-slice catalogues. |
| [`tests/README.md`](tests/README.md) | Deterministic test and evidence plan. |

## Current status

The first Godot prototype is implemented. See [runtime status](docs/runtime_status.md) and [implementation packets](docs/implementation_packets.md). Automated simulation outcomes, rendered visual fixtures, and human playtesting are separate evidence categories. Human playtesting remains outstanding.
