# Scrap Saint — Design decision record

## Decision

Build Scrap Saint as a single-player evolution-driven arena roguelite combining:

- The **Pilgrimage of Repairs**: a clear external journey through industrial ruins toward the First Engine.
- The **Saint Built Wrong** arc: a personal story about a machine assembled from incompatible parts and choosing its own identity.
- A **Blessing plus relic-shop** run structure: Blessings set doctrine; the shop provides agency and evolution ingredients.
- **Visible weapon transformations**: named evolutions must change attack geometry, status logic, objective interaction, or resource behaviour.
- **Compact repair objectives**: arenas are not pure kill rooms; the build must sometimes protect, repair, escort, or recover.

## Why this direction

A generic survivor-like is fast to build but easy to forget. A pure faction narrative is distinctive but expensive. A large route/management game has strong scope but would duplicate the portfolio’s logistics and fortress projects.

This hybrid keeps a small simulation surface while giving the project a strong identity: a tiny devotional machine that repairs a broken world and physically changes through its beliefs and tools.

## Trade-offs

### Breadth versus transformation

The first version limits the catalogue and invests in named weapon evolutions. This sacrifices early content breadth but makes the first ten minutes more memorable and easier to test.

### Randomness versus agency

The relic shop uses controlled randomness. This sacrifices some surprise in exchange for making visible evolution goals achievable and preventing dead runs where the player never sees a required catalyst.

### Story versus interruption

The story is delivered through objectives, shop flavour, memory fragments, boss introductions, and Results. This sacrifices long dialogue scenes but keeps combat rhythm intact.

### Faction variety versus scope

Factions are introduced as compact Blessing and enemy families rather than full diplomacy simulations. This preserves replay value without adding a large social state machine.

### Visual quality versus asset breadth

The first creative vertical invests in the Saint, key weapons, first boss, effects, and UI. Background breadth remains modular and procedural until the core visual identity is proven.

## Rejected alternatives

A pure military mech arena was rejected because it overlapped with Scrapline Courier and weakened the devotional repair identity.

A full dungeon-management version was rejected because rooms, economy, and enemy routing would pull the game toward Pack the Keep.

A hidden-recipe evolution system was rejected for the core path because it would make the first ten minutes dependent on external guides.

A large multi-currency deckbuilder was rejected because it would increase balance and onboarding complexity before the basic shop/evolution loop was proven.

## Success criteria

The direction is working when a player can:

1. Describe the Saint in one sentence.
2. Choose between at least three Blessings that feel mechanically distinct.
3. Understand what the next wave threatens.
4. Make a shop decision between survival, evolution, and flexibility.
5. Reach one named evolution in a single short run.
6. See and hear that the evolution changed the machine.
7. Understand one piece of the Saint’s origin without leaving the run.
8. Replay with a different Blessing and produce a meaningfully different build.

## Review trigger

Revisit this decision only after a complete 8–10 minute playable exists and has been captured, critiqued, and played through with at least three Blessings. Do not revise the premise because content is still missing; revise it only if the core loop fails to create a clear transformation or meaningful shop decision.
