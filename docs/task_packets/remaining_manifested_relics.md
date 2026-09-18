# Task packet: P23 — remaining short-lived manifested relics

## Player-facing objective

Make Candle-Nailer, Hymn Coil, Altar Mortar and Penance Winch read as distinct physical remembered tools that briefly appear, visibly cause their existing attacks and disappear, including a legible four-weapon stress scene at the gameplay camera.

## Authority and command boundary

Simulation continues to own cooldowns, attack events, origins, targets, trajectories, areas, damage, healing, status, objective work, resources, RNG and saves. Presentation may read those events and bounded readiness to draw a tool body, moving mechanism, recoil, opacity and decorative particles. It must not delay, duplicate, redirect or otherwise change an outcome.

## Expected files

`game/main.gd`; `tests/test_weapon_presentation.gd`; `tests/capture_remaining_manifested_relics.gd`; both agent-iteration scripts; provenance metadata; roadmap/runtime/verification documentation; this packet.

## Preserved contracts and non-goals

Preserve the current Saint sprite; P21/P22 manifestations; persistent Procession Gear and Welded Halo lifetimes; all gameplay values and event payloads; saves; reduced-effects information; and 0.6 content. Do not add character attachment arms, imported runtime art, new weapons, balance, audio or Confluences.

## Deterministic acceptance

1. Each of the four relic bodies derives its origin, direction and shape from the matching authoritative attack event.
2. Candle-Nailer exposes a small wick-fed launcher before its existing curved projectile; Candle for the Unreturned exposes a larger three-wick form without changing target selection.
3. Hymn Coil visibly closes paired tuning forks into the existing beam; Quiet Sermon retains its wider separated lanes.
4. Altar Mortar braces, elevates its tube and emits a shell along the existing authored arc; Workshop Benediction retains its distinct ground seal.
5. Penance Winch turns a drum before its segmented hand reaches the recorded target; Long Hand remains visibly heavier and wider.
6. Permanent mounts are absent outside attack or bounded readiness windows, reduced effects retains mechanisms and gameplay boundaries, and presentation preserves simulation hashes.
7. A four-weapon actual-camera fixture keeps the Saint, nearby threats, endpoints and attack families distinguishable in full and reduced effects.

## Screenshot evidence

Capture Godot 4.5.1 configured executable states at 1280×800, seed 147: Candle-Nailer; Candle for the Unreturned; Hymn Coil/Quiet Sermon; Altar Mortar/Workshop Benediction; Penance Winch/Long Hand; and four-family overlap at full and reduced effects. Label every image `FIXTURE / P23`; these are not human playtests.

## Remaining limitation

Configured stills cannot establish normal-speed recognition, sound synchronization, aiming comfort or human preference.

## Exactly one next task

Run a normal-speed human readability pass across all manifested and persistent relic families, then tune only observed recognition, overlap and timing failures.
