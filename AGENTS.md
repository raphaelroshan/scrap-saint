# Scrap Saint agent rules

## Current user decisions and repository sync

The Saint manifests from the grace of repairs freely given in a devastated machine world. See docs/saint_of_freely_given_repairs.md. This supersedes older engineered-origin passages.

Main-mode shop slots contain relics (weapons, catalysts and eligible Gifts), never repair or service cards. Recovery comes from field drops and optional machines. Site work remains optional throughout the chapter; surviving and defeating the site's boss is sufficient to advance. Relay defence and its services remain a development comparison.

The user requests ongoing repository synchronization: fetch before integration, preserve dirty work, commit and push completed validated changes, and report the delivered branch/commit. Never force-push shared history. Keep the working delivery branch synchronized with the remote. Runtime status and the enabled slice supersede historical roster limits below.

## Read first

Before editing, read [`README.md`](README.md), [`docs/agent_completion_prompt.md`](docs/agent_completion_prompt.md), [`docs/astra_game_bible.md`](docs/astra_game_bible.md), [`docs/story_and_acts.md`](docs/story_and_acts.md), [`design/gameplay_contract.md`](design/gameplay_contract.md), [`design/shop_and_blessings.md`](design/shop_and_blessings.md), and [`docs/progression_map_weapons_metagame.md`](docs/progression_map_weapons_metagame.md). Then select the smallest relevant roadmap and source/test files.

## Product invariants

Scrap Saint is a warm industrial devotional machine game, not a generic military shooter. The Saint repairs, salvages, evolves, and chooses what it becomes. Preserve the tension between maintenance and combat, the earnest-but-absurd flavour, readable industrial silhouettes, and visible cause-and-effect.

The canonical story combines the Pilgrimage of Repairs with the Saint Built Wrong arc. The external goal is to reach the First Engine; the personal arc is discovering whether the Saint should restore, repurpose, or dismantle the old machine order.

Blessings define broad run doctrine. The relic shop assembles and modifies that doctrine. Weapon evolutions must change behaviour or geometry, not only damage. The player must be able to understand the next wave, the current doctrine, the available evolution, and the cost of a shop decision without consulting an external wiki.

## Architecture boundary

The deterministic simulation owns movement results, timers, targeting, hit resolution, damage, healing, statuses, pickups, Scrap, Relic Shards, shop rolls, rerolls, purchases, combines, Blessing eligibility, evolution eligibility, objectives, bosses, seeds, save state, and replay traces.

Presentation owns scenes, sprites, particles, animation, audio, camera, UI, input mapping, and screen transitions. Presentation sends validated commands to the simulation and renders returned events. It must not award damage, decide whether a recipe is complete, or mutate authoritative state directly.

Content belongs in stable-ID data files. Do not bury balance values in scene scripts. Every content entry needs a clear description, tags, costs, prerequisites, and deterministic tests where it affects the simulation.

## Task packet contract

Before implementation, write a short packet with:

- One player-facing objective.
- The authoritative owner and command boundary.
- Exact files expected to change.
- Non-goals and preserved contracts.
- Deterministic acceptance tests.
- Screenshot states and build/viewport provenance.
- Remaining limitation.
- Exactly one next task.

Do not broaden a task because an adjacent system is interesting. Create a follow-up packet instead.

## Shop and Blessing rules

The shop uses Scrap and Relic Shards only in the first version. Each shop visit should include a current-build improvement, a visible evolution-path offer, a new-direction offer, and flexible defence or economy support. Packs are called Blessings in all player-facing text.

A Blessing establishes direction but does not hard-lock a run. The shop may bias offers and provide one doctrine-specific service, but hybrid builds must remain viable. One reserve slot and one free refresh should support experimentation. Same-rank combining should be deterministic and reversible only through an explicit sell/dismantle action.

## Combat and content rules

Every enemy must have a readable attack, target preference, telegraph, counter family, and failure explanation. Bosses must change a rule, objective, or arena condition; they must not be health sponges. Effects such as Marked, Rung, Bound, Scoured, Consecrated, Fevered, Quieted, Witnessed, Repaired, Converted, Overloaded, and Mourned need visible presentation and deterministic duration/trigger rules.

Keep the first playable to one arena, five base weapons, four catalysts, three Blessings, three enemy families, one elite, one boss, one objective, one shop, and one visible evolution. Do not add a campaign map, large faction system, multiplayer, procedural world, or complex inventory before this slice has a complete playable loop.

## Evidence honesty

A valid JSON/content check is not gameplay evidence. A timeout is not a pass. If Godot, capture, a required asset, or a login-dependent service is unavailable, classify the limitation honestly. Never fabricate human testing or screenshots. Store invalid or blocked evidence with its reason rather than silently replacing it.

For meaningful UI, visual, audio, or vertical-slice work, run the repository’s autonomous loop, inspect the resulting captures, score the visual rubric, record exact build and viewport provenance, state one limitation, and define exactly one next task.

## Quality bar

A task is not done when code merely runs. The player-facing result must be legible, responsive, aesthetically coherent with the industrial devotional direction, and understandable from a screenshot or short capture. Prefer the smallest complete vertical slice over broad unpresented content.
