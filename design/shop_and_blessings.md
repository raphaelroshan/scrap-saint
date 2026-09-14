# Scrap Saint — Shop and Blessings contract

## Design decision

Scrap Saint uses a two-layer run-building model:

> **Blessings choose the broad doctrine; the relic shop gives the player agency to assemble, repair, upgrade, and evolve it.**

A Blessing is a fiction-facing and mechanically meaningful run direction. It guarantees one starting piece, biases future offers, provides one service, and can be fulfilled for a doctrine effect. It never hard-locks the run.

The shop is the player’s workshop between waves. It should feel like sorting sacred industrial components, not operating a generic rarity slot machine.

## Run currencies

| Currency | Source | Uses |
|---|---|---|
| **Scrap** | Ordinary enemies, destructible objects, wave completion. | Weapons, repairs, combinations, ordinary upgrades, rerolls. |
| **Relic Shards** | Elites, objectives, bosses, shrine events. | Catalysts, recipe support, rare services, Blessing deepening. |

Do not add additional run currencies until this economy has been playtested and a specific missing decision is identified.

## Blessing schema

Each Blessing requires:

- Stable ID and display name.
- Short doctrine description.
- Starting guarantee.
- Weighted shop tags.
- Unique shop service.
- Fulfilment condition.
- Fulfilment reward.
- One weakness or cost.
- Optional character/memory flavour.

### Initial Blessings

| Blessing | Starting guarantee | Shop favour | Unique service | Weakness |
|---|---|---|---|---|
| **The Workshop Gospel** | Nailer or repair passive. | Labour, Mercy, repair. | Rebuild one item for component refund. | Lower burst. |
| **The Bell Ward** | Bell or reveal passive. | Witness, Pulse, control. | Preview the next elite pressure. | Weak single target. |
| **The Procession** | Procession Gear or orbit passive. | Orbit, followers, close defence. | Duplicate one temporary relic effect. | Vulnerable to ranged threats. |
| **The Quiet Order** | Hymn Coil or Silence passive. | Beam, Quieted, elite counters. | Remove one hostile offer and improve catalyst odds. | Low crowd clear. |
| **The Salvage Rite** | Scrap passive or dismantling tool. | Scrap, hybrid tags, calibration. | Convert one unwanted item into a component. | Lower immediate defence. |
| **The Mourner** | Candle-Nailer or spirit passive. | Mourn, remnants, conversion. | Preserve one defeated elite remnant. | Needs kills to compound. |
| **The Red Litany** | Mortar or Wrath passive. | Burst, Fevered, area denial. | Overpress one weapon for the next wave. | Delayed attacks and self-risk. |
| **The Threshold Rite** | Cable or movement passive. | Tether, displacement, escape. | Move one item to reserve for free. | Requires precise positioning. |

## Shop layout

The first shop displays six offers:

- Two weapon-bay offers.
- Two relic-bench offers.
- Two service-altar offers.

Each item shows price, tags, rank, immediate effect, current-build interactions, next-wave relevance, and possible evolution path. A player should be able to understand an item without opening a separate codex.

Every visit should contain one current-build improvement, one visible evolution-path offer, one new-direction offer, one flexible defence or economy option, and two context-sensitive offers influenced by the Blessing and threat forecast.

## Shop actions

| Action | Rule |
|---|---|
| **Buy** | Adds item if active or reserve capacity allows. |
| **Sell** | Returns 60% of Scrap cost for ordinary items. |
| **Dismantle** | Returns a smaller Scrap value and may produce a component tag. |
| **Combine** | Two identical same-rank weapons become one next-rank weapon. |
| **Reserve** | Stores one item outside the active loadout. |
| **Repair** | Restores Saint or objective structure for Scrap. |
| **Reroll** | First refresh free, later refreshes cost 2/4/7 Scrap. |
| **Read the Ledger** | Costs one Relic Shard and reveals a recipe or threat interaction. |
| **Recast Relic** | Costs one Relic Shard and changes one catalyst secondary tag. |

Shop actions are commands into the simulation. UI previews the transaction and shows rejection reasons such as `INSUFFICIENT_SCRAP`, `ACTIVE_SLOTS_FULL`, `RESERVE_FULL`, and `MISSING_INGREDIENT`.

## Ranks and evolutions

Weapons use three ranks:

- Rank 1 establishes geometry and one identity effect.
- Rank 2 improves reliability or adds a secondary interaction.
- Rank 3 enables one or more known evolutions.

An evolution requires a Rank 3 base plus a catalyst or compatible second item. Evolution occurs at an elite reward, boss reward, or altar service. No separate evolution currency is required.

A recipe has three UI states:

```text
UNKNOWN: this relic may have a higher form
DISCOVERED: show ingredients and result
READY: all ingredients and rank requirements are complete
```

The first recipe is:

```text
Nailer of Small Mercies Rank 3 + Saint’s Rivet → Mercy Rail
```

The first shop implementation should also support:

```text
Bell of the Last Shift Rank 3 + Cracked Bell Clapper → The Great Toll
```

## Anti-friction rules

The first ten recipes are visible in the game. An offer should not remove the only current-build improvement unless the player selects a special wild-shop mode. A player can lock one offer for the next visit. Selling and dismantling permit experimentation without destroying the run. No recipe requires more than two active ingredients in the first version.

A player may pursue a different doctrine after the starting Blessing. Hybrid builds are a supported outcome, not a failure state. The shop should create tension between immediate survival, future evolution, and flexibility, but never rely on pure bad luck to create difficulty.

## Threat forecast

The shop includes the next wave’s primary pressure and two or three valid counter families. For example:

```text
NEXT WAVE: Choir Drones
PRESSURE: summon fields and skill suppression
VALID RESPONSES: Hymn Coil / Bell Ward / Procession Gear
```

The forecast does not name one correct purchase. It explains the problem and leaves room for the player’s doctrine.

## First economy target

An eight-to-ten-minute run should target 80–120 Scrap, 3–5 Relic Shards, two or three Blessing moments, one guaranteed visible evolution path, and enough shop visits to make at least five meaningful decisions. These numbers are tuning targets, not permanent contracts.
