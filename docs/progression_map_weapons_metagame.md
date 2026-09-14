# Scrap Saint — Progression, Map, Weapons, and Metagame Design

> Current implementation note: this document preserves the original design recommendation. Later user decisions select free movement with optional repairs, remove manual Foreman interruption, and expand the map and combat roster. Those decisions take precedence over the relay-defence requirements below. See [runtime status](runtime_status.md), [implementation packets](implementation_packets.md), and [Early Access plan](early_access_plan.md).


**Status:** implementation-ready recommendation grounded in the current repository canon and the supplied reference research.  
**Audience:** systems, content, UI, narrative, and QA implementation teams.  
**Primary slice:** *The First Shift*, an 8–10 minute deterministic run.

## 1. Design decision at a glance

Scrap Saint is a compact industrial arena roguelite in which the Saint repairs a live relay while automatic relic weapons solve different enemy and objective questions. The **Pilgrimage of Repairs** supplies the run structure: each completed site opens a route to the next broken system. **Saint Built Wrong** supplies the progression meaning: the player does not recover one “correct” identity; the player assembles a useful one from incompatible parts.

The recommended first implementation uses a **nine-minute authored run** with six combat beats, five consequential shop windows, one guaranteed visible evolution, one elite, and one boss. The player spends **Scrap** on ordinary assembly and maintenance and **Relic Shards** on catalysts, rare services, and doctrine depth. The shop is not a random loot box. It is a deterministic workshop that always exposes a current-build improvement, a path toward Mercy Rail, a new direction, a flexible support option, and two threat- or Blessing-sensitive options.

The simulation remains authoritative. A fixed-timestep state machine owns timers, movement, targeting, damage, repairs, offers, purchases, evolutions, route results, and state hashes. The UI previews commands and consequences but never awards an outcome. This is a direct continuation of the repository gameplay contract.

The following labels separate evidence from decisions:

| Label | Meaning in this document |
|---|---|
| **Direct evidence** | A finding reported by the supplied research or an existing repository contract. It is cited and should be treated as a constraint or a useful observed precedent. |
| **Scrap Saint recommendation** | A deliberate design choice for this project. It is not a claim that the reference games implement the same rule. |
| **Implementation invariant** | A testable rule that must hold in code and replay output. |

## 2. What the research transfers—and what it does not

**Direct evidence:** *Slime 3K* demonstrates that an in-run shop turns build assembly into an economic planning problem. Its official descriptions and updates support automatic weapons, upgradeable cards, tags, escalating enemies, and a boss element at the end of a timed level [1] [2] [3]. Community documentation and player reports describe tag thresholds, separate run Tokens and permanent DNA, hidden-combo readability problems, and cornering or timer-wall friction [4] [5] [6] [7]. Exact universal wave count, shop interval, and map topology were not verified.

**Direct evidence:** *Vampire Survivors* demonstrates the strength of a continuous pressure-and-upgrade spiral. Its documented systems include automatic weapons, frequent level-up choices, limited weapon/passive capacity, catalyst-based evolutions, permanent PowerUps, achievements, characters, stages, and relic-gated features [8] [9] [10] [11] [12] [13] [14] [15] [16] [17] [18] [19] [20]. The reference also exposes friction from delayed or opaque evolution dependencies, stage-specific chest timing, and long late-run restart costs.

**Direct evidence:** *Brotato* demonstrates a readable wave-to-shop handoff. The documented baseline is 20 waves, increasing wave pressure, a shop after each wave, free locking, reroll inflation, six-weapon capacity, four weapon tiers, same-tier combining, threat forecasts, and a final boss wave [21] [22] [23] [24] [25] [26] [27]. Reviews also identify repeated single-arena topology, shop luck, consolidation trade-offs, and checklist grind as risks [28] [29].

**Scrap Saint recommendation:** retain the useful decisions from these precedents without copying their friction. The first slice therefore uses short authored pressure phases rather than a universal reference-game wave count, an explicit relay objective rather than survival-only victory, a six-offer workshop rather than a rare merchant, visible recipes rather than wiki-dependent discovery, and compact route-bearing arenas rather than a large procedural world.

## 3. Run structure and pacing

### 3.1 Run contract

A run has the following state sequence:

```text
Choose Saint frame and Blessing
→ enter site and receive forecast
→ fight, move, collect, and repair
→ resolve shop window
→ fight the next pressure beat
→ resolve objective and elite checkpoint
→ trigger Mercy Rail at an explicit transformation point
→ prepare in the final shop
→ defeat Foreman Engine
→ read Results and memory fragment
→ choose the next pilgrimage route
```

The first slice has no unbounded mode. The run ends in success when the Foreman Engine is defeated and the relay remains operational, or in failure when the Saint is destroyed or the relay is destroyed. A relay with reduced structure is a **costly partial success state**, not an automatic failure; the Results screen states the remaining damage and the repair decisions that caused it.

### 3.2 Nine-minute beat sheet

The clock is simulation time at 60 ticks per second. Shop and choice windows pause simulation. Combat windows use fixed durations so tests can assert exact transitions.

