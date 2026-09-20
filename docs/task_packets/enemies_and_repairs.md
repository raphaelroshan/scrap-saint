# Painted enemies and Workshop repair stations

Objective: make all six ordinary enemies belong to the painted arena and make optional Workshop repairs visibly change three recognizable machines.

Owner: presentation in game/actor_art.gd and game/main.gd. Existing simulation owns enemy movement, attacks, support, statuses, repair progress, rewards and completion; no new commands or outcomes.

Files: assets/actors/**; game/actor_art.gd; game/main.gd; tests/test_actor_art.gd; tests/capture_actor_art.gd; assets/supporting-art/README.md; docs/art_direction.md; docs/asset_provenance.md; docs/runtime_status.md; roadmap.md; this packet.

Generate Rust Pilgrim, Forklift Brute and Cinder Spitter as separate transparent sprites, matching the three existing enemy sprites. Generate three paired-state repair sheets: Salvage Sorter, Coolant Pump, Warning Bell, with matched broken/restored silhouettes. Read the repairing state from actual active-machine/progress data, adding restrained welding feedback. Keep repair art compact inside the existing interaction ring; it does not introduce collision.

Preserve the current Saint, boss/elite renderer, movement geometry, optional repairs, enemy tells, damage flashes and status markers. Use stable normalized pivots and game-scale extents. Do not rotate or mirror baked lighting to fake directional poses. Whole-body motion and engine-drawn mechanisms are presentation studies; no claim of articulated gait or complete directional coverage.

Acceptance: all six ordinary enemy IDs and three repair IDs map to valid alpha regions; sprite bounds stay within declared extents; broken/working/restored selection follows authoritative state; reduced effects suppress decorative motion; drawing does not mutate state. Run full autonomous loop and focused actor checks. Capture roster, actual combat, reduced effects and all three repair states at 1280x800, seed147, recording source hashes and viewport. Inspect small-size readability and repair state differences.

Limitation: fixed-view flattened enemy sprites; bosses/elite and destination objectives remain procedural. Repair hardware differences are subtle at 64 pixels and depend on accompanying progress/check markers. Existing long Warning Bell reward text can clip near the viewport edge. Human normal-speed readability remains unverified.

Verification: 57 focused actor checks pass. Inspected all 11 native captures, including full/reduced roster and broken/working/restored states for each machine. Both roster modes share the same simulation hash. Source and capture hashes, generation prompts and a scored 10-point visual rubric are stored under assets/actors.

Full autonomous loop completed with exit 0: 1087 checks across 26 suites reported zero failures, followed by automated playthroughs and native captures. Scored evidence validation passes. Existing ObjectDB shutdown leak warnings remain in some fixture scripts. Also inspected the natural repair-policy capture and Foreman combat fixture; these are automated evidence, not human playtests.

Next task: give the Memory Crane and Foreman Engine painted bodies and state-driven mechanical animation.
