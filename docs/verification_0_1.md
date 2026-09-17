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

After integration with the P12.1-P12.5 core gate and SC-15 chapter flow, content validation and all 372 focused Godot assertions pass on pinned Godot 4.5.1: acquisition44, arena27, assembly34, chapter41, dev-speed7, frames/progression15, optional17, profile18, relay18, roaming-quality49, settings11, shop25, simulation31, UI17 and variety18. The P14 tests cover Censer close slow and deterministic ember cadence; Winch priority selection, strike cancellation and pull; Halo contact geometry and current-site objective repair; Great Toll rejection/consumption/radial control; independent evolution IDs and Mercy-only Crane copying; two unique Gift slots; save restoration; Gift sale/dismantle; and the explicit downside of every enabled Gift. A deterministic ordinary-economy sweep discovers and purchases every enabled weapon and all three Gifts from generated shop offers. Public buy/combine/evolve commands assemble Great Toll then Mercy Rail and Mercy Rail then Great Toll, and verify both forms coexist while Memory Crane explicitly preserves Mercy Rail's line geometry. Python manifest validation also confirms ten enabled weapons, four catalysts, three Gifts, two Gift slots, two Evolutions, eight authored Workshop wave profiles, two chapter routes and no enabled Confluence.

Four seed-147 assembly policies complete the integrated optional-mode shift using configured starting build identities followed by ordinary movement and shop commands: Censer close-control wins at 507.65s with 92 structure; Winch priority-control wins at 505.5s with 90 structure; Halo/Spare Hand repair-roaming wins at 507.92s with 100 structure and two optional repairs; Great Toll/Inspection Lens/Black Ledger wins at 510.6s with 84 structure. These controlled-start policies establish executable viability, not natural acquisition rates or human balance.

The integrated broader matrix passes 12/12 across seeds 147, 104729 and 104730. Its three repair/explorer policies complete one useful repair, every shop records an affordable action, and unevolved Bell and Mourner routes reach Foreman. This is deterministic policy evidence, not a claim of human balance.

Three actual 1280x800 renderer fixtures were captured and inspected at seed147 using Godot 4.5.1 stable, OpenGL compatibility on Apple M1 Pro. `P14_EXPANSION_A` shows separate teal Censer smoke, segmented brass Winch arm/hook, and cream-green Halo stitch. `P14_GREAT_TOLL` shows the evolved loadout label, physical Bell shrine and full radial ring. `P14_GIFTS` shows Gift pricing/descriptions, both evolution buttons and two active Gift names. The fixtures use configured loadouts, targets and shop offers and are not natural runs. Visual polish remains procedural: simultaneous close rings overlap, the Winch lacks a full prepare/retract animation, and audio has not been human-mixed.

Exactly one next task: uncoached 1x comparison of close-control, priority-control and repair-roaming builds, with attention to shop-pool comprehension and effect readability.

## SC-16 - distinct destination bosses, 2026-09-15

The Choir Regent and Factory Heart no longer inherit the Foreman's generic demolition/worker loop. Boss data owns three named phases apiece, including cadence, warning time, hazard pattern, damage, movement and stop distance. The Regent escalates from one player-centred Measure to three relay-ring Toll warnings and a four-point Answer while applying phase-specific weapon-cycle pressure. The Heart instead pulses through the visible pump, suspends work for a bounded interval, calls a trace-labelled Rust Pilgrim during Graft Feed, and ends with simultaneous pump and player warnings.

Focused evidence passes 341 Godot assertions: chapter54, frames/progression15, profile18, settings11, development-speed7, assembly34, roaming-quality49, simulation31, shop25, optional17, variety18, relay18, arena27 and UI17. Python content validation and four manifest tests pass. The normal-economy full-chapter matrix remains 12/12, the three-frame × four-Blessing × two-route matrix remains 24/24, and the assembly-specialist matrix remains 4/4. These are deterministic policy results, not human playtests.

Two new fixture-configured captures, `CHOIR_REGENT_TOLL` and `FACTORY_HEART_FEED`, were rendered and inspected at 1280×800, seed 147, Godot 4.5.1 stable, OpenGL compatibility on Apple M1 Pro. The Regent capture shows its phase name, distributed relay warnings and cadence notice. The Heart capture shows its separate phase name, visible pump lock, connected pulse and summoned repairer. Goal and counterplay are materially more distinct; reaction-time comfort and audiovisual feel remain unproven.

