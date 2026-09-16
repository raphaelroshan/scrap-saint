# Task packet: P19 — complete weapon animation families

## Player-facing objective

Make the remaining eight base weapons and their Evolutions recognizable from physical motion, attack geometry, and aftermath during ordinary and overlapping combat.

## Authority and command boundary

The deterministic simulation continues to own readiness, target selection, hit geometry, damage, repair, control, resources, rank rules, and Evolution state. Presentation may read authoritative weapon instances and attack, hit, death, repair, and Evolution events to animate mounts, mechanisms, projectiles, residue, and reduced-effects variants. Presentation never delays or awards an outcome.

## Exact files expected to change

- `game/main.gd`
- `tests/test_weapon_presentation.gd`
- `tests/capture_weapon_animation.gd`
- `tests/README.md`
- `docs/weapon_evolution_trait_animation_map.md`
- `docs/runtime_status.md`
- `docs/verification_0_1.md`
- `docs/task_packets/complete_weapon_animation_families.md`

## Preserved contracts and non-goals

- Preserve all weapon values, target rules, cooldowns, statuses, repair/resource behavior, rank behavior, Evolution recipes, saves, event order, RNG, and policy outcomes.
- Do not add imported art, new weapons, new Evolutions, Confluences, Vows, Boss Imprints, currencies, or audio content.
- Do not redesign Nailer/Mercy Rail or Bell/Great Toll beyond compatibility with the shared timing table.
- Avoid camera shake on ordinary attacks and retain objective/enemy telegraph priority.
- Reduced effects must retain the authoritative area, target link, impact point, and resulting status or repair cue.

## Deterministic acceptance tests

1. Every enabled attack shape has an authored presentation duration and deterministic phase progress.
2. Each of the eight weapon IDs selects only its own latest attack for mount motion.
3. Presenting all sixteen base/Evolution attack states leaves the simulation hash unchanged.
4. Rank and Evolution fields remain visible to the presentation helpers without changing their authoritative rules.
5. Expiry uses the same presentation clock for all families.
6. All existing Godot, content, save/replay, policy, and packaging checks remain green.

## Screenshot states and provenance

Capture configured executable states with Godot 4.5.1, 1280×800, seed 147 under `artifacts/weapon-animation`: persistent base families; persistent Evolutions; linked base families; linked Evolutions; Mortar/Benediction; and a four-family overlap in full and reduced-effects modes. Each image must show the exact build and a `FIXTURE / P19` label. Inspect every image and record a scored rubric for family recognition, base/Evolution distinction, target/area readability, overlap hierarchy, reduced-effects parity, and palette coherence.

## Evidence recorded — 2026-09-16

Clean commit `0209b7efd73131f6ac4a417915a826ca33dda5d7` was captured with Godot 4.5.1 stable, OpenGL Compatibility on Apple M1 Pro, at 1280×800 and seed 147. Eight configured executable P19 states were inspected: persistent bases, persistent Evolutions, linked bases, linked Evolutions, base Mortar, Workshop Benediction, full four-family overlap and reduced-effects overlap.

Procession/Parade now read through moving gears, counter-rotating routes and repair-extension flags; Censer/Ashen through chain tension and layered offset smoke; Halo/Repairs through closing gimbals and stitch circuits. Candle/Unreturned uses independently curving violet shots and wick aftermath; Cable/Lattice uses a sweep hook or staged three-anchor boundary; Hymn/Sermon uses converging forks and separated cyan pulses; Winch/Long Hand uses unfolding segmented arms and a visible hook; Mortar/Benediction uses an arcing shell and square industrial seals. Every family also has a persistent Saint-mounted mechanism and family-specific impact residue.

Rendered-evidence rubric (5-point internal review): family recognition 4, base/Evolution distinction 4, target/area readability 4, overlap hierarchy 4, reduced-effects parity 4, palette coherence 4. The full overlap remains dense by design, but the large Parade ring, narrow Sermon lane, curved funeral shots and square Benediction seal remain separable. Reduced effects removes smoke layers, filings, trails and secondary sparks while preserving attack boundaries and targets.

All 878 Godot assertions and thirty-one Python checks pass. The normal-economy matrix wins 12/12, frame/Blessing/first-route 24/24, assembly 4/4, Evolutions 10/10 and Gift-specific routes 4/4. No script-load, resource-load or assertion errors appear in the iteration logs.

## Remaining limitation

Configured deterministic captures can establish silhouette, geometry, and layering but cannot establish enjoyment, audio feel, or responsiveness under human-controlled 1× movement.

## Exactly one next task

Run an uncoached human 1× combat session using two four-weapon builds spanning all ten families, then tune only observed timing, overlap, and recognition failures.
