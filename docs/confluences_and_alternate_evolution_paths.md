# Confluences and alternate Evolution paths

**Status:** `WIP / DESIGN ONLY`

No Vow, Boss Imprint, or Confluence in this document is enabled in `0.5.0-preview`. The current runtime still uses Rank III plus a named catalyst for every Evolution and contains no Confluence.

## Design decision

Evolution and Confluence should answer different questions:

| System | Player question | Inputs | Result |
|---|---|---|---|
| **Combine** | How do I make this familiar tool more capable? | Two identical same-rank weapons | The same weapon at the next rank, with cumulative named traits |
| **Evolution** | What higher form does this tool become? | One Rank III weapon plus one valid proof | One named transformation of that weapon |
| **Confluence** | What am I willing to stop carrying separately so two doctrines can become one? | Two different active Rank III base weapons | One named hybrid with new geometry and one freed active slot |

Confluences are not “two attacks at once.” Each must collapse both source roles into one readable setup/payoff or spatial behaviour. Its weakness must preserve a reason to keep the two source weapons separate.

## WIP alternate Evolution proofs

Catalysts should remain a fast, deterministic material route, but they do not need to be the only way to satisfy an Evolution recipe. The Ledger can eventually show three kinds of proof.

```text
Rank III weapon
├── Material Proof: bring the named catalyst
├── Deed Proof: accept and complete a weapon-specific Vow
└── Adversary Proof: bind a compatible Boss Imprint
         ↓
explicit altar / reward transformation window
         ↓
the same named Evolution
```

The first implementation should produce the same Evolution regardless of proof. Source-specific variants would multiply balance, UI, save, and visual states before the access system itself is proven. The Results screen may record whether the transformation was `MATERIAL`, `VOW`, or `IMPRINT`.

### Vows — WIP

A Vow is an optional, visible behavioural challenge. It rewards using a Rank III weapon according to its identity rather than accumulating generic kills.

Rules:

- A Vow is deliberately accepted at a shop altar or reward window; it never activates silently.
- Only one Vow is active at a time, but progress persists across sites and saves.
- Progress comes only from authoritative attack, status, repair, and objective events.
- The HUD states the action and exact progress. Failure or abandoning a Vow never consumes the weapon.
- A Vow may impose a temporary tactical constraint, but cannot require a particular seed, enemy roll, Gift, or Blessing.
- Completion supplies a Deed Proof; the player still chooses when to transform.

Provisional Vows for the current roster:

| Weapon | Vow concept | Identity demonstrated |
|---|---|---|
| Nailer | Pierce three machines in one line three times, including one support or major machine. | Alignment and priority |
| Last Shift Bell | Catch at least three machines in one Bell stagger, twice. | Timed area control |
| Procession Gear | Complete one optional repair while both opposed contacts strike threats. | Escort defence during work |
| Candle-Nailer | Create and collect six Candle motes while allowing no more than one to expire. | Execution converted into recovery |
| Contrition Cable | Bind at least four machines in one sweep, twice. | Broad route control |
| Hymn Coil | Quiet at least two machines with one beam, three times. | Suppression timing |
| Altar Mortar | Hit at least four machines with one blast, twice. | Cluster prediction |
| Foundry Censer | Produce three Scrap embers from defeats inside smoke. | Close-pressure economy |
| Penance Winch | Pull three machines from more than 400 units away before they enter close range. | Long-range intervention |
| Welded Halo | Apply objective stitches while two threats are inside Halo reach, three times. | Repair under pressure |

These counts are starting hypotheses, not balance commitments. Each Vow needs deterministic feasibility traces across all authored routes before activation.

### Boss Imprints — WIP

A Boss Imprint is a remembered rule, not a dropped item. Defeating a named boss reveals one deterministic pattern at Results. At the next altar, the player may bind it as the proof for one compatible Rank III weapon.

Rules:

- Imprints do not occupy inventory and do not create a currency.
- A boss presents authored compatible families; there is no random drop table.
- One earned Imprint can satisfy one Evolution and is then committed to that weapon lineage.
- The preview explains which boss rule is being repurposed and what the Evolution does with it.
- Mid-site Imprints support the remainder of the chapter. Terminal-boss Imprints become recipe-discovery or future-run unlock evidence rather than power arriving after the run is over.
- An Imprint is an alternate proof, not a stronger version of the catalyst result.

Initial thematic links:

| Boss rule | Compatible families | Reinterpreted proof |
|---|---|---|
| Foreman Engine demolition schedules | Mortar, Winch, Cable | Precise placement, interruption, and work routing |
| Choir Regent resonance measures | Bell, Hymn | Pulse timing and suppression |
| Factory Heart repair lock and graft feed | Halo, Nailer, Censer | Repair circuits and converted machine residue |
| Archivist Prime copied geometry | Any one visible Rank III family | A single mirrored recipe already demonstrated in that encounter |
| Red Cardinal furnace anchors | Mortar, Censer | Heat zones and area denial |
| Null Auditor weapon/work locks | Hymn, Cable | Silence, interruption, and denial |