Rendered-evidence rubric (5-point internal review): goal/action clarity 4, tactical readability 4, phase distinction 4, screen hierarchy 4, industrial identity 4. The strongest cue is the Heart's physical cable into the locked pump. The remaining visual limitation is that the Regent's distributed nodes cannot all fit inside one camera view; the minimap and phase notice carry the off-screen warning, which still needs a human comprehension check in motion.

Exactly one next task: run uncoached 1× sessions against both destination bosses and tune only observed cadence or readability friction.

## P14.1 - eight visible Evolutions, 2026-09-15

The arsenal now has eight data-owned, optional Evolutions and seven catalysts without enabling a Confluence. The six additions change combat geometry and at least one control, objective or resource behavior: Ashen Benediction offsets its Mourn zone and produces seeking motes; The Long Hand binds and pulls along a wide corridor; Halo of Repairs makes dual contacts and chains objective work into Saint repair; Candle for the Unreturned seeks the three weakest threats and returns funeral motes; Quiet Sermon silences support actions across a wide lane; Workshop Benediction consecrates repair work when no threat is in reach. Per-weapon Evolution IDs coexist through save/restore, while Memory Crane remains specific to Mercy Rail.

Focused evidence passes 538 Godot assertions, including 36 Evolution, 76 acquisition, 41 save-flow and 18 UI checks. Content validation reports 20 items, eight Evolutions, four Blessings, three frames, seven enemies and four bosses; all four manifest tests pass. The six controlled-start Evolution policies complete the full optional-mode chapter on alternating routes with 89.5–100 Saint structure. The previously failing seed-104729 Mourner policy was rerun with ordinary economy after stabilising the shop inventory signature and now wins; this preserves the established 12/12 optional-mode matrix. These are deterministic viability results, not human playtest evidence.

Three configured 1280×800 captures under `artifacts/evolutions` were rendered with Godot 4.5.1 stable, OpenGL compatibility on Apple M1 Pro, seed 147. `EVOLUTION_LEDGER` exposes all eight recipes, ingredients, readiness and geometry in one readable screen. `EVOLVED_GEOMETRIES_A` distinguishes the violet Ashen zone, brass tether corridor and dual cream-green Halo contacts. `EVOLVED_GEOMETRIES_B` distinguishes the three execution rays, wide cyan silence lane and orange consecrated Mortar area. The fixtures intentionally overlap effects more densely than a normal run; animation timing, audio mix and uncoached comprehension remain unverified.

Exactly one next task: run uncoached 1× comparisons of all eight Evolution decisions and tune recipe pacing and overlapping effects from observed choices.

## SC-17 three-site chapter expansion, 2026-09-15

Content validation and 522 focused Godot assertions pass on pinned Godot 4.5.1: acquisition44, arena27, assembly34, chapter94, development-speed7, flow-input51, frames/progression15, optional17, profile19, relay18, roaming-quality49, save-flow42, settings14, shop25, simulation31, UI17 and variety18. Tests cover graph-valid route offers, shared Red Foundry access, disconnected-route rejection, ordered/rotating/quiet objective rules, distinct three-phase terminal bosses, terminal memory conclusions, version-one save defaults and complete three-site route/result history.

The optional-repair twelve-policy matrix completes all four route chains, and the four controlled assembly identities each complete a different chain or parent route into shared Red Foundry. Policy guards now derive the longest duration from the authored graph instead of assuming one destination. This is executable viability evidence, not human balance evidence.

Three new fixture-configured captures, `PALE_ARCHIVE_INDEX`, `RED_FOUNDRY_VENTS`, and `NULL_ASSEMBLY_QUIET`, were rendered and inspected at 1280×800, seed 147, Godot 4.5.1 stable, OpenGL Compatibility on Apple M1 Pro. Each image exposes the objective rule, phase name, boss silhouette and spatial pressure. The procedural machinery remains visually repetitive, and the lower arena edge can crowd labels; motion comprehension and road-choice pacing remain untested by a human.

Exactly one next task: run uncoached 1× sessions through all four route chains and record objective comprehension, road-choice preference and boss readability.

## P15 - complete weapon Evolution endpoints, 2026-09-15

The ten-weapon roster now has ten visible, data-owned Evolution endpoints. Procession Gear Rank III plus Pilgrim Spindle becomes **The Maintenance Parade**: two counter-rotating escort rings strike at four contacts, and completing an authoritative Workshop machine or destination node extends the outer route for 240 ticks. Cable of Contrition Rank III plus Blue Wire from the Pump becomes **Contrition Lattice**: three cable edges aim at a distant priority threat, bind and cancel objective strikes, and redirect crossing threats without damaging machines merely inside the triangle. Blue Wire is consumed independently for Long Hand and Lattice; Combine and Evolution remain separate and no Confluence is enabled.

