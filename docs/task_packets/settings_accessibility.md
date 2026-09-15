# Task packet: EA-R02 — Persistent settings and remapping

## Player-facing objective

Players can retain readable text/effect preferences and remap keyboard movement without editing project files.

## Authoritative owner

The settings service owns local presentation and input preferences. It cannot mutate simulation state, run outcomes, or content.

## Exact files

- `game/settings.gd`
- `tests/test_settings.gd`

## Preserved contracts

- Simulation commands remain deterministic and independent of hardware input.
- Controller bindings remain present when keyboard keys are changed.
- Settings have a versioned local save and safe defaults.

## Non-goals

- Platform-specific accessibility certification, cloud synchronization, or gameplay assists that modify balance.

## Deterministic acceptance tests

1. Defaults are valid and complete.
2. Out-of-range values and unknown actions are rejected without mutation.
3. Keyboard bindings apply to named input actions.
4. Save/load is exact and older settings receive safe defaults.

## Evidence states

- Settings panel at 1280×800 showing keyboard bindings, text scale, effect density, sound, and fullscreen state.

## Remaining limitation

Controller rebinding and operating-system screen-reader support require later platform-specific work.

## Exactly one next task

Connect this service to the title and pause settings panels after gameplay branch integration.
