# Task packet: M2 — site-clear and checkpoint lifecycle

## Player-facing objective

After every defeated site boss, show one clear account of the victory, reward, memory and carried build, then let the player safely resume the same pilgrimage from every map, road and arrival boundary without duplicating discoveries or reviving a defeated run.

## Authority and command boundary

The deterministic simulation owns the new `site_clear` phase, its summary payload, completed-site facts and the validated Continue command. Presentation may render that payload and request continuation; it cannot grant rewards or mark a site clear. A reusable persistence store owns atomic temporary-write, replacement, backup and fallback-load behavior. The profile owns durable route discoveries and run-ID/site-ID clear receipts.

## Expected files

`game/simulation.gd`; `game/main.gd`; `game/profile.gd`; a small atomic save-store helper; chapter memory content where the Workshop needs a summary; save/profile/chapter/UI/input tests; configured site-clear captures; agent-iteration/provenance metadata; roadmap/runtime/verification documentation; this packet.

## Preserved contracts and non-goals

Preserve deterministic hashes after restore, all combat/economy/route/road outcomes, optional work, arrival floors, carried builds, the six-site graph and terminal Results. Do not add practice starts, new rewards, new routes, cloud saves, multiple manual slots, chapter selection, balance changes or M3 pacing work. Map inspection remains presentation-only and earns nothing.

## Deterministic acceptance

1. Workshop, middle and terminal boss victories enter the same `site_clear` phase with stable site, boss, earned reward, memory, optional-work and carried-build facts.
2. Continuing a nonterminal clear opens the legal route map; continuing a terminal clear produces chapter Results. Repeated Continue commands cannot duplicate rewards or receipts.
3. Validated boundaries automatically checkpoint site clear, route-map continuation, route commitment, every accepted road choice and destination arrival without advancing simulation RNG.
4. Atomic writes retain the previous valid primary as a backup; an injected failure before replacement leaves the prior save loadable; corrupt primaries fall back to the backup.
5. Restoring every supported phase preserves the exact simulation hash, offers, selected route, RNG and remaining road node.
6. Defeat or terminal completion removes active primary, temporary and backup expedition saves; loading a legacy terminal save cannot resurrect it.
7. Profile clear credit uses a stable run-ID/site-ID receipt. Repeated checkpoint/load/final-result commits grant each site memory and fragment once while preserving earlier clears after a later death.
8. Route discoveries consume `route_history`/`route_ids`; both first branches unlock correctly even when the final `route_id` names a later leg. Merely inspecting a future map node unlocks nothing.
9. Version migration initializes receipts for previously completed sites without duplicating fragments and retains all mandatory starting unlocks.

## Screenshot evidence

Capture Godot 4.5.1 at 1280×800, seed 147: Workshop clear, middle-site clear, terminal clear, and large-text Workshop clear. Label all as configured executable fixtures, not human playtests.

## Remaining limitation

Automated lifecycle tests and configured summaries cannot establish whether a player reads the recap, trusts automatic saving, or understands the difference between site discovery and chapter completion.

## Exactly one next task

Implement M3 distinct arrival presentation and normal-speed four-path pacing evidence.
