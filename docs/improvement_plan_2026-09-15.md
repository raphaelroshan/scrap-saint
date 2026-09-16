# Scrap Saint — Improvement Plan and Design Resolution Backlog

## Current direction — 2026-09-17

This document retains historical planning below. The enabled 0.5 preview now has ten weapons, ten Evolutions, seven Gifts, four Blessings, three frames and a branching three-site expedition. The old seven-weapon count and Mourner wave-five failure describe earlier builds, not the current gate. Current verification and limitations are recorded in docs/runtime_status.md (runtime_status.md from this folder).

User decisions govern integration: the Saint manifests through repairs freely given; main-mode shops contain six relics with healing supplied by drops and optional work; destination work is optional too. Preserve upstream rank, chapter and animation systems. Commit and push completed validated changes so collaborators share the same build.

The next task after this integration is reducing evolved-effect overlap around the Saint. Historical next-task paragraphs below do not supersede this order.

**Date:** 2026-09-15
**Status:** P12 runtime audit and prioritized game-quality plan.
**Current build:** Godot 4.5.1 desktop prototype, version 0.1.0.
**Audience:** Astra, gameplay programmers, content designers, technical artists, QA agents, and future collaborators.

## Executive conclusion

Scrap Saint has crossed the most important early threshold: it is now a runnable prototype rather than only a design foundation. The current build implements an eight-wave roaming arena, optional repair machines, seven automatic weapons, six ordinary enemy families, three Blessings, a six-position shop, rank combining, catalysts, optional Mercy Rail, Memory Crane, Foreman Engine, save/resume, controller navigation, synthesized audio, and rendered fixture captures.

The main problem has changed. The project no longer primarily needs more systems. It needs **game-quality proof and balance discipline**.

The current evidence is encouraging but incomplete:

| Evidence | Current result | Interpretation |
|---|---:|---|
| Content validation | Pass: 11 items, 2 evolutions, 3 Blessings, 7 enemies, 3 bosses | Data references are structurally valid. This is not a game-quality pass. |
| Automated Godot assertions | 129 pass in the current variety build | Simulation, arena, shop, relay, optional repair, UI, and variety regressions execute. |
| Main optional-repair policy runs | 11 of 12 wins | The prototype is broadly executable, but the Mourner run on seed 104729 fails on wave five. |
| Relay comparison runs | 9 of 12 wins after roster expansion | The legacy mode is a useful diagnostic comparison, not the current product direction. |
| Rendered captures | Real Godot renders with provenance | Fixtures prove presentation states can render; configured fixtures are not natural playthrough evidence. |
| Human playtesting | Not performed | Responsiveness, pacing, pressure, audio density, and preference remain unproven. |
| Performance | No sustained benchmark | Hardware targets and peak-density performance remain unverified. |

The accepted direction is now:

> **Free movement through a larger industrial workshop, automatic weapons, optional repair machines that reward exploration, seven meaningful weapons, and a Foreman encounter that is solved through movement, targeting, and build quality rather than a mandatory manual interrupt.**

Relay defence remains a development comparison mode. It is not the main product direction. Mercy Rail is an optional build transformation. It must be valuable without becoming a hidden victory requirement.

The next improvement should therefore be **1× roaming-density, weapon-role, enemy-composition, and economy tuning**, not a new campaign, new permanent progression tree, or a new inventory system.

## 1. Current runtime audit

### 1.1 What is now implemented

| System | Current implementation | Current limitation |
|---|---|---|
| Engine and shell | Godot 4.5.1, fixed-tick simulation, title screen, Blessing selection, pause, save/resume, controller navigation, 1× and 5× development launchers. | Cross-platform certification and save migration are not implemented. |
| Main mode | Optional repairs are the default. The player roams freely, fights automatically, and repairs three distributed machines for Scrap, healing, or a stagger pulse. Repairs are never required to win. | Reward motivation, travel density, and repair risk still need player-quality tuning. |
| Comparison mode | Relay defence remains available in development mode and old saves preserve their mode. | It is a diagnostic mode, not the main launch foundation. |
| Arena | Collapsed Workshop expanded to 1600×1120 world pixels with a following camera, minimap, four solid obstacles, outer yard zones, and three named entry regions. | The larger space may have low-pressure travel intervals and needs 1× density review. |
| Run cadence | Eight 70-second maximum waves, seven shop boundaries, wave-six Memory Crane, wave-eight Foreman Engine, and early termination when the boss dies. | The exact time-to-decision rhythm and late-run density are not yet human-validated. |
| Weapons | Nailer, Bell, Procession Gear, Candle-Nailer, Cable, Hymn Coil, and Altar Mortar. All are automatic and participate in the same shop/rank system. | Secondary effects are uneven. Hymn Coil and Altar Mortar currently provide geometry and damage but limited doctrine interaction. |
| Builds | Four active weapon slots, one reserve, duplicate combining through Rank III, catalysts, sell/dismantle, lock, refresh, and equip/store. | Gifts or a separate trait layer does not yet exist. Catalysts currently carry most support behaviour. |
| Blessings | Workshop Gospel, Bell Ward, and Mourner. Their services and fulfilment are implemented in a smaller prototype form. | Bell’s forecast flag currently gives no meaningful informational advantage beyond its Shard reward. |
| Optional repairs | Three machines: Scrap reward, Saint healing, and enemy stagger pulse. Progress persists and rewards are one-time. | Healing at full structure or a warning pulse with no nearby enemies can waste a reward. |
| Enemy roster | Rivet Hound, Scrap Mite, Choir Drone, Rust Pilgrim, Forklift Brute, and Cinder Spitter. | Current wave selection is still more random pool than authored encounter composition. |
| Elite and boss | Memory Crane copies rail geometry when an evolution exists. Foreman uses hazards and worker waves. Manual interrupt was removed from the accepted direction. | Boss phases and worker priority need stronger movement and targeting questions in the large arena. |
| Evidence | Runtime status, implementation packets, verification history, provenance, 129 assertions, and real rendered fixtures. | Fixtures use supplied positions/budgets, and no natural 1× human session has been captured. |

