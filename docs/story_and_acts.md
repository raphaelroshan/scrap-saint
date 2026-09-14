# Scrap Saint — Story and acts

## Narrative spine

The Saint is a maintenance automaton built from parts that were never meant to share one body. It wakes beneath a collapsed workshop with a damaged instruction: **RESTORE THE FIRST ENGINE**.

At first, the Saint interprets the instruction literally. It repairs relay towers, water pumps, workshops, and machine shrines. Each repair restores a fragment of memory. The fragments reveal that the First Engine coordinated an industrial society that was efficient, productive, and deeply exploitative. The Saint was assembled during the final collapse from whatever parts were available, which is why its memories and doctrines conflict.

The story’s central question is not whether the First Engine can be restarted. It is whether restoring the old order is morally and practically desirable.

## Main characters

### Saint

A small maintenance machine with a formal voice, a damaged memory lens, and an instinct to repair before it understands. The player chooses whether its identity follows Workshop, Bell, Procession, Quiet, Salvage, or Mourner doctrines.

### Ada-9, the relay keeper

A practical settlement engineer who wants the old infrastructure restored but does not trust the First Engine. Ada-9 teaches objective repairs and represents useful continuity.

### Brother Coil

A former factory signal machine that believes the old hierarchy can be purified. Brother Coil offers powerful Witness and Bell technologies, but gradually reveals a preference for obedience over freedom.

### Morrow

A funeral automaton that maintains memory gardens and carries messages for machines that can no longer speak. Morrow introduces Mourner Blessings, spirit effects, and the idea that not every broken machine should be restarted.

### Red-13

A furnace-frame relic bearer who believes power is the only language the ruins respect. Red-13 offers Red Litany weapons, dangerous catalysts, and high-risk boss routes.

### The Archivist Prime

A memory system that records every machine and assumes that anything undocumented is an error. It copies the Saint’s strongest evolution and serves as the main rival in Act III.

### The First Engine

The central machine authority, not a simple villain. It can provide order, production, and safety, but only through central control. Its final fight changes based on the doctrines and repairs the player has chosen.

## Act I — The First Shift

The Saint begins with a single damaged workshop and one operational repair arm. The first arena teaches movement, automatic attack, objective protection, shop decisions, Scrap, and one visible evolution.

### Objectives

- Repair the workshop relay.
- Protect the water pump.
- Recover the Saint’s first memory fragment.

### Enemies

Rivet Hounds, Scrap Mites, and Choir Drones.

### Boss

**The Foreman Engine** schedules demolition zones and calls worker drones. It tests whether the player can move, repair, and fight simultaneously.

### Narrative outcome

The player learns that the Saint’s instruction was issued by the First Engine, but not why the machine stopped.

## Act II — Contested Districts

The Saint enters districts claimed by rival machine doctrines. Each district offers a Blessing and a cost. The player can remain neutral, accept faction aid, or create a hybrid doctrine.

### Districts

| District | Identity | Mechanical pressure |
|---|---|---|
| **Brass Choir** | Bells, signals, and public order. | Timing, silence fields, and forecast manipulation. |
| **Red Foundry** | Furnaces, armour, and production. | Heat, hazard zones, and high burst. |
| **Pale Archive** | Memory, duplication, and records. | Copies, hidden information, and status removal. |
| **Rootworks** | Repair growth, cables, and grafts. | Entanglement, healing, and shifting terrain. |
| **Null Assembly** | Anti-relic machines and erasure. | Blessing suppression and evolution denial. |

### Objectives

- Decide which district receives a repaired relay.
- Escort a machine census crawler.
- Hold a shrine while a faction performs a ritual.
- Steal or protect a blueprint.
- Destroy a Null Assembly erasure engine.

### Bosses

- **The Choir Regent:** changes attack timing through resonance waves.
- **The Red Cardinal:** overheats the arena and weaponises destroyed machinery.
- **The Archivist Prime:** copies the player’s strongest evolution.

