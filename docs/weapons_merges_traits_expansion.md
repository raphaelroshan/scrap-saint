# Scrap Saint — Weapons, Merges, Evolutions, and Traits Expansion

**Status:** design proposal; not enabled in the current runtime catalogue.  
**Current runtime:** prototype 0.1.0 with seven automatic weapons, four catalysts, three Blessings, four active slots, and one reserve slot.  
**Purpose:** expand future build variety without weakening the current game’s readability, deterministic simulation boundary, or warm industrial devotional identity.

## Executive design decision

Scrap Saint should expand through three distinct layers:

| Layer | Player question | What it changes | First expansion timing |
|---|---|---|---|
| **Weapon** | “What problem does my machine solve automatically?” | Attack geometry, targeting, cadence, and primary status. | After the current P12.1 density and repair gate. |
| **Evolution or merge** | “What does this build become when I commit?” | A visible transformation of one weapon or two compatible Rank III weapons. | One catalyst evolution first; cross-weapon merges later. |
| **Gift or trait** | “What rule am I willing to bend?” | One persistent run-local rule with a readable benefit and cost. | After all three Blessings and the current seven weapons are viable. |

The game should not treat every new object as a weapon. A weapon is an automatic attack. A catalyst is an evolution ingredient or narrowly scoped modifier. A Gift is a rule-changing support item. A Blessing is a run-level doctrine. Keeping these categories distinct prevents the shop from becoming a flat catalogue of unrelated bonuses.

> **Recommended production rule:** add breadth only when it creates a new player question. Do not add an item merely because it increases damage, rarity, or catalogue size.

The current simulation contract already supports stable item IDs, deterministic same-rank combining, evolution recipes, catalysts, status effects, save state, and presentation-to-simulation command boundaries [1] [2]. The proposed additions should extend those contracts rather than introduce a new inventory system.

## 1. Non-negotiable design rules

### 1.1 Preserve the current game identity

New weapons should look and sound like repaired industrial objects treated as sacred equipment. The fantasy is not “a robot with guns.” It is “a maintenance automaton assembling a devotional machine from tools, warnings, cables, bells, manuals, and things that were never meant to be weapons.”

Names should imply a practical object, a workplace ritual, or an absurdly sincere religious interpretation of machinery. Visual silhouettes should remain readable at gameplay zoom. A weapon’s effect should be understandable from its shape and motion before the player reads its description.

### 1.2 Preserve the current loadout boundary

The current runtime uses four active weapon slots and one reserve slot. New weapons must fit that boundary. Do not introduce a backpack grid, weapon ammunition, manually aimed weapons, or a second active ability bar as a solution to content variety.

A new weapon definition should include:

| Field | Requirement |
|---|---|
| `id` | Stable identifier, never reused. |
| `name` | Player-facing industrial-devotional name. |
| `geometry` | Line, cone, orbit, beam, tether, zone, pulse, swarm, or another explicitly tested shape. |
| `target_rule` | Nearest, lowest health, support priority, objective attacker, elite, area centre, or authored alternative. |
| `primary_question` | The threat or route problem the weapon answers. |
| `base_effect` | One primary damage, control, repair, reveal, or economy behaviour. |
| `secondary_effect` | One conditional interaction at most for Rank I. |
| `tags` | Two or three visible shop tags. |
| `weakness` | A matchup or situation where another item is preferable. |
| `rank_data` | Explicit Rank I, II, and III changes. |
| `evolution_ids` | Named transformations, if any. |
| `counter_family` | The threat family it is intended to answer. |
| `test_fixture` | A deterministic scenario proving its geometry and effect. |

### 1.3 Keep the synergy surface small

A weapon should have one primary identity and one conditional interaction. A Gift should change one rule. An evolution should change geometry, targeting, status, objective interaction, or resource behaviour. No first expansion item should require a hidden four-tag threshold or a chain of more than two active ingredients.

The first expansion should avoid these patterns:

