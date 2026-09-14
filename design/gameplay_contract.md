# Scrap Saint — Gameplay contract

## Authority

The simulation is the single source of truth. It advances from a deterministic seed, command stream, and fixed update policy. Presentation renders simulation events and never decides outcomes.

```text
Simulation state + seed + command → validated result + events + next state
```

The first project may use a fixed timestep such as 1/60 seconds, but all tests must avoid wall-clock dependence. A replay should reproduce state hashes and event IDs from the same initial state and command stream.

## Core state

The minimum authoritative state contains:

- `run_seed` and `tick`.
- Saint frame, position, velocity, structure, maximum structure, and active Blessing.
- Active weapons with stable ID, rank, cooldown, calibration, and evolution status.
- Companion, terrain tool, ritual, passive traits, and one reserve slot.
- Active statuses on Saint, enemies, objectives, and zones.
- Enemy instances with stable ID, position, state, health, armour, tags, and target.
- Objective instances with stable ID, progress, maximum progress, state, and required interactions.
- Scrap, Relic Shards, shop inventory, locks, rerolls, and transaction history.
- Wave schedule, threat forecast, elite/boss state, and objective result.
- Blessing progress, recipe discoveries, memories, and route result.
- Versioned save and replay metadata.

## Commands

The public command boundary should use explicit command names:

| Command | Validation |
|---|---|
| `move` | Input vector is clamped and accepted only during active play. |
| `use_ritual` | Ritual is owned, charged, and not blocked by a status. |
| `collect` | Pickup is available and within collection rules. |
| `buy_shop_item` | Item is offered, currency is sufficient, slot/reserve rules pass. |
| `sell_item` | Item exists and is sellable. |
| `combine_items` | Two compatible same-rank items exist. |
| `reserve_item` | Reserve slot is empty and item is eligible. |
| `reroll_shop` | Refresh quota and Scrap cost pass. |
| `repair` | Objective or Saint is repairable and cost is sufficient. |
| `choose_blessing` | Blessing is offered and choice window is open. |
| `choose_evolution` | Recipe is eligible and transformation window is open. |
| `choose_route` | Route choice is offered and prior objective resolves. |
| `pause` | Presentation may pause; simulation must stop advancing. |

Every rejected command returns a stable reason such as `INSUFFICIENT_SCRAP`, `MISSING_INGREDIENT`, `RESERVE_FULL`, `OUTSIDE_WINDOW`, or `INVALID_TARGET`.

## Combat

Movement is direct and deterministic. Weapons select targets through data-defined rules such as nearest, marked, lowest health, objective attacker, or elite priority. A weapon attack emits an authoritative event containing source, target/area, effect, damage or repair, and stable event ID.

The first combat model uses health, structure, armour, speed, and one or two tags. Avoid a large stat surface. Attack geometry is represented by data: line, cone, orbit, sweep, beam, swarm, seal, procession, tether, or pulse.

Bosses must alter a rule, objective, or arena condition. Boss health may be high enough for a dramatic phase, but never substitute for a readable mechanic.

## Status effects

The first status vocabulary is:

| Status | Deterministic rule |
|---|---|
| `MARKED` | Compatible effects gain their defined target bonus until expiry or resolution. |
| `RUNG` | Target is staggered and cannot perform its next movement action. |
| `BOUND` | Target movement is scaled or redirected by tether owner. |
| `SCOURED` | Armour is reduced for a defined duration. |
| `CONSECRATED` | Zone grants its defined allied or objective benefit. |
| `FEVERED` | Target receives periodic damage and may resolve a burst on defeat. |
| `QUIETED` | Target special actions are disabled for a defined duration. |
| `WITNESSED` | Hidden properties are revealed and targeting becomes eligible. |
| `REPAIRED` | Structure or objective progress increases through an authoritative event. |
| `CONVERTED` | Target changes allegiance for a defined duration or until damage threshold. |
| `OVERLOADED` | Next compatible effect resolves a burst, then status clears. |
| `MOURNED` | Defeat leaves a defined remnant or spirit event. |

Statuses are not free-form strings. Each has stable duration, stacking, refresh, and removal rules in content data.

## Objectives

An arena can contain one primary objective in the first slice. Objective types are `REPAIR`, `PROTECT`, `ESCORT`, `RECOVER`, and `HOLD`.

The first objective is `REPAIR_RELAY`: the Saint must spend time in a repair zone while surviving waves. The relay has health, progress, damage state, and a visible repair requirement. Repair effects such as Mercy Rail can increase its progress, but presentation cannot award progress directly.

## Shop and Blessing contract

The first shop contains two weapon offers, two relic/catalyst offers, and two services. It uses Scrap and Relic Shards. The shop rolls from a deterministic seed and offer context; rerolls consume a known cost and return a new deterministic set.

A Blessing contains a starting guarantee, shop bias, unique service, fulfilment condition, and doctrine effect. Blessings may support hybrid paths. A Blessing is not a permanent deck and does not own the item inventory.

An evolution recipe contains stable IDs for base item, rank, catalyst or second item, eligibility window, resulting item, and transformation event. It must support `unknown`, `discovered`, and `ready` UI states.

## Saves and replays

Save state must be versioned from the first prototype. It must persist run seed, tick, command boundary, state hash, active content IDs, shop state, currencies, objective state, and Blessing/evolution state. Loading must not re-roll the shop or change enemy timing.

A replay record stores the seed and accepted commands. The test harness should compare state hashes after checkpoints and identify the first divergent event.

## Presentation boundary

Presentation may render the Saint, enemies, relics, status icons, objective progress, shop, Blessings, evolution preview, particles, audio, camera, and UI. It cannot mutate simulation state except through public commands.

The first visual evidence must show a real running state, exact build, viewport, seed, and capture timestamp. Content validation alone is not gameplay evidence.