### Narrative outcome

The Saint discovers records showing that it was assembled during the collapse from parts selected by several factions. Its “wrongness” may have been intentional: a neutral machine was needed to carry knowledge across faction boundaries.

## Act III — The Memory Works

The Saint travels into the archive and manufacturing zones where its components were made. Memories become playable fragments or short visual scenes after objectives.

### Gameplay change

Memory arenas introduce one temporary rule from the Saint’s past. A worker memory increases repair output. A combat memory changes enemy waves. A funeral memory makes defeated enemies leave Mourned remnants. The player chooses whether to preserve or reject the memory after the arena.

### Objectives

- Recover the assembly record.
- Defeat a copied version of the Saint.
- Choose which memory to preserve.
- Repair a memory lens without deleting an old identity.

### Boss

**The Saint of No Repairs** disables healing and turns restored objects into hostile copies. The fight asks whether the player can survive without relying on the Workshop doctrine.

### Narrative outcome

The Saint learns that the First Engine deliberately mixed its components because a machine with one fixed purpose could be controlled. The Saint was built wrong so it could choose.

## Act IV — The First Engine

The Saint reaches the central machine. The final act is a sequence of escalating arenas, shop decisions, faction consequences, and one final boss.

### Final routes

| Route | Requirement | Final question |
|---|---|---|
| **Restore** | Preserve infrastructure and accept central protocols. | Can order save the world if it removes choice? |
| **Repurpose** | Build hybrid systems and support settlements. | Can a central engine serve local needs? |
| **Dismantle** | Support independent factions and reject old authority. | Can a broken world survive without a single coordinator? |

### Final boss

**The First Engine** changes its weaknesses after each major evolution. It uses the player’s chosen doctrines as attack patterns: Bell resonance, Red Foundry hazards, Archive copies, Rootworks tethers, and Null Assembly suppression.

The final fight should be a readable sequence of phases, not a long health sponge. Each phase should test a different type of decision: movement, objective protection, shop preparation, evolution timing, and doctrine flexibility.

## Ending variants

### Restore the First Engine

The Saint reactivates the central machine. Roads open, water flows, and production returns. The final image is orderly and efficient, but the Saint remains connected to the command network. This is a bittersweet ending, not a simple victory.

### Repurpose the First Engine

The Saint rewrites the engine’s authority into a distributed network. Settlements share resources, but no one receives perfect forecasts or complete control. The world becomes harder and more locally governed.

### Dismantle the First Engine

The Saint breaks the central machine into relics and distributes them. The old system ends. There is uncertainty, conflict, and freedom. The Saint becomes a travelling repairer rather than a ruler.

## Optional side stories

Side stories should be short, state-aware events, not large dialogue trees.

| Story | Choice | Mechanical consequence |
|---|---|---|
| **The Bell That Refuses to Ring** | Repair it, retune it, or leave it silent. | Unlock Bell, Quiet, or Mourner catalyst. |
| **The Worker Without a Shift** | Give it a task, memory, or rest. | Recruit, passive, or event unlock. |
| **The Broken Rival** | Repair Red-13, fight it, or trade parts. | Red blessing, boss modifier, or future ally. |
| **A Manual in Three Pieces** | Preserve the manual, burn it, or distribute it. | Shop discount, fire relic, or faction reputation. |
| **The Machine That Wants to Stop** | Restart it, protect its rest, or dismantle it. | Resource reward, Mourner memory, or route change. |

## Narrative implementation limits

The first vertical slice needs only one named character, one memory fragment, one short post-boss scene, and one side event. Do not build a branching dialogue system. Use data-driven event definitions with stable IDs, conditions, choices, consequences, and a short presentation payload.

The plot should be delivered through objective names, shop flavour, brief encounter text, memory snapshots, boss introductions, and Results summaries. Combat must remain the primary activity; narrative should reward attention without interrupting the run.