### 1.2 What is strong enough to preserve

The following should not be redesigned while balance work is still incomplete.

1. **Warm industrial devotional identity.** The Saint is a repair machine, not a conventional soldier or generic survivor character.
2. **Free movement and automatic attacks.** Do not add manual aiming or an ability-bar stack to solve current balance problems.
3. **Optional repairs as the main mode.** Repair machines should become better rewards and movement anchors rather than mandatory relay chores.
4. **Two run currencies.** Keep Scrap and Relic Shards. Do not add a third currency to compensate for weak shop choices.
5. **Four active weapons plus one reserve.** This is enough capacity to create build decisions without introducing a backpack grid.
6. **Blessings as doctrines.** A Blessing should bias the shop and alter the run, but it must not prescribe one exact weapon path.
7. **Visible transformations.** Mercy Rail and future evolutions must alter geometry, targeting, status behaviour, or objective interaction.
8. **Deterministic simulation authority.** Presentation, fixtures, and UI commands must continue to consume state and events rather than award outcomes.
9. **Original procedural placeholder art and synthesized audio.** These are valid for tuning. They should be replaced selectively after the main frame is fun and readable.
10. **Automated evidence before expansion.** The current 129 assertions and policy runners are valuable. They should become stricter and more informative before new content is added.

## 2. What still needs to be figured out

The remaining questions are now product-quality questions rather than premise questions. Each includes a recommended default and a proof method.

| Priority | Question | Why it matters | Recommended default | Proof method |
|---:|---|---|---|---|
| P0 | Is the larger arena too empty at 1×? | Four times the earlier area can create dead travel and weaken automatic-combat tension. | Use authored pressure zones, machine landmarks, and measured spawn windows. Do not simply multiply enemy count. | 1× captures plus travel-time, enemy-contact, and decision-gap metrics. |
| P0 | Why should the player repair an optional machine now? | Current policies skip all optional repairs, showing that rewards do not yet justify the detour. | Make each machine a distinct risk/reward contract with a visible reward preview and a short, interruptible work window. | Three policy profiles plus real 1× capture of each reward. |
| P0 | Why does Mourner fail on wave five? | The only current main-mode loss indicates a doctrine or encounter-specific viability issue. | Diagnose whether the failure is crowd clear, healing cadence, shop affordability, or Cinder/Rust pressure before buffing Mourner globally. | Seed 104729 event trace, purchase log, weapon ranks, damage sources, and controlled reruns. |
| P0 | Are seven weapons actually distinct? | More weapons can hide role overlap and make shop choice noisy. | Keep seven, but assign each a primary question, counter family, and failure case. | Weapon-role matrix and 1× comparison fixtures. |
| P1 | Does the shop create real choices? | Current offers can be unaffordable or redundant, especially calibration. | Preserve six roles, but guarantee one affordable actionable choice and one future path without making every card free. | Affordability traces across three player profiles and shop replay tests. |
| P1 | Are the three Blessings meaningfully different? | Workshop, Bell, and Mourner can otherwise be starting weapon skins. | Give each a distinct service, fulfilment behaviour, shop bias, and weakness. | Same seed, same movement policy, three doctrine runs. |
| P1 | What should traits or Gifts be? | A new trait layer can duplicate catalysts and inflate stat complexity. | Do not add Gifts until weapons, catalysts, and shop decisions are stable. Later add two support slots with behaviour-changing Gifts, not generic stat piles. | Schema and interaction tests after the first balance gate. |
| P1 | How should the Foreman test the player now that interrupt is removed? | The old interrupt plan is obsolete, but the boss still needs a distinct question. | Use moving hazard placement, worker priority, safe-lane pressure, and phase-specific target rules. | Boss traces and captures with non-evolved and evolved builds. |
| P1 | Is the eight-wave cadence satisfying? | Seven shops and 70-second waves may create either repetition or insufficient transformation time. | Keep eight waves for now. Tune the wave composition and shop contents before changing the count. | Track first purchase, first rank-up, first catalyst, elite pressure, and boss arrival. |
| P2 | What is the permanent progression hook? | Local save/resume exists, but campaign persistence and route choice are not yet runtime systems. | Add Memory Fragments and authored route unlocks only after the current run loop has a stable replay rate. | Fresh-save and unlocked-save comparisons. |
| P2 | Which map should follow the Workshop? | More maps will not help if they only change art. | Add Rootworks Pump next, with a new spatial question around moving repair fronts. | Topology test plus route-choice and reward capture. |
| P3 | What is the commercial art/audio replacement order? | Placeholder assets are useful but can become permanent by inertia. | Replace hero Saint, three core enemies, Foreman, shop, and Mercy Rail before background breadth. | Before/after visual rubric and store-frame review. |

### 2.1 Highest-risk unresolved design decision: optional repairs

