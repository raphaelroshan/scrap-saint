# Asset provenance

## P20 procedural presentation assets — 2026-09-17

- **Source / method:** Original code-native vector geometry drawn at runtime in `game/main.gd`; original PCM synthesis in `game/sound.gd`.
- **License / permission:** Created inside this repository for Scrap Saint; no third-party art, audio, texture, font file, model, or generated bitmap is redistributed.
- **Uses:** Title/loading tableau, Bodhi tree, six-armed maintenance Saint, cloud and city layers, living Workshop effects, enemy reaction poses, camera impulse, Evolution showcase, weapon/impact audio, title cue, boss cue and restoration cue.
- **Status:** Coherent prototype/final-direction reference; replace selectively only after human evaluation.
- **Known limitations:** Procedural geometry is intentionally graphic rather than painterly. Audio is synthesized and has not been human-mixed. System font fallbacks are referenced but not redistributed.

The image-generation workflow was evaluated for the title tableau, but its built-in generator was unavailable in the implementation session. The API-key fallback was not authorized, so no generated raster was created or claimed. The shipped tableau instead uses separable procedural layers that already support eye opening, tool activation, cloud parting, city reveal, reduced effects, and crop-safe runtime animation.
