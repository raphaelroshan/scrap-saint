# Task packet: EA-P01 — Frames and memory profile

## Player-facing objective

Completing meaningful repairs, destinations, and discoveries unlocks new ways to play without permanently inflating combat statistics.

## Authoritative owner

`Profile` owns durable unlocks and committed run-result IDs. The run simulation supplies a completed result summary but never reads or writes the profile during combat.

## Exact files

- `content/frames/first_chapter.json`
- `content/progression/first_chapter.json`
- `game/profile.gd`
- `tests/test_profile.gd`

## Preserved contracts

- Memory unlocks options, story, and transparent challenges rather than raw damage.
- Scrap, Relic Shards, weapons, Gifts, and the active build remain run-local.
- A result can be committed only once, including after save/reload.
- Profile data uses stable content IDs and an explicit schema version.

## Non-goals

- Cloud saves, achievements, account identity, a permanent stat tree, or a grindable currency shop.
- UI integration before the expedition branch defines its final result payload.

## Deterministic acceptance tests

1. A fresh profile exposes only the Pilgrim Frame and the three starting Blessings.
2. Repair, Foreman, route, destination, and evolution results unlock their authored options.
3. Recommitting the same run ID grants no duplicate Memory Fragment or unlock.
4. Profile save/load preserves exactly the same state.
5. Version-one profile data migrates with safe defaults and retains prior discoveries.

## Evidence states

- Frame-selection cards and post-run unlock ledger after integration, captured at 1280×800 with build and seed provenance.

## Remaining limitation

These rules cannot prove that frame trade-offs are enjoyable before external playtesting.

## Exactly one next task

Connect frame selection and committed expedition results to the game flow after the route branch integrates.
