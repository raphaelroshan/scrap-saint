# The warning wire answers

Objective: let a player recognize that their Brass road decision has a consequence for other machines, through Ada's reply and a later road report.

Owner: deterministic read-only road presentation selection in game/simulation.gd, driven by existing saved road_flags and stable node IDs. Authored text lives in content/lore/road_echoes.json. No new commands, rewards, morality score, save fields or combat conditions.

Files: content/lore/road_echoes.json; content/chapter/first_chapter.json; game/simulation.gd; game/main.gd; tests/test_road_echoes.gd; tests/capture_road_echoes.gd; scripts/agent_iteration.ps1; scripts/agent_iteration.sh; docs/evidence/road-echoes/**; docs/narrative_implementation_map.md; docs/runtime_status.md; roadmap.md; this packet.

Preserve road costs, free choices, damage, arrival recovery, route connectivity, enemy warnings, optional repairs and all current outcomes. Replace only the current node's news with a matching authored echo; retain the visible risk, choice terms and original content dictionary. Legacy saves without either flag use original news. Reading never marks a beat consumed or changes RNG/state.

Acceptance: splice and cross through real commands select distinct Ada and later Archive/Foundry responses; flags and text survive snapshot/restore; Rootworks-to-Foundry never inherits Brass text; no-flag saves use default news; repeat reads do not alter hash or content; costs and accessible options remain identical. Capture both choices, both later roads and large text at 1280x800, seed147; run focused tests and full autonomous loop with scored native evidence.

Verification: 86 focused story checks pass. The full Windows autonomous loop exits 0 with 1087 checks across 26 suites reporting zero failures, followed by policy playthroughs and native captures. The new story suite was run separately and added to both scripts for subsequent runs. Scored evidence validation passes. Inspected all six large-text branches and a normal-text comparison from the 12 native fixtures; normal/large state hashes match. Existing ObjectDB shutdown leak warnings remain in some fixtures.

Limitation: these are authored textual consequences, not a simulated settlement or new encounter. Human recognition of the causal link remains unverified.

Next task: observe an uncoached human 1x Workshop-to-Brass session, including whether they connect the later report to the wire choice.