| Beat | Time window | Combat and objective event | Shop / decision event | Intended player question |
|---|---:|---|---|---|
| Arrival | 00:00–00:30 | Saint enters at the south maintenance gate. Relay starts at 70% structure and 0% repair progress. | Blessing choice is resolved before the clock begins; one guaranteed starting item is installed. | What am I repairing, and what does my doctrine favour? |
| Wave A: loose parts | 00:30–01:30 | Scrap Mites enter from west and east. The relay cannot yet be damaged. | Shop 1 opens at 01:30. | Can I move, auto-attack, and collect without abandoning the relay? |
| Wave B: chargers | 01:45–02:45 | Rivet Hounds target the relay after a 15-second warning. A repair zone activates north of the relay. | Shop 2 opens at 02:45. The first Mercy ingredient or Rank-up is guaranteed here. | Do I buy immediate coverage or commit to the visible evolution? |
| Wave C: suppression | 03:00–04:00 | Choir Drones deploy a skill-suppression field. One salvage crate opens on the opposite lane. | Shop 3 opens at 04:00. One Saint’s Rivet offer is guaranteed if the player has Rank 2 Nailer; otherwise a Rank-up route is guaranteed. | Which weapon answers the next pressure without hard-locking me? |
| Elite checkpoint | 04:15–05:30 | Memory Crane arrives at 04:15 with a 15-second spawn telegraph. It copies the player’s last completed evolution; before Mercy Rail exists it copies the highest-rank weapon geometry. Relay damage is doubled during its demolition sweep. | Elite reward grants 2 Relic Shards and opens Shop 4 at 05:30. | Can I fight a build-shaped threat while keeping the relay alive? |
| Transformation | 05:30–06:20 | No ordinary spawns for the first 20 seconds. The relay repair zone is safe but not invulnerable. | Shop 4 guarantees the remaining Mercy Rail ingredient or a service that creates it. Player chooses `choose_evolution` at the altar. | What exactly changed in my machine? |
| Final pressure | 06:20–07:20 | Mixed Mites, Hounds, and Drones use the route edges. Foreman warning markers appear at 06:50. | Shop 5 opens at 07:20 and guarantees one boss-counter offer. | Does my evolved geometry solve both enemies and the objective? |
| Boss: Foreman Engine | 07:35–08:45 | Foreman Engine schedules three demolition zones, summons worker drones, and temporarily disconnects one relay cable at 08:05. The boss is defeated by damage plus interrupting two demolition schedules. | No combat shop. Boss grants 2 Relic Shards on defeat. | Can I move, repair, interrupt, and finish instead of merely dealing damage? |
| Results | 08:45–09:15 | Relay result, structure, Scrap, Shards, Blessing progress, recipe state, and evolution are committed. | One memory fragment is shown. Route choice presents two authored next-site nodes. | What did my choices make possible, and where does the pilgrimage go next? |

A five-second tolerance is permitted for presentation buffering, but not for simulation transitions. The acceptance harness uses exact tick thresholds and records any late or early transition as a failure.

### 3.3 Threat cadence

The first slice uses **six named pressure beats**, not an unverified universal wave count. Each beat has one primary pressure and at least two valid counters. The forecast appears before the relevant shop and remains visible in the combat HUD.

| Beat | Primary pressure | Valid counter families | Failure signal |
|---|---|---|---|
| A | Pickup denial and body blocking | Cone, orbit, knockback, movement | Scrap remains uncollected or Saint is pinned away from the relay. |
| B | Relay chargers | Mark, tether, direct priority, repair zone | Hounds reach the relay after a visible approach. |
| C | Skill suppression | Bell, beam, interrupt, cleanse-by-defeat | Drone field disables one named weapon effect. |
| Elite | Copy of the player’s strongest geometry | Focus fire, silence, objective repair, movement | Copied pattern is readable before damage resolves. |
| Final | Mixed route pressure and demolition warnings | Mercy Rail, Bell, Cable, Procession, repair timing | Relay cable is visibly disconnected before the boss. |
| Boss | Rule change plus summons | Interrupt, objective repair, lane control, single-target focus | Two missed demolitions cause a recoverable but expensive relay state; three cause failure. |

**Implementation invariant:** no threat may require one exact item. Forecast copy must list at least two counter families, and the shop guarantee must offer at least one of them.

## 4. Map, arena topology, and route selection

### 4.1 First arena: The Collapsed Workshop

The first arena is a compact industrial diorama, 20 by 14 logical metres, with a clear playable boundary. It is not an open-world map. The relay sits slightly north of centre, the Saint starts at the south maintenance gate, and three enemy entry edges are stable: **West Conveyor**, **North Crane**, and **East Furnace**.

The floor is divided into five functional pockets. The **relay bowl** is the main objective space. The **west salvage lane** holds destructible scrap bins and is the safest route for collection. The **north crane lane** is a narrow but fast route to the elite spawn. The **east furnace lane** contains a visible hazard strip that turns on only during forecasted pressure. The **south workshop alcove** is the shop and Blessing altar; it is a safe decision space, not a combat shortcut.

A continuous outer loop connects all three entry edges. Two machine obstructions create readable cover but never form a dead end. Every pocket has two exits. The relay repair zone has a 2.5-metre radius, a visible ring, and a 0.75-second interaction pulse. Hounds can enter the zone, so the player must create space rather than hold a button with no risk.

| Topology rule | Implementation requirement | Purpose |
|---|---|---|
| Three entry edges | Stable edge IDs and spawn lanes in content data | Supports forecast and deterministic replay. |
| Two-exit rule | Navigation validation rejects pockets with one traversable exit | Prevents unavoidable cornering reported in constrained arenas [6] [28]. |
| Safe repair zone | Fewer hazards, not immunity; enemies can contest it | Makes the objective spatial without removing skill. |
| Salvage detour | Scrap bins are 5–8 seconds from the relay by the outer loop | Makes collection a route decision with a bounded opportunity cost. |
| Shop alcove | Combat pauses on shop open; no hidden free healing | Keeps economy legible. |
| Hazard telegraph | Three-second marker, one-second warning pulse, then effect | Makes industrial machinery readable at gameplay scale. |

