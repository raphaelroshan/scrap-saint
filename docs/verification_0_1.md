# Verification — prototype 0.1.0

Executed locally on 2026-09-14 with official Godot 4.5.1 Windows, compatibility renderer and NVIDIA RTX 4060. Base repository commit: `6b51fffb3b9071dfae0a052dc423cf90bda53237`; runtime changes are local and uncommitted. Exact runtime source hashes and capture timestamp are in `artifacts/agent-iteration/provenance.json`.

- Content validation: PASS, including enabled-slice references and counts.
- Manifest tests: 4 checks, PASS.
- Simulation: 31 checks, PASS. Includes deterministic replay/resume, pause, movement bounds, persistent repair, purchases, capacity, combining, evolution consumption, real hit/stagger events, and one-time pickup healing.
- UI: 7 checks, PASS. Title/selection/start, pause/resume, shop pause regression and actual save-file roundtrip. These are engine-driven UI tests, not mouse/controller hardware playtesting.
- Shared-seed full runs with normal income: Workshop with evolution won in 496.9 seconds; Bell without evolution won in 509.2 seconds; Mourner without evolution won in 505.9 seconds; Workshop without evolution won in 499.3 seconds. Shop thinking time is excluded. Bell finished with only 4 relay structure; this is evidence of a viable route, not broad balance confidence.
- Six actual rendered state fixtures inspected. Their budgets/stages are deliberately configured for visibility. The Results fixture is not a natural win screenshot; full-run outcomes are separately recorded above and in `playthroughs.json`.
- Visual rubric recorded with explicit weak areas. No assertion that the final creative-vertical quality gate has passed.

Earlier sandbox launch failures and superseded fixture limitations are recorded under `artifacts/previous-fixture/`. Final engine runs emitted no script errors.

Remaining limitation: no human playtest of responsiveness, weight, difficulty or maintenance pressure.

Exactly one next task: human playtest of the shared arena and build feedback.

## 5x development launcher

Verified on 2026-09-14. `test_dev_speed.gd` passes all 7 checks in both normal and `--dev-speed=5` launches: default rate, deterministic five-step equivalence, pause, stopping at the shop boundary, stationary shops, and both F6 toggle directions. The existing content, simulation, UI and four full-run checks also pass after this change.

Six development fixtures were rendered in `artifacts/dev-speed`; the relay frame was inspected for badge placement and legibility. These configured fixture ticks do not measure wall-clock speed. The development capture exited successfully with an ObjectDB cleanup warning; its cause remains unverified. The normal capture bundle retains the scored visual review. Development provenance records this narrower inspection and warning.

Limitation: actual acceleration depends on hardware throughput; no human timing or audio-density assessment at 5x.
Next task: human playtest of the development launcher through a combat wave and shop.


## SC-02 authored workshop — 2026-09-14

Current evidence supersedes the open-floor run results above. Preserved baseline bundle: `artifacts/pre-workshop`. Current source and arena/slice content SHA-256 hashes are in `artifacts/agent-iteration/provenance.json`; the base commit is unchanged and the work is uncommitted. Engine: Godot 4.5.1, compatibility renderer, NVIDIA RTX 4060, viewport 1280x800, seed 147 for captures and full runs (104729 for the new movement replay test).

- PASS: 27 arena checks, 31 existing simulation checks, 7 UI checks and 7 development-speed checks; content validation passes. Grid topology checks cover connected free space and removal of each traversable cell without disconnecting the graph. This is a sampled topology check, supplemented by radius-aware route tests for all enemy sizes.
- Full-run balance gate: FAIL. Shared interception policy: Workshop evolved wins at 500.07s, Mourner wins at 499.27s, Workshop unevolved wins at 504.73s. Bell loses its relay at 54s in wave one. The old orbit policy also loses Bell at 52s on the new layout; its trace is preserved in `artifacts/pre-workshop/orbit-policy-new-layout.json`. The runner reports whether each run terminates; exit zero does not imply all builds win.
- Six final rendered fixtures inspected and the ten-row rubric updated. Layout, collision silhouettes, entry arrows and repair circle read clearly. Rail effects still extend over the HUD and the boss bar covers the north entry label; these are presentation limits, not hidden test passes.
- The repair fixture uses an explicit orbit in the work circle. Elite fixture position was relocated onto valid floor. Fixtures still have supplied budgets and authored state setup; Results is not a natural victory capture.
- New arena snapshots preserve deterministic continuation. Saves from before the geometry change are rejected with a visible explanation rather than placing entities inside solid machinery.

