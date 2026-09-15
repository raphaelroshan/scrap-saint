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

## 3. Visual design and animation bible

The distinctive visual promise is that every weapon looks like a **repaired industrial implement performing a small sacred ceremony**. The player should recognise the weapon from its silhouette and motion before reading its name. The effect should then explain the mechanical result through shape, timing, material, and sound.

### 3.1 The four-part visual grammar

Every attack and upgrade should be designed as four linked beats:

| Beat | Visual question | Implementation rule |
|---|---|---|
| **Prepare** | What is about to happen? | Use a short mechanical movement, light-up, recoil, or targeting mark. |
| **Commit** | What object is acting? | Show the physical relic, arm, cable, bell, lens, or altar making the attack. |
| **Resolve** | What area or target is affected? | Use a readable line, cone, ring, tether, zone, or impact shape. |
| **Aftermath** | What changed? | Leave a brief status mark, stagger pose, repair stitch, smoke residue, scrap ember, or altered silhouette. |

The current renderer already uses line, shot, rail, beam, blast, cone, tether, and orbit effects. Future art should preserve those readable geometry classes while giving each weapon a more physical source object [1]. A large particle burst is not a substitute for showing the mechanism that caused it.

### 3.2 Material and colour assignment

Material should communicate doctrine and function without turning the screen into a rainbow.

| Function | Primary material | Accent | Motion language |
|---|---|---|---|
| Repair and Labour | Warm brass, solder, pale green enamel | Cream sparks | Deliberate extension, welding, stitching, and ratcheting. |
| Witness and Bell | Copper, bronze, cracked glass | Gold and cream rings | Resonance, vibration, concentric expansion, and recoil. |
| Orbit and Procession | Dark iron, cloth ties, painted arrows | Oxidised green | Rhythmic rotation, escorting, circling, and marching. |
| Mourn and Remnant | Ivory ceramic, black wax, bone-white plates | Violet and soft lilac | Slow drift, candle flicker, rising motes, and lingering afterimages. |
| Quiet and Archive | Pale enamel, glass, blue wire | Cold cyan | Focus, scanning, straight beams, muted sound, and suppressed motion. |
| Tether and Threshold | Woven cable, hooks, paper seals | Desaturated blue | Snap, pull, tension, route lines, and hinged barriers. |
| Wrath and Furnace | Red-painted iron, heat-blackened steel | Orange and warning yellow | Pressure build, valve release, venting, and ground impact. |

Use one dominant material and one accent per weapon. The accent should brighten only during the resolve beat. The background remains soot black, deep blue, oxidised green, and low-contrast machinery so that gold, cream, red, cyan, and violet retain authority.

### 3.3 Current weapon visual concepts

These are the visual targets for the seven enabled weapons. They should guide placeholder geometry now and commissioned or generated art later.

| Weapon | Silhouette | Attack choreography | Hit and aftermath |
|---|---|---|---|
| **Nailer of Small Mercies** | A squat brass rivet gun bolted to a telescoping shoulder bracket. | The bracket snaps forward, a bright nail travels as a straight gold streak, and the gun recoils with one visible loose washer. | A tiny cross-shaped repair mark appears on a marked target; the Saint’s shoulder gives one satisfied click. |
| **Bell of the Last Shift** | A cracked bronze bell suspended from a short piston arm. | The piston compresses, the bell swings once, and the whole bell briefly becomes the brightest object before a cream resonance ring expands through the cone. | Enemies show a circular vibration mark and lean backward as if struck by sound pressure; the cracked bell continues to wobble after the hit. |
| **Procession Gear** | A large uneven gear with a small candle bracket and two mismatched teeth. | The gear rolls out from behind the Saint, circles at a steady pace, and pauses for one solemn half-beat when it hits a target. | A green mechanical arc marks its orbit; enemies struck shed two brass filings and rotate slightly away from the Saint. |
| **Candle-Nailer** | A flare pistol with a black wax candle fused along its barrel. | The candle flame bends toward the lowest-health target, the pistol raises itself, and a violet shot travels with a thin smoke ribbon. | A defeated target leaves a small floating candle wick; healing motes rise from it like fireflies and drift toward the Saint. |
| **Cable of Contrition** | A maintenance spool mounted on the Saint’s side with a hooked sacramental plate. | The spool spins rapidly, a cable lashes outward, hooks the target, then visibly tightens between the two machines. | The target’s movement leaves short blue tension ticks; when the bind ends, the hook snaps back and the target is pulled one final step. |
| **Hymn Coil** | A copper coil and two tuning forks mounted above the Saint’s sensor. | The forks align, the coil fills with cold cyan light, and a thin beam fires in repeated clean pulses rather than one noisy continuous laser. | Quieted targets lose their support-field ring and display a muted cyan bar; the coil hum drops to near silence during suppression. |
| **Altar Mortar** | A small chapel font on a swivelling iron base, with a shell visibly loaded from a side drawer. | A lid opens, a shell arcs with a cream prayer strip tied to it, and a large ground seal appears just before impact. | The impact leaves a square-edged orange-and-cream scorch seal; clustered enemies are pushed outward while the seal slowly fades like cooling metal. |