**Scrap Saint recommendation:** use deterministic obstacle variants only after the first arena passes the fixed topology validation. Later arenas may rotate relay position, close one lane temporarily, or change hazard strips, but they must preserve the two-exit rule and the forecastable entry-edge model.

### 4.2 Pilgrimage route graph

A completed site opens two route nodes from a small authored graph. The route card shows the next site’s objective type, primary pressure family, expected reward, and one risk. Route selection is a simulation command, not a UI-only transition.

The first campaign graph is:

```text
First Shift: Collapsed Workshop
├── Brass Choir Relay      [control / Bell catalyst]
└── Rootworks Pump         [repair / Cable catalyst]

Brass Choir Relay
├── Pale Archive           [copy / recipe discovery]
└── Red Foundry            [hazards / burst catalyst]

Rootworks Pump
├── Red Foundry            [hazards / burst catalyst]
└── Pale Archive           [copy / recipe discovery]
```

The first slice displays both next-site cards after Results but marks them as post-slice route stubs. The player’s choice is recorded in the run result and deterministic replay even if the next site is not yet implemented. Once implemented, route choice changes the next arena and reward table, not the underlying player power curve.

**Route selection rule:** one option must be a counter to the player’s current weakness, and the other may be a higher-risk doctrine reinforcement. Do not present two equivalent cards or a blind random node. A route preview must include `OBJECTIVE`, `PRESSURE`, `REWARD`, and `RISK` fields.

## 5. Weapon, catalyst, rank, tag, and evolution architecture

### 5.1 Identity and data model

Each build item is a data record with a stable ID, display name, category, rank, geometry, target rule, base effect, tags, cost, and evolution references. Weapons express active behaviour. Catalysts alter a weapon’s behaviour or make an evolution eligible. Blessings bias offers and provide services; they do not own the inventory.

The minimum runtime records are:

```text
ItemInstance {
  instance_id, definition_id, category, rank,
  calibration_seed, active_tags, cooldown_state,
  evolution_state, source_offer_id
}

WeaponDefinition {
  id, geometry, target_rule, base_effect, rank_data,
  tags, compatible_catalysts, objective_interaction
}

CatalystDefinition {
  id, tags, eligible_bases, modifier,
  shard_cost, recipe_refs
}

EvolutionRecipe {
  id, base_id, required_rank, catalyst_id,
  trigger_window, result_id, transformation_event
}
```

The authoritative state uses stable IDs and serialises active weapons, one reserve slot, shop state, currencies, recipes, and evolution status. This extends the existing gameplay contract without introducing an inventory grid.

### 5.2 Rank rules

| Rank | Function | Combining rule | UI requirement |
|---|---|---|---|
| Rank 1 | Establishes geometry and one identity effect. | Two identical Rank 1 instances combine into Rank 2. | Show geometry, target rule, and one tag. |
| Rank 2 | Improves reliability or adds a secondary interaction. | Two identical Rank 2 instances combine into Rank 3. | Show the next combination and any catalyst eligibility. |
| Rank 3 | Enables one or more known evolutions. | No Rank 4 in the first system. | Show `UNKNOWN`, `DISCOVERED`, or `READY` recipe state. |
| Evolved | Replaces the base item with a named miracle. | Cannot be combined with the pre-evolution base. | Show before/after geometry and objective/resource change. |

Combining is an atomic simulation command. If the command succeeds, both source instances are removed and one new instance is created with a stable lineage event. If it fails, the state and RNG cursor do not change.

### 5.3 Tags

Tags are readable shop and synergy labels, not hidden puzzle syntax. The first tag vocabulary is intentionally small:

| Tag family | Meaning | First counter or interaction |
|---|---|---|
| `LABOUR` | Repair, construction, repeated mechanisms | Improves relay progress and service value. |
| `WITNESS` | Reveal, mark, target certainty | Counters hidden or copied threats. |
| `ORBIT` | Close defence and rotating coverage | Counters body blocking and swarms. |
| `QUIET` | Suppression and interrupt | Counters Choir and boss schedules. |
| `MOURN` | Remnants, conversion, defeat value | Converts defeats into temporary support. |
| `TETHER` | Bound movement and lane control | Counters chargers and demolition routes. |
| `PULSE` | Bell, area timing, stagger | Counters clustered drones. |
| `SALVAGE` | Scrap, dismantling, calibration | Supports economy and recovery. |
| `PIERCE` | Armour interaction and line geometry | Counters armoured machines. |
| `REPAIR` | Objective or Saint structure interaction | Converts attacks or rituals into maintenance. |

**Scrap Saint recommendation:** do not implement hidden three-, four-, or five-tag thresholds in the first slice. The visible evolution and Blessing fulfilment provide enough build planning. Later tag thresholds must display their fulfilment progress, effect, and counter family in the Ledger.

### 5.4 First 15-item catalogue

The catalogue below is the first authored pool. The first slice enables the five marked weapons, two marked catalysts, three Blessings, Memory Crane, and Foreman Engine. The remaining entries are authored expansion content, not a requirement for the first playable.

