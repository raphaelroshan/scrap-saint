# Asset provenance

## Painted Workshop major assemblies — 2026-09-21

Memory Crane and Foreman Engine are deterministic, non-destructive runtime composites of project-owned generated PNGs already documented in the actor, environment and supporting-art manifests. `assets/actors/major_assemblies.json` records exact texture paths, source regions, display extents and SHA-256 source hashes. Components are translated and scaled only; none are rotated or mirrored, preserving their baked upper-left lighting. Code-native arms, hooks, rams, lamps, hatches and jaws add state communication without producing gameplay outcomes.

The built-in image generator was unavailable during this implementation session, and the API fallback was not authorized, so no newly generated bitmap is claimed. The composites are a coherent runtime replacement for the procedural gear placeholder; unique bespoke paintings remain a future production opportunity.

## Painted actors — 2026-09-21

Six original OpenAI image-generation outputs add Rust Pilgrim, Forklift Brute, Cinder Spitter and paired broken/restored sheets for Salvage Sorter, Coolant Pump and Warning Bell. The existing generated Rivet Hound was the material reference. Three earlier enemy PNGs are reused directly. Exact prompts, generator output IDs, references and hashes are in `assets/actors/sources.json` and `manifest.json`. Original PNGs are copied unchanged; Python only inspects alpha bounds. Runtime region drawing, servo/hover offsets, progress and welding sparks are code-driven presentation. No external game artwork was used.

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

## Supporting painted pack — 2026-09-21

`assets/supporting-art` contains nine cutouts generated with the built-in OpenAI image tool, using this project’s `assets/concepts/visual-target/arena-target.png` solely as a material/style reference. Each image has its own subject prompt. Original output identifiers, descriptions, sizes, alpha bounds and SHA-256 hashes accompany the assets. No third-party reference art was introduced. Source PNGs are copied unchanged; Pillow only inspects them. Faint alpha noise outside the silhouette is retained, with alpha >16 bounds used for display sizing.

Godot AnimationPlayer scenes animate whole sprites; these are original presentation motion studies, not hand-painted multi-frame gait animations. Captures are isolated asset previews at 1440x1000, not evidence of gameplay integration. The existing Saint and gameplay renderer are unchanged.

## Integrated arena materials — 2026-09-21

Four generated environment PNGs (floor, salvage press, cold furnace and horizontal service manifold) are supplied in `assets/environment`, with exact prompts and original output IDs in `sources.json`. They reference only the project's existing generated arena concept. Source PNGs are untouched; alpha bounds are inspected for aspect-preserved runtime drawing. Existing supporting-art Scrap and Repair Kit images now render field pickups; Relic Shard and Scrap artwork also render in the currency HUD. This pass does not change healing mote identity, add currencies or replace the Saint. The environment README documents scale, lighting, footprint and layering rules.