The visual goal is not maximal spectacle. It is **recognisable mechanical authorship**. A player should be able to identify a Bell pulse, Cable bind, or Mortar landing even when several effects overlap.

### 3.4 Expansion A visual concepts

The first three new weapons should be visually distinct from the current catalogue and should advertise their mechanical role immediately.

| Weapon | Visual concept | Signature moment | Readability constraint |
|---|---|---|---|
| **Foundry Censer** | A soot-black censer hangs from a short chain and swings around the Saint. Its lid opens and emits layered teal smoke. | On a close enemy defeat, the censer snaps toward the body, inhales a spark, and drops a single gold Scrap ember. | The smoke ring must stay translucent enough to show enemies and the Saint inside it. |
| **Penance Winch** | A **telescoping brass maintenance arm** unfolds from the Saint’s back, reaches across the arena, and drives a spear-shaped hook into a selected enemy before retracting. | The arm extends in three visible segments, the hook pins the enemy for a beat, and the winch drum spins backward as the target is pulled from its route. | The target line and endpoint must be visible before the hook commits; no invisible long-range displacement. |
| **Welded Halo** | A crooked brass ring is held by a small three-axis gimbal above the Saint. One bright welding arc travels around the ring. | The arc pauses at a cardinal point, projects a narrow repair beam, then the ring rotates to continue the circuit. | The repair beam must be distinct from damage rays through cream-green colour and a stitch-like endpoint. |

Penance Winch is the clearest example of the desired character animation. It should feel like an overextended repair arm doing a slightly alarming job, not like a generic tentacle or a copied superhero weapon. The brass arm can have one mismatched elbow, a dangling inspection lamp, and a visible cable spool. Its spear-hook should look like a repurposed alignment tool.

### 3.5 Additional weapon visual concepts

| Weapon | Distinctive visual design | Mechanical result shown visually |
|---|---|---|
| **Door of Two Exits** | Two small iron doors unfold from a floor seal, each with a different painted arrow. They close, rotate ninety degrees, and reopen facing the chosen route. | Redirected enemies visibly turn toward the longer arrow; `WITNESSED` appears as a paper inspection stamp. |
| **Gatekeeper’s Hinge** | A huge rusted hinge swings out from the Saint’s side like a folding gate. | A heavy charge hits the hinge, stops, and leaves a clear sideways skid mark. |
| **Blue Wire Benediction** | Three blue wires emerge from brass sockets and form a temporary triangular loom between nearby enemies. | When two bound enemies overlap, the loom flashes yellow and releases a small pulse. |
| **Foreman’s Chalk** | A chalk-box turret rolls beside the Saint and draws a straight white line with a red warning tick at its end. | The line becomes a safe corridor for the Saint while enemies crossing it are pushed away. |
| **Archive Eye** | A glass inspection lens unfolds on a stalk and sweeps a pale cyan cone like a lighthouse. | The selected support enemy receives a bright lens-shaped mark and its next action appears as a small icon. |
| **Loose Bolt Communion** | One brass bolt ricochets between targets, leaving a dotted thread of tiny stamped circles. | Each successful bounce adds one visible stamp; the third stamp returns a Scrap ember to the Saint. |
| **Receipt of Mercy** | A paper maintenance receipt shoots from a side slot and sticks to a weakened machine. | The receipt folds itself into a seal as the target reaches execution range, then becomes a small violet remnant. |
| **Hymnal Lens** | A glass lens slides over the Hymn Coil and narrows its beam to a hard-edged scanning line. | The beam visibly pauses on a special-action enemy and cuts its support animation short. |
| **Boiler Psalm** | Three pressure valves inflate on the Saint before releasing a fan of white steam and orange rivets. | The steam cone leaves a safe pale route for the Saint and a hot red strip for enemies. |
| **Ashen Censer** | A thrown censer bounces once, cracks open, and spreads a low black-violet smoke pool. | Healing pulses visibly stop inside the pool; defeated enemies leave slow violet embers. |
| **Furnace Psalter** | Small red pressure gauges around the Saint fill one by one like organ stops. | The fifth filled gauge slams shut and releases the radial burst; an interrupted charge vents harmlessly. |
| **Spare-Part Mortar** | The mortar’s shell is visibly assembled from three mismatched parts before launch. | A miss lands as a small salvage crate instead of silently wasting the shot. |