| ID | Item | Type | First availability | Tags | Core behaviour |
|---|---|---|---|---|---|
| `wp_nailer` | Nailer of Small Mercies | Weapon | First slice | `LABOUR`, `PIERCE`, `REPAIR` | Nearest-target rivet shot; Rank 2 marks relay attackers; Rank 3 can evolve. |
| `wp_bell` | Bell of the Last Shift | Weapon | First slice | `PULSE`, `WITNESS`, `QUIET` | Radial rung pulse; Rank 2 reveals drones; Rank 3 can evolve. |
| `wp_procession` | Procession Gear | Weapon | First slice | `ORBIT`, `LABOUR` | Orbiting gear damages nearby enemies and protects the repair zone. |
| `wp_candle` | Candle-Nailer | Weapon | First slice | `MOURN`, `PIERCE` | Slow homing shot that leaves a short-lived Mourned remnant on defeat. |
| `wp_cable` | Cable of Contrition | Weapon | First slice | `TETHER`, `REPAIR` | Tethers the nearest relay attacker and gives a small repair pulse when it breaks. |
| `wp_hymn` | Hymn Coil | Weapon | Post-slice | `QUIET`, `PULSE` | Beam that quiets support actions in a narrow lane. |
| `wp_mortar` | Altar Mortar | Weapon | Post-slice | `LABOUR`, `PULSE`, `PIERCE` | Delayed consecrated shell; strong objective denial, weak close defence. |
| `wp_door` | The Door That Opens Once | Weapon | Post-slice | `WITNESS`, `TETHER` | Places a one-use seal that redirects one enemy group. |
| `wp_sermon` | The Sermon That Cannot Be Heard | Weapon | Post-slice | `QUIET`, `MOURN` | Silence field that converts defeated quieted enemies into a brief ally. |
| `cat_rivet` | Saint’s Rivet | Catalyst | First slice | `LABOUR`, `REPAIR` | Enables Nailer Rank 3 → Mercy Rail. Costs 1 Shard plus 8 Scrap. |
| `cat_clapper` | Cracked Bell Clapper | Catalyst | Post-slice | `PULSE`, `WITNESS` | Enables Bell Rank 3 → The Great Toll. |
| `cat_spindle` | Pilgrim Spindle | Catalyst | Post-slice | `ORBIT`, `TETHER` | Enables Procession Gear transformation; increases orbit radius, not raw damage only. |
| `cat_wick` | Mourner’s Wick | Catalyst | Post-slice | `MOURN`, `QUIET` | Enables Candle-Nailer transformation; remnant duration becomes deterministic and visible. |
| `cat_blueprint` | Folded Maintenance Blueprint | Catalyst | Post-slice | `SALVAGE`, `LABOUR` | Converts one service interaction into a component refund and reveals one recipe. |
| `cat_wire` | Blue Wire from the Pump | Catalyst | Post-slice | `TETHER`, `REPAIR` | Enables Cable transformation; tethered enemies can be redirected to hazard lanes. |

### 5.5 Evolution rules and first ten recipes

The repository canon requires `Nailer of Small Mercies Rank 3 + Saint’s Rivet → Mercy Rail`. Mercy Rail is the only required visible evolution in the first slice. It changes the Nailer from a nearest-target rivet shot into a long horizontal rail that pierces a lane, **repairs the relay when it hits a marked relay attacker**, and has a target rule that prioritises objective attackers before ordinary enemies. Its geometry, target priority, and objective interaction are the acceptance surface; a damage increase alone is invalid.

The first ten authored recipes are:

| # | Base at Rank 3 | Catalyst | Result | First implementation state |
|---:|---|---|---|---|
| 1 | Nailer of Small Mercies | Saint’s Rivet | Mercy Rail | **Required first slice; guaranteed.** |
| 2 | Bell of the Last Shift | Cracked Bell Clapper | The Great Toll | Authored; post-Mercy implementation. |
| 3 | Procession Gear | Pilgrim Spindle | The Maintenance Parade | Authored; post-slice. |
| 4 | Candle-Nailer | Mourner’s Wick | Candle for the Unreturned | Authored; post-slice. |
| 5 | Cable of Contrition | Blue Wire from the Pump | Contrition Lattice | Authored; post-slice. |
| 6 | Hymn Coil | Folded Maintenance Blueprint | Quiet Sermon | Authored; post-slice. |
| 7 | Altar Mortar | Saint’s Rivet | Workshop Benediction | Authored; post-slice. |
| 8 | The Door That Opens Once | Blue Wire from the Pump | The Door of Two Exits | Authored; post-slice. |
| 9 | The Sermon That Cannot Be Heard | Mourner’s Wick | Unheard Procession | Authored; post-slice. |
| 10 | Any Rank 3 `SALVAGE` weapon | Folded Maintenance Blueprint | Rebuilt Instrument | Authored wildcard service; must name the selected base in the preview. |

Recipes use three states. `UNKNOWN` means the player knows that a higher form exists but not the full recipe. `DISCOVERED` shows base, rank, catalyst, trigger window, and result preview. `READY` means all requirements are satisfied. The first ten recipes are visible in-game through the Ledger; “visible” does not mean every recipe is immediately unlocked for every run. No first-version recipe uses more than two active ingredients.

Evolution triggers only at an elite reward, boss reward, or altar transformation window. A recipe may not silently transform in the middle of movement. The transformation event records source IDs, catalyst ID, result ID, geometry delta, objective delta, and resource delta.

## 6. Shop offer generation and economy targets

### 6.1 Workshop layout

Every shop visit displays six offers in fixed columns:

| Column | Count | Offer role |
|---|---:|---|
| Weapon bay | 2 | Base weapon, rank duplicate, or current-build improvement. |
| Relic bench | 2 | Catalyst, recipe support, or rank/effect component. |
| Service altar | 2 | Repair, reserve, dismantle, blessing deepening, forecast, or calibration service. |

Each offer shows price, currency, rank, tags, immediate effect, next-wave relevance, current-build interaction, missing ingredients, and any rejection condition. Shop opening emits a deterministic `SHOP_OPENED` event containing the offer IDs and roll context. Reloading a save does not reroll the offer set.

The six roles are guaranteed in this order:

