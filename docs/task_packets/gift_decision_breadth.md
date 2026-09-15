# Task packet: P16 — Gift decision breadth

## Player-facing objective

Let the Saint choose between seven legible run-local support rules, adding four Gifts that change repair movement, shop comprehension, silence timing, or Bell control without becoming passive stat clutter.

## Authoritative owner and command boundary

`content/items/first_slice.json` and `content/slices/first_shift.json` own Gift identity, values, descriptions, trade-offs and activation limits. `game/simulation.gd` owns acquisition, two-slot capacity, repair-completion triggers, movement, Quiet recovery, Mark application, Bell cadence, purchase previews, saves and event traces. `game/main.gd` only renders authoritative state and pure purchase previews; player actions continue through existing shop commands.

## Exact files expected to change

- `content/items/first_slice.json`
- `content/slices/first_shift.json`
- `game/simulation.gd`
- `game/main.gd`
- `scripts/validate_content.py`
- focused Gift, acquisition, save, UI and policy tests
- one configured 1280×800 Gift/shop capture
- `README.md`, `docs/runtime_status.md`, `docs/verification_0_1.md`, `docs/weapons_merges_traits_expansion.md`, `roadmap.md`, and this packet

## Preserved contracts

- Gifts remain unique, rankless, run-local items in two dedicated slots and use Scrap only.
- Weapons, catalysts, Evolutions, Blessings, four active slots and one reserve remain separate systems.
- Every route and boss remains viable without a Gift.
- Effects are deterministic, stable-ID data-owned, save-safe and visible in trace or UI state.
- Shop cards retain the six-role layout and at least one affordable action.

## Enabled rules

- **Loose Spring:** completing a repair gives a 90-tick movement burst; one trigger per completed machine or objective node.
- **Honest Scale:** shop cards preview the exact post-purchase active/reserve count and any automatic Combine result; it grants no combat power.
- **Choir Filter:** Quieted support enemies remain unable to use support actions for a short recovery window; Hymn Coil and Quiet Sermon deal less direct damage while carried.
- **Brass Fuse:** the first enemy staggered by Bell or Great Toll each wave stays Marked for that wave; Bell mechanisms cycle more slowly.

## Non-goals

- No new Gift slots, currencies, rarity tiers, permanent traits, weapons, Evolutions, Confluences, enemies, routes or bosses.
- No Gift fragments, random affixes, stacking identical Gifts, or hidden multi-item threshold.
- No claim that deterministic policies prove the seven-Gift shop is enjoyable for human players.

## Deterministic acceptance tests

1. All seven enabled Gifts have a stable schema, unique IDs, a primary effect, and an explicit trade-off or activation limit.
2. Loose Spring triggers only from authoritative repair completion, lasts exactly its data-owned duration, survives save/restore and cannot retrigger from the same completed work.
3. Honest Scale previews no-combine, auto-combine, active/reserve capacity and rejection outcomes without mutating inventory, currency, RNG or offers.
4. Choir Filter extends support suppression after Quiet ends and applies its documented beam/silence damage trade-off.
5. Brass Fuse marks only the first Bell-staggered target in each site/wave segment and applies its documented Bell cooldown trade-off.
6. Gift purchase, duplicate rejection, full-slot rejection, sale, dismantle, Results and version-3 save restoration remain deterministic.
7. The complete focused suite, 12-policy normal-economy matrix, 24-policy breadth matrix, four assembly policies and ten Evolution policies remain green.

## Screenshot states and provenance

- Seven-Gift workshop pool with Honest Scale preview text.
- Loose Spring active during post-repair movement.
- Choir Filter recovery and Brass Fuse Marked activation in combat.
- Godot 4.5.1, Compatibility renderer, 1280×800, seed 147, configured-fixture label, exact commit and build identifier.

## Remaining limitation

Configured captures and deterministic policies cannot establish whether seven support choices are immediately understood or whether the expanded pool creates frustrating offer dilution.

## Exactly one next task

Run uncoached 1× workshop sessions comparing the original three-Gift pool with the seven-Gift pool, then tune only observed card-comprehension and offer-quality failures.
