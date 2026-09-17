# Main menu: the Saint beneath the Bodhi tree

Player objective: arrive at a calm, illustrated front door and immediately find Continue, New Pilgrimage, Settings, How to Play, Histories and Quit.

Authority: presentation owns artwork, menu focus, navigation and transition; existing simulation, save validation, frame and Blessing commands remain authoritative.

Files: game/main.gd; assets/title/meditation.png and awakening.png plus provenance; tests/test_main_menu.gd and capture_main_menu.gd; scripts/agent_iteration.ps1 and .sh; docs/saint_loading_tableau.md, art_direction.md, runtime_status.md, asset_provenance.md; this packet; docs/evidence/main-menu/.

Preserve: upstream 922b521 game-feel changes, all gameplay, saved-run validation, keyboard/controller focus, normal/large text, reduced effects and existing procedural tableau fallback. No new modes, progression systems or balance changes. Existing setup holds frame/Blessing/seed options.

Acceptance: title never advances simulation; new-run transition enters setup; Continue uses existing save validation and respects unavailable saves; settings and histories return to title; quit confirmation cannot accidentally exit; all six actions fit normal/large text. Existing flow and presentation tests remain passing.

Evidence: configured title, saved-run title, settings, quit and awakening screenshots at 1280x800 and 1920x1080, seed147; source hashes and scored visual review. Run the repository autonomous loop.

Art approach: generate two matched painterly menu keyframes using the approved six-arm/four-tool Bodhi composition; crossfade during the short wake transition. These are flattened preview illustrations, not independently rigged production layers. Keep procedural fallback. Inspect anatomy before integrating.

Limitation: no uncoached menu test; painted keyframes cannot provide independent tool articulation.

Exactly one next task: validate the Workshop opening at normal speed with uncoached players.

## Implementation notes

The two generated illustrations preserve a six-arm silhouette and four distinct repair tools. The lower hands meet in the lap; they are not clearly palm-up, and the city is more ornate than the utilitarian factory brief. These are recorded preview limitations. No independent limb rig or camera match-cut is claimed.

The main menu uses the existing Settings panel and saved-run validation. Continue restores a saved shop without rerolling it; an invalid serialized save leaves the current state intact. Quit focuses Stay first. Escape/controller Back return from panels and setup. A Settings caption that overlapped Camera motion was moved below the binding controls.

Initial review captures were superseded after fixing a striped scrim, the Settings caption overlap, and capture output that omitted the 16:9 window's letterbox margins. Those intermediate files were overwritten during recapture; this record preserves their invalid status. Final evidence records actual PNG dimensions. No screenshots are claimed as human testing.

Supporting files: tests/test_ui.gd and test_flow_input.gd follow the renamed New pilgrimage action; test_presentation_quality.gd explicitly selects full motion when asserting 1.35-second timing.

## Verification and delivery

The full PowerShell autonomous loop exited 0: content validation, 31 manifest tests, deterministic suites and 30 successful chapter scenarios (12 general, four assembly, ten Evolution and four Gift). The final menu suite passed 30 checks. Eleven configured menu captures cover normal/large title, settings, quit and awakening at both window sizes, plus a saved-run title. Selected actual renders and hashes are committed under docs/evidence/main-menu. The scored evidence validator passed. The existing core-quality capture still reports an ObjectDB shutdown-leak warning; no new cleanup or audio-quality claim is made.

Inspected final title, awakening and Settings captures show the corrected scrim, preserved six-arm outline and unobscured labels. The generated illustrations and their import metadata are included in the repository, not referenced from an external cache. README.md documents the new front door.