1. **Current-build improvement:** upgrades an owned weapon, repair option, or valid combine.
2. **Visible evolution path:** offers the missing Mercy Rail ingredient, the Rank-up route, or the deterministic service that creates it.
3. **New direction:** offers a weapon or catalyst outside the current dominant tags.
4. **Flexible defence/economy:** repair, reserve, Scrap generation, or a broad counter.
5. **Threat counter A:** one forecast-valid counter family.
6. **Threat counter B / Blessing context:** another valid counter or a Blessing-favoured service.

Duplicates are permitted only when they are actionable. A duplicate offer that cannot combine, be reserved, or contribute to an evolution is rejected by the generator and replaced.

### 6.2 Deterministic generation algorithm

The generator receives `run_seed`, `shop_visit_index`, `blessing_id`, `forecast_id`, `inventory_signature`, and `reroll_index`. It derives a local RNG stream from those fields. It never consumes the combat RNG stream. The algorithm is:

```text
roll guaranteed current-build slot
roll guaranteed evolution-path slot
roll new-direction slot from unowned catalogue
roll flexible support slot
roll two forecast/Blessing slots from valid counter families
apply duplicate and affordability filters
if a mandatory role is invalid, use the role's deterministic fallback list
sort offers by fixed UI role order, not random order
emit SHOP_OPENED with full offer IDs and prices
```

A reroll changes only the six offers and increments `reroll_index`. It does not alter enemy timing, pickup positions, objective damage, or future route selection. The first refresh is free; subsequent refreshes cost 2, 4, and 7 Scrap, then remain at 7 Scrap for the first slice. A player may lock one offer. Locked offers preserve their ID and price across a refresh.

### 6.3 Economy targets and price bands

The current design target is **80–120 Scrap**, **3–5 Relic Shards**, **five meaningful shop decisions**, **two or three Blessing moments**, and one guaranteed visible evolution in an 8–10 minute run. These are tuning targets already stated in the shop contract, not claims about the reference games.

The first slice economy budget is:

| Source | Scrap target | Shard target | Notes |
|---|---:|---:|---|
| Ordinary enemy defeats | 35–50 | 0 | Small enemies produce 0–1 Scrap with a deterministic weighted pickup rule. |
| Wave completion rewards | 20–25 | 0 | Five combat/shop handoffs award 4–5 Scrap each. |
| Destructibles and salvage lane | 10–15 | 0 | Optional route detour; never required for Mercy Rail. |
| Repair and objective milestones | 10–20 | 1 | Full repair and elite-warning survival produce objective value. |
| Memory Crane | 0 | 2 | Guaranteed if defeated. |
| Foreman Engine | 0 | 2 | Guaranteed on boss defeat. |
| **Total target** | **80–120** | **3–5** | Includes normal collection, not perfect play. |

Recommended first-slice price bands are:

| Transaction | Cost | Refund / result |
|---|---:|---|
| Rank 1 weapon | 12–16 Scrap | Sell for 60% of paid Scrap. |
| Rank 2 weapon or premium service | 20–28 Scrap | Sell/dismantle according to definition. |
| Saint’s Rivet | 1 Shard + 8 Scrap | Catalyst is consumed only on successful evolution. |
| Ordinary repair pulse | 5 Scrap | Restores 8% relay structure or 6% Saint structure, subject to cap. |
| Full repair service | 1 Shard + 10 Scrap | Restores the relay to the current phase cap, not automatically to 100%. |
| Reserve service | 4 Scrap | Moves one eligible item to the one reserve slot. |
| Ledger reveal | 1 Shard | Reveals one recipe or threat interaction; never reveals a false path. |
| Recast Relic | 1 Shard | Changes one catalyst secondary tag using a fixed table. |
| Reroll | 0 / 2 / 4 / 7 Scrap | Refreshes unlocked offers only. |

**Economy acceptance target:** a player who collects roughly 70% of ordinary pickups and completes the first repair objective can buy one Rank 1 improvement, one repair/service, and one catalyst component before the elite, while a perfect collector can also buy a flexible second improvement. Mercy Rail must not require perfect collection.

### 6.4 Blessings and fulfilment

The first slice offers **The Workshop Gospel**, **The Bell Ward**, and **The Mourner**. Their starting guarantees, shop bias, unique services, and weaknesses follow the existing shop contract. Blessings are broad doctrines rather than fixed decks. The player may build hybrid tags at any time.

Blessing fulfilment is displayed as a three-step ledger. Each step names a causal action, such as `REPAIR 2 RELAY SEGMENTS`, `WITNESS 5 SUPPORT MACHINES`, or `CREATE 3 MOURNED REMNANTS`. The reward is applied at the next shop boundary. The UI explains the effect before the player commits.

**Anti-reroll rule:** Blessing bias changes weights but cannot remove the Mercy Rail guarantee or the current-build improvement. A player who ignores the doctrine may receive fewer favoured offers but cannot be locked out of a viable run.

## 7. Permanent metagame and run-local state

### 7.1 Separation of layers

The most important economy rule is that run-local assembly must remain meaningful after permanent progression exists.

| Layer | Persists after run? | Contents | Design purpose |
|---|---|---|---|
| Run-local Scrap | No | Ordinary shop, repair, combine, sell, dismantle, reroll. | Makes every current decision economically legible. |
| Run-local Relic Shards | No | Catalysts, Ledger, rare services, Blessing deepening. | Creates elite/objective/boss stakes. |
| Run-local build | No | Weapons, ranks, tags, catalyst state, reserve, evolution. | Makes the machine assembled rather than selected. |
| Recipe discovery flags | Yes | First ten recipe definitions and discovered states. | Removes wiki dependence without granting free power. |
| Memory Fragments | Yes | Story memories and authored unlock conditions. | Connects repair choices to identity and campaign. |
| Frames | Yes | Body movement profile and starting rule. | Expands playstyle, not raw damage only. |
| Blessings | Yes | Doctrines and services. | Expands shop/build vocabulary. |
| Catalysts and services | Yes | New transformation verbs, routes, or shop actions. | Adds options and counterplay. |
| Arenas and objectives | Yes | New topology and repair/protect/escort rules. | Expands the pilgrimage. |
| Difficulty modifiers | Yes, once unlocked | Transparent pressure mutators. | Adds challenge without mandatory grind. |

