# Memory Crane and Foreman Engine painted presentation

Objective: make the Workshop elite and boss immediately identifiable as different industrial machines, with mechanical poses that communicate copy preparation, demolition scheduling, worker calls and final pressure before their authoritative effects resolve.

Owner: presentation in `game/actor_art.gd` and `game/main.gd`. Existing simulation state owns phase, hazards, copied geometry, movement, attacks, summons, health, damage and rewards; the renderer reads that state and never changes it.

Files: `assets/actors/major_assemblies.json`; `assets/actors/README.md`; `assets/actors/evidence/**`; `game/actor_art.gd`; `game/main.gd`; `tests/test_actor_art.gd`; `tests/capture_actor_art.gd`; `scripts/agent_iteration.sh`; `docs/art_direction.md`; `docs/asset_provenance.md`; `docs/runtime_status.md`; `roadmap.md`; this packet.

Implementation: build two layered painted bodies from licensed project sources without rotating or mirroring their baked lighting. Memory Crane uses a tracked service chassis, high mast and descending hook; its arm extends toward an active copied hazard. Foreman Engine uses a heavy press body whose shutter, ram and signal lamps select schedule, worker-call and final-order states. Small deterministic servo motion may interpolate within a selected state. Reduced effects keeps silhouette and gameplay tells while suppressing decorative oscillation and sparks.

Preserve the existing Saint, ordinary actors, collision radii, movement, boss health/phase thresholds, hazard locations and timing, copy geometry, worker spawning, damage, status overlays and boss HUD. The new sheets are presentation assets, not new simulation states. Do not rotate or mirror painted lighting, add collision, or use animation to conceal a gameplay tell.

Acceptance: both stable IDs map to valid alpha regions and three declared states; each state remains inside its declared gameplay extent and shares a stable pivot. Elite copy preparation follows a real hazard sourced from that elite. Foreman visuals follow authoritative phase and active demolition warnings. Stun and reduced-effects behavior remain readable. Drawing either actor leaves the simulation hash unchanged. Run the focused actor suite, full autonomous loop and policy matrices. Capture Memory Crane idle/copy and Foreman schedule/workers/final-orders in normal and reduced-effects modes at 1280x800, seed 147; record build, renderer, source hashes and capture hashes, then inspect and score the rendered states.

Limitation: the bodies are deterministic composites of the repository's existing generated painted machinery rather than newly generated bespoke paintings because the built-in image generator is unavailable in this session. Normal-speed human recognition and reaction timing remain unverified.

Next task: run an uncoached human 1x Workshop session and tune only observed elite/boss recognition, telegraph timing and overlap failures.
