# Task packet: QA runner coverage

Delivery status: implemented and verified; [final evidence](../evidence/repair-readability/review.md). Human acceptance remains open.

## Player-facing objective

The complete automated iteration loop checks menu navigation, actor and repair presentation, and optional repair readability on both supported runner platforms before producing review captures.

## Authoritative owner and boundary

The runner scripts only invoke existing Godot test entry points and fail on nonzero exit. The simulation remains authoritative for game state; tests may inspect presentation but do not change runtime command boundaries.

## Exact files

- `scripts/agent_iteration.ps1`
- `scripts/agent_iteration.sh`
- `docs/task_packets/qa_runner_coverage.md`

## Preserved contracts and non-goals

Preserve test order where possible, distinct logs, fail-fast behavior, capture commands, provenance, and the meaning of each suite's printed check count. Do not alter runtime code, tests, visual assets, or prior QA totals. This packet does not declare the repair interaction accepted.

## Deterministic acceptance tests

1. Both runners invoke `tests/test_menu_panels.gd`, `tests/test_actor_art.gd`, and `tests/test_repair_readability.gd` exactly once in the headless test phase, with distinct logs.
2. Each added invocation stops the runner on a nonzero Godot exit; the existing test and capture invocations remain present.
3. Static syntax checks pass for PowerShell and Bash. The lead owner runs the full pipeline and inspects native capture evidence after the repair suite lands.

## Screenshot states and provenance

This runner-only change creates no screenshots. The full iteration loop retains its existing capture scripts and provenance writer, including build/commit, Godot version, viewport and scaling. The repair owner records the edge, progress, deferral and completion captures separately.

## Remaining limitation

Static runner checks cannot establish that the new repair test passes or that a player can read the interaction at 1× speed. Existing suite counts cannot be added to a new loop total without a fresh run.

## Exactly one next task

Run the complete iteration loop after `tests/test_repair_readability.gd` lands and inspect its native capture bundle.
