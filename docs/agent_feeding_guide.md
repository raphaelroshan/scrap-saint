# Scrap Saint — Astra feeding guide

## Minimal context to provide Astra

Start with the repository URL and this sequence:

1. Read `README.md`.
2. Read `docs/astra_game_bible.md`.
3. Read `AGENTS.md`.
4. Read `docs/story_and_acts.md` and the smallest relevant design contract.
5. Inspect the owning content and test files.
6. State one player-facing objective and one non-goal.
7. Implement the smallest deterministic vertical slice.
8. Run content and focused simulation checks.
9. Capture the real running state with provenance.
10. Critique the capture, record one limitation, and name exactly one next task.

Do not paste the entire repository into a prompt. The bible and task packet establish the durable context; source files establish the local implementation truth.

## Standard task packet

```markdown
# Scrap Saint task packet

## Objective
One player-facing improvement.

## Preserve
Authoritative simulation, stable IDs, save/replay contract, controller/scaling support, Blessing/shop language, and visual direction.

## Change
Exact files and command boundary.

## Acceptance
Deterministic tests and visible player-facing proof.

## Non-goals
Adjacent improvements explicitly deferred.

## Evidence
Build, commit, Godot version, viewport, seed, state name, capture path.

## Limitation
What remains unproven.

## Next task
Exactly one follow-up.
```

## Design vocabulary

Use **Blessing** for a run-level doctrine. Use **Gift** for an individual shop item or relic. Use **catalyst** for an evolution ingredient. Use **memory** for a story fragment that can affect identity or progression. Use **repair objective** for a player-facing arena task.

## Quality standard

The target is not “a functional arena with items.” It is a readable industrial devotional machine game in which the shop, Blessing, weapon geometry, enemy question, objective, and story beat reinforce one another. A task that adds content without improving a player decision should be reconsidered.