### 3.6 Rank-up visual progression

Ranks should communicate **more mechanism**, not merely a larger number or more particles.

| Rank | Visual change | Animation change | UI language |
|---|---|---|---|
| **Rank I** | One clear tool silhouette with one repair seam. | Short preparation and simple resolve. | “This is what the relic does.” |
| **Rank II** | A second moving part, new brace, or added material accent appears. | A secondary beat becomes visible, such as a mark, bounce, tether, or delayed seal. | “This is how the relic is becoming reliable.” |
| **Rank III** | The object looks overworked and ready to transform: extra bolts, glowing seam, exposed coil, or unstable balance. | The attack has a recognisable signature pause or charge. | “This relic is ready for a higher form.” |
| **Evolved** | The silhouette changes category, not just scale. | A short transformation sequence reconfigures the object and immediately demonstrates the new geometry. | “This is a different machine now.” |

The Rank II change should appear in the first few seconds of combat after the combine. The Rank III change should be visible in the loadout panel and on the Saint. The evolution should use a brief freeze of approximately 0.25–0.4 seconds, a mechanism-reconfiguration sound, and one showcase attack before full control resumes.

## 4. Evolution and Confluence visual transformations

### 4.1 Catalyst evolutions

| Evolution | Transformation sequence | New attack image | Persistent silhouette change |
|---|---|---|---|
| **Mercy Rail** | Nailer’s small barrel splits into two rails; the shoulder bracket unfolds into a long alignment arm; the Saint braces with one foot. | A gold-white rail fires through a whole lane and leaves tiny green repair stitches on major targets. | A long pale rail remains mounted beside the Saint’s sensor. |
| **The Great Toll** | Bell cracks open along a hidden seam; its piston detaches and becomes a central striker. | A full cream-and-gold ring expands in every direction, with four brief bell silhouettes at the cardinal points. | The bell hangs above the Saint like a small moving shrine. |
| **The Maintenance Parade** | Procession Gear separates into two offset rings; a strip of faded cloth and tiny maintenance flags unfurl. | The two rings rotate at different speeds and briefly align into a marching path when a machine is restored. | Two gears escort the Saint rather than one. |
| **Candle for the Unreturned** | Candle-Nailer’s wax melts upward into three small candles; the flare barrel becomes a black ceramic reliquary. | Kills release violet motes that curve toward the Saint rather than floating randomly. | Three faint candle flames orbit the Saint when the weapon is ready. |
| **Contrition Lattice** | Cable spool splits into three smaller drums; hooks connect into a triangular frame. | Three blue lines form a lane or triangle, binding enemies that cross its edges. | A faint triangular cable frame follows the Saint. |
| **Quiet Sermon** | Hymn Coil’s tuning forks close around the beam and the copper turns pale enamel. | A narrow cyan lane removes sound and motion from support actions before they restart. | A pale lens sits over the Saint’s sensor. |
| **Workshop Benediction** | Mortar font opens into a small altar; the shell drawer becomes a repair compartment. | A damaging shell or a missed shell creates a visible choice between scorch and repair/salvage zone. | A tiny altar plate rotates behind the Saint. |
| **Ashen Benediction** | Foundry Censer’s lid breaks into a second orbiting lid and black smoke gains violet sparks. | The ring drifts toward the nearest damaged machine after enough defeats. | A small soot plume remains attached to the Saint’s trail. |
| **The Long Hand** | Penance Winch unfolds a second brass elbow and a longer cable spool. | The hook visibly travels along a marked route before pulling a far objective attacker. | The brass arm remains extended in a folded resting pose. |
| **Halo of Repairs** | Welded Halo becomes a two-ring gimbal with a bright solder point on each ring. | The repair beam chains from machine to Saint and back, forming a temporary moving circuit. | The halo floats higher and casts a cream reflection on nearby floor. |