The accepted main mode is correct for the desired freer movement, but the current implementation treats repairs as optional proximity interactions with automatic progress. The evidence that all twelve automated optional policies skip repairs is not a failure of the premise. It shows that the reward is currently underpriced relative to travel, combat, or attention cost.

The recommended repair contract is:

1. The player approaches a named machine.
2. A visible three-second work ring begins when the Saint remains within the work radius.
3. Movement outside the radius, severe knockback, or a direct hit pauses progress rather than deleting it.
4. Enemies continue to spawn and can make the work unsafe, but the machine is not itself a health bar or kill target.
5. The player sees the reward before starting: `+8 Scrap`, `+30 structure`, or `stagger living enemies`.
6. Completion grants a one-time reward and a strong local cue.
7. The three machines are distributed so that the player can choose one or two, not sweep all three by default.

Do not make repair mandatory. Do not make repair free healing with no opportunity cost. Do not make the reward a silent stat increase. The player should be able to say, “I am going there because this reward solves my current problem.”

Recommended machine placement:

| Machine | Position role | Reward | Best use |
|---|---|---|---|
| Salvage Sorter | West detour with moderate travel time | +8 Scrap or a shop discount token later | Evolution and shop economy. |
| Coolant Pump | North route near elite pressure | +30 Saint structure, capped | Recovery before late waves. |
| Warning Bell | East route near ranged pressure | Stagger living enemies for 180 ticks | Space creation before a dangerous wave. |

The immediate prototype should keep automatic repair by proximity. A button-held work command is not required yet. The first improvement is **risk, visibility, and reward timing**, not input complexity.

## 3. Run structure and pacing plan

### 3.1 Current run contract

The current run is eight combat waves of up to 70 seconds with a paused shop between waves. Memory Crane arrives on wave six. Foreman Engine arrives on wave eight and ends the run early when defeated. The target is approximately nine minutes of combat plus shop decisions.

Keep this cadence while tuning. Do not redesign the run into a 20-minute mode until the following moments are consistently readable:

- First threat.
- First shop purchase.
- First optional repair decision.
- First meaningful rank combine.
- First elite pressure.
- First catalyst or evolution decision.
- First boss hazard.
- Results explanation.

### 3.2 Recommended wave composition

The current runtime should move from a mostly random enemy pool toward authored composition bands. Randomness should select positions and small variations inside a defined pressure family.

| Wave | Primary pressure | Supporting pressure | Player question |
|---:|---|---|---|
| 1 | Scrap Mites | Light Rivet Hounds | Can I move, collect, and recognize danger? |
| 2 | Rivet Hounds | Scrap Mites | Can I protect structure without standing still? |
| 3 | Choir Drones | Hounds | Can I reach support threats before their field dominates? |
| 4 | Cinder Spitters | Mites | Can I read delayed danger and keep moving? |
| 5 | Rust Pilgrim | Hounds or Mites | Do I focus the repairer or clear the immediate threat? |
| 6 | Memory Crane | One support family | Can I answer a build-shaped elite? |
| 7 | Forklift Brute | Cinder Spitters or Hounds | Can I preserve space after displacement? |
| 8 | Foreman Engine | Worker Hounds plus hazards | Can I route through a shrinking pressure pattern and finish? |

Do not make each wave a strict single-enemy tutorial. Use a clear primary pressure and one support family. The first encounter with a new family should have lower density and longer telegraphs. The second encounter should test a combination.

### 3.3 Metrics for 1× tuning

The agent should record these metrics for seeds 147, 104729, and 104730 under all three Blessings:

| Metric | Initial target or diagnostic |
|---|---|
| Time to first enemy contact | Short enough that the arena does not feel empty; record rather than hard-code before capture review. |
| Longest no-threat travel gap | No unexplained empty interval during an active wave. |
| Enemy-contact density | Enough to create movement decisions without permanent body-blocking. |
| First shop arrival | After the player has seen one complete pressure question. |
| First affordable purchase | Available without requiring perfect Scrap collection. |
| First rank combine | Achievable for at least two of three starting doctrines on representative seeds. |
| Optional repair completion | At least one machine is attractive in a normal run without being mandatory. |
| Wave-five Mourner survivability | Must be explained and either corrected or deliberately accepted as a documented challenge. |
| Boss arrival | Enough time to understand the final shop and threat forecast. |
| Run failure cause | Must classify as positioning, threat response, economy, or build geometry rather than unexplained attrition. |

## 4. Weapon and evolution plan

### 4.1 Weapon role matrix

The seven weapons should remain, but each must have one dominant purpose and one clear weakness.

| Weapon | Current runtime geometry | Primary role | Secondary role to add or clarify | Weakness to preserve |
|---|---|---|---|---|
| Nailer of Small Mercies | Two-target line | Precision and priority damage | Mark objective-relevant or elite targets. | Weak swarm coverage. |
| Bell of the Last Shift | Forward cone | Stagger, push, and space creation | Make Witness state visible and useful to shop/fulfilment. | Weak sustained single-target damage. |
| Procession Gear | Orbit | Close defence while roaming or repairing | Stronger near restored machines or Consecrated zones later. | Weak at long range. |
| Candle-Nailer | Weakest-target shot | Execute damaged enemies and create healing motes | Make Mourned or mote economy legible. | Low crowd clear and dependent on kills. |
| Cable of Contrition | Sweep/tether cone | Delay, pull, and route control | Make Bound enemies leave a short slow or redirect line later. | Low burst. |
| Hymn Coil | Rapid piercing beam | Line clear and ranged pressure response | Add a controlled Quieted interaction after base balance. | Narrow line and low per-hit damage. |
| Altar Mortar | Cluster burst | Area denial and clustered enemy clear | Add delayed ground warning and a later Consecrated interaction. | Slow cadence and poor emergency defence. |

