# Painted enemies and Workshop repairs

All six ordinary enemy families now render with painted sprites in gameplay. This pack adds Rust Pilgrim, Forklift Brute and Cinder Spitter and reuses Scrap Mite, Rivet Hound and Choir Drone from supporting-art. The Saint and manifested weapons retain their existing presentation.

Salvage Sorter, Coolant Pump and Warning Bell each use a paired broken/restored sheet. Working uses the broken frame with simulation-driven progress and restrained welding sparks. Completion switches artwork and adds a mint check. These compact fixtures remain optional and nonblocking; existing simulation code owns every timer and reward.

[Open the native gameplay review](review.html). The 11 captures use the real renderer at 1280x800, seed 147. The roster is a configured stress fixture; repairs progress through actual simulation updates. Screenshots are not human playtesting.

## Integration

`game/actor_art.gd` caches textures and reads `manifest.json`. Extents range from 28 pixels for the Mite to 68 for the Brute; fixtures use 64 pixels. Aspect ratio and painted lighting are preserved. Enemy attack warnings, support fields, statuses and health bars remain. Small whole-body servo/hover motion pauses during windup or stun; reduced effects suppress this decorative motion and welding sparks.

`sources.json` records exact generation prompts and source IDs. PNGs are unmodified generator output. `build_manifest.py` inspects alpha and computes regions only; it never resamples or edits images. Repair cells use common bounds to preserve their scale and pivot across completion. Run it from the repository root with Python/Pillow.

## Validation and limits

57 focused checks pass, including all enemy mappings, texture bounds, real repair transitions, reduced motion and unchanged state hashes after drawing. Full-loop results and the scored review are recorded in the task packet and evidence folder.

Fixed-view flattened sprites, not articulated or directional gait. Fine repair details are subtle at gameplay scale; state markers carry completion clarity. Bosses, elite and destination objectives remain procedural. Human 1x readability testing remains outstanding.

Next task: Give the Memory Crane and Foreman Engine painted bodies and state-driven mechanical animation.