Archivist Prime must not become a universal free choice: it may imprint only a geometry visibly copied during that fight.

## Confluence contract

### Eligibility and mutation

- Both sources are different, active, unevolved Rank III base weapons.
- The recipe is discovered and the player is inside an elite, boss-reward, or altar transformation window.
- No catalyst or third currency is required.
- The command removes both source instances atomically, creates one Confluence instance with both complete lineages, resets readiness, and frees one active weapon slot.
- A rejected command changes no inventory, currency, readiness, RNG cursor, or discovery state.
- A Confluence cannot Combine or Evolution again in the first implementation.
- Selling or dismantling is permitted with an explicit authored refund, but it does not recreate the two source weapons.
- Multiple Confluences are not forbidden by a hidden cap; their source cost, recipe pool, and four-slot loadout create the constraint.

Stable rejection reasons should include `RECIPE_UNDISCOVERED`, `MISSING_SOURCE`, `SOURCE_NOT_ACTIVE`, `SOURCE_NOT_RANK_III`, `SOURCE_ALREADY_EVOLVED`, and `OUTSIDE_WINDOW`.

### What the preview must show

The altar card should avoid a conventional crafting-tree presentation. It should read as a consequential before/after decision:

```text
GIVE UP
Nailer III — narrow priority line
Bell III — emergency cone control

BECOMES
THE LINE THAT RINGS — rail with a terminal stagger pulse

YOU LOSE
independent fast shots and rear emergency coverage

YOU GAIN
one free weapon slot and a setup/payoff attack
```

The card also shows exact target rule, cadence, geometry, compatible Gifts, sell value, both source lineages, and one sentence explaining why keeping the sources separate remains valid.

### Inheritance rules

Confluences do not automatically inherit every base trait, catalyst effect, Gift interaction, and tag. Each recipe authors them explicitly:

- maximum three visible tags;
- at most one signature Rank trait from each source;
- explicit `compatible_gift_ids` rather than matching by name or tag;
- carried catalyst effects retain their ordinary global rules, but are never silently consumed;
- source-specific Blessings bias the recipe offer but do not alter eligibility;
- Results attribute damage, control, repair, and resource contribution to the Confluence while preserving both source IDs.

This prevents combinations such as Bell plus Hymn from accidentally inheriting every mark, stagger, Quiet, Filter, catalyst, and doctrine multiplier at once.

## Current-roster Confluence candidates

### Tier A — first implementation candidates

| Rank III sources | Confluence | New geometry and behaviour | Cost and weakness | Gift links |
|---|---|---|---|---|
| Nailer + Last Shift Bell | **The Line That Rings** | A priority rail pierces one lane, then its endpoint unfolds into a short bell pulse. Targets touched by both are Marked and Rung. | Slower than Nailer, much narrower than Bell, and the pulse occurs only at the rail endpoint. Surrounding pressure can bypass it. | Brass Fuse may mark the first surviving terminal-pulse stagger; its cadence penalty applies to the whole Confluence. |
| Procession Gear + Contrition Cable | **Procession Harness** | A physical gear travels on a rotating cable ring. Contact binds and draws threats toward the moving route; defeating a Bound threat near visible work produces one restrained repair filing. | Commits the player to close range, loses Cable's distant reach, and cannot answer support enemies outside the orbit. | Loose Spring and Spare Hand share its repair context but do not modify its attacks. A future Tether Spool may be explicitly compatible. |

These two are the strongest first pair because they contrast a directional setup/payoff weapon with a persistent close-control weapon. Their geometries, weaknesses, and source identities are visibly different.

### Tier B — viable later candidates

| Rank III sources | Confluence | New geometry and behaviour | Cost and weakness | Gift links |
|---|---|---|---|---|
| Candle-Nailer + Hymn Coil | **Requiem Coil** | A cyan-violet beam selects a support machine performing an action, then jumps through up to two weaker targets. It Quiets each hit; only the first defeat per cycle releases a seeking mote. | Loses Hymn's full straight-line density and Candle's reliable weakest-target volley; poor against healthy isolated elites. | Choir Filter is compatible and applies its suppression extension and damage penalty. |
| Altar Mortar + Foundry Censer | **Incense Engine** | A shell creates an offset smoke zone; the next completed cycle detonates and consumes that zone while a new zone is placed. | Requires a two-cycle setup, moving targets can leave the zone, and it provides little immediate close defence. | No current Gift directly modifies it; Loose Spring merely helps reposition between zones. |
| Penance Winch + Altar Mortar | **Demolition Liturgy** | The hook drags one priority threat to a visible work mark; a delayed shell lands on that mark as the cable releases. | Long cadence, weak against scattered swarms, and pulling danger toward the Saint can make a missed blast costly. | Inspection Lens improves information only. No Gift changes the attack without an explicit future contract. |
| Penance Winch + Welded Halo | **Mercy Gantry** | The Winch carries a two-contact Halo to a distant objective attacker or damaged machine, creating a temporary remote control-and-repair anchor. | Leaves the Saint without Halo's close guard, affects only one remote pocket, and cycles slowly. | Spare Hand and Loose Spring share repair context only; neither multiplies the Gantry pulse. |

