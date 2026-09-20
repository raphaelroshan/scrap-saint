# Relic asset pack 01

This is a reusable asset pack and isolated animation preview. Live gameplay still uses its existing procedural weapon renderer; the Saint is unchanged.

Open `preview.html` for animated normal/reduced comparisons, frame scrubbing, speed and light/dark backgrounds. The gallery repeats each clip with a pause; the Godot resources deliberately do not loop.

## Contents

- `art/nailer.png`, `art/bell.png`: transparent illustrated inventory/detail candidates generated from our relic concepts. They are not animation frames. The Nailer retains a rear coupling in the generated design; no character attachment is required.
- `pixels/*.png`: ten transparent 1536x128 strips, each containing twelve 128x128 cells. Nailer, Mercy Rail, Bell, Cable and Censer, with reduced variants.
- `pixels/*.tres`: ready-to-load Godot SpriteFrames, animation `manifest`, authored presentation duration, no looping.
- `animations.json`: frame sizes, clip durations, direction and anchor for every strip.
- `contact-sheet.png`: actual rendered frame review, rows in manifest order. It is an asset preview, not gameplay evidence.
- `provenance.json`: methods, checks and source/output hashes.

## Use in Godot

Assign a `.tres` to an AnimatedSprite2D, set texture_filter to NEAREST and centered to false, and set offset to the negative `anchor` from animations.json. Position the node at the presentation event origin. Play `manifest` only in response to the existing simulation event. On animation_finished hide or release the sprite. Never resolve hits from animation frames.

These are mechanism-only exports of existing native art, rendered at 64px and enlarged 2x with nearest-neighbor sampling. They are not hand-authored pixel translations of the detailed illustrations. Initial and final frames are intentionally transparent. Retain procedural attack lines, target-dependent tethers and areas separately. Cable's baked 72-unit reach is only a preview; integration must keep its real endpoint authoritative. Bell/Censer are upright sprites, so arbitrary rotation is not a substitute for directional art.

Nailer: 380ms; Mercy Rail: 560ms; Bell: 460ms; Cable: 500ms; Censer: 520ms. Frame sampling follows the native presentation curve. Normal and reduced can be identical when there are no optional particles in that mechanism.

## Rebuild and validate

Run `godot --path . --script res://tools/bake_relic_assets.gd` from the repository. Import with `godot --headless --editor --path . --import`, then run `godot --headless --path . --script res://tests/test_relic_assets.gd`. The bake writes assets in this folder; review changed outputs before committing.

All 120 cells passed alpha/border checks and all ten SpriteFrames loaded with the expected regions and timings. Painted illustrations contain transparent background pixels. Exact pixel-size visual recognition, four-weapon crowding and final art-style consistency still need an in-game comparison.

Next task: integrate and compare the Nailer illustration/sprite options in one actual shop and combat view before replacing procedural rendering.