### 4.2 Cross-weapon Confluences

Confluences should feel like two tools agreeing to become an institution. The transformation should show both source silhouettes before revealing the hybrid result.

| Confluence | Transformation staging | Result silhouette and attack |
|---|---|---|
| **The Line That Rings** | Nailer rail and Bell piston detach, rotate around one another, and lock with a visible bronze collar. | A long gold rail fires first; its terminal end folds into a bell-shaped pulse that marks and staggers the survivors. |
| **Procession Harness** | Procession Gear’s orbit slows while Cable’s hook wraps the gear’s rim and becomes a moving harness. | The gear rolls outward on a cable ring, pulls enemies inward, then snaps back to the Saint with repair filings. |
| **Requiem Coil** | Candle flame is drawn into Hymn Coil’s copper loops, leaving three purple sparks between the turns. | The beam jumps from low-health target to low-health target; a final kill releases one audible, visible mote. |
| **Incense Engine** | Mortar font seals onto the underside of the Censer, which becomes a floating smoke furnace. | Shells create smoke zones, then a hot burst occurs only when a second attack enters the zone. |
| **Threshold Toll** | Bell’s striker becomes the pin of Door of Two Exits; the two doors acquire bronze bell faces. | Every crossing enemy triggers a contained toll that turns the group toward the longer route. |
| **Demolition Liturgy** | Winch hooks a mortar shell and pulls it through a visible arc before releasing it at the gathered target point. | The winch creates the cluster and the mortar resolves the delayed impact as a single setup/payoff event. |

The source objects should remain recognisable for the first two attacks after a Confluence. This gives the player a visual explanation of the merge rather than presenting an unrelated new icon.

## 5. Gift and trait presentation

Gifts should attach to the Saint as small visible modifications. They should look like an item the Saint has chosen to carry, not a floating stat icon detached from the world.

| Gift | Physical attachment | Activation cue |
|---|---|---|
| **Spare Hand** | A folded brass tool arm rests on the Saint’s back and extends beside the normal repair arm. | It unfolds with two quick clicks when optional repair begins. |
| **Loose Spring** | A large spring is strapped to one leg with mismatched leather. | The spring visibly compresses during repair and releases on completion. |
| **Mended Spine** | A stitched iron brace runs up the Saint’s back. | It flashes green at the first reduced knockback each wave. |
| **Last Safe Step** | A chalk ring is painted beneath one foot. | The ring remains for the short repair grace window after leaving. |
| **Cooling Mantle** | A small cloth-and-copper mantle vents pale steam. | The mantle opens whenever a hazard warning is extended. |
| **Inspection Lens** | A folding glass monocle rotates over the Saint’s sensor. | It locks onto the next elite property and projects a small cyan diagram. |
| **Brass Fuse** | A short fuse runs from the Bell mount to the Saint’s main relay. | It lights on the first valid stagger and burns down visibly. |
| **Tether Spool** | A secondary blue spool hangs under the main Cable mount. | A faint line trails behind every Bound enemy. |
| **Choir Filter** | A perforated brass filter covers one side of the sensor. | Quieted enemies emit no support chime when their field attempts to return. |
| **Black Ledger** | A folded black book is clipped to the Saint’s side. | When dismantling, a component stamp appears on the page and then in the next shop card. |
| **Pilgrim’s Map** | A rolled paper map is tied to the back with red thread. | The map unrolls briefly when the next pressure lane is forecast. |
| **Honest Scale** | A tiny balance hangs from the Saint’s arm. | It tips toward the post-purchase loadout result before a shop confirmation. |
| **Mourner’s Thread** | A violet thread connects the Saint’s sensor to the nearest healing mote. | The thread knots when the mote intercepts a hit, then unravels between waves. |
| **Saint’s Debt** | A brass receipt is pinned beneath the sensor. | The receipt gains a red unpaid mark when the deferred cost is accepted. |

