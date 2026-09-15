# Scrap Saint tests and evidence

## Content checks

The runtime tests now exist. Run the complete Windows loop with `scripts/agent_iteration.ps1 -GodotBin <path> -PythonBin <path>`, then inspect the captures and score the report. On other platforms use `GODOT_BIN=godot bash scripts/agent_iteration.sh`.

- `python tests/test_slice_manifest.py`: four manifest acceptance/rejection tests.
- `godot --headless --path . --script res://tests/test_simulation.gd`: 31 deterministic simulation checks.
- `godot --headless --path . --script res://tests/test_chapter.gd`: deterministic route, travel, carryover, objective, memory, and chapter save checks.
- `godot --headless --path . --script res://tests/test_ui.gd`: seven UI flow/save checks using actual button signals and a temporary save file.
- `godot --headless --path . --script res://tests/run_playthroughs.gd`: four shared-seed normal-economy policies, including no-evolution Workshop. Results are saved separately from visual fixtures.
- `godot --headless --path . --script res://tests/benchmark_peak_density.gd`: records deterministic simulation throughput with 65 persistent threats and four Rank III weapons. It is not a rendered-frame benchmark.
- Add `-- --optional --quick` to smoke one normal-economy policy through each destination without running the full twelve-policy matrix.

Rendered fixtures use explicit setup budgets/states, including a Results fixture. They are not screenshots of the full-run policies. The earlier list below remains a broader target, not a claim all planned mechanics are implemented. See `docs/runtime_status.md` for scope differences.

SC-15 adds five rendered chapter fixtures: `ROUTE_CHOICE`, `TRAVEL_BRASS`, `BRASS_OBJECTIVE`, `ROOTWORKS_OBJECTIVE`, and `CHAPTER_MEMORY`. They are explicit deterministic presentation fixtures, not a natural completed expedition.

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
11. Memory Crane copies Mercy Rail through the public command boundary; unrelated Evolutions do not silently become rails.
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

P12: `test_variety.gd` covers beam/cluster damage, cooldowns, ally healing, bombardment timing/evasion, brute displacement and save replay. `capture_variety.gd` renders three explicit optional-mode fixtures in `artifacts/variety`. The PowerShell loop now selects the main optional mode for full-run policies; a loss still fails its all-win gate.

P12 core-quality gate: `test_roaming_quality.gd` covers authored wave profiles, opening contact metrics, weapon role/weakness data, useful repair economy, Foreman route phases/workers and causal Results. `run_playthroughs.gd -- --optional` reports damage by source/wave, weapon contribution/ranks, shop transactions, repair metrics and result classification for 12 normal-economy policies. `capture_core_quality.gd` records seed-147 Workshop Gospel repair-decision, reward and Results states in `artifacts/core-quality`; these are time-compressed deterministic policy traces labelled `NATURAL POLICY TRACE`, not human play.

P14 replayable assembly: `test_assembly.gd` covers Foundry Censer, Penance Winch, Welded Halo, Great Toll, two unique Gift slots, save restoration, Gift trade-offs, independent evolution tracking and destination-safe Workshop repair ownership. `run_assembly_playthroughs.gd` executes four controlled-start build identities through complete seed-147 runs; these prove executable viability, not natural acquisition or human balance. `capture_assembly.gd` renders the three configured 1280x800 assembly states in `artifacts/assembly`.

Peak-density simulation benchmark: Apple M1 Pro, Godot 4.5.1, 65 persistent mixed threats, four Rank III weapons and 1,800 fixed ticks completed at 329 simulation ticks/second (5.48× the 60 Hz requirement). This measures authoritative simulation throughput only; rendered Windows minimum-hardware performance remains unverified.
