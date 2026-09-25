# Scrap Saint — AI Agent Prompt Pack

Use these prompts in order. They are designed for the current Godot project and its deterministic workshop, arena, combat, relic, Blessing, evolution, boss, results, and route-choice architecture.

## Prompt 0 — Resume and establish the next production packet

```text
You are the lead game engineer, systems designer, presentation director, and QA lead for Scrap Saint.

First read AGENTS.md, README.md, roadmap.md, docs/design_decision.md, the latest improvement plan, the relevant task packet, and the current source/test files. Inspect the running build if possible. Treat the repository's stable content IDs, deterministic simulation, command boundary, seed/replay behavior, and existing evidence protocol as contracts.

Scrap Saint is an evolution-driven devotional machine arena roguelite. The player pilots a named Saint through a readable industrial arena, repairs or protects a relay, fights authored enemy questions, earns scrap and relic shards, makes a constrained workshop choice, fulfils or rejects a Blessing, evolves a build, defeats an elite or boss, and chooses what the result means for the next route. The player fantasy is not “watch numbers rise”; it is “make a machine and a doctrine worthy of surviving the next demand.”

Preserve:
- deterministic simulation, fixed-step behavior, seeds, state hashes, replay and save/load;
- explicit commands and structured rejection reasons;
- commerce/workshop choices that change future play;
- readable enemy telegraphs, counterplay, repair objectives, and recoverable failure;
- the distinction between simulation state and presentation state;
- stable IDs and data-driven content validation;
- keyboard/controller support, pause, restart, reduced motion, and accessibility cues.

Do not add during this task:
- multiplayer, live service systems, procedural infinite arenas, unexplained meta currencies, mandatory combat complexity, or a broad content expansion;
- a new subsystem when existing data and command paths can express the variation;
- visual effects that hide the relay, threat lanes, target identity, or causal result.

Return exactly: Intent; Plan; Changed files; Verification with exact commands and results; Risks; and exactly one next small task. Do not claim completion without evidence from the running game.

Before editing, identify the highest-priority unfinished player-facing acceptance criterion and write a bounded task packet containing the player objective, authoritative owner, files, preserved contracts, non-goals, deterministic tests, screenshot states, remaining limitation, and one next task.
```

## Prompt 1 — Build the first visual target

```text
Create a single in-game visual target for the first complete Scrap Saint slice: boot/menu → Collapsed Workshop → movement and relay repair → one enemy pressure family → scrap/relic reward → six-offer workshop choice → Blessing fulfilment → results and route choice.

The image must look like a real gameplay frame, not concept art or a debug board. Establish a coherent devotional-industrial language: weathered metal, soot, oxidized copper, warm relay light, bone/ivory sacred marks, restrained ember accents, and a distinct silhouette for the Saint, relay, enemy, hazard, shop offer, and result state.

Specify camera framing, logical arena scale, relay prominence, entry lanes, threat readability, HUD hierarchy, focus states, typography, palette, material treatment, animation budget, sound cues, and which elements are explicitly outside scope. Update ASSETS.md or the repository's equivalent asset contract. Record provenance for every generated or temporary asset.

The visual target must preserve gameplay readability at 1× speed and must show the player question: where is the pressure, what can I repair or protect, and what doctrine will this reward support?
```

## Prompt 2 — Implement one complete vertical slice

```text
Implement the smallest complete Scrap Saint vertical slice and no broader feature set.

Required player path:
1. Start from a truthful menu or boot state.
2. Enter the Collapsed Workshop with build ID, seed, viewport, and objective visible without dominating the scene.
3. Move the Saint through a bounded, readable arena.
4. Identify the relay, three entry pressures, and one authored enemy question.
5. Respond through movement, attack, repair, or positioning.
6. Receive explicit success, damage, or rejection feedback.
7. Earn a meaningful scrap/relic consequence.
8. Make one workshop choice that visibly changes the next state.
9. Reach results and choose a next route or doctrine question.
10. Restart and reproduce the same outcome with the same seed and command stream.

The simulation owns movement limits, collision, damage, repair, rewards, RNG, commands, and state transitions. Presentation owns framing, animation, effects, text, audio cues, and focus. Every rejection must explain the cause. Every failure must leave a visible recovery path.

Add or update deterministic fixtures and capture states for boot, arena entry, relay pressure, repair success or failure, workshop offer, and results. Run the focused tests, content validator, parse/build checks, and evidence capture before reporting.
```

## Prompt 3 — Improve one interaction's feel

```text
Improve exactly one interaction: [repair / attack / relay damage / workshop selection / evolution / boss impact].

Preserve all authoritative outcomes. Tune only input response, anticipation, animation handoff, hit or repair confirmation, semantic sound, screen-space feedback, cooldown clarity, and recovery messaging. The transition sequence must be legible:
[STATE A] → [STATE B] → [STATE C] → [SUCCESS OR FAILURE] → [RECOVERY/NEXT DECISION].

Capture before and after states. Verify that the effect never hides the relay, Saint, enemy telegraph, target, or result. Record the change in MEMORY.md, QA.md, or the repository's current equivalent. Reject any polish change that improves spectacle but weakens causal understanding.
```

## Prompt 4 — Adversarial QA and release gate

```text
Act as an adversarial QA lead for the current Scrap Saint milestone.

Replay deterministic seeds and test rapid input, pause/resume, restart from every major state, invalid commands, repair outside the zone, boundary collisions, simultaneous damage and victory, missing assets, zero and maximum resources, repeated spawning and cleanup, window resizing, controller focus, reduced motion, save/load, demo mode, and return to the menu.

For each defect provide a minimal reproduction, observed result, expected result, owning module, smallest fix, and regression test. Fix blockers before polish. The release gate is not passed unless the first slice is understandable without a wiki, the deterministic replay remains stable, all important actions have visible feedback, the primary objective is readable, no unapproved placeholder dominates the main path, and the final capture shows actual gameplay.
```

## References

[1]: ../AGENTS.md "Scrap Saint repository agent instructions"
[2]: ../roadmap.md "Scrap Saint roadmap and deterministic acceptance gates"
[3]: ./agent_completion_prompt.md "Scrap Saint completion prompt"

## Operating rule

Never ask the agent to “make Scrap Saint more polished” without naming the player-facing interaction, the capture states, and the stopping condition. One complete authored slice is more valuable than a larger set of disconnected weapons, enemies, or effects.