The trait UI should show the physical attachment in the loadout panel. On acquisition, the Saint should perform a short inspection tilt, the item should visibly attach, and the panel should state both the benefit and the trade-off in plain language.

## 6. Animation, audio, and camera budget

Visual identity is most valuable when it survives the current procedural renderer and later asset replacement. Every proposed effect should be implementable with simple shapes first and refined art later.

| Event | Target timing | Required readable cue | Audio cue |
|---|---:|---|---|
| Ordinary weapon prepare | 0.08–0.18 seconds | One physical part moves or brightens. | Short mechanism tick. |
| Ordinary resolve | 0.05–0.20 seconds | Geometry shape is visible at the target or area. | Weapon-specific impact. |
| Charge or delayed attack | 0.5–1.2 seconds | Target line, landing marker, or pressure gauge grows. | Rising tension with a clear end point. |
| Repair start | 0.15 seconds | Work ring and mechanism engage. | Click, weld spark, low hum. |
| Repair interruption | Immediate | Ring stops and one segment remains incomplete. | Cut-off weld and short warning chirp. |
| Gift acquisition | 0.3–0.5 seconds | Physical attachment appears on the Saint. | Small material-specific fastening sound. |
| Catalyst evolution | 0.25–0.4 seconds | Source object separates, reconfigures, and returns. | Resonance, mechanism lock, signature tone. |
| Confluence | 0.4–0.6 seconds | Both source objects are visible before the hybrid locks. | Two source notes resolve into one lower chord. |
| Boss phase change | 0.4 seconds maximum | Arena route or hazard rule changes. | Concise title hit, not a long cutscene. |

The camera should not zoom or shake for ordinary hits. Use a very small recoil offset for the Saint and a short camera impulse only for evolution, boss phase, or a large Confluence resolve. The player must retain control quickly. Any effect that obscures the Saint, enemy telegraph, repair machine, or minimap route fails the visual gate.

### 6.1 Procedural placeholder implementation

The first implementation can use:

- Lines and arcs for rails, beams, cables, rings, and pulses.
- Rectangles and polygons for doors, mortar shells, seals, and machine arms.
- Small circles for sparks, motes, lenses, and scrap embers.
- Scale, rotation, and alpha animation for preparation and aftermath.
- One material colour plus one accent colour per effect.

The placeholder must still include the signature motion. A golden line alone is not a Penance Winch; a brass arm extending, hooking, pulling, and retracting is the identity. A circle alone is not The Great Toll; the bell striker, wobble, ring, and stagger pose are the identity.

## 7. Visual acceptance checklist for new content

Every new weapon, evolution, Confluence, or Gift should pass the following checklist before entering the runtime pool:

1. Its silhouette is recognisable at 1280×800 gameplay scale.
2. The prepare beat identifies the acting relic before resolution.
3. The resolve geometry communicates its target or area.
4. The aftermath explains damage, control, repair, economy, or status.
5. The effect uses the assigned material and colour language.
6. It remains distinguishable when two existing weapon effects overlap.
7. The attack does not hide the Saint, threat telegraph, optional machine, or boss hazard.
8. The rank-up changes a visible mechanism, not only a number.
9. The evolution or Confluence visibly contains both the source and result identity.
10. A Gift’s physical attachment and activation state are visible in the loadout or arena.
11. Audio has a distinct onset and does not mask boss or repair warnings.
12. A real capture records build, viewport, seed, state, and whether it was natural or fixture-configured.

The visual target is not photorealism or particle density. It is a small machine performing understandable, characterful acts of maintenance under pressure.

## 8. Merge and evolution system

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

## 9. Gifts and traits to acquire

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

## 10. Blessing interactions

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

## 11. Acquisition and shop pacing

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

## 12. Data and simulation extension

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

## 13. Implementation sequence

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

## 14. Quality gates

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

## 15. Recommended first build after the current balance work

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
