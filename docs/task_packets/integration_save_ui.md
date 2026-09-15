# Task packet: EA-Q01 — Integrated save and navigation contracts

## Player-facing objective

An expedition can be saved and resumed at every major phase, and keyboard or controller-style UI input can traverse the complete chapter without becoming stranded.

## Authoritative owner and command boundary

`Simulation` owns versioned run state and deterministic phase commands. `Profile` and `Settings` own their separate durable files. `Main` owns focus, input dispatch, and screen transitions without mutating combat outcomes directly.

## Exact files

- `game/main.gd`
- `game/profile.gd`
- `game/settings.gd`
- `tests/test_save_flow.gd`
- `tests/test_flow_input.gd`
- `tests/test_profile.gd`
- `tests/test_settings.gd`

## Preserved contracts and non-goals

- Preserve weapon, Gift, boss, encounter, economy, and route balance.
- Preserve fixed-tick simulation authority and stable content IDs.
- Do not add GitHub CI, new content, or new gameplay rules.
- Legacy saves receive safe defaults; invalid preference values never replace safe settings.

## Deterministic acceptance tests

1. Combat, shop, route, travel, destination, and memory snapshots restore to the same state hash and produce the same next authoritative transition.
2. Version-one Workshop and assembly-shaped saves receive frame, route, Gift, evolution, metric, machine, weapon, and enemy defaults without losing known state.
3. Required starting recipe/profile unlocks survive migration, including a legacy save that explicitly stored an empty recipe list.
4. Invalid legacy settings fall back to bounded defaults while valid controls survive.
5. Focused buttons activated through synthetic `ui_accept` traverse title, settings, setup, shop, route, travel, memory, Results, and return flow; controller Start pauses and resumes combat.

## Screenshot states and provenance

No new screenshot is required: this packet protects existing rendered screens and adds headless interaction/state evidence. Runtime provenance is the pinned Godot 4.5.1 executable used by the test report.

## Remaining limitation

Synthetic focus/action tests do not replace hands-on testing with multiple physical controller models.

## Exactly one next task

Run a packaged Windows build through the same route and save checkpoints on Windows hardware.