- Generic `+damage`, `+health`, or `+attack speed` items without a behavioural hook.
- Effects that only work with one exact weapon and make hybrid builds invalid.
- Passive triggers that cannot be seen in the arena.
- Three or more simultaneous status dependencies on a Rank I item.
- Traits that make optional repairs mandatory.
- Evolutions that are strictly stronger in every situation than their base weapon.

## 2. Weapon catalogue proposals

The following weapons are authored expansion candidates. They are not all immediate implementation tasks. The first implementation set should contain three weapons that address current gaps: a roaming zone weapon, a long-range control weapon, and a repair-oriented movement weapon.

### 2.1 First expansion set

| Weapon | Geometry and target rule | Primary question | Core effect | Weakness |
|---|---|---|---|---|
| **Foundry Censer** | Short orbiting smoke ring around the Saint. | “Can I survive close pressure while moving between machines?” | Enemies inside the ring are slowed; defeats inside the ring have a small chance to leave a Scrap ember. | It does little against distant support enemies. |
| **Penance Winch** | Tether to the furthest eligible enemy or the nearest objective attacker. | “Which enemy should I pull out of position?” | Pulls a charger toward the Saint or drags an objective attacker away from a machine. The direction is determined by target rule, not manual aiming. | Low swarm coverage and a long cooldown. |
| **Welded Halo** | A slow rotating ring with a repair beam at one cardinal point. | “Can I turn roaming and repair detours into a combat choice?” | Damages nearby enemies and, when the beam crosses a damaged optional machine or Saint, adds a small repair pulse. | Low burst damage and poor performance against ranged targets. |

These three weapons create distinct reasons to buy them. Censer is a close-pressure stabilizer, Winch is a priority-control tool, and Halo is a roaming/repair hybrid. None is a universal replacement for the current seven weapons.

### 2.2 Control, routing, and objective weapons

| Weapon | Geometry and target rule | Primary effect | Secondary interaction | Intended counter |
|---|---|---|---|---|
| **Door of Two Exits** | Places a temporary seal on the floor at the next reachable pressure lane. | The first enemy group crossing the seal is redirected along the longer valid route. | Redirected enemies become `WITNESSED` for a short duration. | Hound charges and Foreman worker routes. |
| **Gatekeeper’s Hinge** | Wide rotating sweep in front of the Saint. | Stops the first heavy charge that reaches the sweep and pushes the attacker sideways. | A stopped heavy leaves a short-lived hazard-free lane. | Forklift Brute and close body blocking. |
| **Blue Wire Benediction** | Three short tether lines from the Saint to nearby threats. | Binds up to three enemies and reduces their movement. | If two bound enemies overlap, they become `OVERLOADED` and release a small stagger pulse. | Mixed charger packs. |
| **Foreman’s Chalk** | Draws a delayed straight hazard line from the Saint toward the highest-threat target. | After a warning, the line damages and pushes enemies away from the Saint’s route. | The line becomes a temporary safe corridor for the Saint. | Dense lanes and boss hazards. |

The routing weapons should be introduced only after the current arena can show reliable route relationships. Their purpose is not to create a tower-defense layer. They should make the existing free movement more intentional.

### 2.3 Precision, reveal, and support-counter weapons

| Weapon | Geometry and target rule | Primary effect | Secondary interaction | Intended counter |
|---|---|---|---|---|
| **Archive Eye** | Narrow spotlight that tracks the highest-priority support enemy. | Marks and reveals one support enemy; the next compatible hit deals a controlled bonus. | Revealed enemies expose their next action in the HUD. | Choir Drones, Rust Pilgrims, and future hidden elites. |
| **Loose Bolt Communion** | A bouncing projectile that prefers `MARKED` targets. | Bounces between up to four enemies with reduced damage per bounce. | A final bounce returns to the Saint and grants a tiny Scrap pickup only if three targets were hit. | Swarms with a visible mark setup. |
| **Receipt of Mercy** | Slow stamp projectile against the lowest-health eligible enemy. | Executes targets below a defined threshold. | Execution creates a brief `MOURNED` remnant only when the target was previously `WITNESSED`. | Rust Pilgrim support targets and damaged elite workers. |
| **Hymnal Lens** | Narrow beam that prioritizes enemies currently performing a special action. | Interrupts or delays one support action when the beam remains aligned. | Does less ordinary damage than Hymn Coil. | Support fields and delayed ranged attacks. |

