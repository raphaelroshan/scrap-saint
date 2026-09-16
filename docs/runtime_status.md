# First Shift runtime — 0.1.0

## Sacred ledger presentation (current)

The title now introduces the Saint as born of repairs freely given. An optional ledger is accessible from the title and relic shop, with the manifestation, eight relic histories and six corrupted-machine entries. Shop entry opens the relic section. Keyboard/controller buttons navigate the pages; Escape returns. Reading does not advance the simulation or change offers. The first victory memory recalls an act of freely given repair.

Authored text lives in content/lore/first_shift.json. No combat, currency, repair or save rules changed. All 30 page/scale combinations rendered and preserved the simulation snapshot; title/shop return checks passed. Existing 170 regression checks and content validation passed. The full-run sweep reproduced the recorded W-02a result: 11/12 wins, with Mourner seed 104730 timing out at the Foreman with 100 health. The all-win gate remains failed, so the standard loop stopped before its general capture stage. Dedicated new UI fixtures were captured independently and inspected; no older general captures are claimed as fresh evidence.

Captures, exact source/content hashes and ten scored visual observations are in artifacts/sacred-ledger. Normal and large text use a 1280x800 viewport on Godot 4.5.1. The initial sandboxed graphical launch crashed before rendering; reviewed elevated execution produced valid captures and exited cleanly. This is fixture evidence, not human playtesting.

Limitation: creature pages share a generic corruption emblem; bespoke portraits, combat expression of the new lore and human tone testing remain outstanding.
Exactly one next task: give Nailer and Bell more tactile attack preparation and aftermath in ordinary combat.

The project now contains a runnable Godot 4.5.1 desktop prototype. This is the first implementation, not a finished creative vertical. `content/slices/first_shift.json` is the authoritative enabled catalogue and tuning source; the larger catalogues also contain future concepts.

## Implemented

- Eight 70-second maximum waves, with the final boss ending the run early when defeated. Shop reading time is additional and paused.
- Three starting Blessings, five automatic weapon geometries, four catalysts, four active slots and one reserve.
- Movement, relay work/structure, pickups, three enemy families, elite and phased boss attacks.
- Purchases, automatic duplicate combining, explicit combine, sell/dismantle, reserve/equip, offer lock and one free/two paid refreshes.
- Optional Rank III Nailer plus Saint's Rivet evolution. The catalyst is consumed once. Every encounter supports runs without it.
- Procedural weapon effects and synthesized audio, title/selection/shop/pause/Results, keyboard and basic controller navigation, local save/resume.
- Deterministic simulation tests and full-run scripted policies; real rendered fixture captures with provenance.

## Exact prototype rules

Relay progress persists outside the work radius. Proximity work progresses repairs for every build and restores structure. Winning requires completed repairs, surviving relay and Saint, and Foreman defeated before wave eight expires. Completing repair alone does not end the run.

Two copies of the same rank combine into the next rank, up to III. Purchase previews explain automatic combining. The transaction validates final inventory capacity before spending. The last active weapon cannot be sold or stored. Ordinary sales return floor(60% of base cost times invested copy count); dismantling returns 40% without extra component currencies. Combine itself costs no currency in this prototype.

Blessing fulfilment counts two distinct active weapon IDs sharing the doctrine's principal tag: Labour, Witness, or Mourn. Reserve, catalysts, ranks and duplicate IDs do not increase this count. Workshop fulfilment increases proximity work; Bell fulfilment marks staggered enemies for extra damage; Mourner fulfilment creates healing motes more often. These replace the underspecified catalogue fulfilment placeholders for this prototype.

The three doctrine services are deliberately small: Workshop restores Saint/relay structure, Bell offers a Shard and forecast flag, Mourner restores Saint structure and grants a Shard. Full rebuild/refund and elite-remnant services from the long-term bible are deferred. The forecast is already visible to all builds; Bell's flag currently has no additional informational advantage beyond its Shard reward.

The Nailer pierces up to two targets, Bell staggers/pushes a cone, Gear deals orbital contact damage, Candle targets low-health enemies and leaves healing motes on kills, Cable binds/pulls a cone. Mercy Rail changes line width/range/damage and repairs relay structure on major-enemy hits. Additional authored secondary effects, including Scoured and Consecrated interactions, remain future work and are not shown as active promises in the runtime UI.

The Crane copies rail geometry if an evolution exists and otherwise telegraphs a circular attack. Foreman phases add worker waves and an additional demolition circle; shrinking-floor mechanics are deferred. Bosses hold outside relay contact range, so they threaten it through telegraphed demolition and workers. Choir fields slow weapon cycling rather than disabling an unimplemented active-skill system. Mites return stolen Scrap on defeat. All of these are shared rules, not adaptations to the selected player build.

## Evidence limits

Screenshots are actual Godot renders from scripted visual fixtures. Fixtures explicitly supply shop budgets, position stages, and set up the Results presentation; they are not evidence of a naturally completed run. Full-run policies separately exercise normal income and commands without bonus health/currency. Passing these establishes executable routes and regressions, not human enjoyment or balanced difficulty. No human playtest, controller hardware session, or sustained performance benchmark has been claimed.

Art is original procedural placeholder geometry drawn by the renderer. Audio is original synthesized placeholder audio in `game/sound.gd`. Both were created on 2026-09-14, use no downloaded art/audio assets, and require later art direction/feel iteration. System fonts use installed fallbacks; no font files are redistributed.

## Remaining limitations

Settings are basic; full remapping and persisted settings are not implemented. The fixed simulation is replay-tested within the pinned engine/platform, not certified cross-platform. Save files are local version-1 snapshots, with no migration support yet. Content tuning, shop breadth and secondary effects remain prototype-level. The visual fixtures do not certify all effects as readable in motion.

