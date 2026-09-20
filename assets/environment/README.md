# Painted arena materials

The runtime now uses these assets through `game/arena_art.gd`. The floor, obstacle machinery, field Scrap and repair kits share the painted material language; the Saint, enemies, effects and objective indicators retain their current renderer.

## Placement rules

- Floor material repeats at 384 by 256 world pixels on every site. Edge tiles are clipped. It is a flat top-down surface with no baked scenery or perspective convergence.
- Floor contrast is deliberately below pickups and actors. No decorative glow, holes, coins or hazard-like circles are painted into it.
- A dark plinth and rim show each simulation-owned obstacle rectangle. Raised machine art fits entirely inside that footprint, preserves its aspect ratio, and never changes navigation.
- Vertical footprints use a press or cold boiler. Wide footprints use a dedicated horizontal manifold. Do not rotate baked lighting or shrink a row of full-size machines to fill a bench.
- Warm upper-left highlights, desaturated green enamel, cream access panels, dark iron and brass couplings unify props with the other painted assets.
- Faded lane corners and perimeter services establish order without filling movement lanes with decoration. Zone/machine names are available in the diagnostic overlay rather than painted over normal play.
- Site tint is restrained: green Rootworks, warmer Foundry/Brass, cooler Archive/Null. Site-specific silhouettes remain a future art pass.
- Scrap and field repair kits use their existing simulation events and collection rules. Spectral healing motes are not Relic Shards. Shard artwork is used in the currency HUD, not as a new drop system.

## Sources and integration

Generated with the built-in OpenAI image tool using this project's arena-target concept as the material reference. `sources.json` records exact prompts, original generator output IDs, dimensions and source hashes. Original PNGs are copied unchanged. `regions.json` records alpha >16 silhouette bounds; these are draw regions, not edited source bitmaps. Textures are loaded once and reused. No per-frame image decoding or generated-texture allocation occurs.

To reproduce the focused evidence: run `godot --path . --script res://tests/capture_arena_art.gd`. The matching before/after fixtures use seed 147 and the same configured state; these are real renderer captures but not human playtests. The test `tests/test_arena_art.gd` checks footprint containment and aspect ratio across all six arena layouts, as well as simulation-state isolation.