All 761 focused Godot assertions pass on pinned Godot 4.5.1: acquisition92, arena27, assembly34, chapter131, development-speed7, Evolutions51, expedition-map36, flow-input51, frames/progression15, optional17, profile19, relay18, roaming-quality49, save-flow46, settings14, shop25, simulation31, UI24, variety18 and weapon-ranks56. Seventeen Python manifest checks and content validation pass with 21 items, eight catalysts, ten Evolutions, seven enemies and seven boss records. Tests cover atomic rejection and consumption, shared Blue Wire re-offer, active/reserve identity, Parade extension save state, Lattice edge geometry, both new Archivist copy geometries, exact recipe/rule/backlink parity and Results-compatible IDs.

All ten controlled-start Evolution policies complete full two-leg chapters at seed 147, covering every terminal family. `EVOLUTION_LEDGER.png` and `EVOLVED_GEOMETRIES_C.png` are configured 1280×800 captures rendered with Godot 4.5.1 stable, OpenGL compatibility on Apple M1 Pro. The Ledger fits ten recipes without clipping. The paired combat fixture shows the Parade's separate green/brass rings and four escorts alongside Lattice's blue triangular boundary without covering the objective or boss telegraphs. These prove executable presentation, not natural acquisition timing, human comprehension or final audio balance.

Exactly one next task: run an uncoached 1× comparison of Maintenance Parade and Contrition Lattice, focusing on repair-extension comprehension and cable-edge readability.

## P16 Gift decision breadth, 2026-09-16

Seven data-owned Gifts now compete for two support slots. Loose Spring releases movement after completed work, Honest Scale previews purchase capacity and automatic Combine results, Choir Filter extends post-Quiet support suppression for reduced Hymn damage, and Brass Fuse trades Bell cadence for one wave-long Mark per site-wave. Conditional offer scopes prevent incompatible Filter/Fuse cards and exhausted repair cards from occupying the support role.

All 842 focused Godot assertions pass on pinned Godot 4.5.1: acquisition94, arena27, assembly34, chapter131, development-speed7, Evolutions51, expedition-map36, flow-input51, frames/progression15, Gift-breadth74, optional17, profile19, relay18, roaming-quality49, save-flow46, settings14, shop25, simulation31, UI29, variety18 and weapon-ranks56. Thirty-one Python manifest/graph rejection checks pass with 25 items, seven Gifts, eight catalysts and ten Evolutions. The 12/12 normal-economy, 24/24 frame/Blessing/route, 4/4 assembly and 10/10 Evolution matrices remain green; four Gift-specific two-leg policies also win and exercise their causal rule.

The configured `P16_HONEST_SCALE_SHOP`, `P16_SPRING_FUSE_COMBAT` and `P16_CHOIR_FILTER_RECOVERY` fixtures use Godot 4.5.1, 1280×800, seed 147 and the Compatibility renderer on Apple M1 Pro. They verify layout and state visibility, not uncoached decision quality or minimum-hardware performance.

Rendered-evidence rubric (5-point internal review): shop consequence clarity 4, Gift-state readability 4, combat cue separation 4, screen hierarchy 4, industrial attachment identity 4. Honest Scale exposes Combine and rejection outcomes without crowding the action row; Spring/Fuse and Filter states remain distinguishable from weapon geometry. The remaining visual limitation is that short-lived attachment motion and sound timing need observation in an uncoached real-time session.

Exactly one next task: run uncoached 1× workshop sessions comparing the original three-Gift pool with the seven-Gift pool, then tune only observed card-comprehension and offer-quality failures.

## P18 weapon-animation foundation, 2026-09-16

Nailer/Mercy Rail and Bell/Great Toll now render through authored event-driven presentation phases while the deterministic simulation retains ownership of cooldowns, targets, geometry, damage, status and Evolution state. Eleven new presentation checks cover simulation-hash isolation, exact durations, deterministic fixture progress/fade, correct mount selection, Evolution timing and expiry cleanup.

The complete pinned-engine loop passes 853 Godot assertions plus thirty-one Python manifest checks. Full-run evidence remains 12/12 normal-economy routes, 24/24 frame/Blessing/first-route combinations, 4/4 assembly identities, 10/10 Evolution routes and 4/4 Gift-specific routes. No script-load, resource-load or assertion errors appear in the iteration logs.

