# Task packet: P15 — complete weapon progression

## Player-facing objective

Make every current weapon become meaningfully more expressive as it ranks up, and give the two remaining base weapons—Procession Gear and Cable of Contrition—their own visible Evolution endpoints.

## Authoritative owner

`game/simulation.gd` owns rank-dependent geometry, targeting, statuses, objective interactions, Evolution eligibility, inventory mutation, saves and event traces. Stable content records own all rank and Evolution values. `game/main.gd` only previews and renders those rules.

## Exact files

- `content/items/first_slice.json`
- `content/slices/first_shift.json`
- `game/simulation.gd`, `game/main.gd`, and `game/sound.gd` only where presentation is required
- `scripts/validate_content.py`
- focused weapon, Evolution, acquisition, save, UI and policy tests
- `README.md`, `docs/runtime_status.md`, and this packet

## Preserved contracts

- Four active weapon slots, one reserve slot, Scrap and Relic Shards remain unchanged.
- Combine remains two identical same-rank weapons; Evolution remains Rank III plus one catalyst.
- Every encounter and boss remains viable without a particular weapon or Evolution.
- Rank changes and Evolutions are deterministic, data-owned and save-safe.
- The existing ten weapons, eight Evolutions, stable IDs and version-3 saves remain compatible.

## Non-goals

- No new base weapons, Gifts, Blessings, currencies, Confluences, maps or permanent stat progression.
- No requirement that a player complete an Evolution to finish the chapter.
- No generic rarity or random affix system.

## Deterministic acceptance tests

1. Every enabled weapon defines distinct Rank II and Rank III behavior beyond scalar damage.
2. Rank behavior changes a visible geometry, targeting, cadence, control, repair or resource outcome and emits traceable events.
3. Procession Gear Rank III plus Pilgrim Spindle atomically becomes The Maintenance Parade.
4. Cable of Contrition Rank III plus Blue Wire from the Pump atomically becomes Contrition Lattice.
5. Rejected Evolutions do not consume catalysts, change inventory or advance RNG.
6. Both new Evolutions survive save/restore, appear in the Ledger and Results, and complete a full two-leg chapter under controlled policies.
7. Existing acquisition, shop, chapter, controller and all eight Evolution contracts remain green.

## Evidence states

- Rank I/II/III comparison for representative precision, control and orbit weapons.
- Evolution Ledger showing ten complete current-weapon paths.
- Maintenance Parade and Contrition Lattice overlapping ordinary combat pressure without obscuring boss or objective telegraphs.
- 1280×800, seed 147, Godot version and configured/natural evidence label visible.

## Remaining limitation

Automated policies and configured captures cannot establish whether the added rank decisions are understandable or exciting during an uncoached 1× run.

## Exactly one next task

Add a four-Gift decision packet centred on Honest Scale, Loose Spring, Choir Filter and Brass Fuse, then test whether the expanded support pool improves shop decisions without creating dead offers.