These weapons create a stronger reason for the player to value `WITNESSED`, `MARKED`, and `QUIETED` without requiring every run to use the same status chain.

### 2.4 Area, heat, and delayed-pressure weapons

| Weapon | Geometry and target rule | Primary effect | Secondary interaction | Intended counter |
|---|---|---|---|---|
| **Boiler Psalm** | Delayed forward steam cone. | Pushes enemies and leaves a brief hot zone that damages machines crossing it. | The Saint may move through the zone without penalty, creating a temporary route. | Hound charges and clustered melee threats. |
| **Ashen Censer** | Throws a slow shell that creates a smoke zone. | Enemies inside are slowed and cannot receive healing from support pulses. | Defeated enemies inside the zone leave a longer-lived Mourned remnant. | Rust Pilgrim groups and dense waves. |
| **Furnace Psalter** | Charges a heat meter through small shots, then emits a radial burst. | Every fifth completed cycle produces a large pulse. | If the Saint is hit during the charge, the meter drops and releases a smaller emergency vent. | Density and timing pressure. |
| **Spare-Part Mortar** | Lobbed shell that targets the largest cluster rather than the nearest enemy. | Area burst with a readable landing marker. | If it hits no enemy, it leaves a Scrap cache that expires quickly. | Mites and worker groups; poor against isolated fast targets. |

These weapons add time and space decisions. They should not be added until hazard readability and screen density are stable, because delayed zones can otherwise create visual noise.

### 2.5 A compact authored expansion pool

The first post-P12 catalogue should not enable all proposals. The recommended order is:

| Release | Enable | Reason |
|---|---|---|
| **Expansion A** | Foundry Censer, Penance Winch, Welded Halo | Covers close defence, priority control, and optional-repair roaming. |
| **Expansion B** | Archive Eye, Door of Two Exits, Boiler Psalm | Adds support targeting, route manipulation, and safe-lane creation. |
| **Expansion C** | Ashen Censer, Loose Bolt Communion, Furnace Psalter | Adds Mourn, bounce targeting, and heat-cycle build identity. |
| **Expansion D** | Gatekeeper’s Hinge, Foreman’s Chalk, Receipt of Mercy, Spare-Part Mortar | Adds boss/elite counter depth after the arena and shop are mature. |

Expansion A should be the only weapon-content goal in the first weapon task. The other ideas should remain design records until the automated viability suite shows that the current seven weapons and three Blessings are understandable and successful.

## 3. Merge and evolution system

### 3.1 Use three kinds of merge deliberately

“Merge” should not be a single overloaded word in the UI or data. Use these names:

| Player-facing term | Ingredients | Result | When to use |
|---|---|---|---|
| **Combine** | Two identical weapons at the same rank. | One higher-rank copy. | Existing shop action; routine build assembly. |
| **Evolution** | Rank III weapon plus one catalyst. | Named transformed weapon. | Current primary transformation system. |
| **Confluence** | Two compatible Rank III weapons. | A hybrid named weapon consuming both. | Later system for high-commitment cross-builds. |

The player should never need more than two active ingredients for a first-version recipe. Confluences should be disabled until the current evolution and Gift layers are stable, because they can otherwise make every shop decision feel like a puzzle about preserving future ingredients.

### 3.2 Evolution design rules

Each evolution must answer five questions:

1. What geometry changed?
2. What target rule changed?
3. What status or objective interaction changed?
4. What situation became easier?
5. What weakness or opportunity cost remains?

A valid evolution should be visible within one combat beat. The player should understand it without comparing raw damage numbers.

### 3.3 Catalyst evolution proposals

