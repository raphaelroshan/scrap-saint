# First Shift runtime — 0.6.0 preview

## Ownership audit — 2026-09-25

No gameplay changes. The [production ledger](production_state.md) distinguishes implemented technical milestones from pending creative acceptance. [Fresh QA](qa_current.md) verifies content/import, 400 focused assertions and native captures at source `3464991`. The known Warning Bell description clipping remains open under the [next bounded packet](task_packets/workshop_repair_readability.md).

## Warning-wire story consequence — 2026-09-24

The Brass wire decision now selects Ada's immediate response and a later roof-crew report on either the Archive or Foundry road. Six authored passages use existing persisted road flags; Rootworks and old saves without matching flags keep default news. Existing risks, prices, free options, damage, warnings and progression are unchanged. Reading is deterministic and read-only; no new save fields or moral score are introduced.

See [where the broader story fits](narrative_implementation_map.md), [the implementation packet](task_packets/warning_wire_story.md) and [native captures](evidence/road-echoes/review.html). The consequence is conveyed through text; there is no simulated roof-crew encounter. Human causal comprehension remains unverified.

## Painted Memory Crane and Foreman — 2026-09-21

The Workshop's two major enemies no longer share the procedural gear body. Memory Crane is a tracked service crane with a painted chassis, boom and inspection lens; its hook aims toward the real copied-geometry hazard while that warning is active. Foreman Engine is a mobile painted demolition press whose ram, lamps, worker hatches and final-order jaws follow its authoritative phase. The boss HUD now names Schedule, Worker Call and Final Orders.

The renderer only reads enemy phase, stun and hazard data. It does not move hazards, spawn workers, apply damage or change state. Reduced effects holds decorative servo oscillation while keeping poses and attack boundaries. The complete loop passes 1,224 Godot assertions across 27 suites and 34 Python manifest checks; all existing natural policy matrices remain green. Seven new native fixtures were captured at 1280x800, seed 147, Godot 4.5.1 Compatibility on Apple M1 Pro. See [the task packet](task_packets/memory_crane_foreman_art.md) and [actor review](../assets/actors/review.html).

The major bodies are deterministic composites of existing generated project-painted assets rather than bespoke new paintings. This preserves source provenance and produces a coherent runtime replacement, but a future art-production pass can give each body unique painted parts. Human 1x recognition and reaction timing remain unverified.

## Supporting menus — 2026-09-21

How to Play now has five illustrated pages covering the Saint's manifestation through freely given repairs, movement, optional work, relic assembly and the three-site expedition. It is available from the title and Pause. Completing it from Pause returns to the same paused run; completing it from the title opens setup.

Settings groups sound/display, comfort and movement, exposes the existing persistent master-volume preference and explains effects and camera controls. Controller Back cancels a pending binding first; leaving Settings clears pending input capture. Pause displays the current site, wave, elapsed combat time, structure and currencies beside Resume, Save, Settings, How to Play and Save & Title. The illustrated title, setup, shop and map retain their established flows.

See [the menu packet](task_packets/menu_completion.md) and [native review](evidence/menu-panels/review.html). Human comprehension and physical controller testing remain outstanding.

## Painted enemies and repairs — 2026-09-21

All six ordinary enemy families now use painted bodies. Rust Pilgrim, Forklift Brute and Cinder Spitter join the earlier Mite, Hound and Drone. Existing charge warnings, support fields, statuses and hit reactions remain. Workshop Salvage Sorter, Coolant Pump and Warning Bell use matched broken/restored artwork, with progress and welding feedback while repairing. Simulation outcomes and optional-work rules are unchanged.

The original ordinary-actor pass had 57 focused checks; the expanded actor suite now has 137. See [the task packet](task_packets/enemies_and_repairs.md) and [native gameplay review](../assets/actors/review.html). Fixed-view ordinary body motion is not an articulated gait. Destination bosses and objectives still use procedural art.

## Painted arena material pass — 2026-09-21

All six sites use a subdued painted metal floor, fixed 384×256 world-space material tiles, subtle site tints and scenery fitted inside existing obstacle plinths. Vertical machines use press/boiler art; wide machines use a horizontal service manifold without sprite stretching or rotated lighting. Normal-play zone/machine labels move to F3 diagnostics. The old animated belt chevrons, decorative furnace circle and drifting floor steam are replaced by quiet perimeter services.

Field Scrap and repair kits now use painted cutouts. Scrap and Relic Shard icons also appear beside their HUD totals. Healing motes retain their previous spectral form, and no new drops or currencies are introduced. At that delivery, the Saint, enemies and optional-work symbols retained their prior renderer; the actor pass above supersedes ordinary enemy and Workshop repair presentation. See [the task packet](task_packets/arena_material_pass.md) and [before/after review](../assets/environment/review.html).

## Main menu artwork and navigation — 2026-09-17

The title uses painted meditation/awakening keyframes based on the six-armed Saint beneath the Bodhi tree. Continue is disabled without a save and focused when a save exists; New pilgrimage leads to frame/Blessing setup. Settings, How to play, Sacred histories and a cancellable Quit complete the menu. Settings retain mute, reduced effects, text size, fullscreen, camera motion and movement bindings. Reduced effects shortens the awakening dissolve to 300 ms; normal presentation takes 1.35 seconds. Simulation remains stopped until setup begins the run.

This replaces the default procedural title presentation while retaining its development fallback. The bitmap preview does not have independently articulated arms or cloud layers. Evidence and limitations are in docs/task_packets/main_menu_art.md.


## 2026-09-17 integration — authoritative current rules

Upstream 3a3808b and local work preserved at 67f1fec are reconciled. Keep all ten weapons, ten Evolutions, seven Gifts, four Blessings, three frames, chapter routes and the complete weapon-animation families.

Main-mode shops have six unique relic offers with eligible Gifts and unowned catalysts. They retain deterministic locks, preview validation and an affordable first choice when available. Services remain only in the relay comparison. Loading an older main-mode shop with service cards regenerates that shop under the relic rules; subsequent saves preserve the new offers. Previously purchased service effects finish their existing lifetime.

