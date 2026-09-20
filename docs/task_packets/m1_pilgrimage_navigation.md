# Task packet: M1 — pilgrimage map and destination clarity

## Player-facing objective

Let the player inspect the complete three-level First Pilgrimage before starting, then make every between-level destination choice explain what lies ahead, what carries over, what travel costs and whether optional work is actually optional.

## Authority and command boundary

The deterministic simulation remains the sole owner of route eligibility, fare payment, assignment status, route history, road choices, arrival recovery, build carryover and RNG. The departure preview is presentation-only and starts no simulation. Active route-map controls may only select previews or send the existing `choose_route` command; inspection cannot tick the simulation or mutate a run.

## Expected files

`game/main.gd`; `content/chapter/first_chapter.json`; map/UI/input tests; expedition-map capture; agent-iteration/provenance metadata; roadmap/runtime/verification documentation; this packet.

## Preserved contracts and non-goals

Preserve the six-site graph, all route costs, current wave counts/timing, two authored road stops, arrival floors, build/economy carryover, optional-repair rules, save format, manifested relics and every combat outcome. Do not add checkpoints, site-clear rewards, arbitrary destination starts, practice mode, new sites, balance changes or profile migration; those belong to M2 or later.

## Deterministic acceptance

1. Completing Frame/Blessing setup opens a departure map without creating or stepping simulation state.
2. All six stable site IDs are inspectable by mouse, keyboard and controller; only Collapsed Workshop can launch from departure.
3. Departure communicates three levels, four valid paths, persistent build carryover and terminal chapter endings.
4. Active route maps distinguish current, cleared, reachable, future and not-taken nodes with text/shape as well as color.
5. Reachable map nodes and explicit route controls select the same stable route ID; inspection remains reversible until a separate Travel action.
6. Destination detail shows experience, threat/boss, optional opportunity, waves/estimated combat time, fare/current Scrap, arrival floor, road sequence and next sites or chapter ending.
7. Travel calls the existing command exactly once; insufficient or disconnected routes remain non-mutating and state why travel is unavailable.
8. Existing road, arrival, save, route-history, economy and policy tests remain unchanged in authority and outcome.

## Screenshot evidence

Capture Godot 4.5.1 at 1280×800, seed 147: departure Workshop; inspectable future finale; first-tier Brass and Rootworks previews; second-tier available finale; branch-not-taken state; and accepted/road handoff. Label fixtures as configured states, not human playtests.

## Remaining limitation

Configured captures and controller-style automation cannot establish newcomer comprehension, reading pace or destination preference at normal speed.

## Exactly one next task

Implement M2: unified site-clear summary and atomic automatic checkpoints with exactly-once discovery credit.
