# Asset provenance

## P20 procedural presentation assets — 2026-09-17

- **Source / method:** Original code-native vector geometry drawn at runtime in `game/main.gd`; original PCM synthesis in `game/sound.gd`.
- **License / permission:** Created inside this repository for Scrap Saint; no third-party art, audio, texture, font file, model, or generated bitmap is redistributed.
- **Uses:** Title/loading tableau, Bodhi tree, six-armed maintenance Saint, cloud and city layers, living Workshop effects, enemy reaction poses, camera impulse, Evolution showcase, weapon/impact audio, title cue, boss cue and restoration cue.
- **Status:** Coherent prototype/final-direction reference; replace selectively only after human evaluation.
- **Known limitations:** Procedural geometry is intentionally graphic rather than painterly. Audio is synthesized and has not been human-mixed. System font fallbacks are referenced but not redistributed.

The image-generation workflow was evaluated for the title tableau, but its built-in generator was unavailable in the implementation session. The API-key fallback was not authorized, so no generated raster was created or claimed. The shipped tableau instead uses separable procedural layers that already support eye opening, tool activation, cloud parting, city reveal, reduced effects, and crop-safe runtime animation.

## Painted main-menu preview — 2026-09-17

`assets/title/meditation.png` and `awakening.png` were generated with the built-in OpenAI image tool for this project from the original Bodhi-tree brief. Awakening is an edit of Meditation. No external reference artwork was used. Both show six arms, four repair tools and two empty lap hands. They are generated preview assets supplied for the user's project, not third-party stock under an asserted stock license. No guarantee of exclusive copyright is made. System fonts remain referenced, not redistributed.

The runtime uses the original PNGs as aspect-preserved textures with a presentation-only dissolve. These are flattened illustrations; individual limb animation is not implemented. The city is more ornate than the intended utilitarian factory world, and the lap hands meet rather than clearly face upward. Keep these mismatches visible in future art review. Asset hashes and generator output identifiers are in assets/title/provenance.json.

## Relic asset pack — 2026-09-21

See assets/relic-pack/README.md and provenance.json. Two generated RGBA relic illustrations accompany ten Godot-baked pixel mechanism strips and SpriteFrames resources. The illustrated Nailer received a transparency edit; RGB under zero-alpha pixels may retain background colors and should never be displayed without alpha compositing. Native sheets reuse existing repository geometry at a fixed low-resolution render size; they are not generated animation guesses or hand-painted sprite atlases. These are reusable preview assets, not replacements already enabled in gameplay.