Every twelfth defeat drops a 15-integrity repair kit. It waits at full health, heals once up to the frame's cap, and expires at the shop boundary. Motes and optional machine rewards remain. All main-mode destinations advance when their boss is defeated; unfinished station work cannot fail the run. Completing a station grants +3 Scrap once and retains existing Gift and Evolution interactions. Upstream repair interruption, grace and banked empty-bell control remain.

The title and optional histories ledger present the approved manifestation through freely given repairs. Ten relic histories and six creature histories accompany the origin. Reading freezes the run and preserves shop offers; the ten-recipe Evolution Ledger remains separate. Creature histories do not yet cover the seventh enemy family.

The earlier evidence below belongs to its named build. Integration verification is recorded in packet_sync_2026-09-17.md; do not apply the older local Mourner timeout or old policy counts to this combined build.

Limitation: human 1× balance and effect readability remain unverified. Exactly one next task: reduce overlapping evolved effects around the Saint without changing authoritative attacks.

## Historical implementation and evidence

The project now contains a runnable Godot 4.5.1 desktop prototype. This is the first implementation, not a finished creative vertical. `content/slices/first_shift.json` is the authoritative enabled catalogue and tuning source; the larger catalogues also contain future concepts.

## Implemented

- A title screen, five-page field manual, three selectable Saint frames, persistent accessibility/settings controls, save/resume and profile unlocks.
- Eight 70-second Workshop waves, followed by two selectable road legs, a four-wave mid-site and a three-wave terminal site. Each road has two unskippable authored decisions; shop, map and travel reading time is paused.
- Four Blessings, ten automatic weapons with authored Rank II and Rank III behavior, eight catalysts, ten visible evolutions, four active slots, one reserve and seven run-local Gifts competing for two Gift slots.
- Movement, three optional repair machines, pickups, seven ordinary enemy families, an elite and six distinct phased destination bosses. Relay defence remains a development comparison.
- Purchases, automatic duplicate combining, explicit combine, sell/dismantle, reserve/equip, offer lock and one free/two paid refreshes.
- Ten Rank III plus catalyst Evolutions with distinct geometry, target, control, repair or resource behaviour. Catalysts are consumed atomically, and every encounter supports unevolved runs.
- Procedural weapon effects and synthesized audio, title/tutorial/selection/shop/travel/pause/Results, remappable keyboard and basic controller navigation.
- Deterministic simulation tests and full-run scripted policies; real rendered fixture captures with provenance.

## Exact prototype rules

Optional repairs is the main mode. Winning requires the Saint to survive and defeat Foreman before wave eight expires; no repair is mandatory. Machine progress persists outside its work radius, pauses after a direct hit, and resumes without losing work. Relay defence retains the older completed-work, relay-survival and Foreman requirements as a development comparison.

Two copies of the same rank combine into the next rank, up to III. Purchase previews explain automatic combining. The transaction validates final inventory capacity before spending. The last active weapon cannot be sold or stored. Ordinary sales return floor(60% of base cost times invested copy count); dismantling returns 40% without extra component currencies. Combine itself costs no currency in this prototype.

Blessing fulfilment counts two distinct active weapon IDs sharing the doctrine's principal tag: Labour, Witness, or Mourn. Reserve, catalysts, ranks and duplicate IDs do not increase this count. Workshop fulfilment increases proximity work; Bell fulfilment marks staggered enemies for extra damage; Mourner fulfilment creates healing motes more often. These replace the underspecified catalogue fulfilment placeholders for this prototype.

The three doctrine services are deliberately small: Workshop restores structure, Bell lengthens authored threat telegraphs by 50% for the next wave, and Mourner makes the next six defeats leave healing motes. Full rebuild/refund and elite-remnant services from the long-term bible are deferred. Every shop exposes the authored next-wave pressure and valid geometry families; Bell buys additional response time rather than hidden information.

The ten weapons cover piercing priority, stagger, orbit, execution, binding, dense-line fire, clustered bombardment, close smoke control and repair contact. Every base weapon has cumulative, content-owned Rank II and Rank III rules that change geometry, target count, cadence, control, repair or resource behavior beyond the shared damage increase. Combat events carry the stable active rank-behavior IDs, and the loadout identifies the current named rank behavior. Shop cards state each relic's role and weakness. Ten Evolutions visibly alter geometry, targeting, control, objective interaction or resource behaviour; the in-game Ledger previews each recipe and its missing ingredients.

The Crane copies rail geometry if an evolution exists and otherwise telegraphs a circular attack. Foreman moves faster and closes distance across Demolition, Workers and Final Orders phases. Each phase uses a deterministic route-shaped hazard pattern; later phases summon trace-labelled workers and close one additional lane. The Choir Regent has its own Measure, Grand Toll and Answer in Threes contract: announced resonance slows weapon cycling, then shifts from the Saint's position to the three visible relay rings. The Factory Heart instead pulses through the visible pump, temporarily suspends repair work, calls a trace-labelled Rust Pilgrim during Graft Feed, and ends with a pump-versus-personal-safety hazard choice. Destination boss cadence, warning, damage, movement and stop distances are owned by boss content data. Mites return stolen Scrap on defeat.

## Evidence limits

Screenshots are actual Godot renders. Most legacy captures are scripted fixtures with supplied positions or budgets. `artifacts/core-quality` additionally contains a normal-economy, seed-147 repair-policy trace at the repair decision, reward and naturally reached Results; it is labelled `NATURAL POLICY TRACE`, not human play. Passing policies establishes executable routes and regressions, not enjoyment or final balance. The integrated 65-threat headless benchmark reaches 315 simulation ticks/second (5.25× real time) on an Apple M1 Pro; it does not establish rendered Windows minimum-hardware performance. No human playtest or controller hardware session has been claimed.

Art is original procedural placeholder geometry drawn by the renderer. Audio is original synthesized placeholder audio in `game/sound.gd`. Both were created on 2026-09-14, use no downloaded art/audio assets, and require later art direction/feel iteration. System fonts use installed fallbacks; no font files are redistributed.

## Remaining limitations

Settings, volume, screen mode, reduced motion, high contrast and movement remapping persist locally. The fixed simulation is replay-tested within the pinned engine/platform, not certified cross-platform. Save files are local version-3 snapshots and migrate version-1 Workshop and version-2 chapter runs. Content tuning, shop breadth and secondary effects remain preview-level. Natural policies do not establish feel, preference, effect readability in motion or ideal 1x density.