The first slice has no permanent stat shop. After the first slice, the only permanent resource should be **Memory Fragments**, earned by authored objectives and first-time route outcomes. Memory Fragments unlock content flags and can be refunded only where a future system explicitly supports loadout choice; they do not buy unlimited damage, health, or reroll power.

### 7.2 Permanent layers in release order

1. **Frames:** one starting frame in the first slice; later frames alter movement, reserve capacity, starting service, or structure trade-offs.
2. **Blessings:** three in the first slice; later doctrines unlock through clear authored conditions, not repeated farming alone.
3. **Catalysts and recipes:** Mercy Rail is available immediately. Additional catalysts reveal new objective verbs and geometry.
4. **Arenas and objectives:** repair first; then protect, escort, recover, and hold. Each is paired with a clear mechanical question.
5. **Memory scenes:** a short result scene and memory ledger connect each route to the Saint Built Wrong arc.
6. **Difficulty modifiers:** unlocked after the player demonstrates the relevant counter skill. Modifiers are visible before route selection and award cosmetic, memory, or challenge rewards rather than mandatory power.

### 7.3 Unlock and difficulty strategy

Unlocks use three condition classes:

| Condition | Example | Reward |
|---|---|---|
| Mastery | Defeat Foreman Engine while preserving at least 60% relay structure. | New repair-oriented service. |
| Discovery | Complete a route with two hybrid tags and read the Ledger. | New catalyst or recipe. |
| Choice | Choose Brass Choir rather than Rootworks after the First Shift. | New Blessing or memory branch. |

The game never hides a required unlock behind an untelegraphed numerical wall. Each locked item has a `WHY LOCKED` explanation and a preview of its play pattern. The first Mercy Rail run cannot require a permanent unlock.

Difficulty increases by changing forecast composition, hazard timing, objective trade-offs, or enemy combinations. It does not primarily multiply enemy health. Each modifier lists the new pressure and at least one counter family. A failed higher-difficulty run preserves all prior discoveries and can be restarted immediately.

## 8. Failure and anti-friction rules

The research identifies three relevant failure risks: constrained geometry can turn movement into unavoidable contact damage [6] [28], short boss timers can produce power walls [7], and hidden economy or recipe behaviour can create guide dependence [4] [5] [9]. Scrap Saint addresses those risks with the following invariants.

| Risk | Rule | Player-facing evidence |
|---|---|---|
| Cornering | Every arena pocket has two exits; hazard activation leaves a marked escape corridor. | Topology debug overlay and visible route edge. |
| Early dead run | No lethal objective damage before the first shop; relay begins at 70% and receives a warning state before damage. | `RELAY UNDER THREAT` forecast and damage event. |
| Boss power wall | Mercy ingredient path is guaranteed by Shop 2–4; boss has interrupt windows and a recoverable first failure. | Missing-ingredient preview and demolition schedule. |
| Reroll hunting | One free reroll, one lock, protected current-build and evolution roles. | Offer role labels and reroll cost before commit. |
| Full inventory frustration | Four active weapon slots plus one reserve; combine, sell, dismantle, and reserve actions show direct rejection reasons. | Stable reasons such as `ACTIVE_SLOTS_FULL` and `RESERVE_FULL`. |
| Opaque economy | Every reward displays source, amount, and spend category. | Transaction history and next-decision affordability. |
| Hidden recipe dependence | First ten recipes visible in Ledger; first evolution guaranteed and previewed. | `UNKNOWN` / `DISCOVERED` / `READY` state. |
| Objective tunnel vision | Relay repair has partial progress and reward tiers; fighting away from it has a visible cost. | Relay structure, progress, and repair log. |
| Late-run restart cost | Nine-minute slice, fast restart, preserved discoveries, concise Results. | Results names cause of failure and one improvement cue. |
| Hybrid-build punishment | Blessing tags bias rather than hard-lock offers. | Blessing panel shows “favoured,” not “required.” |

Failure Results must classify the primary cause as one of `BUILD_GEOMETRY`, `OBJECTIVE_NEGLECT`, `POSITIONING`, `THREAT_RESPONSE`, `ECONOMY`, or `META_GATE`. The classification is derived from simulation events, not a post-hoc UI guess. It may include one secondary cause. The player can restart with the same seed or choose a new seed without returning to a loading hub.

## 9. First three implementation milestones and deterministic acceptance tests

These milestones intentionally match the first three repository tasks. They are the dependency gate before adding the full shop and evolution loop.

### Milestone 1 — SC-01: deterministic Godot shell and harness

**Player promise:** the Saint can boot a named build, accept a fixed command stream, pause, restart, and reproduce the same simulation state.

**Authoritative owner:** simulation core and replay harness.

**Required implementation:** project shell, fixed 60 Hz update, seed input, command queue, versioned state, state hash checkpoints, pause/restart, minimal debug overlay with build ID, seed, viewport, and tick.

**Deterministic acceptance tests:**

