# Task packet: P20 — game-feel and presentation release pass

## Player-facing objective

Make Scrap Saint feel alive before, during, and after combat through a devotional loading tableau, stronger mechanical sound, moving workshop atmosphere, readable enemy reactions, restrained impact response, and a premium Evolution reveal.

## Authority and command boundary

The deterministic simulation retains ownership of movement, target selection, hit timing, damage, control, repair, Evolution eligibility, clocks, RNG, saves, and all outcomes. `game/main.gd` may derive camera impulse, pose, particles, title transition, environment motion, and Evolution overlays from existing simulation state/events. `game/sound.gd` synthesizes presentation-only audio. The title transition may delay entry to setup, but never advances or pauses an active simulation.

## Exact files expected to change

- `game/main.gd`
- `game/sound.gd`
- `tests/test_presentation_quality.gd`
- `tests/test_ui.gd`
- `tests/test_flow_input.gd`
- `tests/capture_game_feel.gd`
- `scripts/agent_iteration.sh`
- `scripts/agent_iteration.ps1`
- `scripts/write_provenance.py`
- `tests/README.md`
- `content/slices/first_shift.json`
- `export_presets.cfg`
- `docs/asset_provenance.md`
- `docs/saint_loading_tableau.md`
- `docs/confluences_and_alternate_evolution_paths.md`
- `docs/weapon_evolution_trait_animation_map.md`
- `docs/weapons_merges_traits_expansion.md`
- `docs/runtime_status.md`
- `docs/verification_0_1.md`
- `docs/release_checklist.md`
- `docs/task_packets/game_feel_release_pass.md`

## Preserved contracts and non-goals

- Preserve every gameplay value, accepted command, event order, save field, policy outcome, and replay hash.
- Do not add hit-stop that pauses authoritative combat, gameplay camera displacement, new weapons, enemies, currencies, or imported third-party assets.
- Screen impulse is visual-only, small, bounded, and disabled by reduced motion/effects.
- The title tableau is original procedural Godot geometry because the built-in image generator is unavailable; do not claim generated key art.
- Audio remains original synthesized preview audio, not a final human-mixed soundtrack.
- Publishing is an unsigned Windows preview release, not store certification or minimum-hardware validation.

## Deterministic acceptance tests

1. Title transition progress is deterministic under the presentation clock and never starts the simulation before handoff.
2. Reduced effects removes camera impulse, local sparks, secondary steam, and cloud movement without hiding core state.
3. Presenting attack, hit, hurt, boss, repair, and Evolution events never changes the simulation hash.
4. Enemy pose helpers derive only from existing flash, stun, windup, charge, and presentation events.
5. Evolution showcase is entered only after an accepted Evolution command and expires without changing simulation state.
6. Every audio cue has a generated stream, obeys voice/rate limits, and introduces no external files.
7. All existing content, Godot, policy, save/replay, packaging, and boot-smoke checks remain green.

## Screenshot states and provenance

Capture configured executable states under `artifacts/game-feel` with Godot 4.5.1, 1280×800, seed 147: meditation title; eyes-open city reveal; enemy windup; weapon impact/reaction; premium Evolution reveal; living Workshop atmosphere; four-family combat; and reduced-effects combat. Every image must show exact build/viewport provenance and a `FIXTURE / P20` label. Inspect every image and score title identity, action readability, enemy response, environment depth, Evolution premium, overlap hierarchy, reduced-effects parity, palette coherence, UI hierarchy, and provenance.

## Evidence recorded — 2026-09-17

Clean commit `7f878def7a41d23af5194c548274463cb3e72866` was captured with Godot 4.5.1 stable, OpenGL Compatibility on Apple M1 Pro, at 1280×800 and seed 147. All eight P20 fixtures were inspected. The title preserves exactly six arms, four distinct maintenance tools and two empty lap hands across the eye-opening/cloud-parting transition. Combat captures show braced windup, directional hit recoil, local impact marks, active workshop machinery, premium Evolution presentation, and full/reduced four-family overlap.

Rendered-evidence rubric (5-point internal review): title identity 4, transition clarity 4, combat action readability 4, enemy response 4, environment depth 3, Evolution premium 4, overlap hierarchy 4, reduced-effects parity 4, palette/UI coherence 4, provenance clarity 5. Environment motion remains intentionally restrained and reads more strongly in motion than in a still.

All 892 Godot assertions and thirty-one Python checks pass. The normal-economy matrix wins 12/12, frame/Blessing/first-route 24/24, assembly 4/4, Evolutions 10/10 and Gift-specific routes 4/4. The scored rendered-evidence validator passes. No script-load, resource-load or assertion errors appear in the iteration logs.

## Remaining limitation

Automated captures and synthesized audio inspection cannot establish human-controlled timing feel, mix comfort, controller comfort, or rendered performance on Windows minimum hardware.

## Exactly one next task

Run an uncoached human 1× session on the packaged Windows build and record only observed timing, audio-mix, recognition, and performance failures.