Limitation: Bell first-wave relay viability regressed and no human normal-speed playtest has been performed.
Exactly one next task: SC-04 relay threat and repair feedback, including shared first-beat protection and Bell viability verification.


## P08 - relay pressure and feedback, 2026-09-14

The previous Bell regression is superseded by twelve successful full-run traces: four policies on each of seeds 147, 104729 and 104730. Workshop evolved/unevolved, Bell unevolved and Mourner unevolved all win in 498.48-526.27 combat seconds. All report zero backup-absorbed damage: the first-wave floor did not rescue these policies. Some runs suffer little or no relay damage, so success is not proof of good difficulty. The runner now exits unsuccessfully for any loss or incomplete run.

Focused relay tests: 18 passes. Existing arena: 27 passes; simulation: 31 passes; UI: 7 passes. Tests cover warning timing, actual damage/source, cooldown, stagger and range cancellation, real Bell interaction, save continuation, backup expiry, repair cap and hazard routing through the common damage function.

Seven actual fixtures rendered on Godot 4.5.1 / compatibility / RTX 4060 / 1280x800. The new RELAY_THREAT_WARNING fixture explicitly places a hound in contact with a damaged relay and samples a pending strike halfway through windup. It is presentation evidence, not natural gameplay. Updated provenance includes source/content hashes and capture timestamp. Reviewed relay, threat, shop and boss images; updated the ten-row rubric with overlap and density limitations.

Initial exact-float test assertions were corrected to approximate comparisons. An invalid source encoding and carriage-return issue interrupted UI verification and was fixed before the successful UI/capture runs. An initial capture schedule omitted the seventh trigger; final schedule renders all seven. Earlier logs/baseline are retained in artifacts/pre-relay-pressure. Final capture exits successfully but still reports an ObjectDB cleanup warning; no claim of a warning-free runtime.

Limitation: no human normal-speed or audio-density playtest, and difficulty needs further assessment.
Exactly one next task: six-role workshop offers and distinct Blessing services.


## P09 - workshop roles and Blessing services

105 checks pass: shop 22, relay 18, arena 27, simulation 31 and UI 7. All twelve existing shared policies finish successfully across seeds 147, 104729 and 104730, in 497.63-515.47 combat seconds. These policies do not buy the doctrine service; service effects and expiry are exercised separately by focused tests. Shop RNG no longer changes combat RNG.

Seven main fixtures and three seeded service-shop captures were generated on Godot 4.5.1 / compatibility / RTX 4060 / 1280x800. Inspected the purpose-labelled shop, relay warning and Bell/Mourner service screens. Text fits; purpose labels are small. Source/content hashes and provenance are recorded in the evidence bundle. Service captures jump to a workshop at tick zero and are explicitly fixtures, not earned shops. An initial service capture allowed the main scheduler to overwrite the menu image; invalid image preserved in pre-workshop-services and all captures regenerated with that scheduler disabled. The first full capture reported an ObjectDB cleanup warning; final standalone captures did not report it.

Limitation: no human economy/choice-quality assessment; exhausted builds may get duplicate calibration cards, with repeat purchase blocked.
Exactly one next task: Foreman interrupt and relay-disconnect interactions.


## P10 - optional repair comparison

117 checks pass in the main loop (optional12, shop22, relay18, arena27, simulation31, UI7); development-speed checks add seven passes. All twelve baseline relay runs and all twelve optional-mode runs finish successfully across seeds147/104729/104730. Six optional runs finish with no machines repaired, and six incidentally repair one. Reward correctness, one-time completion, partial progress, pause/shop, save continuation and legacy-mode compatibility have focused checks. These runs do not prove player preference.

Four comparison fixtures under artifacts/optional-comparison show title selection, partial repair, completed sorter/reward, and baseline relay. Final machine labels were moved to avoid entry label overlap. Comparison source/content hashes and ten-row review are recorded in that bundle at 1280x800 on Godot4.5.1/RTX4060. Captures use controlled positions; the ObjectDB shutdown warning remains. No human audio/feel assessment claimed.