Exactly one next task: focused uncoached human playtest of the complete First Shift at 1x.


## P15-A — differentiated base ranks

All ten enabled weapons now resolve cumulative data-owned Rank II and Rank III overlays before simulation targeting, geometry, cadence, control, repair and resource effects. Explicit Combine and purchase auto-combine share one canonical assembly path, reset readiness identically and emit the same stable rank behavior IDs. Evolved weapons continue to resolve only their authored Evolution rule, so rank overlays do not leak into transformed behavior.

Configured 1280×800 fixtures under `artifacts/weapon-ranks` compare the same precision, control, orbit and execution loadout at Ranks I, II and III. The focused table-driven suite exercises all twenty rank behaviors and validates the explicit/automatic combine equivalence. These deterministic fixtures are not evidence of player comprehension or preference.

Exactly one next task: uncoached 1× comparison of Rank I/II/III readability during ordinary acquisition.


## P14.1 - eight visible Evolutions

The Evolution Ledger now exposes ten stable Rank III plus catalyst recipes. Mercy Rail and The Great Toll remain intact. Foundry Censer becomes **Ashen Benediction**, an offset Mourn smoke zone that seeks damaged work and creates seeking motes. Penance Winch becomes **The Long Hand**, a routed corridor that binds and pulls several aligned threats. Welded Halo becomes **Halo of Repairs**, with two opposed contacts and a machine-to-Saint repair circuit. Candle-Nailer becomes **Candle for the Unreturned**, which executes the three weakest reachable threats and sends its funeral motes toward the Saint. Hymn Coil becomes **Quiet Sermon**, a wider silence lane that delays healer, ranged and Choir support actions. Altar Mortar becomes **Workshop Benediction**, retaining clustered damage while gaining a consecrated objective shot when no threat occupies its reach.

Recipe definitions, catalysts and combat values are content-owned. Each weapon stores its own Evolution ID, so feasible multi-Evolution loadouts, chapter carryover, Results and saves no longer depend on one shared evolved form. The ordinary-economy acquisition harness buys and combines every base, acquires its catalyst and evolves it through public commands. Memory Crane remains explicitly keyed to Mercy Rail geometry. Combine and Evolution remain separate and no Confluence is enabled.

Configured 1280×800 renderer fixtures under `artifacts/evolutions` show the eight-entry Ledger and the six new geometries at seed 147 on Godot 4.5.1. Controlled-start policies establish executable chapter viability on both roads, not natural recipe timing or human preference.

Exactly one next task: uncoached 1× comparison of all eight Evolution choices, with attention to Ledger comprehension and overlapping effect density.

## P15 - complete weapon Evolution endpoints

Procession Gear Rank III plus Pilgrim Spindle now becomes **The Maintenance Parade**. Its single close orbit becomes two counter-rotating escort rings with four contact points. Completing an actual Workshop machine or destination objective node extends the outer route for four seconds, so repair work visibly changes its coverage without removing the close-range commitment.

Cable of Contrition Rank III plus Blue Wire from the Pump now becomes **Contrition Lattice**. Its broad inward sweep becomes a triangular cable boundary aimed at a distant priority threat. Enemies crossing any edge are bound, have objective strikes cancelled and are redirected laterally; enemies merely standing inside the triangle are not hit. Blue Wire remains shared with The Long Hand and is consumed separately for either recipe.

Both forms use stable per-weapon Evolution IDs, survive version-3 save/restore, appear in the ten-entry Ledger and Results, and expose authored geometry/behaviour to the Archivist Prime copy. Ten controlled-start Evolution policies complete full two-leg chapters. Configured 1280×800 fixtures under `artifacts/evolutions` show the complete Ledger and the two new forms together at seed 147 on Godot 4.5.1; they are not human playtests.

Exactly one next task: uncoached 1× comparison of the ten Evolution choices, focusing on Parade extension comprehension and Lattice edge readability.

## P16 — Gift decision breadth

The two support slots now draw from seven unique, rankless Gifts. **Loose Spring** turns each completed repair into one 90-tick movement release. **Honest Scale** previews exact post-purchase active/reserve capacity, rejection and automatic Combine results without mutating the shop. **Choir Filter** extends suppression of Choir and repair support after Quiet ends while reducing Hymn Coil and Quiet Sermon damage by 15%. **Brass Fuse** keeps the first Bell or Great Toll target Marked through its site-wave while making Bell mechanisms cycle 15% slower.

Gift offers are now filtered by their authored scope: repair Gifts require unfinished work, Choir Filter requires Hymn Coil, Brass Fuse requires Last Shift Bell, and broad information/economy Gifts remain generally available. The simulation owns all timers, one-use keys, status recovery, purchase projection and causal metrics. Results snapshot ordered Gift IDs and activation counts; selling an attachment clears carried-only presentation state without undoing an already-applied enemy status.

Current integrated evidence passes 842 Godot assertions plus thirty-one Python manifest checks on Godot 4.5.1. The normal-economy matrix wins 12/12, the three-frame × four-Blessing × two-first-route matrix wins 24/24, all four assembly paths and all ten Evolution paths remain complete, and all four Gift-specific two-leg policies win and exercise their rule. Configured 1280×800 fixtures cover the Honest Scale shop, Spring/Fuse combat and Choir Filter recovery; these are not human playtests.

Exactly one next task: run uncoached 1× workshop sessions comparing the original three-Gift pool with the seven-Gift pool, then tune only observed card-comprehension and offer-quality failures.


## SC-02 — authored Collapsed Workshop

The arena now measures 20 by 14 logical metres at 40 pixels/metre. `content/arenas/collapsed_workshop.json` owns bounds, start, relay, a 2.5-metre repair radius, two solid machines, three named entrances, and four lane/alcove regions. Movement, enemy navigation, charges, pushes and pulls resolve against the same geometry. Low machinery blocks bodies but permits automatic weapon fire. The outer circuit and spaces around the machines remain connected; the alcove is ordinary combat floor, with no healing or invulnerability.

