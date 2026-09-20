# Task packet: M3 — arrival identity and four-path pacing

## Player-facing objective

Give every destination a deliberate arrival beat that explains its immediate combat question before time starts, then prove that every authored pilgrimage path remains completable at normal simulation speed without optional repairs or an Evolution.

## Authority and command boundary

The deterministic simulation owns an `arrival` phase, its stable summary payload and the validated `begin_site` transition into combat. Presentation renders the arrival and sends that command; reading cannot tick combat, change RNG or award recovery. Existing route, road, recovery, wave, objective, boss and build state remain authoritative.

## Expected files

`game/simulation.gd`; `game/main.gd`; chapter/route presentation data only if required; chapter/save/UI/input tests; a deterministic four-path pacing runner; arrival captures; agent-iteration/provenance metadata; roadmap/runtime/verification documentation; this packet.

## Preserved contracts and non-goals

Preserve route prices, two road choices, arrival floors, wave counts/ticks, enemy schedules, boss rules, optional work, checkpoint semantics, run/site receipts, weapons, Evolutions and Gifts. Do not tune combat from automated policy alone, add sites or rewards, make optional work mandatory, add practice starts, or claim human confusion/readability evidence.

## Deterministic acceptance

1. Resolving the final road choice enters `arrival`, applies the authored recovery once and exposes site, boss, threat, optional opportunity, wave count, estimated duration, current build and road consequences.
2. Arrival reading cannot advance tick/RNG or repeat recovery. Only `begin_site` starts combat, and repeated commands are non-mutating.
3. Saving and restoring arrival preserves the exact hash, payload, route history, offers/RNG and carried build; beginning after restore emits the same next state and events.
4. Mouse, keyboard and controller-style activation can continue from arrival, with a clear focused action and a Save & Title option.
5. A normal-speed deterministic runner completes Brass→Pale, Brass→Red, Rootworks→Red and Rootworks→Null with no optional work and no Evolution.
6. Every route commitment remains affordable from authored rewards, and forcing zero Scrap after commitment still leaves a valid free choice at both road nodes.
7. Pacing output records combat ticks/seconds by site, shop count, road decisions, boss-entry tick, outcome, build and remaining structure for each path.

## Screenshot evidence

Capture Godot 4.5.1 at 1280×800, seed 147: Brass arrival, Rootworks arrival, one terminal arrival, and a large-text arrival. Label fixtures as configured executable states, not human playtests.

## Remaining limitation

Deterministic policy completions and configured arrivals cannot establish human reading time, confusion, boss recognition, difficulty comfort or desire to replay.

## Exactly one next task

Run uncoached human 1× sessions across all four paths and tune only observed pacing, arrival-comprehension and boss-readability failures.