Limitation: rewards change economy and can be wasted at full integrity or without enemies; mode preference remains untested.
Exactly one next task: human A/B playtest at 1x with the same Blessing and seed, before boss-disconnect work.


## P11 - selected main mode and Foreman counterplay, 2026-09-15

User explicitly selected free movement with optional repairs as the main direction. Normal title hides the legacy comparison toggle; development mode retains it, and existing saves preserve their mode.

128 checks pass: Foreman11, optional12, shop22, relay18, arena27, simulation31, UI7. Both sets of twelve full-run policies (defence and optional) win across the same three seeds without issuing interrupts, establishing that the new action is not a required victory gate. Focused tests cover pause/shop/range/obstruction rejection without mutations, source-specific cancellation, repeat rejection, saved-state replay, and actual 1.5x damage followed by normal damage at exposure expiry. When the exposure test advanced the clock, the obstruction fixture's old absolute warning expired; its deadline was corrected to a relative deadline and all checks rerun successfully.

Actual warning and interrupt captures in artifacts/foreman-counterplay use Godot4.5.1 compatibility, RTX4060, 1280x800, seed147, tick210. Fixtures supply wave and positions but invoke real warning generation and interrupt commands. Both inspected; success banner was fixed after an initial UI notification overwrite and recaptured. Source/content hashes and scored rubric accompany the captures. No human controller/feel test claimed. ObjectDB cleanup warning remains in capture exit.

Limitation: risk/reward timing still needs human play, and boss-adjacent labels can overlap.
Exactly one next task: causal Results showing damage sources, build contribution and optional-repair rewards.


## P14 - replayable assembly, 2026-09-15

After integration with the P12.1-P12.5 core gate and SC-15 chapter flow, content validation and 273 focused Godot assertions pass on pinned Godot 4.5.1: assembly34, chapter38, roaming-quality49, simulation31, shop25, optional17, variety18, relay18, arena27 and UI9. The P14 tests cover Censer close slow and deterministic ember cadence; Winch priority selection, strike cancellation and pull; Halo contact geometry and current-site objective repair; Great Toll rejection/consumption/radial control; independent evolution IDs and Mercy-only Crane copying; two unique Gift slots; save restoration; Gift sale/dismantle; and the explicit downside of every enabled Gift. Python manifest validation also confirms ten enabled weapons, four catalysts, three Gifts, two Gift slots, two Evolutions, eight authored Workshop wave profiles, two chapter routes and no enabled Confluence.

Four seed-147 assembly policies complete the integrated optional-mode shift using configured starting build identities followed by ordinary movement and shop commands: Censer close-control wins at 507.65s with 92 structure; Winch priority-control wins at 505.5s with 90 structure; Halo/Spare Hand repair-roaming wins at 507.92s with 100 structure and two optional repairs; Great Toll/Inspection Lens/Black Ledger wins at 510.6s with 84 structure. These controlled-start policies establish executable viability, not natural acquisition rates or human balance.

The integrated broader matrix passes 12/12 across seeds 147, 104729 and 104730. Its three repair/explorer policies complete one useful repair, every shop records an affordable action, and unevolved Bell and Mourner routes reach Foreman. This is deterministic policy evidence, not a claim of human balance.

Three actual 1280x800 renderer fixtures were captured and inspected at seed147 using Godot 4.5.1 stable, OpenGL compatibility on Apple M1 Pro. `P14_EXPANSION_A` shows separate teal Censer smoke, segmented brass Winch arm/hook, and cream-green Halo stitch. `P14_GREAT_TOLL` shows the evolved loadout label, physical Bell shrine and full radial ring. `P14_GIFTS` shows Gift pricing/descriptions, both evolution buttons and two active Gift names. The fixtures use configured loadouts, targets and shop offers and are not natural runs. Visual polish remains procedural: simultaneous close rings overlap, the Winch lacks a full prepare/retract animation, and audio has not been human-mixed.

Exactly one next task: uncoached 1x comparison of close-control, priority-control and repair-roaming builds, with attention to shop-pool comprehension and effect readability.
