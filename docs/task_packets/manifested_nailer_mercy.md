# Task packet: P21 — manifested Nailer and Mercy Rail

## Player-facing objective

Make the Nailer of Small Mercies look like a recognizable repaired tool that briefly manifests, performs its mechanism and disappears, while Mercy Rail visibly unfolds that same humble tool into a longer two-guide structural joiner.

## Authority and command boundary

The deterministic simulation continues to own attack cadence, origin, target, geometry, rank, damage, repair effects, hits, RNG and saves. Presentation reads existing attack events and weapon readiness only. It may choose drawing phase, recoil, carriage position, material, opacity and decorative sparks; it must not delay, duplicate or redirect an attack.

## Expected files

- `game/main.gd`
- `tests/test_weapon_presentation.gd`
- `tests/capture_manifested_nailer.gd`
- `scripts/agent_iteration.sh`
- `scripts/agent_iteration.ps1`
- `scripts/write_provenance.py`
- `tests/README.md`
- `docs/runtime_status.md`
- `roadmap.md`
- this packet

## Preserved contracts and non-goals

Preserve the current Saint sprite, weapon rules, all event payloads, reduced-effects gameplay information, main-menu art, save format and 0.6 content. Do not add attachment arms, mount sockets, new weapons, balance changes, imported runtime art, new audio or alternate attack timing. Bell, Cable, Censer and the other families remain follow-up work.

## Deterministic acceptance

1. Presentation derives the manifestation origin and direction from the authoritative Nailer attack event.
2. Base Nailer and Mercy Rail expose distinct deterministic phase data: compact driver versus unfolded dual guides and travelling carriage.
3. The relic is absent outside an attack or bounded readiness window; no permanent Nailer silhouette remains on the Saint.
4. Normal and reduced effects retain the driver, muzzle, line boundary and target endpoint; reduced effects removes only decorative sparks and glow.
5. Facing changes and movement after an attack do not move the already-emitted manifestation away from its recorded origin.
6. Presenting and drawing the slice leave the simulation state hash unchanged, and every existing deterministic suite remains green.

## Screenshot evidence

Capture configured executable states under `artifacts/manifested-nailer` with Godot 4.5.1, 1280×800 and seed 147: base Nailer preparation; base commit; Mercy Rail guide unfold; Mercy Rail resolve after the Saint has moved and changed facing; normal overlap; and reduced-effects overlap. Every image is labelled `FIXTURE / P21`; these are not human playtests.

## Remaining limitation

Configured stills cannot establish human recognition, perceived recoil timing, audio synchronization or comfort at normal speed.

## Exactly one next task

Manifest Bell, Cable and Foundry Censer with the same event-driven boundary and actual-camera capture gate.

## Verification record

Clean implementation commit `4b65b6915d154ebb08393141ac50e642bcecbbb8` was tested and captured with Godot 4.5.1 stable at 1280×800, seed 147, using the Compatibility renderer on Apple M1 Pro. The full suite passes 993 Godot assertions and thirty-one Python manifest checks. The normal-economy, assembly, Evolution and Gift policy suites remain green. Six configured P21 captures were inspected; they establish event-origin stability, compact-versus-unfolded silhouette, threat overlap and reduced-effects parity, not human timing or enjoyment.