| Base Rank III | Catalyst | Result | Behavioural transformation | Remaining weakness |
|---|---|---|---|---|
| Nailer | Saint’s Rivet | **Mercy Rail** | Long rail, objective-attacker priority, repair on major hit. | Requires alignment and has a slow charge. |
| Bell | Cracked Bell Clapper | **The Great Toll** | Cone becomes a radial pulse that marks and displaces every affected threat. | Weak against distant threats between pulses. |
| Procession Gear | Pilgrim Spindle | **The Maintenance Parade** | Orbit becomes two offset rings; restored machines extend the outer ring briefly. | Close-range commitment remains dangerous. |
| Candle-Nailer | Mourner’s Wick | **Candle for the Unreturned** | Kills create seeking motes; a defeated marked support enemy creates two weaker motes. | Needs the player to finish damaged targets. |
| Cable of Contrition | Blue Wire from the Pump | **Contrition Lattice** | One tether becomes a triangular lane that binds and redirects enemies crossing its edges. | Poor immediate damage and vulnerable to scattered spawns. |
| Hymn Coil | Folded Maintenance Blueprint | **Quiet Sermon** | Beam creates a narrow moving silence lane; support actions inside are delayed. | Narrow coverage and low burst. |
| Altar Mortar | Saint’s Rivet | **Workshop Benediction** | Empty shells become temporary repair/salvage zones; occupied shells remain damaging. | Misses are useful but damage output is less consistent. |
| Foundry Censer | Black Candle | **Ashen Benediction** | Smoke ring leaves Mourned embers on defeated enemies and slowly drifts toward the nearest damaged machine. | Low value when no enemies enter the ring. |
| Penance Winch | Blue Wire | **The Long Hand** | Tether can choose a farthest objective attacker and pulls it through a marked route. | Long cooldown and poor swarm response. |
| Welded Halo | Saint’s Rivet | **Halo of Repairs** | The repair beam chains from a restored machine back to the Saint, creating a short moving repair circuit. | Reduced direct enemy damage. |

The first new evolution after Mercy Rail should be **The Great Toll**, because Bell is already in the runtime and the recipe is already represented in the catalogue. However, it should not be implemented until Bell’s Blessing service provides a meaningful forecast advantage and Bell has a viable non-evolution route.

### 3.4 Cross-weapon Confluence proposals

Confluences should be rare, visible, and deliberately expensive in opportunity cost. They consume both Rank III weapons and do not require a third currency. The player gives up two weapon slots and receives one weapon with a new geometry.

| Rank III pair | Confluence | Resulting behaviour | Why it is interesting |
|---|---|---|---|
| Nailer + Bell | **The Line That Rings** | A piercing rail ends in a short pulse; targets hit by both become `MARKED` and `RUNG`. | Combines precision with control without making either base weapon obsolete. |
| Procession Gear + Cable | **Procession Harness** | Orbiting gear carries a tether ring that pulls enemies inward and repairs nearby machines when a bound enemy falls. | Creates a close-range repair/route build. |
| Candle-Nailer + Hymn Coil | **Requiem Coil** | A beam jumps to low-health targets; deaths create one short-lived healing mote. | Turns execution and support suppression into one deliberate chain. |
| Altar Mortar + Foundry Censer | **Incense Engine** | Shells create smoke zones that slow, mute healing, and amplify the next burst inside. | Creates a delayed area-control identity. |
| Bell + Door of Two Exits | **Threshold Toll** | A placed threshold pulses when enemies cross it, pushing them back toward the longer route. | Makes map geometry part of the build. |
| Penance Winch + Spare-Part Mortar | **Demolition Liturgy** | The winch groups a cluster, then the mortar schedules a shell on the gathered position. | Creates a visible setup/payoff loop. |

Confluence rules:

- The recipe is visible before either Rank III item is sold or dismantled.
- The shop must show at least one non-Confluence alternative on the same visit.
- The result must not be strictly stronger than two independent weapons in every matchup.
- Confluences cannot be required for a boss or objective victory.
- The Results screen records both source lineages and the resulting geometry.
- The first implementation should contain only two Confluences, preferably **The Line That Rings** and **Procession Harness**.

## 4. Gifts and traits to acquire

### 4.1 Terminology and slot rules

Use **Gifts** as the player-facing term for traits. A Gift is a run-local support rule, not a permanent stat and not an active weapon.

Recommended rules:

- Two Gift slots after the current seven-weapon balance gate.
- Gifts are rankless in the first implementation.
- A Gift has one primary effect and one trade-off or activation condition.
- Gifts do not stack with an identical copy.
- Gifts may be sold or dismantled, but the player sees the refund before confirming.
- Gifts are acquired from relic-bench offers, optional repair milestones, elite rewards, Blessing fulfilment, and authored route rewards.
- Gifts never create a third run currency.
- A Gift must be visible in the HUD or loadout whenever its rule is active.

The purpose of Gifts is to change how the player evaluates a situation. A trait that merely increases damage belongs in a weapon rank or catalyst, not in the Gift layer.

### 4.2 Repair, movement, and survival Gifts

| Gift | Effect | Trade-off or limit | Best with |
|---|---|---|---|
| **Spare Hand** | Optional repair work completes 25% faster. | Saint movement speed is reduced while inside a work radius. | Workshop Gospel, Welded Halo. |
| **Loose Spring** | Completing a repair gives a 1.5-second movement burst. | The burst cannot be refreshed by the same machine. | Explorer builds and Censer. |
| **Mended Spine** | The first knockback each wave is reduced and converts part of the distance into a short repair pulse. | Saint structure maximum is reduced slightly. | Procession Gear, Bell. |
| **Last Safe Step** | Leaving a repair radius preserves a short grace window before progress pauses. | Repair progress cannot exceed 90% without remaining in the radius. | Repair-focused runs. |
| **Cooling Mantle** | Cinder and hazard warnings remain visible slightly longer. | Weapon cooldowns are modestly slower during a boss phase. | Mortar, Bell, future hazard maps. |

These Gifts support the optional-repair direction without making a repair machine a mandatory quest. Spare Hand is the best first test because it directly changes the risk/reward equation.

### 4.3 Targeting and status Gifts

| Gift | Effect | Trade-off or limit | Best with |
|---|---|---|---|
| **Inspection Lens** | Reveals the next elite or boss property and highlights the first priority target. | Ordinary Scrap pickups are slightly less valuable. | Archive Eye, Nailer, Bell Ward. |
| **Brass Fuse** | The first enemy staggered each wave becomes `MARKED`. | Bell cooldown is slightly longer. | Bell and Great Toll. |
| **Tether Spool** | Bound enemies leave a short slow line when they move. | Pull distance is reduced. | Cable, Penance Winch, Procession Harness. |
| **Choir Filter** | Quieted enemies cannot immediately create another support field when the status ends. | Beam and silence weapons deal less direct damage. | Hymn Coil and Quiet Sermon. |
| **Scoured Ledger** | The first armoured or heavy enemy hit each wave is revealed as a valid focus target. | The effect does not apply to ordinary Mites. | Mercy Rail and Nailer. |
| **Witness Nail** | The first `WITNESSED` enemy defeated each wave drops one additional small Scrap pickup. | The player must finish the target rather than merely reveal it. | Candle-Nailer and Archive Eye. |

These Gifts create visible status decisions. None should require the player to build a complete status chain before providing value.

### 4.4 Economy and shop Gifts

| Gift | Effect | Trade-off or limit | Best with |
|---|---|---|---|
| **Black Ledger** | Dismantling an item reveals a temporary component tag that improves one matching shop offer. | Dismantling refunds less Scrap. | Salvage Rite and hybrid builds. |
| **Pilgrim’s Map** | The minimap previews the next pressure lane and one nearby repair route. | One shop refresh is unavailable each run. | Explorer and repair-seeking builds. |
| **Honest Scale** | Shop cards show the exact post-purchase active/reserve capacity and combine result. | No direct combat benefit. | New players and high-combine runs. |
| **Borrowed Receipt** | The first unaffordable offer each shop remains locked for the next visit. | It occupies a lock slot. | Evolution and catalyst pursuit. |
| **Salvage Magnet** | Scrap pickups drift toward the Saint from farther away. | Repair-machine rewards cannot be collected from outside their work radius. | Salvage Rite and roaming builds. |
| **Recast Seal** | The first catalyst purchase each run reveals one compatible alternative recipe. | The catalyst cannot be sold for full value. | Recipe discovery and hybrid builds. |

