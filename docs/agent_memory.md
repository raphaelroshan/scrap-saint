# Agent memory — 2026-09-25

Read [production state](production_state.md), [current QA](qa_current.md) and [canonical prompt entry](agent_prompt_pack.md) first. Update this handoff after each bounded iteration.

## Decisions that must survive context loss

- Freely given repairs caused the Saint to manifest; no maker deliberately engineered it.
- Free movement and optional repairs are the main mode. Boss defeat advances. Field drops and optional work provide recovery; shops have six relic offers, no repair/service slots.
- Preserve the current Saint sprite. Weapons manifest through their own mechanisms/effects; no attachment rig is required.
- Deterministic simulation owns outcomes, RNG, commerce, saves and progression. Presentation reads state/events and submits validated commands. Preserve stable content IDs.
- The user requests commit and push after validated changes; fetch before integration, preserve unrelated work, never force-push.
- Pack references to required relay defence and old design-document roster limits are historical. Current user decisions and enabled runtime supersede them.

## Handoff

Prompt 0 was executed against clean, synchronized main at `3464991`. No gameplay source or generated art changed. The audit adds durable planning and evidence, not a feature-completion claim. Current fresh checks: content/import pass, 400 assertions in six suites; native natural policy seed 147 wins through Brass to Pale Archive with normal economy. Rendering was inspected on Windows / RTX 4060 / Godot 4.5.1 Compatibility at 1280x800. These are automated captures, not human play.

Concrete defect: Warning Bell reward text clips at the arena edge in FOREMAN_FINAL_ORDERS.png; game/main.gd draw_optional_machines uses an unwrapped line. Execute [Workshop repair readability](task_packets/workshop_repair_readability.md) next, preserving all simulation outcomes. Its full approach → progress/deferral → reward → departure interaction is the scope. Do not expand into boss balance or new assets.

The uncoached 1x Workshop gate is still open after that fix. Observe actual understanding rather than assuming passing policies establish fun. Existing ObjectDB exit warnings remain; Windows and shell iteration runners have different focused-suite coverage. Destination art is unfinished; the retained procedural Saint is an explicit decision, not an accidental placeholder.

## Local execution

Repository: `C:/Users/Raph/Documents/ChatGPT/Scrap saint/source`.
Godot: `../.runtime/godot/Godot_v4.5.1-stable_win64_console.exe` from the repository.
Python: `C:/Users/Raph/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`.
Native captures are available through Godot scripts even when desktop interaction is unavailable. Read the captures; do not equate a process exit with visual acceptance. Exact commands and results are in [QA](qa_current.md).
