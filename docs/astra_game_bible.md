# Scrap Saint — Astra game bible

## One-sentence promise

**Scrap Saint is a warm industrial arena roguelite about a small devotional machine that repairs a ruined world while assembling relic weapons, receiving competing Blessings, and discovering what kind of machine it chooses to become.**

## Player fantasy

The player should feel like a stubborn little maintenance machine that is simultaneously a pilgrim, mechanic, protector, and accidental saint. It is physically small, underpowered, and surrounded by dangerous industrial remnants, but it can make broken things work again. The player’s satisfaction comes from turning humble components into a coherent doctrine and watching a build become visibly stranger and more capable.

The game should create three recurring feelings:

1. **Improvisation:** make a useful machine from whatever the shop and battlefield provide.
2. **Transformation:** evolve an ordinary relic into a named, visibly different miracle.
3. **Meaning:** choose whether repair, power, memory, or freedom matters most to this machine.

## Canonical story

The Saint awakens beneath a collapsed workshop with one instruction intact: **Restore the First Engine**. It travels through industrial ruins, broken settlements, and contested machine districts, repairing relays, pumps, workshops, and shrines while searching for evidence of its own origin.

The Saint was assembled incorrectly from incompatible machines. Its bell was taken from a factory, its maintenance arm from a waterworks, its memory lens from an archive, and its protective shell from a combat platform. The old machine order calls this an error. The Saint gradually decides that being assembled from many purposes may be a strength rather than a defect.

The First Engine can be restored, repurposed for the surviving settlements, or dismantled so the world is no longer controlled by one central authority. These endings should emerge from the player’s Blessings, repairs, faction choices, and final decisions rather than from a late dialogue quiz.

## Tone and flavour

The tone is earnest industrial melancholy with gentle absurdity. The Saint treats a warning bell, a maintenance manual, and a box of rivets with solemn respect. Humour comes from the mismatch between ritual seriousness and improvised machinery, never from mocking belief.

The writing should be concise and concrete. A relic name should imply history: **The Nailer of Small Mercies**, **The Bell of the Last Shift**, **The Door That Opens Once**, **The Sermon That Cannot Be Heard**, and **The Maintenance Parade**. Avoid generic names such as Divine Gun, Holy Sword, or Sacred Blast.

## Core run

```text
Choose a Saint frame and Blessing
→ enter a compact industrial zone
→ move and auto-attack
→ protect or repair an objective
→ collect Scrap and Relic Shards
→ visit the relic shop
→ buy, sell, combine, reserve, repair, or reroll
→ pursue a visible evolution
→ survive an elite or boss
→ reveal a memory and choose the next route
```

The target run length is 15–25 minutes. The first playable run is 8–10 minutes. Combat should be active but readable: direct movement, automatic attacks, one or two active responses, meaningful positioning, and clear enemy telegraphs.

## Blessings and shop

A Blessing is a run-level doctrine. It guarantees an initial direction, biases shop offers, supplies a unique service, and may unlock a fulfilled-doctrine effect. It is not a permanent deck and must not hard-lock the player.

The shop uses **Scrap** for ordinary weapons, upgrades, repairs, rerolls, and combinations. It uses **Relic Shards** for catalysts, evolution support, rare services, and major doctrine choices. The first version has four active weapon slots, one reserve slot, six offers, one free refresh, and paid rerolls.

Every shop should offer one current-build improvement, one visible evolution-path offer, one new direction, one flexible support option, and two forecast-informed options. If the player is one ingredient away from a known evolution, controlled randomness should make that path attainable without making it free.

## Weapon language

Weapons combine a relic, a mechanism, and a doctrine. The first base catalogue includes the Nailer of Small Mercies, Bell of the Last Shift, Procession Gear, Candle-Nailer, Cable of Contrition, Hymn Coil, and Altar Mortar.

The first readable effects are Marked, Rung, Bound, Scoured, Consecrated, Fevered, Quieted, Witnessed, Repaired, Converted, Overloaded, and Mourned. Each effect has one visible state, one deterministic trigger, one duration or resolution, and one counter family.

The first evolution is:

```text
Nailer of Small Mercies Rank 3 + Saint’s Rivet → Mercy Rail
```

The evolution must change attack geometry and repair behaviour, not only increase damage. A player should preview the result, see the missing ingredients, trigger it at an explicit transformation point, and understand what changed.

## Enemy and boss philosophy

Enemies are questions. The Rivet Hound asks whether the player can protect an objective from a charger. The Choir Drone asks whether the player can interrupt a support field. The Rust Pilgrim asks whether armour and healing can be countered. The Memory Crane asks whether the player can fight a copy of its own evolution.

Every boss changes a rule, objective, or arena condition. The Foreman Engine schedules demolition zones and summons worker drones. The Factory Heart pulses damage through connected machinery. The Saint of No Repairs disables healing. The First Engine changes its weakness after major evolutions.

## Progression

Run progression consists of shop decisions, Blessing deepening, weapon ranks, catalysts, and evolutions. Meta-progression unlocks new frames, Blessings, catalysts, arenas, objective types, memory scenes, and difficulty modifiers. Avoid permanent damage inflation as the primary progression; unlock new ways to play.

The campaign should have four acts:

1. **The First Shift:** awakening, repair, and the first shop.
2. **Contested Districts:** rival relic traditions and hybrid Blessings.
3. **The Memory Works:** evidence of the Saint’s incompatible construction.
4. **The First Engine:** final doctrine, boss, and restore/repurpose/dismantle choice.

## Visual identity

The target is a chunky industrial diorama with a warm-cool palette: rust, brass, cream, soot, faded red, warning yellow, deep blue, and oxidized green. Silhouettes must read at gameplay zoom. Relics should look repaired and reused rather than pristine fantasy loot. Effects should distinguish repair sparks, bell resonance, cables, beams, seals, and status states.

The camera should prioritise the Saint, objective, threat direction, and active effects. Background detail must remain subordinate to play. Audio should use mechanical rhythm, bell resonance, servo movement, low machinery, and brief choral or tonal cues rather than a constant wall of music.

## Technical boundaries

The simulation owns movement results, timers, targeting, hits, damage, healing, statuses, pickups, currencies, shop rolls, rerolls, purchases, combinations, Blessings, evolutions, objectives, bosses, seeds, saves, and replay traces. Presentation renders returned events and owns animation, particles, audio, camera, UI, and input mapping.

Content must use stable IDs and data files. The first project should prove one deterministic shell and one complete weapon/evolution loop before expanding into a full campaign or faction simulation.

## Agent quality contract

Astra must work in bounded slices. Every task states the player-facing objective, authoritative owner, files, acceptance tests, non-goals, screenshot state, build/viewport provenance, limitation, and exactly one next task.

A content check is not gameplay proof. A timeout is not a pass. If a playable project does not exist yet, report that limitation instead of producing fake screenshots. Once a runtime exists, use Build → Run → Capture → Critique → Revise and preserve invalid evidence with its explanation.

## Non-goals for the first vertical slice

Do not build multiplayer, freeform procedural worlds, a large faction diplomacy system, a deep inventory grid, a squad, a broad dialogue tree, or more than one persistent currency. Do not implement every Blessing, enemy, or ending before the first shop/evolution loop is visually and mechanically credible.