The first shop Gift should be **Honest Scale**, because it improves comprehension rather than power. The first economy Gift should be **Black Ledger**, because it makes dismantling a real choice rather than a fallback button.

### 4.5 Risk/reward and boss Gifts

| Gift | Effect | Trade-off or limit | Best with |
|---|---|---|---|
| **Overpressure Valve** | Every fifth completed weapon cycle gains a visible burst effect. | The weapon pauses briefly after the burst. | Furnace Psalter and Mortar. |
| **Red Thread** | A boss hazard that passes within a short distance of the Saint grants a temporary damage mark on the Foreman. | Taking direct hazard damage still hurts normally. | Skilled movement and precision builds. |
| **Quiet Alarm** | The first boss hazard in each phase is telegraphed earlier. | The Saint begins the boss with fewer Scrap. | Bell Ward and defensive players. |
| **Mourner’s Thread** | The next healing mote collected after three defeats prevents one small hit. | The protection expires between waves. | Mourner and Candle-Nailer. |
| **Unfinished Vow** | If the player completes no optional repair during a wave, the next wave begins with a short haste effect. | The player receives no repair reward for that wave. | Aggressive non-repair builds. |
| **Saint’s Debt** | The player may buy one shop item while short on Scrap, paying the missing amount at the next shop. | The next shop begins with reduced Scrap and cannot be rerolled for free. | Evolution pursuit and calculated risk. |

These Gifts are later content. They should not be used to patch weak boss design or make missed repairs feel mandatory.

## 5. Blessing interactions

Gifts and evolutions should reinforce Blessings without becoming Blessing-exclusive. The following pairings are recommended as **biases**, not requirements.

| Blessing | Favoured weapons | Favoured Gifts | Distinctive build question |
|---|---|---|---|
| Workshop Gospel | Nailer, Procession Gear, Welded Halo, Mortar | Spare Hand, Loose Spring, Black Ledger | Do I spend capacity on repair strength or immediate combat? |
| Bell Ward | Bell, Archive Eye, Door of Two Exits, Great Toll | Inspection Lens, Brass Fuse, Quiet Alarm | Can I prepare for the next pressure before it becomes dangerous? |
| Mourner | Candle-Nailer, Ashen Censer, Requiem Coil | Mourner’s Thread, Witness Nail, Choir Filter | Can defeats become recovery without sacrificing all direct damage? |
| Future Quiet Order | Hymn Coil, Hymnal Lens, Quiet Sermon | Choir Filter, Inspection Lens | Can suppression prevent a problem rather than merely damage it? |
| Future Salvage Rite | Cable, Loose Bolt Communion, Black Ledger | Salvage Magnet, Honest Scale | Can I build economy without falling behind in combat? |
| Future Threshold Rite | Penance Winch, Door, Boiler Psalm | Pilgrim’s Map, Last Safe Step | Can I win by controlling routes rather than killing everything quickly? |

A Blessing should bias offers toward these pairings, but the shop must still expose at least one viable off-doctrine counter in each important visit.

## 6. Acquisition and shop pacing

### 6.1 Proposed sources

| Source | What it should offer | Pacing rule |
|---|---|---|
| Weapon-bay shop offer | New Rank I weapon or actionable duplicate. | One current-build offer and one new-direction offer remain guaranteed. |
| Relic-bench shop offer | Catalyst or Gift. | Do not show two redundant support items in the same visit. |
| Optional repair | A choice of immediate reward or a future Gift fragment later. | The first implementation should use ordinary rewards; Gifts come after repair motivation is proven. |
| Elite reward | Relic Shards, one catalyst/Gift choice, or a recipe reveal. | Never force an evolution. |
| Blessing fulfilment | Doctrine-appropriate Gift or service improvement. | Reward causal play, not passive time. |
| Route node | One site-specific Gift or catalyst. | Preview the play pattern and risk. |
| Boss result | Memory Fragment, recipe discovery, and one optional support choice. | Do not grant a permanent raw-stat increase. |

### 6.2 Recommended shop guarantees

After the Gift layer is implemented, a normal shop should contain:

1. One affordable current-build improvement or valid combine.
2. One visible evolution or Confluence path, if the player has begun one.
3. One new-direction weapon or Gift.
4. One forecast-valid counter.
5. One Blessing-biased service or Gift.
6. One flexible repair, economy, or reserve option.

The generator must replace an unaffordable or capacity-invalid mandatory role with a deterministic fallback. It should not make every offer affordable. Tension comes from choosing between good options, not from six unusable cards.

## 7. Data and simulation extension

The current item catalogue can evolve with a small schema extension.

### 7.1 Weapon definition

```json
{
  "id": "weapon.foundry_censer",
  "kind": "weapon",
  "scope_stage": "creative_vertical",
  "name": "Foundry Censer",
  "geometry": "orbit_zone",
  "target_rule": "nearest_in_radius",
  "tags": ["mourn", "orbit", "control"],
  "counter_family": "swarm_close_pressure",
  "base_effect": "slow_enemies_inside_ring",
  "secondary_effect": "defeat_inside_ring_drops_scrap_ember",
  "weakness": "low_value_against_distant_support",
  "cost_scrap": 18,
  "evolution_ids": ["evolution.ashen_benediction"]
}
```

### 7.2 Gift definition

```json
{
  "id": "gift.spare_hand",
  "kind": "gift",
  "scope_stage": "post_balance_gate",
  "name": "Spare Hand",
  "tags": ["repair", "risk"],
  "effect": "optional_repair_progress_multiplier",
  "effect_value": 1.25,
  "tradeoff": "movement_speed_multiplier_while_working",
  "tradeoff_value": 0.8,
  "stack_rule": "unique",
  "source_tags": ["workshop", "repair"],
  "description": "A second hand appears only when the first one is already busy."
}
```

### 7.3 Evolution recipe definition

```json
{
  "id": "evolution.great_toll",
  "kind": "evolution",
  "base_item_id": "weapon.bell_last_shift",
  "required_rank": 3,
  "required_catalyst_id": "catalyst.cracked_bell_clapper",
  "result_id": "weapon.great_toll",
  "geometry_delta": "forward_cone_to_radial_pulse",
  "target_rule_delta": "all_in_radius",
  "status_delta": ["marked", "rung", "displace"],
  "objective_delta": "clears_repair_zone_pressure",
  "weakness_after": "gap_between_pulses",
  "transformation_event": "evolution.great_toll_triggered"
}
```

### 7.4 Confluence recipe definition

```json
{
  "id": "confluence.line_that_rings",
  "kind": "confluence",
  "required_items": [
    {"id": "weapon.nailer_small_mercies", "rank": 3},
    {"id": "weapon.bell_last_shift", "rank": 3}
  ],
  "result_id": "weapon.line_that_rings",
  "geometry_delta": "piercing_rail_with_terminal_pulse",
  "status_delta": ["marked", "rung"],
  "slot_delta": -1,
  "transformation_event": "confluence.line_that_rings_triggered"
}
```

The simulation must validate ingredient identity, rank, capacity, recipe state, and trigger window atomically. A rejected merge must not mutate inventory, consume currencies, or advance an RNG cursor. The event trace should record source instance IDs, source definitions, result definition, geometry delta, status delta, and resulting slot count.

## 8. Implementation sequence

### Packet W-01 — catalogue and role audit

**Player-facing objective:** none; make every current and proposed weapon’s role, counter family, and weakness explicit.

**Files:** `docs/weapons_merges_traits_expansion.md`, `content/items/first_slice.json`, validator fixtures only if required.

**Acceptance:** current seven weapons have role entries, no proposed item is accidentally enabled, and the validator distinguishes `first_playable`, `creative_vertical`, and `future` scope.

**Non-goals:** no new runtime behaviour and no new shop offers.

### Packet W-02 — Expansion A weapons

**Player-facing objective:** the player can choose a close-control, priority-routing, or repair-roaming weapon that changes how movement through the Workshop feels.

**Enable:** Foundry Censer, Penance Winch, Welded Halo.

