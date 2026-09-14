# Scrap Saint tests and evidence

## Content checks

Run:

```bash
python3 scripts/validate_content.py
```

This verifies stable IDs, cross-references, Blessing starting guarantees, evolution base/catalyst references, enemy counter contracts, and boss phase/reward contracts.

## Deterministic simulation tests

When the Godot runtime exists, the authoritative test suite must cover:

1. Identical seed plus command stream produces identical checkpoint hashes.
2. Movement is clamped to arena bounds.
3. Weapon targeting follows its data-defined rule.
4. Damage, repair, status application, status expiry, and objective progress are deterministic.
5. Scrap and Relic Shards are awarded exactly once.
6. Shop rolls and rerolls reproduce after save/load.
7. Buy, sell, dismantle, combine, reserve, repair, and rejection reasons are stable.
8. Blessing shop bias changes offers without changing the seed contract.
9. Mercy Rail requires Rank 3 Nailer plus Saint’s Rivet.
10. Evolution changes geometry/effects and emits a stable transformation event.
11. Memory Crane copies the last evolution through the public command boundary.
12. Foreman Engine phase transitions and demolition telegraphs reproduce.
13. Save/load resumes the same wave, shop, objective, and boss state.
14. Replay identifies the first divergent event when a command is changed.

## Presentation evidence

Each meaningful UI, visual, audio, or vertical-slice change must include a real running capture with:

- Repository commit and build identifier.
- Godot version.
- Exact viewport and scaling settings.
- Seed and replay/command identifier.
- State name.
- Screenshot or short capture of the real runtime.
- Test result and duration.
- Visual critique scores.
- One remaining limitation.
- Exactly one next task.

Content validation is not gameplay evidence. A planned scenario is not an executed scenario. A timeout remains `TIMEOUT_PARTIAL`.

## Visual smoke states

The first runtime should capture these named states:

- `WORKSHOP_BLESSING_SELECT`.
- `RELAY_REPAIR_WAVE`.
- `SHOP_MERCY_RAIL_PATH`.
- `MERCY_RAIL_EVOLUTION`.
- `FOREMAN_ENGINE_PHASE_TWO`.
- `RESULTS_MEMORY_FRAGMENT`.

The visual rubric should check Saint silhouette, enemy direction, objective state, attack geometry, status readability, shop clarity, evolution transformation, effect density, palette consistency, and provenance.