Exactly one next task: human playtest of the shared arena and build feedback.


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


## P12 - larger roaming arena and combat variety (current)

The chosen main mode remains free movement with optional repairs. The user rejected P11 manual boss interruption; E/X interrupt, exposure bonuses and their HUD prompts are removed.

Collapsed Workshop is now 1600 x 1120 world pixels (40 x 28 logical metres), four times its previous area. A following camera, minimap, two additional solid industrial obstacles and outer yard zones support roaming. Optional reward machines are distributed west, north and east. Optional-mode enemies spawn around the Saint at 460 pixels where walkable rather than only at distant fixed gates.

Seven base weapons are playable. Hymn Coil is a fast piercing beam (4 damage every 8 ticks, range 420); Altar Mortar is a cluster burst at the nearest target (38 damage every 100 ticks, radius 72). Both participate in the existing shop/rank/build systems. Six ordinary enemy families now include Rust Pilgrim (periodic nearby-ally healing), Forklift Brute (heavy charge and contact shove) and Cinder Spitter (a delayed blast locked to the Saint's earlier position). These use ordinary movement and automatic combat; no extra input or weapon-specific encounter requirement.

The previous relay-defence policy suite produced 9 wins and 3 losses after roster expansion; this is retained as a balance regression in the development comparison mode. Current main mode records 11/12 wins; Mourner seed 104729 dies on wave five. All twelve skip optional repairs. The all-win gate therefore remains failed, while 129 Godot assertions pass. Rendered evidence and exact provenance are recorded in artifacts/variety.

Limitation: automated fixtures and policies do not establish human pacing, balance or audio quality. Capture teardown still reports an ObjectDB leak warning.
Exactly one next task: playtest roaming density and weapon/enemy balance at 1x.


## P14 - relic shop and repair drops (current)
The user moved recovery out of main-mode shop services. All six cards now offer relics: four weapons and two unowned catalysts when available, with weapon fallback when catalysts are exhausted. Repeated IDs are excluded; a held offer is preserved. Legacy relay comparison keeps its historical service shop. Old optional-mode shop saves containing services migrate to relic offers.

Every twelfth defeat drops a repair kit worth 15 Saint integrity. Kits are ordinary field pickups, cannot over-heal, are consumed once and remain available at full health until the wave ends. Candle/Mourner healing motes and optional map machines remain. No new currency or inventory slot is added.

Main-mode cards show distinct attack icons, behaviour labels, base damage/cycle, owned ranks, rank-combine outcome, cost, and disabled purchase reasons. Purchases update the equipped column. The UI uses the existing lock/refresh/reserve/evolution commands and supports normal and large text. Damage/cycle is explicitly the rank-I base; catalysts and enemy fields can modify actual output.

The user's P14 decision supersedes service-card recommendations in the improvement plan. Recovery and build choices are now separate activities in the main mode.
Limitation: repair-drop cadence and the new offer economy require human balance testing; automated wins are not enjoyment evidence.
Exactly one next task: playtest relic purchases and repair-drop availability at 1x.

P14 verification: 154 Godot assertions pass (129 existing + 25 relic-shop/pickup checks). Final main-mode policy sweep: 12/12 wins across three seeds and evolved/unevolved variants. Actual normal-text, large-text, purchased and repair-drop fixtures were inspected. Results and exact source/content provenance are in `artifacts/relic-shop`. The earlier capture formatting error was corrected and the final capture exits without script errors.


## W-02a - Penance Winch (current)
Penance Winch is the eighth enabled automatic weapon and the only implemented weapon from the new expansion proposals. It costs 19 Scrap, deals 34 base damage, has 440 range and a 210-tick (3.5s) base cycle. Rank combining uses the existing damage scaling. Foundry Censer, Welded Halo, Gifts and Confluences remain proposals.

It locks the furthest living enemy between 110 and 440 pixels with clear line of access. It prepares for18 ticks, extends for12, deals one hit and holds for8, reels for24, then retracts for12. It pulls at most180 pixels toward the Saint and stops at110 separation, using body collision. Targets that die, leave range or move behind solid machinery before contact cannot be hit; it never silently retargets that cast. Pulling ends if access is lost. Major enemies remain eligible. Quiet Gear, calibration and Choir fields modify cooldown through the existing rules. Holding interrupts ordinary movement/charges; boss hazard scheduling remains separate.

Simulation owns the complete phase state. Rendering reads it to animate three brass arm segments, elbow joints, braces, a spool, inspection lamp and hooked tip, including a folded idle pose. RankII adds braces. The shop has a hook icon and explicit distant-hook/pull role. Audio uses an original synthesized preparation ratchet and hook impact; no licensed source audio. Save/replay preserve a mid-hook cast and pause freezes it; entering shop clears an unfinished cast.

Evidence: 16 dedicated assertions cover target selection, delayed single damage, movement/stop distance, cover, target loss, pause, save/replay and rank purchases. Real prepare/extend/hook/pull/retract and shop fixtures are in artifacts/winch. Fixtures use deliberately placed enemies and a supplied rankII weapon; they are not natural playthrough captures.
Limitation: forceful automatic pulls, mixed-effect readability and audio weight still need human testing at1x.
Exactly one next task: playtest Penance Winch alongside Cable and close-range weapons at1x.

W-02a verification: 170 Godot assertions and four manifest checks pass. Full-run sweep:11/12 main-mode wins. Mourner seed104730 times out at the Foreman with100 health; the all-win gate remains failed. This is a recorded build/economy or targeting regression, not evidence of a solved balance gate. Six Winch/Shop renders were inspected and scored; exact provenance is in artifacts/winch.
