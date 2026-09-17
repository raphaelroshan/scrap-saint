# Sync approved direction with the 0.5 preview

- Objective: play the latest chapter with relic-only shops, field recovery, optional work at every destination, and the Saint's approved sacred origin.
- Authority: simulation owns offers, pickups, rewards, migration and victory; presentation reads state and routes ledger navigation. Preserve upstream ranks, ten evolutions, seven Gifts, four Blessings, frames, chapter routes and weapon animation.
- Baselines: upstream 3a3808b; complete local work preserved in 67f1fec on codex/preserve-local-sacred-repairs. Reapply intent, not the older simulation implementation. Upstream repair interruptions and banked empty-bell reward supersede local alternatives.
- Files: game/simulation.gd, game/main.gd, content/slices/first_shift.json, content/chapter/first_chapter.json, content/lore/first_shift.json, tests/test_sync_contract.gd, tests/capture_sync_contract.gd; existing tests/fixtures only where their assertions encode superseded rules; scripts/agent_iteration.ps1 and .sh; AGENTS.md, README.md, roadmap.md, design/shop_and_blessings.md, docs/astra_game_bible.md, docs/story_and_acts.md, docs/runtime_status.md, docs/agent_completion_prompt.md, docs/improvement_plan_2026-09-15.md, this packet and preserved lore/research documents.
- Preserved: two currencies, four active relics plus reserve, automatic attacks, optional Mercy, existing saves and all upstream mechanics not superseded by user decisions.
- Non-goals: new weapons, broad balance retuning, art replacement, removing legacy relay comparison.
- Acceptance: unique six relic offers including eligible Gifts; affordable slot when available; lock/reload determinism; reject main-mode services atomically; repair kits heal once, cap and wait at full health; each destination can resolve with its boss dead and unfinished work; optional node reward pays once; old service shops migrate; lore navigation freezes and preserves run state. Run integrated regressions and chapter policy matrix.
- Evidence: real 1280×800 Godot 4.5.1 captures of title/lore/shop/field recovery; configured states labelled, seed147 and source hashes recorded. Retain natural-run traces separately.
- Limitation: changed acquisition cadence still needs human 1× playtesting; automated victories are not a fun or release gate.
- Exactly one next task: reduce overlapping evolved effects around the Saint without changing authoritative attacks.
- Delivery: commit and push completed work; fetch before pushing, never force-push shared main, retain preservation branch remotely. Keep local delivery checkout aligned with the resulting remote commit.

## Verification record

Content validation and 31 Python manifest tests passed. The integrated deterministic suites passed, including 64 new sync-contract checks; the separate frame/progression suite passed all 15 checks. All 30 automated chapter scenarios won: 12 general policies, four assembly scenarios, ten preconfigured Evolution scenarios and four Gift scenarios. These are scripted policies, including explicitly configured builds, not human playtests or proof of balance.

The rendered capture harness checks 34 ledger page/text-size states without advancing simulation state, plus title, shop and repair-kit fixtures. Origin, large-text shop and field kit captures were visually inspected. An earlier origin capture exposed a leaked drawing transform; resetting the transform fixed it. That failed capture was overwritten during recapture and is not retained; this record preserves the reason and does not present it as valid evidence. An initial fixture footer incorrectly said LIVE; the harness now explicitly enables the configured-fixture label.

Selected captures, source hashes and the scored visual review are stored in docs/evidence/sync-2026-09-17. Full generated logs remain in ignored artifacts/agent-iteration and artifacts/sync-review. Supporting delivery changes include generated-image import exclusions in .gitignore and the matching next-task metadata in scripts/write_provenance.py.

The full PowerShell autonomous loop exited 0. The additional rendered natural-economy seed147 policy won after 12 shops. Core-quality capture logged an ObjectDB shutdown-leak warning; it did not fail the run, but resource cleanup remains unproven.