Old saves without the authored arena ID are refused with an explanation; new-layout saves continue deterministically. No old save is overwritten merely by trying to load it. Timed crane/furnace hazards and shop timing changes are deferred.

The shared scripted interception policy wins with Workshop (with and without evolution) and Mourner, but Bell loses the relay during wave one. This is a recorded balance regression against the prior open arena, not proof that Bell is impossible for a human. Do not treat the first-slice viability gate as passed.

Next task: SC-04 relay threat and repair feedback, including shared first-beat relay protection and Bell viability verification.


## P08 - shared relay pressure

The relay begins at 70% integrity. During wave one, visible startup backup prevents damage below 18 integrity; the backup ends after the first workshop and does not protect the Saint. Every relay damage source uses the same rule.

Ordinary enemies in relay contact range wind up a strike for 60 ticks, then recover for 90 ticks before another warning. Leaving range or staggering cancels the windup. Bell's existing stagger interrupts attacks without encounter customization. Damage records actual loss and source; the HUD distinguishes integrity from work, with attacker links/countdown arcs and local damage flashes. The relay impact cue is original synthesized placeholder audio created 2026-09-14.

Authored-workshop saves load with defaults for new pressure fields. Saves made under these rules preserve strike timing. Twelve shared-policy runs across seeds 147, 104729 and 104730 all win, including Bell without evolution; none uses the backup floor. This supersedes the recorded P07 Bell regression without proving human balance. Some builds take little relay damage, so pressure tuning remains open.

Exactly one next task: six-role workshop offers and distinct Blessing services.


## P09 - workshop roles and services

Six offer positions now explain their purpose: build improvement, new direction, evolution path, threat support, field repair and Blessing service. Upgrade candidates exclude completed ranks and consider capacity and current Scrap. New-direction offers exclude owned weapon IDs and weight the chosen doctrine's tag; support prefers an unowned catalyst associated with the next threat. Owned catalysts and completed evolution paths fall back to next-wave calibration where appropriate. The existing recipe footer and evolve command remain independent of these offers.

Shop selection hashes seed, wave, doctrine, reroll, slot and inventory context without consuming combat RNG. Explicit locks can override a flexible offer, so the corresponding original role is subordinate to the player's lock. Locked prices remain catalogue-defined. Rerolls are not guaranteed to change every card.

Workshop restoration repairs 20 Saint and 45 relay integrity; Bell's Advance warning gives 50% longer relay-strike and demolition warnings next wave; Mourner's Remember the fallen makes the next six defeats produce extra healing motes. Services cost 5 Scrap and can be purchased once per visit. Calibration shortens weapon cooldowns by 10% for the next wave and cannot stack. Effects expire at the next shop; inventory and saves retain the active effect until that boundary. Existing baseline weapon and catalyst effects still apply.

Limits: offers are not universally affordable and a fully exhausted build can encounter redundant calibration cards; buy validation prevents repeated spending on used services. The six positions are an initial practical layout, not the entire long-term service catalogue. Human choice quality and economy remain unverified.

Exactly one next task: Foreman interrupt and relay-disconnect interactions.


## P10 - optional repair A/B comparison

The title screen defaults to Optional repairs and can switch to Relay defence. Both use the displayed seed (initially 147); new-comparison changes it explicitly. Compare at 1x with the same Blessing and seed. Arena geometry, shop catalogue and wave schedule are shared, while enemy objective targeting changes because optional machines are not attack targets.

Optional mode removes relay defence/progress from victory. Survive, defeat the elite before its wave deadline and defeat the Foreman by the final deadline. Three independent machines take 180 work ticks (three seconds before doctrine/catalyst modifiers): the west sorter gives 8 Scrap; north pump heals up to 30 Saint integrity; east warning bell staggers currently living enemies for 180 ticks. Progress persists when leaving, machines stay restored, and rewards apply once per run. No repair grants invulnerability or prevents defeat. Twelve recorded policies win; six finish with zero optional repairs and six incidentally finish one.

Repair services and Mercy Rail have mode-appropriate effects: ordinary repair restores Saint integrity, Workshop service restores 45 Saint integrity, and major-enemy Mercy Rail hits restore 6 Saint integrity. Bell service still extends demolition warnings. Rivet and Workshop repair-rate bonuses apply to optional machines. New saves preserve mode and machine state; older saves default to relay defence.

This is a comparison prototype, not a conclusion that either mode is more fun. Healing at full integrity and warning pulses with no enemies can waste a reward, and reward balance is provisional. Optional rewards alter the economy, so identical seeds do not imply identical run outcomes.

Exactly one next task: human A/B playtest of movement freedom and repair motivation at 1x; defer Foreman relay-disconnect work until that decision.


## P11 - historical, superseded by P12 below

On 2026-09-15 the user selected optional repairs as the main direction after the comparison. Normal title UI starts that mode; the development launcher retains the baseline toggle. Existing saved modes remain compatible.

During a live Foreman demolition warning, approach within 100 pixels with unobstructed access and press E or controller X. The simulation cancels that boss instance's pending hazards, records an interrupt and exposes it for 180 ticks. Hits against the exposed boss deal 50% more damage. No specific weapon, repair or evolution is required. Interrupting is optional; ordinary evasion and damage still work. Paused, shop, out-of-range, obstructed and out-of-window commands are rejected without mutating authoritative state. Source IDs prevent cancelling unrelated hazards.

Exactly one next task: causal Results showing damage sources, build contribution and optional-repair rewards.


## P12 - larger roaming arena and combat variety (historical baseline)

The chosen main mode remains free movement with optional repairs. The user rejected P11 manual boss interruption; E/X interrupt, exposure bonuses and their HUD prompts are removed.

Collapsed Workshop is now 1600 x 1120 world pixels (40 x 28 logical metres), four times its previous area. A following camera, minimap, two additional solid industrial obstacles and outer yard zones support roaming. Optional reward machines are distributed west, north and east. Optional-mode enemies spawn around the Saint at 460 pixels where walkable rather than only at distant fixed gates.