1. Start two runs with seed `104729` and the exact command stream `move(1,0)` for 60 ticks, `pause` at tick 60, `resume` at tick 120, and `restart` at tick 180. The checkpoint hash at ticks 0, 60, 120, and 180 must match byte-for-byte.
2. Run seed `104729` and seed `104730` with the same command stream. At least one checkpoint hash must differ; otherwise the seed is not authoritative.
3. Issue `pause` at tick 60 and advance 120 wall-clock frames. The simulation tick, RNG cursors, and state hash must remain unchanged.
4. Save at tick 90, reload, and continue with the same commands. The post-reload shop placeholder, RNG cursors, event IDs, and final hash must match uninterrupted execution.
5. Send an invalid command during the wrong window. The command must return a stable rejection reason and must not advance the RNG cursor or mutate state.

**Evidence gate:** a real running shell capture with seed, tick, viewport, and build identifier. A content validator result alone is not a pass.

### Milestone 2 — SC-02: Saint movement and one arena

**Player promise:** the Saint can move through the Collapsed Workshop, remain inside the arena, reach the repair relay, and see deterministic objective state.

**Authoritative owner:** movement, collision boundary, objective state machine, and arena data.

**Required implementation:** direct movement, three stable entry edges, relay at 70% structure, repair zone, safe shop alcove, two-exit topology validation, deterministic arena reset, camera framing.

**Deterministic acceptance tests:**

1. With seed `104729`, issue the same 600-tick movement stream. Saint position, velocity, relay structure, and objective progress must match at ticks 0, 120, 300, and 600.
2. Apply an input vector of magnitude 10. The accepted movement vector must be clamped to the defined maximum and produce the same result as the equivalent unit vector; no diagonal speed exploit is allowed.
3. Attempt to cross each of the four arena boundaries. The Saint must remain inside the same collision bounds and emit no position beyond the boundary.
4. Enter the repair zone and issue `repair` while the relay is repairable. Progress must increase only through an authoritative `REPAIRED` event. Issue `repair` outside the zone and assert `INVALID_TARGET` with no progress change.
5. Run the topology validator. Every traversable pocket must have at least two exits, all three entry edges must be reachable, and the shop alcove must not be the only route to the relay.
6. Reset the arena twice with the same seed. Obstacle positions, relay state, entry-edge IDs, and initial Saint position must match.

**Evidence gate:** gameplay capture at movement zoom showing the Saint, relay structure/progress, repair ring, three entry edges, and exact seed.

### Milestone 3 — SC-03: base combat

**Player promise:** three base relic weapons and three enemy families interact deterministically, with every hit and status traceable to simulation events.

**Authoritative owner:** targeting, attack scheduling, collision/effect resolution, enemy state, and event trace.

**Required implementation:** Nailer of Small Mercies, Bell of the Last Shift, Procession Gear; Rivet Hounds, Scrap Mites, Choir Drones; nearest/objective-attacker/area target rules; `MARKED`, `RUNG`, `QUIETED`, and `WITNESSED` statuses; authoritative damage, stagger, and defeat events.

**Deterministic acceptance tests:**

1. Spawn one enemy of each family at fixed positions with seed `104729`. Let the simulation advance 300 ticks without input. Attack event IDs, target IDs, damage, statuses, and defeat order must match a golden trace.
2. Move a Rivet Hound into and out of the Nailer’s target range. The Nailer must select the nearest eligible target, then prioritise an objective attacker when the content rule says so.
3. Apply Bell to a Choir Drone. The drone must receive `RUNG` or `WITNESSED` only through the authoritative effect event, with the defined duration and no presentation-side mutation.
4. Activate Procession Gear with two enemies on opposite sides. Orbit geometry, hit order, and cooldown must be identical across repeated runs.
5. Attempt to award damage by emitting a presentation-only event. The authoritative health must not change.
6. Verify that enemy telegraphs precede their damaging event by the authored warning duration and that the event trace includes source, target or area, effect, amount, and stable event ID.

**Evidence gate:** real combat capture plus trace excerpt. A screenshot that only shows particles is insufficient evidence of combat authority.

## 10. Implementation boundaries after milestone 3

The next dependency order is fixed: SC-04 relay damage and repair, SC-05 Scrap and Shards, SC-06 six-offer shop, SC-07 the three first Blessings, SC-08 ranks and Mercy Rail, SC-09 Memory Crane and Foreman Engine, and SC-10 Results and memory. Each step must preserve the seed/command/hash contract and must not introduce an untracked currency or hidden outcome.

The first complete slice is accepted only when a new player can answer four questions without external documentation: **what is being repaired, what the next threat wants, why a shop item matters, and how Mercy Rail changed the build.**

## 11. Explicit non-goals

The following are intentionally outside this design’s first implementation and must not be smuggled in as “small extensions”:

- Multiplayer, co-op, PvP, networking, or shared simulation.
- A freeform procedural world, large exploration map, or open-world traversal.
- A deep inventory grid, equipment durability maze, or more than one reserve slot.
- More than the two run currencies Scrap and Relic Shards.
- A permanent damage/health inflation tree as the main metagame.
- Hidden tag puzzles that require external guides.
- A shop whose best outcome depends on unlimited rerolling or rare random drops.
- More than one visible evolution in the first vertical slice; Mercy Rail is the required transformation.
- A broad dialogue tree, faction diplomacy simulation, squad management, or branching conversation system.
- A complete campaign, all four acts, every Blessing, every enemy family, or every ending before the first shop/evolution loop is credible.
- Bosses that are only health sponges, presentation-triggered damage, or untelegraphed one-hit failures.
- A universal wave count or shop cadence copied from a reference game without playtest evidence.

## 12. Research caveats

The supplied *Slime 3K* research could verify timed survivor-like progression, escalating enemies, a boss element, tag-oriented build assembly, and the separation of run and permanent progression, but it could not verify a universal wave count, universal timer, universal shop interval, or complete map topology. Community reports about Finance behaviour, hidden combinations, constrained movement, and level-specific boss pressure are useful friction evidence but are version-sensitive and not authoritative balance specifications [4] [5] [6] [7].

