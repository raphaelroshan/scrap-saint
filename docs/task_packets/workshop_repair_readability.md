# Next production packet: Workshop repair readability

Delivery status: implemented and verified; [final evidence](../evidence/repair-readability/review.md). Human acceptance remains open.

Status: IMPLEMENTED and native-verified. Prompt 3. Priority: observed feedback failure before the uncoached Workshop gate. Baseline capture: [Foreman final orders](../evidence/prompt0-audit/FOREMAN_FINAL_ORDERS.png).

## Player objective

Approach an optional machine, read its entire reward and optional nature, understand progress or why healing is deferred, recognize restoration, then leave and resume combat. This must remain readable near every viewport edge without hiding the Saint or hazard boundaries.

## Authority, files and contracts

Presentation owner: game/main.gd draw_optional_machines and the existing camera/arena coordinate conversion. game/actor_art.gd remains read-only rendering. Simulation repair progress, reward, cancellation/deferral and completion remain authoritative and unchanged.

Expected implementation files: game/main.gd; tests/test_actor_art.gd (or one focused layout test if clearer); tests/capture_actor_art.gd. Records: roadmap.md; docs/production_state.md; docs/agent_memory.md; docs/qa_current.md; docs/runtime_status.md; docs/asset_provenance.md; docs/CHANGELOG.md; this packet; new docs/evidence/repair-readability/*.

Preserve IDs, text meaning, reward amounts, radius, timings, enemy/warning geometry, state hashes, saves, optional repair rules and all command boundaries. Use measured wrapping and bounded placement in the correct coordinate space; choose a compact presentation after inspecting existing camera helpers. Do not move machines or truncate the reward to disguise overflow.

## Non-goals

No mandatory relay, new repair mechanic, shop service, balance adjustment, boss redesign, new art, global HUD redesign or unrelated defect cleanup.

## Acceptance and verification

1. Show all three Workshop machines at central and edge camera positions: idle benefit, active progress, completed state; include Coolant Pump at full integrity (deferred) and after damage (eligible).
2. Leave and re-enter a repair zone. Feedback matches existing simulation behavior, clears stale progress/deferral and does not imply a failed or granted reward incorrectly. Do not prescribe changed cancellation semantics.
3. At 1280x800 and 1920x1080, normal/large text and full/reduced effects, complete labels stay inside the visible playfield; the associated machine remains identifiable. Foreman warning circles and the Saint remain readable.
4. Focused geometry tests establish bounded text layout from actual font measurement; capture scripts assert presentation does not mutate simulation hashes. Existing optional-repair and actor tests verify unchanged outcomes. Do not rely only on string snapshots.
5. Run content validation, Godot import, tests/test_optional_repairs.gd, tests/test_actor_art.gd, tests/test_simulation.gd and relevant presentation tests, then scripts/agent_iteration.ps1 with its declared Godot parameter. Explicitly run menu/actor suites absent from that runner. Inspect its resulting native captures and score the repository visual rubric. A timeout is not a pass.
6. Launch the normal-speed build and exercise approach → repair/deferral → restoration → departure; if only automated native input is available, label it honestly. Capture before/after idle Bell near right edge, active repair, deferred healing, completed reward, departure, and overlapping Foreman hazards. Record exact commands, commit, viewport, seed, state hashes and capture method.

## Stopping condition and limitation

Finish only when the whole interaction is legible and all relevant gates pass; repair obvious failures within this slice before reporting. No presentation-driven state changes. Screenshots alone cannot establish human comprehension or reaction time. Do not call the creative vertical accepted.

## Exactly one next task

Conduct the uncoached 1x Workshop acceptance session already required by the roadmap, recording setup, optional work, shop reasoning, elite/boss understanding and failure/retry observations.