**Acceptance tests:** deterministic geometry, target selection, status/effect events, save/replay, shop capacity, and one natural-policy fixture per weapon. The three weapons must not be required for any existing victory.

**Non-goals:** no Confluences and no Gift slots.

### Packet W-03 — Great Toll evolution

**Player-facing objective:** a Bell build can visibly transform into a radial control instrument without becoming mandatory for victory.

**Enable:** Cracked Bell Clapper and The Great Toll.

**Acceptance tests:** Rank III plus catalyst validation, atomic catalyst consumption, before/after geometry, status events, non-evolution Bell victory, and a clear shop alternative.

### Packet W-04 — First three Gifts

**Player-facing objective:** the player can acquire a support rule that changes repair risk, information, or dismantling decisions.

**Enable:** Spare Hand, Inspection Lens, and Black Ledger with two Gift slots.

**Acceptance tests:** unique stacking, save/replay, sell/dismantle, visible active effects, no third currency, and no mandatory Gift for a first-slice win.

### Packet W-05 — First Confluences

**Player-facing objective:** a committed Rank III hybrid build can become one unmistakably new machine.

**Enable:** The Line That Rings and Procession Harness only.

**Acceptance tests:** two-source lineage, atomic slot reduction, readable recipe preview, non-Confluence alternatives, and wins with both source weapons kept separate.

### Packet W-06 — Expansion B and C content

Add further weapons, evolutions, and Gifts only after the P12.1 density gate, Blessing viability gate, and shop-decision gate pass. Each new item must include one deterministic fixture and one documented weakness before it enters the runtime pool.

## 9. Quality gates

The expansion is successful only if it improves decision quality rather than catalogue size.

| Gate | Required result |
|---|---|
| Role clarity | A player or agent can state the primary question and weakness of each enabled weapon. |
| Build viability | All three current Blessings retain non-evolution victory routes. |
| Counter coverage | Each authored wave profile exposes at least two valid counter families. |
| Shop quality | No repeated dead support offers; at least one actionable choice per visit. |
| Merge readability | Combine, Evolution, and Confluence have different labels and previews. |
| Trait value | Each enabled Gift changes a decision and has visible state feedback. |
| Determinism | Same seed and command stream reproduce offers, merges, status events, and results. |
| Evidence | Real 1× captures include build, viewport, seed, state, and whether the state was natural or fixture-configured. |
| Scope honesty | Proposed content remains disabled until its packet and tests pass. |

## 10. Recommended first build after the current balance work

The first practical content release should be:

- **Weapons:** Foundry Censer, Penance Winch, and Welded Halo.
- **Evolution:** The Great Toll.
- **Gifts:** Spare Hand, Inspection Lens, and Black Ledger.
- **No Confluences yet.**

This package tests the three most important future directions:

1. **Movement and close pressure** through Foundry Censer.
2. **Target selection and route control** through Penance Winch.
3. **Optional-repair identity** through Welded Halo and Spare Hand.
4. **A second visible evolution** through The Great Toll.
5. **Information and economy traits** through Inspection Lens and Black Ledger.

Do not implement this package until P12.1 has measured the current arena density and diagnosed the Mourner wave-five loss. New content should explain a known design question, not distract from an unresolved one.

## References

[1]: https://github.com/raphaelroshan/scrap-saint/blob/main/design/gameplay_contract.md "Scrap Saint gameplay contract"
[2]: https://github.com/raphaelroshan/scrap-saint/blob/main/design/shop_and_blessings.md "Scrap Saint shop and Blessings contract"
[3]: https://github.com/raphaelroshan/scrap-saint/blob/main/docs/progression_map_weapons_metagame.md "Scrap Saint progression, map, weapons, and metagame design"
[4]: https://github.com/raphaelroshan/scrap-saint/blob/main/docs/improvement_plan_2026-09-15.md "Scrap Saint current runtime improvement plan"
[5]: https://github.com/raphaelroshan/scrap-saint/blob/main/content/items/first_slice.json "Scrap Saint current item catalogue"

*Prepared by Manus AI from the current private repository contracts. This document is a design proposal; proposed weapons, Gifts, evolutions, and Confluences are not claims about enabled runtime content.*