Seven base weapons are playable. Hymn Coil is a fast piercing beam (4 damage every 8 ticks, range 420); Altar Mortar is a cluster burst at the nearest target (38 damage every 100 ticks, radius 72). Both participate in the existing shop/rank/build systems. Six ordinary enemy families now include Rust Pilgrim (periodic nearby-ally healing), Forklift Brute (heavy charge and contact shove) and Cinder Spitter (a delayed blast locked to the Saint's earlier position). These use ordinary movement and automatic combat; no extra input or weapon-specific encounter requirement.

The previous relay-defence policy suite produced 9 wins and 3 losses after roster expansion; this is retained as a balance regression in the development comparison mode. Current main mode records 11/12 wins; Mourner seed 104729 dies on wave five. All twelve skip optional repairs. The all-win gate therefore remains failed, while 129 Godot assertions pass. Rendered evidence and exact provenance are recorded in artifacts/variety.

Limitation: automated fixtures and policies do not establish human pacing, balance or audio quality. Capture teardown still reports an ObjectDB leak warning.
Exactly one next task: playtest roaming density and weapon/enemy balance at 1x.

## P14 - replayable assembly

Foundry Censer, Penance Winch and Welded Halo are enabled in the ordinary weapon pool. Censer is a close smoke ring that slows threats and drops one deterministic Scrap ember per three close defeats. Winch selects an announced relay attacker before the farthest eligible threat, cancels its strike and pulls that single target toward the Saint. Halo uses a rotating contact point and adds a repair stitch to a nearby unfinished optional machine, falling back to a small Saint repair when no eligible machine is near. Their roles, target rules, weaknesses, tags and prices remain data-owned.

The Great Toll is the second enabled Evolution: Bell Rank III plus Cracked Bell Clapper. It replaces the Bell cone with a radial marked stagger and outward displacement. Its catalyst is consumed only on successful transformation. Failed eligibility leaves inventory and currency unchanged apart from the normal visible rejection reason. Same-rank Combine remains unchanged, and no Confluence is enabled.

Spare Hand, Inspection Lens and Black Ledger are enabled as unique, rankless Gifts in two dedicated slots. Spare Hand increases optional work by 25% while reducing movement by 20% inside an unfinished work circle. Inspection Lens labels the next elite or boss property and priority target while spending every fifth ordinary Scrap pickup. Black Ledger reduces dismantle return to 25% and stamps one matching tag onto a deterministic shop lead until that matching weapon is purchased. Gifts use Scrap and never introduce another currency.

Focused deterministic coverage includes attack geometry, target priority, status/control, machine repair, evolution consumption/rejection, unique Gift capacity, save restoration and each Gift trade-off. Fixture captures at `artifacts/assembly` use Godot 4.5.1, Apple M1 Pro OpenGL compatibility, 1280x800, seed 147. They are configured executable states, not human playtests.

Limitation: the larger pool changes shop probabilities, and deterministic viability does not establish human comprehension or enjoyment. The three new weapon fixtures overlap intentionally to show authorship, but final art, effect timing and audio mixing remain deferred.

Exactly one next task: run uncoached 1x sessions comparing close-control, priority-control and repair-roaming builds.

## P12.1-P12.5 - core-quality foundation included in P14

The eight waves now use authored primary/support profiles instead of selecting from an uncontrolled growing enemy pool. Positions remain seeded, but each wave states one pressure question and valid geometry families. Optional-mode spawns arrive 390 pixels around the Saint where walkable. Automated traces record first contact and longest no-threat gap; after counting short-lived threats at spawn, the representative opening contact is tick 96 (1.6 seconds).

Optional repairs now expose reward and remaining work time. Leaving the circle or taking a direct hit emits a stable interruption reason and preserves progress; a hit pauses work for 45 ticks. The Coolant Pump defers at full integrity rather than consuming a wasted heal. If the Warning Bell finishes with no living enemies, its three-second stagger is banked for the next arrival. Scrap, repair starts, interruptions and useful completions are source-recorded. The repair/explorer policy completes the west Salvage Sorter on all three representative seeds while ordinary policies remain free to ignore every repair.

All ten weapons carry data-authored role, weakness, target rule and counter-family descriptions. Nailer prioritises enabled support threats, Candle executes the weakest reachable target, Hymn Coil chooses a dense piercing line and Altar Mortar chooses a cluster. Controlled tests preserve Gear's range weakness, Cable's low burst, Bell's control role and the three P14 roles. This is matchup evidence, not a claim that final human balance is complete.

The workshop preserves six roles and guarantees an affordable normal-economy build action. Owned or exhausted paths are de-duplicated rather than showing repeated calibration cards. The next authored wave name, pressure and counter geometries are visible. Workshop healing, Bell warning time and Mourner kill-mote service mutate distinct authoritative state.

Foreman phases now change movement speed, stop distance and route-shaped demolition offsets. Final Orders closes a fourth pocket; worker summons are trace-labelled priority targets. Results are generated from authoritative run records: completed machine rewards, Scrap sources, top weapon contribution, largest damage wave, Blessing fulfilment, evolution status and one stable failure category (`BUILD_GEOMETRY`, `OBJECTIVE_NEGLECT`, `POSITIONING`, `THREAT_RESPONSE` or `ECONOMY`). The replay cue follows that cause or the successful route actually taken.

The prior Mourner seed-104729 loss was an uncontrolled mixed-wave composition failure, not evidence that Mourner required a global damage bonus. The authored wave-five Pilgrim repair line isolates healer priority with Hound/Mite support. On the same seed, the non-evolved Mourner policy now reaches and defeats Foreman with Rank III Candle, Rank III Bell and Rank I Cable. The full main-mode matrix is 12/12 wins across seeds 147, 104729 and 104730; each seed includes an evolution policy, Bell survival policy, non-evolved Mourner policy and repair/explorer policy. No shop visit in that matrix lacks an affordable action, and all three repair policies complete one useful machine.

Current integrated evidence: 469 focused Godot assertions plus four Python manifest checks. The normal-economy chapter matrix wins 12/12, the three-frame × four-Blessing × two-route matrix wins 24/24, and assembly-specialist policies win 4/4. Natural policy captures live at 1280x800 in `artifacts/core-quality`; product-shell and destination-boss fixtures cover the complete flow. Godot is pinned to 4.5.1. This is deterministic viability evidence, not human enjoyment evidence.

Exactly one next task: uncoached 1x comparison of close-control, priority-control and repair-roaming builds across both chapter routes.

## SC-15 — compact first-chapter pilgrimage foundation

Foreman victory now opens an authoritative two-route decision instead of ending the expedition. Eight Scrap recovered from the Foreman guarantees both roads remain affordable. Brass Choir Relay costs 8 Scrap and asks the Saint to clear and tune three distributed signal rings; Rootworks Pump costs 6 Scrap and asks it to finish one exposed, persistent pump repair while healer-heavy enemies sustain the crowd. Each destination runs four compact waves, uses a route-specific authored pressure profile and boss, and ends in its own memory and causal Results.

Route choice, travel beat, selected arena, objective nodes, carried weapons/reserve/catalysts/currencies, core-quality metrics, boss result, memory and chapter completion are part of version-2 deterministic save state. Version-1 Workshop saves migrate to the combined state without being rerolled. Arrival clears per-wave shop services and timers while preserving permanent build state. Boss hazards and destination pressures schedule from boss arrival rather than inherited global time. Damage and income traces use `site_id:wave_N` segment keys, and Results expose completed site and defeated boss IDs. Presentation sends `choose_route`, `advance_travel` and `accept_memory`; it does not decide arrival, repair progress or completion.

The implementation is a systems-complete chapter proof layered on the P12 core-quality gate, not the full Early Access breadth target. It deliberately reuses the current combat roster and procedural visual/audio language. The two destination bosses now have distinct three-phase authoritative contracts and labelled fixture evidence; reaction-time comfort, boss enjoyment and the intended 25–35 minute commercial expedition still require human testing.

Exactly one next task: run uncoached full-expedition playtests of the expanded builds on both routes at 1× and tune destination pressure from observed comprehension and pacing evidence.

## SC-17 — complete three-site chapter graph (current)

Each expedition now crosses the Collapsed Workshop, one mid-site and one terminal site. Brass Choir opens Pale Archive or the shared Red Foundry; Rootworks opens Red Foundry or Null Assembly. Pale asks for three ordered records while Archivist Prime copies the latest visible Evolution geometry. Red rotates one active furnace vent while the Red Cardinal marks arena anchors and calls cinder pressure. Null silences automatic relics only while the Saint works an anchor, and the Null Auditor temporarily locks both work and weapon cycles. Each site has its own arena, wave profiles, boss contract, memory, assignment ID, route risk and authored encounter plus merchant/service road nodes ready for the expedition-map command layer.

Route eligibility, two-leg history, objective state, transient boss locks, completed sites, defeated bosses and recovered memories are deterministic simulation/save data. Terminal memories end the chapter; mid-site memories preserve the build and return to the next valid route choice. Policy timeouts derive the longest authored graph path rather than assuming one destination.

Current integrated evidence passes 761 Godot assertions plus seventeen Python manifest checks on Godot 4.5.1. The normal-economy matrix wins 12/12, the three-frame × four-Blessing × two-first-route matrix wins 24/24, all four controlled assembly paths finish, and all ten Evolution policies complete their two-leg route. Chapter and Evolution fixtures include all three terminal objective/boss states and the two final Evolution geometries at 1280×800, seed 147, Compatibility renderer on Apple M1 Pro. These are deterministic policies and configured captures, not human enjoyment evidence.

Exactly one next task: run uncoached 1× sessions through all four route chains and tune only observed objective comprehension, road-choice value and boss reaction-time friction.

## P18 — Nailer and Bell weapon-animation foundation

Nailer/Mercy Rail and Bell/Great Toll now have physical mounts and deterministic, event-driven presentation phases without changing authoritative combat. Nailer fires a traveling fastener along its existing line with recoil, a staged aim trace and brass discharge. Mercy Rail resolves as a wider split, braced lane. Bell compresses its mounted striker before releasing its existing cone; Rank III adds a secondary pressure arc. Great Toll replaces the cone with a full radial boundary, cardinal impacts and a visible Evolution reconfiguration beat. Reduced-effects mode keeps attack boundaries, endpoints and status cues while removing decorative particle density.

All 853 Godot assertions and thirty-one Python manifest checks pass on pinned Godot 4.5.1. The 12/12 normal-economy, 24/24 frame/Blessing/first-route, 4/4 assembly, 10/10 Evolution and 4/4 Gift-specific policy matrices remain green. Eleven new presentation checks prove authored duration/progress, weapon-specific mount selection, expiry cleanup and unchanged simulation hashes.

Six configured executable fixtures under `artifacts/weapon-animation` were captured from clean commit `1fe4efd991429b29aff2e0973a70cc6920fb3ce5` at 1280×800, seed 147, using Godot 4.5.1 stable and OpenGL Compatibility on Apple M1 Pro. They cover Nailer commit, Mercy Rail resolve, Bell commit, Great Toll resolve, overlapping Nailer/Bell fire and the same overlap with reduced effects.

Rendered-evidence rubric (5-point internal review): physical authorship 4, base/Evolution distinction 5, geometry readability 5, overlap hierarchy 4, reduced-effects parity 4, palette/coherence 4. Configured stills establish visual structure and layering, not normal-speed responsiveness. The other eight weapon families still need the same full prepare/commit/resolve/recover treatment.

Exactly one next task: run a human-controlled 1× Nailer/Bell session across Ranks I–III and both Evolutions, then tune anticipation and persistence only from observed motion readability.

## P19 — complete weapon animation catalogue

The eight remaining families now use the P18 presentation-only prepare/commit/resolve/recover pattern. Procession Gear and Maintenance Parade use physical gear contacts, counter-rotating paths and extension flags. Candle-Nailer and Candle for the Unreturned use curving flame shots and wick residue. Contrition Cable and Lattice use a sweeping hook or staged triangular anchors. Hymn Coil and Quiet Sermon use converging forks and separated cyan pulse lanes. Altar Mortar and Workshop Benediction use a visible shell arc and square ground seals. Foundry Censer and Ashen Benediction use chain tension and layered smoke. Penance Winch and Long Hand unfold segmented arms before retracting. Welded Halo and Halo of Repairs close their gimbals and return visible stitch circuits.

All ten base/Evolution families now have a persistent physical mechanism on the Saint, authored effect lifetime, deterministic particles or residue, Evolution-specific reconfiguration, and reduced-effects parity. Presentation consumes existing authoritative events and does not change cooldowns, targets, damage, repair, control, resources, RNG or saves.

The full suite passes 878 Godot assertions and thirty-one Python checks on pinned Godot 4.5.1. The 12/12 normal-economy, 24/24 frame/Blessing/first-route, 4/4 assembly, 10/10 Evolution and 4/4 Gift-specific matrices remain green. Eight P19 fixtures were captured from clean commit `0209b7efd73131f6ac4a417915a826ca33dda5d7` at 1280×800, seed 147, using OpenGL Compatibility on Apple M1 Pro.

Rendered-evidence rubric (5-point internal review): family recognition 4, base/Evolution distinction 4, target/area readability 4, overlap hierarchy 4, reduced-effects parity 4, palette coherence 4. The visual language is complete at the procedural prototype level. Normal-speed response, audio impact and player recognition remain unverified by a human.

Exactly one next task: run an uncoached human 1× combat session using two four-weapon builds spanning all ten families, then tune only observed timing, overlap and recognition failures.

## P20 — game-feel and presentation release pass

The title is now a layered procedural tableau: a six-armed bronze maintenance Saint meditates beneath a Bodhi tree with inspection lamp, spanner, welder, cable clamp and two empty lap hands. Selecting Begin opens its eyes, activates the four tools, parts the cloud banks and reveals the broken industrial city during a deterministic 1.35-second handoff. Reduced effects removes secondary drift, sparks and motion while preserving the state change. That procedural build shipped no generated bitmap; the later main-menu update above adds two generated keyframes.

Combat presentation now adds bounded camera impulse, directional enemy recoil, windup bracing, impact marks, stagger vibration, animated workshop belts/lamps/furnace/steam and an accessibility toggle for camera motion. Accepted Evolutions temporarily replace workshop controls with a 1.45-second named reconfiguration panel showing the base relic, resulting geometry and effects; the simulation is already paused at that shop boundary. Thirty-one original synthesized cues now cover every weapon family plus title confirmation, quiet, death, repair, boss contract, machine restoration and Evolution.

All 958 Godot assertions and thirty-one Python checks pass on pinned Godot 4.5.1, including the 64-check sacred-origin/relic-shop/field-recovery sync contract. The 12/12 normal-economy, 24/24 frame/Blessing/first-route, 4/4 assembly, 10/10 Evolution and 4/4 Gift-specific matrices remain green. Eight P20 fixtures were recaptured from clean integration commit `349381764b0b26bffd0e21892560227ccad37ed6` at 1280×800, seed 147, using OpenGL Compatibility on Apple M1 Pro.

Rendered-evidence rubric (5-point internal review): title identity 4, transition clarity 4, combat action readability 4, enemy response 4, environment depth 3, Evolution premium 4, overlap hierarchy 4, reduced-effects parity 4, palette/UI coherence 4, provenance clarity 5. Automated evidence cannot establish audio mix, normal-speed feel, controller comfort or minimum-Windows-hardware performance.

Exactly one next task: run an uncoached human 1× session on the packaged Windows build and record only observed timing, audio-mix, recognition and performance failures.

## P21 — manifested Nailer and Mercy Rail

The equipped Nailer is no longer rendered as a permanently attached extra limb. It condenses during a bounded pre-fire readiness window, then the committed object is rendered from the authoritative attack event's recorded origin and direction. The base form has a compact green-and-cream driver casing, household repair patch, exposed flywheel, moving carriage and blunt jaws. Mercy Rail retains that casing while unfolding two longer cream guide rails, cross-braces and a travelling structural-rivet carriage. Recoil and fade are presentation-only.

Moving or turning after emission does not drag the manifested relic away from its recorded origin. Reduced effects removes only the secondary glow and impact spark density; driver silhouette, rails, attack boundary and endpoint remain. The current Saint sprite, target selection, timing, damage, hit geometry, repair effects, RNG and save state are unchanged.

All 993 Godot assertions and thirty-one Python manifest checks pass on pinned Godot 4.5.1. Six configured executable fixtures were captured from clean commit `4b65b6915d154ebb08393141ac50e642bcecbbb8` at 1280×800, seed 147, using OpenGL Compatibility on Apple M1 Pro. The full normal-economy, assembly, Evolution and Gift policy suites remain green. These stills do not establish human recognition, normal-speed recoil timing or audio synchronization.

Exactly one next task: manifest Bell, Cable and Foundry Censer with the same event-driven boundary and actual-camera capture gate.

## P22 — manifested Bell, Cable and Foundry Censer

Bell, Cable and Foundry Censer no longer remain as permanent extra attachments during combat. Each physical relic condenses only during bounded readiness or its matching authoritative attack event. Bell appears as an upright bronze dome in a dark frame with a side hammer before its existing cone or Great Toll radial boundary. Cable exposes a rotating reel, travelling line and closing clamp at the recorded endpoint. Censer hangs from a repaired bracket, sways and vents beside its existing low smoke field. The three bodies occupy separate positions around the unchanged Saint so their causes remain visible during overlap.

The simulation still owns every cadence, origin, target, radius, tether, damage, control effect, resource change, RNG result and save value. Reduced effects removes only decorative smoke/glow while preserving mechanisms and gameplay boundaries. Presentation-state tests confirm all three manifestations use recorded event origins and shapes without changing the simulation hash.

All 996 Godot assertions and thirty-one Python manifest checks pass on pinned Godot 4.5.1. Six configured executable fixtures were captured from clean implementation commit `86d1da47888ae20552d94c8bb211d51572fe387d` at 1280×800, seed 147, using OpenGL Compatibility on Apple M1 Pro. The 12/12 normal-economy, 4/4 assembly, 10/10 Evolution and 4/4 Gift policy suites remain green. These stills do not establish human recognition, normal-speed timing, audio synchronization or comfort.

Exactly one next task: manifest the remaining short-lived relic families and stress-test four-weapon overlap at the actual gameplay camera.

## P23 — remaining short-lived manifested relics

Candle-Nailer, Hymn Coil, Altar Mortar and Penance Winch now appear as event-driven physical relics rather than permanent extra attachments. Candle-Nailer exposes a dark wick-fed launcher and expands from one to three violet flames for Candle for the Unreturned. Hymn Coil's paired forks visibly tune into its cyan beam, with a wider coil and separated lanes for Quiet Sermon. Altar Mortar braces and recoils before its shell follows the existing arc, while Workshop Benediction adds its green frame and existing ground seal. Penance Winch turns a ratcheted drum before the articulated hand extends; Long Hand adds a heavier brace and wider reach.

Together with P21/P22, every short-lived weapon now manifests only during bounded readiness or its committed attack event. Procession Gear and Welded Halo retain their appropriate persistent lifetimes. The four-Evolution stress capture assigns separate directions and authored colors so the Saint, nearby threats, projectile endpoints and attack families remain identifiable at the actual gameplay camera. Reduced effects removes decorative layers without removing mechanisms or boundaries.

All 1,000 Godot assertions and thirty-one Python manifest checks pass on pinned Godot 4.5.1. Ten configured executable fixtures were captured from clean implementation commit `add331bafc18750c05740704f626f1979844a49a` at 1280×800, seed 147, using OpenGL Compatibility on Apple M1 Pro. The 12/12 normal-economy, 4/4 assembly, 10/10 Evolution and 4/4 Gift policy suites remain green. These stills do not establish human recognition, normal-speed timing, audio synchronization or aiming comfort.

Exactly one next task: run a normal-speed human readability pass across all manifested and persistent relic families, then tune only observed recognition, overlap and timing failures.

## M1 — First Pilgrimage navigation

Frame and Blessing setup now opens a presentation-only departure map before a run exists. All six chapter sites are inspectable, only Collapsed Workshop can launch, and browsing cannot advance simulation state. Between sites, the same full-screen map separates inspection from commitment: reachable nodes arm the existing stable route ID, future and excluded nodes explain their state, and a separate Travel action sends the authoritative command exactly once.

The destination dossier now presents combat experience, boss/threat, explicitly optional work, waves and estimated combat duration, fare/current Scrap, arrival floor, both road stops and later connections. Current, cleared, reachable, future and route-not-taken states use labels and marker geometry rather than color alone. The carried build remains visible without reintroducing the combat HUD.

Clean implementation commit `64df0eb021443c83ffbc0eb28ece95904b5a3c6e` passes 1,027 Godot assertions and 33 Python manifest checks on pinned Godot 4.5.1. The 12/12 normal-economy, 4/4 assembly, 10/10 Evolution and 4/4 Gift policy matrices remain green. Eleven configured map/road captures cover departure, future inspection, both route tiers, branch exclusion, road handoff and normal/large-text layouts at 1280×800, seed 147. Internal rendered-evidence score: 46/50. This does not establish human comprehension, reading pace or route preference.

Exactly one next task: implement M2 unified site-clear summaries and atomic automatic checkpoints with exactly-once discovery credit.

## M2 — site-clear and checkpoint lifecycle

Every defeated boss now enters one authoritative `site_clear` phase. Workshop, middle and terminal summaries use the same hierarchy to report the site and boss, structure and Scrap, optional-work result, earned road salvage, recovered memory, carried relic build and the exact next action. Workshop opens the pilgrimage map, middle sites open the next destination choice and terminal sites complete the chapter; repeated Continue commands cannot reapply rewards.

Expedition and profile saves now use a shared atomic temporary-write/replacement path with a last-known-good backup. A new pilgrimage retires all prior-run generations. Validated site clears, map continuation, route commitments, each road choice and destination arrival checkpoint automatically. Continue can restore a structurally valid backup when the primary is corrupt; defeat and chapter completion remove primary, temporary and backup run saves.

Profile version 3 allocates unique run IDs and records stable `run_id|site_id` clear receipts. Site fragments and memories are granted once, route discoveries derive from the complete route history, and migration initializes receipts for older completed sites without regranting fragments. Map inspection remains presentation-only.

Clean implementation commit `d3d78304c44586dd807d4e00c5462dcfc50c7f63` passes 1,062 Godot assertions and 34 Python manifest checks on pinned Godot 4.5.1. All 12/12 normal-economy routes, 4/4 assembly builds, 10/10 Evolution routes and 4/4 Gift routes pass. Fifteen configured map/road/site-clear captures include normal and large-text recaps at 1280×800, seed 147. Internal rendered-evidence score: 47/50. Configured fixtures do not establish recap reading, autosave trust or normal-speed route pacing.

Exactly one next task: implement M3 distinct arrival presentation and normal-speed four-path pacing evidence.

## M3 — destination arrival and four-path pacing evidence

Every road now ends at an authoritative, non-ticking `arrival` phase before destination combat. The screen identifies the site and level, combat experience, boss and threat, optional opportunity, waves and estimated duration, exact arrival recovery, cumulative road consequences, current Structure/Scrap and carried build. A distinct Enter action starts combat; reading or repeating that action cannot advance ticks, reroll state or apply recovery twice. Arrival itself and the subsequent combat handoff are automatic checkpoints, and Save & Title remains available.

The clean implementation commit `08f12084d6ae77df8f113f64593f0a642f3c34aa` passes 1,087 Godot assertions and 34 Python manifest checks on pinned Godot 4.5.1. Existing natural matrices remain 12/12 normal-economy routes, 4/4 assembly builds, 10/10 Evolution routes and 4/4 Gift routes. A dedicated M3 1× fixed-tick runner wins Brass→Pale, Brass→Red, Rootworks→Red and Rootworks→Null with a controlled Rank III base build, no Evolution, no completed optional work and four zero-Scrap road choices per run.

Recorded combat totals are 754.90, 758.02, 750.97 and 752.32 seconds. Each route crosses twelve shop boundaries. Final structure is respectively 61, 24, 40 and 80, identifying Brass→Red as the narrowest automated result without proving that it is unfair. Nineteen configured map/road/clear/arrival captures include normal and large-text arrival states at 1280×800, seed 147. Internal arrival evidence score: 46/50.

No human reading time, confusion, boss recognition, difficulty comfort or replay motivation is claimed. Exactly one next task: run uncoached human 1× sessions across all four paths and tune only observed pacing, arrival-comprehension and boss-readability failures.