The first balance pass must not make every weapon equally good at every task. The goal is that a player can explain why they purchased a weapon.

### 4.2 Weapon damage and cadence audit

The current data has large differences in damage and cooldown. That is acceptable only if the geometry and target access justify them. The agent should calculate and log effective damage per second against representative targets, but balance by **time-to-solve the intended question**, not raw DPS alone.

| Test target | Weapons that should excel | Weapons that should struggle |
|---|---|---|
| Scrap Mite cluster | Procession Gear, Hymn Coil, Altar Mortar | Nailer, Cable. |
| Relay charger or Hound | Nailer, Bell, Cable | Slow Mortar if caught late. |
| Support drone | Nailer, Candle-Nailer, Hymn Coil | Orbit-only Gear at distance. |
| Armoured Rust Pilgrim | Hymn Coil after Scour is implemented, Nailer focus | Mite-oriented orbit builds. |
| Forklift Brute | Cable, Bell, Mortar | Candle-Nailer without support. |
| Cinder Spitter | Nailer, Candle, Bell movement control | Short-range Gear without route support. |
| Foreman workers | Bell, Mortar, Gear, Hymn | Single-target Candle without crowd support. |

A weapon should not be buffed globally because it loses a matchup it was not designed to solve. If the shop cannot provide a valid counter to the next wave, fix offer generation or encounter composition first.

### 4.3 Evolution sequence

Mercy Rail is now optional and should remain optional. It must be a satisfying transformation, not a hidden completion condition.

| Stage | Evolution | Recommended work |
|---|---|---|
| Current | Nailer Rank III + Saint’s Rivet → Mercy Rail | Audit visual readability, target priority, damage, repair interaction, and catalyst opportunity cost. |
| Next | Bell Rank III + Cracked Bell Clapper → The Great Toll | Add only after Bell’s base role and service are viable; change cone into radial pulse and create a meaningful crowd-control reset. |
| Following | Procession Gear Rank III + Pilgrim Spindle → The Maintenance Parade | Add moving Consecrated repair stations or a roaming orbit route. |
| Later | Cable, Candle, Hymn, and Mortar evolutions | Add one at a time when a new objective or enemy question requires it. |

The first evolution audit should answer:

- Can a non-evolution run win without relying on perfect damage?
- Does the player understand what Mercy Rail changed within one combat beat?
- Is the Saint’s Rivet worth buying instead of immediate Scrap or another catalyst?
- Does the Memory Crane copy create a new question rather than a punishment for trying the evolution?
- Does the shop show a credible alternative when the player does not want Mercy Rail?

## 5. Traits, catalysts, buffs, and status plan

### 5.1 Do not add a separate Gift inventory yet

The runtime already has catalysts, active weapon slots, reserve, Blessing services, and optional repairs. Adding a separate trait inventory immediately would make build state harder to read and would obscure why the Mourner run fails.

For the next balance milestone, treat catalysts as the support layer:

- Saint’s Rivet: repair-rate bonus and Mercy Rail eligibility.
- Cracked Bell Clapper: control-duration bonus and future Great Toll eligibility.
- Black Candle: additional mote cadence.
- Quiet Gear: cooldown reduction.

The next content task should add a proper Gift schema only after the following conditions pass:

1. All three Blessings have viable main-mode runs across representative seeds.
2. All seven weapons have a clear role.
3. The shop has no frequent redundant or unaffordable dead visits.
4. Optional repairs create at least one attractive decision.

When Gifts are added, use two support slots and behaviour-changing effects rather than generic `+10% damage` items.

### 5.2 Recommended future Gifts

| Gift | Behaviour change | Trade-off |
|---|---|---|
| Inspection Lens | Reveals one elite property and improves target certainty. | Lower ordinary Scrap yield. |
| Spare Hand | Shortens repair exposure time. | Slower movement while working. |
| Loose Spring | Repair completion grants a brief movement burst. | Reduced structure during the burst. |
| Black Ledger | Dismantling returns a defined component tag. | Lower direct sell value. |
| Choir Filter | Quieted enemies cannot immediately recreate support fields. | Lower crowd damage. |
| Mourner’s Thread | One healing mote can intercept one hit. | Requires recent defeats to activate. |
| Brass Fuse | The next staggered target becomes Marked. | Longer Bell cooldown. |
| Tether Spool | Bound enemies leave a temporary slow line. | Reduced pull distance. |

Do not introduce these as a rarity ladder. Each Gift should be a small rule that changes a decision.

### 5.3 Buff and status rules

The runtime should standardize visible status behaviour before adding many new statuses.

| Status | Current or planned role | Required presentation |
|---|---|---|
| `MARKED` | Target priority and compatible damage interaction. | Clear seal or target reticle. |
| `RUNG` | Stagger and cancelled windup. | Resonance rings and interrupted pose. |
| `BOUND` | Slowed or redirected movement. | Visible cable line. |
| `QUIETED` | Later support-action suppression. | Cold cyan field and muted support icon. |
| `SCOURED` | Later armour reduction. | Exposed plates or pale fracture mark. |
| `MOURNED` | Remnant or mote-producing defeat. | Candle or spirit remnant. |
| `CONSECRATED` | Later machine or objective zone benefit. | Cream repair ring. |

