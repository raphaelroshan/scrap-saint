# P12.1a — measured roaming and repair decisions

- Objective: identify a useful optional repair route and explain the current Mourner loss before changing difficulty.
- Owner: simulation owns outcomes; the diagnostic runner reads events/state and sends ordinary movement and shop commands. No supplied budgets, enemies, health or ranks in natural runs.
- Files: game/simulation.gd (event detail only), tests/run_roaming_audit.gd, docs/packet_p12_1.md, docs/runtime_status.md; generated evidence in artifacts/roaming-audit.
- Preserve: eight enabled weapons, sacred origin, optional repairs, six relic offers, four active slots plus reserve, fixed 60 Hz, shared enemies and optional evolution.
- Non-goals: new weapons, encounter tuning, Gifts, campaign, automatic failure classifier without evidence.
- Acceptance: three seeds (147, 104729, 104730), all three Blessings, baseline and repair-seeking policies; sampled density within 240 pixels, longest no-nearby-enemy gap, travel distance, repairs, purchases, major-target damage/healing and final HP. Repeat failing baseline to verify determinism. Existing regressions must remain valid.
- Evidence: build 0.1.0, Godot 4.5.1, base 6168b5e on dirty main. Headless accelerated execution of unchanged 1× simulation ticks, not wall-clock feel evidence. A subsequent repair packet will capture natural states at 1280×800 with exact tick/hash and source provenance.
- Limitation: automated policies measure execution and opportunity, not human preference; density radius is a diagnostic definition, not a universal threat model.
- Exactly one next task: implement the smallest repair improvement supported by these measurements.

# P12.1b — useful repair work

- Objective: see an optional machine's reward and remaining work before taking its route, preserve work when hit, and leave recovery ready until useful.
- Evidence selecting this packet: seed 147 Workshop repair policy earns +8 Scrap at tick 295 and wins unevolved; baseline policies never seek machines. Code currently consumes full-health healing and empty stagger rewards and progresses before incoming damage resolves.
- Owner: simulation provides read-only repair status, remaining work and local enemy count, then advances work after combat damage. UI reads these values; no new command or mandatory objective.
- Files: game/simulation.gd, game/main.gd, tests/test_repair_quality.gd, tests/capture_repair_quality.gd, tests/run_roaming_audit.gd, scripts/agent_iteration.ps1, docs/packet_p12_1.md, docs/runtime_status.md.
- Preserve: machine positions, rewards, rates, pause/shop/save semantics, currencies, automatic weapons, shared encounter schedule, all eight weapons.
- Non-goals: spawn or boss balance changes, wider shop redesign, new reward types or inputs.
- Acceptance: full-health pump and empty-field bell defer; useful rewards complete once; incoming damage pauses work for existing recovery interval; leaving preserves progress; save/replay and pause preserve work; compare the same 18 natural cases after change.
- Screenshots: natural seed 147 Workshop repair route at ticks 60, 240, 360, plus clearly labelled full-health/hurt/bell fixtures; Godot 4.5.1 build 0.1.0 at 1280×800 normal/large text. Record source hashes and inspect actual renders.
- Limitation: a three-second work ring remains a positioning commitment; observed automated reward value does not establish human preference.
- Exactly one next task: use the completed traces to resolve the strongest remaining P12.1 pressure or Mourner targeting issue.
