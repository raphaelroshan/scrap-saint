# Task packet: P17 — weapon, Evolution, and trait animation map

## Player-facing objective

Make every enabled relic family understandable as one continuous path: base attack, Rank II and Rank III behaviour, catalyst, named Evolution, compatible Gift, and the physical animation that communicates each result.

## Authority and command boundary

This is a documentation-only design pass. `content/items/first_slice.json` and `content/slices/first_shift.json` remain authoritative for identities, recipes, values, tags, and effects. `game/simulation.gd` remains authoritative for attack resolution. `game/main.gd` remains the current presentation implementation. The map may describe future presentation work, but it cannot redefine simulation behaviour.

## Files

- `docs/task_packets/weapon_evolution_animation_map.md`
- `docs/weapon_evolution_trait_animation_map.md`
- `README.md`

## Preserved contracts and non-goals

- Preserve all ten enabled base weapons, ten catalyst Evolutions, eight catalysts, seven Gifts, four Blessings, four weapon slots, one reserve slot, and two Gift slots.
- Combine remains cumulative Rank II/III assembly; Evolution remains Rank III plus one named catalyst.
- Traits means named rank behaviours, catalyst carry effects, Gifts, and Blessing affinities. These layers stay visibly distinct.
- Do not add or enable weapons, Evolutions, Gifts, Confluences, currencies, balance changes, combat timing, or presentation code.
- Do not present proposed animation as already implemented evidence.

## Acceptance checks

1. All ten enabled weapons map to their exact Rank II trait, Rank III trait, catalyst, and Evolution.
2. Shared catalysts are visible: Saint's Rivet links three families and Blue Wire links two; every other enabled Evolution link remains one-to-one.
3. All seven enabled Gifts are classified as direct attack modifiers, shared-trigger synergies, or non-attack support.
4. Every base weapon and Evolution has Prepare, Commit, Resolve, and Aftermath direction.
5. Current procedural presentation is separated from the intended animation target and does not claim unimplemented art.
6. Timing, colour, silhouette, overlap, accessibility, and simulation/presentation boundaries are explicit.
7. Repository links resolve and content validation remains green.

## Screenshot states and provenance

No new runtime screenshot is valid evidence for this documentation-only task. The next presentation implementation should capture three 1280x800 fixture comparisons on Godot 4.5.1, seed 147: Nailer to Mercy Rail, Bell to Great Toll, and a four-weapon overlap stress state. Each capture must show build commit, viewport, seed, and `FIXTURE` provenance.

## Remaining limitation

The current renderer communicates resolve geometry but does not yet implement the complete Prepare/Commit/Aftermath choreography, physical silhouette transformations, or authored sprite animation described by the map.

## Exactly one next task

Implement the shared weapon animation timeline and use it to deliver the complete Nailer/Mercy Rail and Bell/Great Toll animation families, including overlap captures.
