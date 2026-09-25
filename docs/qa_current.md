# Current QA — Prompt 0 audit, 2026-09-25

Runtime source: `3464991`; build 0.6.0-preview; Godot 4.5.1 stable, Compatibility OpenGL 3.3, NVIDIA RTX 4060 driver 616.92, Windows. No gameplay changes were made after capture. [Evidence and hashes](evidence/prompt0-audit/review.md).

## Fresh commands and results

Commands below ran from the repository in PowerShell. Each invocation exited 0. Logs are retained in the evidence directory as .txt files.

```powershell
$godot = '../.runtime/godot/Godot_v4.5.1-stable_win64_console.exe'
$python = 'C:/Users/Raph/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
& $godot --headless --path . --editor --import --quit
& $python scripts/validate_content.py
& $godot --headless --path . --script tests/test_main_menu.gd
& $godot --headless --path . --script tests/test_menu_panels.gd
& $godot --headless --path . --script tests/test_actor_art.gd
& $godot --headless --path . --script tests/test_road_echoes.gd
& $godot --headless --path . --script tests/test_simulation.gd
& $godot --headless --path . --script tests/test_checkpoint_lifecycle.gd
& $godot --path . --resolution 1280x800 --script tests/capture_core_quality.gd
& $godot --path . --script tests/capture_main_menu.gd
& $godot --path . --resolution 1280x800 --script tests/capture_actor_art.gd
```

Import completed with no SCRIPT ERROR or ERROR entries. Content validation passed (25 items, 10 Evolutions, 4 Blessings, 3 frames, 7 enemy catalogue entries, 7 boss catalogue entries; catalogue totals are not the enabled ordinary-enemy count).

| Fresh suite | Checks | Failures |
| --- | ---: | ---: |
| Main menu | 32 | 0 |
| Menu panels | 81 | 0 |
| Actor art | 137 | 0 |
| Road echoes | 86 | 0 |
| Simulation | 31 | 0 |
| Checkpoint lifecycle | 33 | 0 |
| Total | 400 | 0 |

Native core-quality policy: seed 147, Workshop Gospel, repair-seeking, normal economy, 12 shops, expedition won through Brass to Pale Archive. The fixture advances fixed ticks automatically; this is not a human 1x run. Title and actor fixtures inject representative states and render the actual Godot scene. Selected images were inspected visually, not merely generated.

## Open findings

**P2 — optional repair benefit clips at arena edge.** Reproduce with the actor capture command above; inspect FOREMAN_FINAL_ORDERS at 1280x800. Warning Bell's description is cut off after “Stagger present or next-arriving ene…”. Expected: read the full benefit while retaining its machine association and unobscured warnings. Owner: game/main.gd, draw_optional_machines, currently unwrapped text at p + (-75, 76). Smallest candidate fix: measured wrapping and placement constrained to the visible playfield, accounting for camera transform. Regression: actual text bounds plus edge-camera normal/large-text captures, and unchanged simulation hashes. Status: open; [bounded packet](task_packets/workshop_repair_readability.md).

**Fixture cleanup warning.** Core-quality and some focused fixtures report ObjectDB instances leaked at exit. Exits remain 0; this is not a warning-free run. Do not infer a live-game leak rate from this warning alone. Resource-lifetime diagnosis remains pending.

**Coverage mismatch.** scripts/agent_iteration.sh includes test_actor_art; the Windows runner does not. Neither runner includes test_menu_panels. Both focused suites were run explicitly here. A single “full loop” total is not interchangeable across platforms/revisions.

**Unverified gates.** No fresh full regression matrix, all-four-route policy matrix, export/build-package smoke test, human session, physical controller test, audio listening review or sustained minimum-hardware measurement was performed. The headless import is a parse/resource check, not release packaging.

## Historical evidence, not rerun claims

[Road-echo validation](evidence/road-echoes/validation.json) records 86 story checks plus a 1,087-check Windows loop at the story implementation. [Actor validation](../assets/actors/evidence/validation.json) records the major-actor validation from its implementation. These are earlier deliveries, not additional checks from this audit. Do not sum their totals into the fresh 400.

## Disposition

Documentation verification: `python docs/evidence/prompt0-audit/verify_records.py` passes all 135 local links, verifies the original prompt pack is unchanged from 3464991 and checks all six screenshot SHA-256 hashes. `git diff --check` exits 0. These checks validate records, not gameplay.

Prompt 0 audit complete; creative vertical and release gates remain open. Documentation-only changes do not require another full gameplay matrix after the fresh source-baseline checks. Next implementation must run the full relevant presentation loop and inspect new captures before declaring the repair interaction complete.
