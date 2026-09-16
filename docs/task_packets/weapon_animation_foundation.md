# Task packet: P18 — weapon animation foundation

## Player-facing objective

Make Nailer/Mercy Rail and Bell/Great Toll attacks feel like physical industrial mechanisms while keeping their line, cone, and radial outcomes readable during overlapping combat.

## Authority and command boundary

The deterministic simulation continues to own weapon readiness, target selection, geometry, hits, damage, Mark, stagger, push, repair, and Evolution state. `game/main.gd` owns only a presentation clock, physical relic drawing, staged attack effects, deterministic decorative particles, recoil, and reduced-effects rendering. Presentation reads authoritative attack events and never changes simulation state.

## Files

- `game/main.gd`
- `tests/test_weapon_presentation.gd`
- `tests/capture_weapon_animation.gd`
- `scripts/agent_iteration.sh`
- `scripts/agent_iteration.ps1`
- `tests/README.md`
- `docs/runtime_status.md`
- `docs/verification_0_1.md`
- `docs/task_packets/weapon_animation_foundation.md`

## Preserved contracts and non-goals

- Preserve every weapon value, target rule, cooldown, status duration, rank behaviour, Evolution rule, save format, event order, and policy outcome.
- Do not add animation-owned targeting or delayed presentation-owned damage.
- Do not add imported art, new weapons, Confluences, Vows, Boss Imprints, currencies, or screen transitions.
- Scope physical mechanism work to Nailer/Mercy Rail and Bell/Great Toll; other weapon geometries retain their current renderer.
- Reduced effects must retain the attack boundary, endpoint, and status communication.

## Deterministic acceptance tests

1. Presenting an attack adds presentation state without changing the simulation hash.
2. Nailer, Mercy Rail, Bell, and Great Toll use authored presentation durations and deterministic phase progress.
3. The latest matching attack controls only its own physical mount recoil/commit state.
4. Rank and Evolution identity remain available to the renderer through existing event fields.
5. Reduced-effects mode changes decorative density, not core geometry or authoritative state.
6. All existing content, Godot, policy, save/replay, and packaging tests remain green.

## Screenshot states and provenance

Capture configured executable states at Godot 4.5.1, 1280×800, seed 147 in `artifacts/weapon-animation`: Nailer commit, Mercy Rail resolve, Bell commit, Great Toll resolve, Nailer/Bell overlap, and the same overlap with reduced effects. Every image must show the exact build and `FIXTURE / P18` label. Inspect all six and record the visual rubric here.

## Evidence recorded — 2026-09-16

Commit `1fe4efd991429b29aff2e0973a70cc6920fb3ce5` was captured from a clean worktree with Godot 4.5.1 stable, OpenGL Compatibility on Apple M1 Pro, at 1280×800 and seed 147. All six configured executable states were inspected. Nailer now reads as a shoulder-mounted industrial tool with a traveling fastener, staged aim line and deterministic brass discharge. Mercy Rail widens that language into a split, braced lane. Bell visibly compresses its mounted striker before expanding cone pressure; Great Toll replaces it with a full radial brass boundary and cardinal impacts. The overlap fixture keeps straight-line and cone silhouettes separable, while reduced effects preserves boundaries and hit/status cues without decorative sparks.

Rendered-evidence rubric (5-point internal review): physical authorship 4, base/Evolution distinction 5, geometry readability 5, overlap hierarchy 4, reduced-effects parity 4, palette/coherence 4. These scores describe configured stills, not player preference or timing feel.

The complete repository loop passes 853 Godot assertions and thirty-one Python manifest checks. The normal-economy matrix wins 12/12, the frame/Blessing/first-route matrix 24/24, assembly 4/4, Evolutions 10/10 and Gift-specific routes 4/4. Presentation-state tests additionally verify that rendering does not mutate the simulation hash.

## Remaining limitation

Configured stills can prove geometry and layering, not whether the timing feels responsive in a human-controlled run. Other weapon families still lack the complete four-beat mechanism treatment.

## Exactly one next task

Run a human-controlled 1× combat session with Nailer/Bell at Ranks I–III and both Evolutions, then tune anticipation and effect persistence from motion readability.
