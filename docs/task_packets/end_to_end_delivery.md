# End-to-end playable delivery — 2026-09-25

Delivery status: implemented and verified; [final evidence](../evidence/repair-readability/review.md). Human acceptance remains open.

User authorization: continue implementation, break work into bounded tasks and delegate to GPT-6 Sol. This packet sequences existing-game completion; it does not authorize broad content expansion while feedback or recovery is broken.

## Player objective

Launch the normal game, start an expedition, make combat/shop/road decisions, complete a three-site route or recover from defeat, and start again. Deliver a locally launchable Windows preview with truthful evidence of its flow.

## Sequence and delegated ownership

1. **Repair interaction:** GPT-6 Sol implementation agent owns game/main.gd and focused repair layout tests/captures under the existing Workshop repair-readability packet. Finish approach, progress/deferral, reward and departure feedback first.
2. **Independent flow audit:** GPT-6 Sol reviewer inspects title/setup/shop/travel/arrival/Results/retry/save paths and reports concrete blockers without editing shared code. Any actual additional blocker gets a separate bounded packet before correction.
3. **QA coverage:** GPT-6 Sol QA agent owns the two agent_iteration runners and its coverage packet; close existing actor/menu coverage omissions and include the repair regression suite.
4. **Integration and delivery:** lead agent reviews changes, runs the full iteration, inspects real captures, records the visual rubric, exports the existing Windows preset if templates are available, smoke-tests the resulting executable and records build hashes. Commit and push validated source and records. Local binaries stay in ignored build output.

Each agent has disjoint edit ownership. Integration and native full-loop execution remain serial to avoid competing capture windows or shared evidence. No agent may claim another agent's validation as its own.

## Contracts and expected files

Simulation/data/schema/IDs, rewards, seeded outcomes and commands remain authoritative and unchanged. Main mode is free movement with optional repairs and six relic-only offers. Preserve the Saint and manifested weapon decision.

Expected files are those in the repair and runner packets plus this packet, existing durable production/memory/QA/roadmap/changelog/asset records and docs/evidence/repair-readability. Export uses export_presets.cfg without changing content. No new weapons, enemies, maps, rigging, public release or store deployment.

## Verification and stopping condition

Content validator and import, all runner suites and natural-policy matrices pass. Native repaired-interaction captures show complete text at both target resolutions, normal/large text, full/reduced effects. Inspect fresh shop, route, arrival and Results captures. Verify pause, save/continue and failure/retry through existing focused tests and review identified gaps. Any progression or save-loss failure blocks delivery.

Package only after integration passes; launch the Windows export without editor/development flags and record successful boot separately from source-runtime full-route evidence. Do not claim full exported-route interaction unless exercised. Record exact source state, executable/PCK hashes, commands and limitations. The delivery is an end-to-end technical preview, not Early Access certification.

## Remaining limitation

Automated native runs cannot establish uncoached player understanding, controller comfort or fun. Human acceptance remains open without blocking autonomous correction of proven software defects.

## Exactly one next task

Observe an uncoached 1x Workshop session using the delivered preview and turn its first demonstrated comprehension failure into one bounded follow-up packet.