Every status needs a deterministic duration, stack limit, refresh rule, removal rule, source event, and failure explanation. Do not add a new status when an existing one can express the intended question.

## 6. Blessing and shop plan

### 6.1 Blessing differentiation

The three current Blessings are the correct first set. Their current runtime services are small, but Bell’s service needs a stronger identity.

| Blessing | Current identity | Required improvement |
|---|---|---|
| Workshop Gospel | Repair-rate and restoration support. | Make the player choose between faster repairs and immediate combat purchases; show the effect on optional-machine progress. |
| Bell Ward | Control, stagger, and warning service. | Replace the current mostly redundant forecast flag with a concrete next-wave preview: primary family, first pressure timing, or boss hazard count. |
| Mourner | Candle-Nailer, healing motes, recovery. | Diagnose wave-five failure before buffing. Improve the conversion between kills, motes, and survivability only if the trace shows recovery is too delayed. |

Blessing fulfilment should remain easy to understand. The current prototype uses two distinct weapon IDs carrying the doctrine’s principal tag. That is acceptable as an interim rule, but the UI should show the two qualifying weapons and the resulting reward.

### 6.2 Six-role shop contract

The current six positions are a good foundation:

1. Build improvement.
2. New direction.
3. Evolution path.
4. Threat support.
5. Field repair.
6. Blessing service.

The next shop pass should enforce **decision quality**, not universal affordability.

| Shop requirement | Recommended rule |
|---|---|
| Build improvement | At least one offer must be an affordable upgrade, combine, or valid capacity-preserving purchase for a normal run. |
| New direction | Show a weapon outside the current owned IDs, but do not fill the slot with a weapon that cannot fit after combining. |
| Evolution path | Show Mercy Rail support when relevant, but show a valid non-evolution alternative in the same visit. |
| Threat support | Select from the next wave’s actual pressure family rather than a broad generic catalyst list. |
| Field repair | Show the field option only when there is a meaningful structure or optional-machine opportunity. Otherwise use another flexible support. |
| Blessing service | Explain the mechanical effect in plain language and show whether it is already used. |

Current limitations to fix:

- Some offers are not affordable.
- Fully exhausted builds can receive redundant calibration cards.
- Locked flexible offers can subordinate the intended role.
- The Bell service does not yet give a meaningful informational advantage.
- The current shop is still largely item text plus buttons rather than a build diagnosis tool.

The next UI pass should show, for each offer: `role`, `cost`, `what changes now`, `next-wave relevance`, `evolution contribution`, and `why unavailable` when rejected.

### 6.3 Economy recommendations

Keep the current two-currency economy. Tune the distribution around optional repairs and the seven-wave shop rhythm.

| Player profile | Desired viable outcome |
|---|---|
| Survival player | Buys immediate coverage, completes at least one useful repair, and reaches Foreman with a coherent build. |
| Evolution player | Can buy or earn the Saint’s Rivet, reach Rank III, and trigger Mercy Rail without perfect collection. |
| Explorer player | Can repair one or two machines, buy a new-direction weapon, and still afford a later defensive choice. |
| Mourner player | Can turn kills into enough recovery or control to survive wave five without requiring a special fixture budget. |

A failed shop decision should be attributable to the player’s choice or a documented scarcity trade-off. It should not be caused by the generator presenting six irrelevant or impossible cards.

## 7. Map and roaming plan

### 7.1 Current arena strengths

The expanded Collapsed Workshop now has meaningful named regions, obstacles, a following camera, minimap, and multiple entry edges. The geometry is connected and has passed topology and route tests. This is a strong base for the free-roaming direction.

### 7.2 Current map risk: empty travel and threat detachment

The larger arena creates two new risks:

1. The player may spend too long travelling without a decision.
2. Enemies may spawn around the Saint without giving the player a readable relationship between location, machine, and pressure.

The answer is not to fill every metre with enemies. The answer is to create **pressure geography**.

Recommended additions:

| Map element | Function |
|---|---|
| Machine approach marker | Shows reward, estimated work time, and current risk before the player commits. |
| Pressure lane | A region where the next wave’s primary family is more likely to arrive. |
| Salvage pocket | Contains Scrap pickups or a repair machine but costs travel time. |
| Recovery pocket | Provides line-of-sight or space, not free invulnerability. |
| Boss route | Gives Foreman hazards visible destinations and prevents random arena-wide noise. |
| Landmark minimap icon | Makes route choices legible without forcing constant minimap reading. |

### 7.3 Optional repair routing

Keep three machines, but tune their positions and rewards so a normal run wants one or two rather than zero or all three. A machine should be close enough to reach within one pressure beat and far enough to create a decision.

Use deterministic metrics:

- Distance from current likely path.
- Time to reach at current movement speed.
- Time to complete the work ring.
- Enemies spawned during the work window.
- Reward value relative to the next shop cost.
- Whether the reward is wasted at full structure or with no nearby enemies.

A reward should never be silently wasted. If the Coolant Pump would heal zero structure, show a warning and allow the player to leave it for later. If the Warning Bell has no active enemies, it may still grant a short next-wave forecast benefit instead of a wasted stagger.

### 7.4 Future maps

Do not add a second map until the Workshop has a stable density and repair decision profile. The first follow-up should be **Rootworks Pump**, which introduces moving repair fronts and cable-shaped routes. Brass Choir Relay and Red Foundry should follow only when timing and hazard composition are ready.

## 8. Enemy and boss plan

### 8.1 Current enemy roles