The supplied *Vampire Survivors* research is strong on documented systems such as stages, level-up choices, evolution conditions, PowerUps, achievements, characters, coffins, relics, and random events, but wiki snapshots and exact counts are patch-sensitive. Those sources support design precedents, not direct Scrap Saint balance values [9]–[20].

The supplied *Brotato* research provides the clearest documented wave/shop cadence, tier combining, forecasts, and compact-arena trade-offs, but counts and roster details are also version-sensitive. Its evolution conclusions are bounded inferences; recipe-style visible transformations are a Scrap Saint recommendation rather than a claim about the reference game [21]–[29].

All Scrap Saint timings, prices, topology dimensions, economy totals, and content gates in this document are recommendations to be validated by deterministic playtest traces and real gameplay captures. They are not presented as facts about the reference games.

## References

[1]: https://store.steampowered.com/app/2348610/Slime_3K_Rise_Against_Despot/?l=english "Slime 3K: Rise Against Despot — Steam store page"
[2]: https://www.nintendo.com/us/store/products/slime-3k-rise-against-despot-switch/ "Slime 3K: Rise Against Despot — Nintendo store page"
[3]: https://store.steampowered.com/news/app/2348610/view/4130434733331066838 "Slime 3K — Steam update on mini-bosses and boss abilities"
[4]: https://store.steampowered.com/news/app/2348610/view/6471198577686057727 "Slime 3K — Steam update and system changes"
[5]: https://store.steampowered.com/news/app/2348610/view/526462740974273479 "Slime 3K — Steam developer update"
[6]: https://www.stackup.org/post/review-slime-3k-rise-against-despot "Stack Up review of Slime 3K: Rise Against Despot"
[7]: https://steamcommunity.com/app/2348610/discussions/0/4626979145080960751/ "Slime 3K Steam community discussion on level timer and boss pressure"
[8]: https://store.steampowered.com/app/1794680/Vampire_Survivors/ "Vampire Survivors — Steam store page"
[9]: https://vampire.survivors.wiki/w/Stages "Vampire Survivors Wiki — Stages"
[10]: https://vampire.survivors.wiki/w/Evolution "Vampire Survivors Wiki — Evolution"
[11]: https://vampire.survivors.wiki/w/Level_up "Vampire Survivors Wiki — Level up"
[12]: https://vampire.survivors.wiki/w/Weapons "Vampire Survivors Wiki — Weapons"
[13]: https://vampire.survivors.wiki/w/Passive_items "Vampire Survivors Wiki — Passive items"
[14]: https://vampire.survivors.wiki/w/Merchant "Vampire Survivors Wiki — Merchant"
[15]: https://vampire.survivors.wiki/w/PowerUps "Vampire Survivors Wiki — PowerUps"
[16]: https://vampire.survivors.wiki/w/Achievements "Vampire Survivors Wiki — Achievements"
[17]: https://vampire.survivors.wiki/w/Characters "Vampire Survivors Wiki — Characters"
[18]: https://vampire.survivors.wiki/w/Coffin "Vampire Survivors Wiki — Coffin"
[19]: https://vampire.survivors.wiki/w/Relics "Vampire Survivors Wiki — Relics"
[20]: https://vampire.survivors.wiki/w/Random_Events "Vampire Survivors Wiki — Random Events"
[21]: https://store.steampowered.com/app/1942280/Brotato/ "Brotato — Steam store page"
[22]: https://brotato.wiki.spellsandguns.com/Waves "Brotato Wiki — Waves"
[23]: https://brotato.wiki.spellsandguns.com/Shop "Brotato Wiki — Shop"
[24]: https://brotato.wiki.spellsandguns.com/Characters "Brotato Wiki — Characters"
[25]: https://brotato.wiki.spellsandguns.com/Weapons "Brotato Wiki — Weapons"
[26]: https://brotato.wiki.spellsandguns.com/Progress "Brotato Wiki — Progress"
[27]: https://brotato.wiki.spellsandguns.com/Stats "Brotato Wiki — Stats"
[28]: https://higherplaingames.com/switch/brotato-review/ "Higher Plain Games review of Brotato"
[29]: https://www.thexboxhub.com/brotato-review/ "TheXboxHub review of Brotato"
[30]: https://steamcommunity.com/app/2348610/discussions/0/3909745662428682094/ "Slime 3K Steam community discussion on permanent progression and economy"
[31]: https://slime-3k-rise-against-despot.fandom.com/wiki/Tags_and_Synergies "Slime 3K community wiki — Tags and Synergies"
[32]: https://slime-3k-rise-against-despot.fandom.com/wiki/Upgrades "Slime 3K community wiki — Upgrades"
[33]: https://slime-3k-rise-against-despot.fandom.com/wiki/Slimes "Slime 3K community wiki — Slimes"
[34]: https://steamdb.info/app/2348610/patchnotes/ "SteamDB — Slime 3K patch notes"
[35]: https://seasonedgaming.com/2022/11/18/review-vampire-survivors-the-opposite-of-sucking/ "Seasoned Gaming review of Vampire Survivors"
[36]: https://www.lostatticgames.com/post/how-vampire-survivors-made-me-rethink-the-concept-of-the-core-gameplay-loop "Lost Attic Games analysis of the Vampire Survivors gameplay loop"
[37]: https://jboger.substack.com/p/the-secret-sauce-of-vampire-survivors "Analysis of the design structure of Vampire Survivors"

*Prepared by Manus AI from the supplied research results and current Scrap Saint repository contracts.*
