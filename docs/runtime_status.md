# First Shift runtime — 0.1.0

The project now contains a runnable Godot 4.5.1 desktop prototype. This is the first implementation, not a finished creative vertical. `content/slices/first_shift.json` is the authoritative enabled catalogue and tuning source; the larger catalogues also contain future concepts.

## Implemented

- Eight 70-second Workshop waves, followed after Foreman victory by one selected four-wave destination. Shop and travel reading time is additional and paused.
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


## SC-15 — compact first-chapter pilgrimage

Foreman victory now opens an authoritative two-route decision instead of ending the expedition. Eight Scrap recovered from the Foreman guarantees both roads remain affordable. Brass Choir Relay costs 8 Scrap and asks the Saint to clear and tune three distributed signal rings; Rootworks Pump costs 6 Scrap and asks it to finish one exposed, persistent pump repair while healer-heavy enemies sustain the crowd. Each destination runs four compact waves, uses a route-specific enemy pool and boss, and ends in its own memory and conclusion.

Route choice, travel beat, selected arena, objective nodes, carried weapons/reserve/catalysts/currencies, boss result, memory and chapter completion are part of version-2 deterministic save state. Version-1 Workshop saves migrate to the expanded state without being rerolled. Presentation sends `choose_route`, `advance_travel` and `accept_memory`; it does not decide arrival, repair progress or completion.

The implementation is a systems-complete chapter proof, not the full Early Access breadth target. It deliberately reuses the current combat roster and procedural visual/audio language. Destination pacing, boss differentiation in motion and the intended 25–35 minute commercial expedition still require human testing.

Evidence: 30 deterministic chapter assertions plus the existing simulation/UI/arena/shop/optional/variety suites. Two seed-147 normal-economy automated policies completed the whole expedition: Workshop Gospel through Brass Choir at 659 simulated seconds and Bell Ward through Rootworks at 655.7 simulated seconds. Actual Godot 4.5.1 desktop fixture captures at 1280×800 cover route choice, Brass travel, both objectives and the Rootworks memory in `artifacts/chapter`. These policy wins are executable evidence, not human playtests.

Exactly one next task: run an uncoached full-expedition playtest on both routes at 1× and tune destination wave pressure from observed comprehension and pacing evidence.