| Enemy | Current role | Required tuning question |
|---|---|---|
| Scrap Mite | Pickup denial and swarm | Does it create collection risk without stealing too much economy? |
| Rivet Hound | Charger and direct pressure | Can the player read, avoid, and punish the charge? |
| Choir Drone | Support and slow field | Does it create a meaningful priority target at roaming distance? |
| Rust Pilgrim | Nearby ally healer | Is Scour, focused damage, or silence actually available when it appears? |
| Forklift Brute | Heavy charge and shove | Does displacement create route decisions rather than random frustration? |
| Cinder Spitter | Delayed ranged blast | Is the earlier-position telegraph visible and avoidable at 1×? |
| Memory Crane | Elite copy | Does copying rail geometry test build identity without invalidating non-evolved runs? |

### 8.2 Spawn composition

The runtime currently selects from a growing type pool by wave. Convert this to authored wave bands with deterministic weighted variation. Each wave should have one primary question and one support family. The player should not meet Rust Pilgrim, Forklift Brute, and Cinder Spitter simultaneously for the first time during a high-density spike.

Add a content field such as:

```text
wave_profile {
  primary_family,
  support_families,
  spawn_budget,
  spawn_interval,
  elite_or_boss_flag,
  threat_description,
  valid_counter_families
}
```

The simulation should select positions and small variations from the profile but not invent a new encounter question through uncontrolled random composition.

### 8.3 Foreman design after removing manual interrupt

Manual Foreman interruption and exposure bonuses were correctly removed from the accepted direction. The boss now needs a replacement decision structure:

| Phase | Rule | Player response |
|---|---|---|
| Demolition | Telegraph circles with distinct safe corridors. | Move early and preserve a route. |
| Workers | Worker machines create a secondary target priority. | Decide between boss damage, worker removal, and optional-machine detours. |
| Final orders | Increase hazard density or remove one route temporarily. | Use the build’s geometry and keep moving; do not rely on one evolution. |

The boss should not be parked outside contact range with hazards as the only meaningful interaction. It should move enough to create target and routing decisions while remaining readable. It should not become a health sponge.

The boss acceptance gate should require successful wins with:

- A non-evolved Workshop build.
- A non-evolved Bell build.
- A non-evolved Mourner build after the wave-five issue is resolved or explicitly tuned.
- An evolved build.

## 9. Progression, Results, and metagame

The current prototype has local save/resume and a strong Results foundation, but it does not yet provide the full campaign route and persistent Memory Fragment layer described by the long-term design.

### 9.1 Immediate progression work

Before adding campaign breadth, improve Results so it explains:

- Which optional machines were repaired.
- Which rewards were received or declined.
- Where Scrap and Relic Shards came from.
- Which weapon contributed most to kills or boss damage.
- Which wave caused the largest structure loss.
- Why the run failed, if it failed.
- Whether Mercy Rail was pursued, ignored, or unavailable.
- Which Blessing fulfilment milestones were completed.

The Results screen should make the next attempt obvious without prescribing one build.

### 9.2 Early Access progression target

The current early-access plan is appropriately larger than the prototype: three authored sites, three objective patterns, three frames, four complete Blessings, eight weapons, four evolutions, ten to twelve catalysts/support relics, six enemy families, two elites, and three bosses.

Do not implement that breadth immediately. Use this release order:

1. Stable Workshop run with all three current Blessings.
2. Strong non-evolution and evolution routes.
3. One additional Gift/support layer if the shop needs it.
4. Rootworks Pump as the second authored site.
5. Brass Choir Relay or Red Foundry as the third site.
6. Three frames and fourth Blessing.
7. Additional evolutions and bosses.
8. Memory Fragment route consequences and Act I conclusion.

### 9.3 Permanent progression

Use Memory Fragments to unlock options, not permanent raw damage. Recommended unlock classes are frames, Blessings, catalysts, site routes, memories, and transparent challenge modifiers. Every unlock should explain its play pattern and reason for being locked.

Do not add a permanent stat treadmill while the current Mourner loss and optional-repair motivation are unresolved. A stat tree would make it harder to tell whether the core loop or the meta power is carrying the run.

## 10. Game feel, visual, and audio plan

### 10.1 Current presentation status

The renderer already provides a coherent temporary palette, named arena zones, minimap, shop panels, enemy telegraphs, procedural silhouettes, and synthesized sounds. This is sufficient for tuning. It is not yet a final commercial visual pass.

The runtime status identifies these presentation limitations:

- Rail effects can extend over the HUD.
- Boss bars can cover the north entry label.
- Purpose labels in the shop are small.
- Visual fixtures do not certify all effects in motion.
- ObjectDB cleanup warnings remain in some capture exits.
- System fonts are installed fallbacks rather than redistributed art assets.

Fix readability problems before adding more effects.

### 10.2 Hero asset replacement order

When the core loop passes 1× balance gates, replace assets in this order:

1. Saint silhouette and movement states.
2. Nailer, Bell, Procession Gear, and Mercy Rail.
3. Scrap Mite, Rivet Hound, Choir Drone, and Foreman.
4. Optional repair machines and shop UI.
5. Rust Pilgrim, Forklift Brute, Cinder Spitter, and Memory Crane.
6. Background workshop machinery, route landmarks, and memory scenes.

Every replacement asset must record source/generation method, license, date, temporary/final status, scene usage, and known mismatch.

### 10.3 Audio priorities

The next audio pass should be about weight and causal readability:

- Make each weapon’s onset and cadence distinct.
- Give optional repairs a clear start, progress, interruption, and completion sound.
- Give each enemy family a distinct warning language.
- Keep the boss hazard warning audible over ordinary weapon noise.
- Reduce continuous sound density during shop and Results.
- Test audio at 1× and 5× separately; 5× is for development throughput, not final feel.

## 11. QA and automated improvement plan

### 11.1 Preserve the current test layers

The current repository has a valuable test suite covering variety, optional repairs, shop, relay, arena, simulation, UI, development speed, and scripted playthroughs. Keep these layers separate:

| Layer | Current role | Next improvement |
|---|---|---|
| Content validation | IDs, references, counts, enabled slice | Validate wave profiles, repair machines, scope flags, and counter families. |
| Simulation tests | Deterministic state, damage, repair, shop, save/replay | Add build-role and optional-repair reward invariants. |
| Arena tests | Connectivity, route access, body collision | Add travel-time and machine-reachability metrics. |
| Shop tests | Six roles, rerolls, services, save stability | Add affordable-actionable-offer checks and no-wasted-service checks. |
| Playthrough policies | Automated build viability across seeds | Add survival, evolution, explorer, and repair-seeking policies. |
| UI tests | Title, shop pause, save roundtrip, navigation | Add 1× HUD overlap, minimap legibility, repair reward clarity, and boss-phase label checks. |
| Capture fixtures | Real rendered states with provenance | Add a natural-policy capture distinct from configured state fixtures. |
| Visual review | Ten-row rubric and explicit limitations | Score 1× density, weapon readability, and repair feedback separately. |

### 11.2 New automated policies

Add these policies before new weapons:

1. **Survival policy:** prioritizes structure and boss completion, with no optional repair requirement.
2. **Evolution policy:** buys ranks and Saint’s Rivet when affordable.
3. **Repair policy:** attempts one machine per two waves when the reward is not wasted.
4. **Explorer policy:** buys a new-direction weapon and completes one west or east detour.
5. **Mourner diagnostic policy:** records whether the wave-five loss follows a failure to acquire crowd clear, failure to collect motes, shop affordability, or excessive Cinder/Rust pressure.

The automated runner should report wins, loss wave, time to first damage, repair completions, weapon ranks, shop decisions, and primary failure cause. A process exit of zero must not mean “all policies won” unless the script explicitly checks that condition.

### 11.3 Current 1× balance gate

The next balance gate should require:

- 12/12 main-mode policy runs across seeds 147, 104729, and 104730, or a documented deliberate difficulty exception.
- No unexplained Mourner wave-five loss.
- At least one repair-seeking policy completes one useful repair in a normal run.
- All three Blessings can reach Foreman without a fixture-only budget.
- At least one non-evolution win for each Blessing.
- At least one Mercy Rail win.
- No frequent dead shop visits across the same seeds.
- No known HUD overlap in the primary 1280×800 capture.
- A natural-policy capture in addition to configured visual fixtures.

This is still not a human-fun gate. It is the automated prerequisite for focused human playtest.

## 12. Prioritized execution roadmap

### P12.1 — 1× roaming density and optional-repair motivation

**Player-facing objective:** the player can roam the enlarged Workshop, understand where pressure is coming from, and choose at least one optional repair because its reward is worth the travel risk.

**Authoritative owner:** arena data, spawn profiles, machine progress/reward state, movement timing, and simulation event trace.

**Required work:**

- Measure and tune travel gaps at 1× across three seeds.
- Add authored wave profiles rather than selecting from an uncontrolled growing pool.
- Keep three optional machines but show reward, work time, and local risk before commitment.
- Pause repair progress on severe hit, knockback, or leaving the work radius while preserving accumulated progress.
- Prevent wasted rewards where a machine can offer a useful alternative or a clear defer state.
- Add repair start, progress, interruption, and completion events.
- Add repair-seeking automated policy and metrics.

**Acceptance:** 1× captures show readable roaming, at least one attractive repair decision, no unexplained empty wave interval, and no state mutation from presentation. The repair policy completes one useful machine on representative seeds.

**Non-goals:** new weapons, new maps, permanent progression, manual boss interruption, or a new trait inventory.

### P12.2 — Mourner viability and weapon-role balance

**Player-facing objective:** all three Blessings support a coherent main-mode run, and every weapon has a clear reason to be purchased.

**Required work:**

- Trace the Mourner seed-104729 wave-five loss.
- Compare kill sources, mote generation, shop affordability, weapon ranks, and incoming enemy composition.
- Tune only the failing cause; do not globally inflate Mourner or healing.
- Validate all seven weapons against the role matrix.
- Add coverage for Rust Pilgrim, Forklift Brute, and Cinder Spitter in controlled compositions.
- Add non-evolution and evolution policy variants.

**Acceptance:** 12/12 main-mode policies win or the remaining failure is a deliberate documented challenge. Each Blessing has a non-evolution success route. Each weapon has a tested primary matchup and weakness.

### P12.3 — Purposeful shop and distinct Blessing services

**Player-facing objective:** every shop visit presents one affordable current-build decision, one future-build decision, and one meaningful response to the next pressure.

**Required work:**

- Keep the six role layout.
- Guarantee one affordable actionable offer for a normal run.
- Prevent redundant calibration when no other service is useful.
- Make Bell’s Advance warning reveal a concrete forecast advantage.
- Make Workshop restoration and Mourner recovery visibly different.
- Show why an offer is relevant and what it will change.
- Add economy traces for survival, evolution, explorer, and repair policies.