Six configured executable captures in `artifacts/weapon-animation` were rendered from clean commit `1fe4efd991429b29aff2e0973a70cc6920fb3ce5` with Godot 4.5.1 stable, OpenGL Compatibility on Apple M1 Pro, at 1280×800 and seed 147. Inspection confirms that Mercy Rail's split lane is materially heavier than base Nailer, Great Toll's full radial boundary is materially different from Bell's cone, overlapping families retain separate silhouettes, and reduced effects preserves core combat information.

Rendered-evidence rubric (5-point internal review): physical authorship 4, base/Evolution distinction 5, geometry readability 5, overlap hierarchy 4, reduced-effects parity 4, palette/coherence 4. This is still-image and deterministic-policy evidence, not a human assessment of feel. The principal limitation is unverified 1× anticipation/recovery timing; eight other weapon families retain their earlier presentation treatment.

Exactly one next task: run a human-controlled 1× Nailer/Bell session across Ranks I–III and both Evolutions, then tune anticipation and persistence only from observed motion readability.

## P19 complete weapon-animation catalogue, 2026-09-16

The remaining eight base/Evolution families now render through deterministic presentation-only timelines. Persistent-contact weapons have moving physical contacts and repair/smoke aftermath; target-link weapons stage locks, travel, tension and recovery; Mortar now exposes its shell arc and differentiated ground seals. Family-specific Saint mounts, rank silhouette cues and all ten Evolution reconfiguration motifs are present. Reduced effects retains authoritative area/target communication while suppressing decorative layers.

The complete suite passes 878 Godot assertions plus thirty-one Python manifest checks. Thirty-six presentation checks cover every base/Evolution attack duration, all eight newly animated mount selectors, simulation-hash isolation and common-clock expiry. The normal-economy matrix wins 12/12, the frame/Blessing/first-route matrix 24/24, assembly 4/4, Evolutions 10/10 and Gift-specific routes 4/4. No script-load, resource-load or assertion failures appear in the full iteration logs.

Eight configured executable P19 captures under `artifacts/weapon-animation` were rendered from clean commit `0209b7efd73131f6ac4a417915a826ca33dda5d7` with Godot 4.5.1 stable, OpenGL Compatibility on Apple M1 Pro, 1280×800 and seed 147. Inspection covers persistent bases/Evolutions, linked bases/Evolutions, Mortar/Benediction and four-family overlap at full and reduced effects.

Rendered-evidence rubric (5-point internal review): family recognition 4, base/Evolution distinction 4, target/area readability 4, overlap hierarchy 4, reduced-effects parity 4, palette coherence 4. These are configured stills and deterministic policies, not human evidence. Audio impact, normal-speed response and recognition during movement remain the principal limitation.

Exactly one next task: run an uncoached human 1× combat session using two four-weapon builds spanning all ten families, then tune only observed timing, overlap and recognition failures.

## P20 game-feel and presentation release pass, 2026-09-17

The 0.6.0 preview adds a deterministic title/loading transition, six-arm procedural key tableau, bounded camera impulse, enemy windup/recoil presentation, moving Workshop atmosphere, premium accepted-Evolution overlay, camera-motion accessibility control and thirty-one original synthesized cues. All additions remain presentation-only; the title handoff precedes simulation creation, while Evolution runs during an existing shop pause.

The combined suite passes 958 Godot assertions and thirty-one Python manifest checks, including the 64-check sacred-origin/relic-shop/field-recovery sync contract. Fourteen presentation-quality checks cover title timing and authority isolation, impulse/reduced-effects behavior, hit-driven enemy pose, accepted Evolution presentation, overlay expiry and generated PCM coverage. The existing 12/12, 24/24, 4/4 assembly, 10/10 Evolution and 4/4 Gift policy matrices remain green.

Eight configured P20 captures were recaptured from clean integration commit `349381764b0b26bffd0e21892560227ccad37ed6` with Godot 4.5.1 stable, OpenGL Compatibility on Apple M1 Pro, at 1280×800 and seed 147. The scored evidence validator passes. Internal scores are 4/5 for title identity, transition clarity, combat readability, enemy response, Evolution premium, overlap, reduced-effects parity and palette/UI coherence; 3/5 for deliberately restrained environment depth; and 5/5 for provenance.

No human audio, timing, controller or Windows minimum-hardware test is claimed. Exactly one next task: run an uncoached human 1× session on the packaged Windows build and record only observed timing, audio-mix, recognition and performance failures.
