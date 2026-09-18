# Task packet: P22 — manifested Bell, Cable and Foundry Censer

## Player-facing objective

Make three more relics readable as physical remembered tools: a struck Bell that causes its arcs, a clamp-and-reel Cable that causes its tether, and a hanging filter Censer that rocks before venting its low field.

## Authority and command boundary

Simulation continues to own attack timing, origin, target, cone, tether, smoke radius, status, damage, control, resources, RNG and saves. Presentation reads existing attack events and bounded readiness only; it may draw mechanisms, recoil, sway, opacity and decorative particles without delaying or duplicating an outcome.

## Expected files

`game/main.gd`; `tests/test_weapon_presentation.gd`; `tests/capture_manifested_relics.gd`; both agent-iteration scripts; provenance metadata; test/runtime/roadmap documentation; this packet.

## Preserved contracts and non-goals

Preserve the Saint sprite, all gameplay values and event payloads, P21 Nailer/Mercy behavior, saves, menu and 0.6 content. Do not add character mounts, imported runtime art, new weapons, balance, audio or Confluences. Remaining relic families stay out of this packet.

## Deterministic acceptance

1. Bell, Cable and Censer manifestations use their matching authoritative attack origin and geometry.
2. Bell hammer contact precedes the visible cone/radial resolve within its existing presentation window.
3. Cable clamp reaches the recorded endpoint while its reel responds; Lattice remains unchanged.
4. Censer body hangs and rocks while its vented field preserves the authored radius.
5. The three relic bodies are absent outside attack or bounded readiness windows.
6. Reduced effects retains physical mechanisms and gameplay boundaries, and presentation preserves state hashes.

## Screenshot evidence

Capture Godot 4.5.1 configured executable states at 1280×800, seed 147: Bell strike; Great Toll; Cable clamp; Censer vent; three-family overlap; reduced overlap. Label every image `FIXTURE / P22`; these are not human playtests.

## Remaining limitation

Configured stills do not establish normal-speed recognition, sound synchronization or comfort under human control.

## Exactly one next task

Manifest the remaining short-lived relic families and stress-test four-weapon overlap at the actual gameplay camera.

## Verification record

Clean implementation commit `86d1da47888ae20552d94c8bb211d51572fe387d` was tested and captured with Godot 4.5.1 stable at 1280×800, seed 147, using the Compatibility renderer on Apple M1 Pro. The complete suite passes 996 Godot assertions and thirty-one Python manifest checks. The 12/12 normal-economy, 4/4 assembly, 10/10 Evolution and 4/4 Gift policy suites remain green. Six configured P22 captures were inspected; they establish authoritative origin use, distinct Bell/Cable/Censer mechanisms, three-family overlap and reduced-effects parity, not human timing, audio or enjoyment.