**Acceptance:** shop replay is deterministic; no role is permanently dead; all services are distinct; the player can form a meaningful build without repeated rerolls.

### P12.4 — Foreman and elite encounter quality

**Player-facing objective:** the elite and boss create readable movement and targeting questions that do not depend on Mercy Rail or manual interrupts.

**Required work:**

- Rework hazard placement around visible routes and machine landmarks.
- Give workers a clear priority relationship to the Saint and optional machines.
- Add a movement rule or safe-lane change in each boss phase.
- Keep the boss mobile enough to be a target, but never a health sponge.
- Test evolved and non-evolved builds.

**Acceptance:** each phase has a distinct question, telegraphs precede effects, and four build policies can win without presentation-only damage.

### P12.5 — Results and replay motivation

**Player-facing objective:** the Results screen explains what happened and gives the player a clear reason to try a different build or route.

**Required work:**

- Show machine rewards and repair choices.
- Show weapon contribution, damage source, and wave of failure.
- Show Blessing fulfilment and evolution status.
- Show a primary failure classification.
- Add a short memory fragment and route-preview stub without expanding into dialogue trees.
- Preserve immediate same-seed restart.

**Acceptance:** Results differ causally across survival, repair, evolution, and failure policies. The player can identify one next experiment.

### P12.6 — Gifts and support relics

**Player-facing objective:** a support item changes one meaningful rule without becoming generic stat inflation.

**Prerequisites:** P12.1 through P12.3 pass.

**Required work:**

- Add a stable Gift schema and two support slots.
- Add four to six behaviour-changing Gifts.
- Add stacking, replacement, sell/dismantle, and save/replay rules.
- Keep catalysts distinct as evolution ingredients or specific modifiers.

**Acceptance:** Gifts create different decisions from weapons and catalysts; the UI remains readable at 1280×800; no Gift is required for first-slice viability.

### P13 — Creative vertical and early-access breadth

Only after the current Workshop loop passes the automated gate should the project add Rootworks Pump, additional frames, the fourth Blessing, new evolutions, authored route consequences, and hero art/audio replacements. The early-access target remains three sites, three objective patterns, three frames, four Blessings, eight weapons, four evolutions, ten to twelve catalysts/support relics, six enemy families, two elites, and three bosses.

## 13. Definition of done

An improvement is complete only when:

1. The player-facing objective is stated in one sentence.
2. The authoritative owner and command boundary are explicit.
3. The current accepted direction is preserved: optional repairs, free movement, automatic attacks, no manual Foreman interrupt.
4. Content has stable IDs and references.
5. Valid and invalid commands are tested.
6. Same seed and command stream reproduce the same state where relevant.
7. Save/load and replay behaviour are covered where relevant.
8. The real runtime state is captured with commit, build, Godot version, viewport, scaling, seed, and state name.
9. The capture is identified as natural or fixture-configured.
10. The visual result is critiqued for hierarchy, readability, density, feedback, and polish.
11. One limitation is recorded honestly.
12. Exactly one next task is named.

## 14. Immediate next task

The next task is **P12.1 — 1× roaming density and optional-repair motivation**. Do not add a new map, Gift inventory, permanent stat tree, or broad narrative system first. Use the existing enlarged Collapsed Workshop, seven weapons, six enemy families, three optional machines, and current shop. Measure the current experience, fix the largest density or repair-motivation problem, rerun the automated policies, and capture one natural-policy 1× state with exact provenance.

The current evidence does not justify claiming game-quality completion. It does justify continuing runtime iteration from a real, testable foundation.

## References

[1]: https://github.com/raphaelroshan/scrap-saint/blob/main/docs/runtime_status.md "Scrap Saint current runtime status"
[2]: https://github.com/raphaelroshan/scrap-saint/blob/main/docs/implementation_packets.md "Scrap Saint implementation packets"
[3]: https://github.com/raphaelroshan/scrap-saint/blob/main/content/slices/first_shift.json "Scrap Saint enabled First Shift slice"
[4]: https://github.com/raphaelroshan/scrap-saint/blob/main/content/arenas/collapsed_workshop.json "Scrap Saint Collapsed Workshop arena data"
[5]: https://github.com/raphaelroshan/scrap-saint/blob/main/content/items/first_slice.json "Scrap Saint item catalogue"
[6]: https://github.com/raphaelroshan/scrap-saint/blob/main/content/enemies/first_slice.json "Scrap Saint enemy catalogue"
[7]: https://github.com/raphaelroshan/scrap-saint/blob/main/docs/early_access_plan.md "Scrap Saint early-access delivery plan"
[8]: https://github.com/raphaelroshan/scrap-saint/blob/main/docs/verification_0_1.md "Scrap Saint verification history"
[9]: https://github.com/raphaelroshan/scrap-saint/blob/main/game/simulation.gd "Scrap Saint authoritative simulation"
[10]: https://github.com/raphaelroshan/scrap-saint/blob/main/game/main.gd "Scrap Saint runtime renderer and UI"
[11]: https://github.com/raphaelroshan/scrap-saint/blob/main/docs/art_direction.md "Scrap Saint art and feel direction"
[12]: https://github.com/raphaelroshan/scrap-saint/blob/main/tests/README.md "Scrap Saint tests and evidence plan"

*Prepared by Manus AI from the current private repository state. Automated evidence is reported as evidence of execution and regression coverage, not as proof of human enjoyment or final game quality.*
