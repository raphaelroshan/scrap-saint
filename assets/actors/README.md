# Painted Workshop actors and repairs

Memory Crane and Foreman Engine now join the ordinary roster as layered painted bodies. The Crane combines a freight chassis, service boom and inspection lens; its articulated hook points toward the authoritative copied hazard. The Foreman combines a freight chassis, demolition press and warning bell; phase data selects Schedule, Worker Call and Final Orders poses, lamps, hatches and jaws. No painted source is rotated or mirrored. `major_assemblies.json` records every component region, extent and source hash.

All six ordinary enemy families now render with painted sprites in gameplay. This pack adds Rust Pilgrim, Forklift Brute and Cinder Spitter and reuses Scrap Mite, Rivet Hound and Choir Drone from supporting-art. The Saint and manifested weapons retain their existing presentation.

Salvage Sorter, Coolant Pump and Warning Bell each use a paired broken/restored sheet. Working uses the broken frame with simulation-driven progress and restrained welding sparks. Completion switches artwork and adds a mint check. These compact fixtures remain optional and nonblocking; existing simulation code owns every timer and reward.

[Open the native gameplay review](review.html). The captures use the real renderer at 1280x800, seed 147. Major states and the roster are configured stress fixtures; repairs progress through actual simulation updates. Screenshots are not human playtesting.

## Integration

`game/actor_art.gd` caches textures and reads `manifest.json`. Extents range from 28 pixels for the Mite to 68 for the Brute; fixtures use 64 pixels. Aspect ratio and painted lighting are preserved. Enemy attack warnings, support fields, statuses and health bars remain. Small whole-body servo/hover motion pauses during windup or stun; reduced effects suppress this decorative motion and welding sparks.

`sources.json` records exact generation prompts and source IDs. PNGs are unmodified generator output. `build_manifest.py` inspects alpha and computes regions only; it never resamples or edits images. Repair cells use common bounds to preserve their scale and pivot across completion. Run it from the repository root with Python/Pillow.

## Validation and limits

137 focused checks pass, including all enemy and major mappings, source bounds, authoritative major-state selection, real repair transitions, reduced motion and unchanged state hashes after drawing. The full loop passes 1,224 Godot assertions across 27 suites plus 34 Python checks. Full-loop results and the scored review are recorded in the task packet and evidence folder.

Ordinary enemies remain fixed-view flattened sprites without directional gait. The two major bodies deliberately reuse generated project-painted modules because no image generator was available in this implementation session; bespoke paintings remain a production opportunity. Fine repair details are subtle at gameplay scale, and destination bosses/objectives remain procedural. Human 1x readability testing remains outstanding.

Next task: Run an uncoached human 1x Workshop session and tune only observed elite/boss recognition, telegraph timing and overlap failures.