Tier B recipes should remain disabled until the first two prove that Confluences improve decisions rather than simply compressing two strong weapons into one slot.

### Rejected or deferred pairs

| Pair | Reason not to pursue now |
|---|---|
| Bell + Hymn | A radial Quiet/stagger tool answers too many support and swarm problems while duplicating Great Toll and Quiet Sermon. |
| Gear + Halo | Dual repair orbits overlap Maintenance Parade and Halo of Repairs without a sufficiently new player question. |
| Nailer + Winch | A priority tethered rail is too close to Mercy Rail and The Long Hand. |
| Cable + Hymn | A triangular silence field risks becoming a universally correct support shutdown and adds excessive status density. |
| Censer + Halo | Mobile repair smoke obscures whether the player is dealing damage, slowing, or repairing and creates poor overlap readability. |
| Any three-weapon recipe | Three ingredients turn every shop choice into future-recipe preservation and are incompatible with the current four-slot clarity target. |

## Four-beat Confluence animation

Every transformation shows the two source silhouettes before they lock together. The source objects remain visually recognisable for the first two attacks.

| Confluence | Prepare → Commit → Resolve → Aftermath |
|---|---|
| **The Line That Rings** | Nailer rail and Bell piston align along one sightline → a bronze collar locks and the striker follows the fired pin → the rail reaches its endpoint before blooming into a contained bell pulse → a glowing line and one fading endpoint ring explain which targets received both effects. |
| **Procession Harness** | Orbit slows and Cable wraps through the Gear hub → the spool pays out as the Gear rolls onto the wider tether route → contact pulls struck enemies toward the moving ring → the line snaps taut, drops repair filings near valid work, and retracts into a steady procession. |
| **Requiem Coil** | Three violet wick sparks enter the copper winding → tuning forks select the active support target → one cyan beam bends into two thinner funeral branches → Quiet bars remain while a single violet mote returns along the final branch. |
| **Incense Engine** | Mortar font seals beneath the swinging Censer and the current smoke zone gains an orange seam → shell drawer closes and pressure vents through the chain → a new smoke zone lands as the previous zone folds inward and bursts → black-violet residue cools with one square orange seal marking the consumed zone. |
| **Demolition Liturgy** | Hook endpoint and mortar landing seal appear together → telescoping arm places the target on the work mark and holds tension → cable release and shell impact occur as one timed beat → the hook retracts through the fading scorch seal, exposing the dangerous gap before the next cycle. |
| **Mercy Gantry** | Winch unfolds while Halo contracts around its hook → the gimbal travels along the arm to the selected remote pocket → two contacts rotate around the anchor while one cream stitch returns along the cable → the Halo folds and rides the retracting arm home, leaving no false repair zone behind. |

Transformation target is 0.4–0.6 seconds, with a brief control pause and small camera impulse. Ordinary Confluence attacks use no camera zoom. Reduced-effects mode retains source silhouettes, core geometry, target endpoint, and status icons while removing decorative sparks, smoke layers, cloth, and filings.

## Balance and pacing gates

A Confluence should produce roughly 65–80% of the two sources' combined raw throughput. Its value comes from integrated behaviour and a freed slot, not superior numbers in every matchup. Exact values must be authored per recipe rather than calculated at runtime.

Before enabling even the first pair, evidence must show:

1. Ordinary chapter income and shop guarantees let a non-perfect player assemble one chosen Rank III pair early enough to use it meaningfully.
2. Pursuing the pair does not force six or more dead shop decisions or make every other purchase incorrect.
3. Separate Rank III source weapons remain viable through the same encounter matrix.
4. The hybrid has at least one authored wave it solves well and one where its stated weakness is visible.
5. Two Confluences can coexist in save/replay and remain visually distinguishable under four-slot effect density.
6. The shop always presents a non-Confluence alternative at the transformation window.
7. Archivist Prime and Memory Crane copy only explicitly authored Confluence geometry; they never infer behaviour from source tags.

## Proposed first implementation packet

Enable only **The Line That Rings** and **Procession Harness** after the outstanding P16 human test and a normal-economy acquisition trace.

Required implementation surface:

- stable content records and explicit source/inheritance/Gift fields;
- deterministic `confluence` command and atomic rejection tests;
- shop and Ledger before/after preview;
- dual-source lineage in saves, replay traces, Results, and boss-copy rules;
- physical transformation and four-beat attack presentation;
- controlled fixtures plus natural 1× acquisition and full-run policies;
- unchanged winning policies using the four separate source weapons.

Until those gates pass, Confluences, Vows, and Boss Imprints remain `WIP / DESIGN ONLY` and must not appear as available runtime choices.
