# Supporting menu completion

Objective: give players a readable field manual, grouped working settings and a pause screen that explains the current expedition.

Owner: presentation in game/main.gd and game/menu_panels.gd; authored guidance in content/ui/field_manual.json. Settings service owns local preferences. Pause/resume and saves retain existing simulation commands and SaveStore boundaries.

Files: game/main.gd; game/menu_panels.gd; content/ui/field_manual.json; tests/test_menu_panels.gd; tests/capture_menu_panels.gd; docs/evidence/menu-panels/**; docs/runtime_status.md; roadmap.md; this packet.

Preserve the illustrated title, setup, shop, route map, Saint and weapons. Reuse existing artwork. No new simulation rules, unlocks, boss assets or balance changes. Expose the existing master-volume setting and add manual access from pause. Leaving the manual must return to the paused run without starting setup.

Acceptance: every manual page supports navigation at normal/large text; settings controls fit and volume persists through the settings service; Escape/controller Back cancel rebinding without leaving stale input capture; reading and settings never advance or mutate run state; pause resume uses the existing command. Capture five manual pages, settings/binding, pause at 1280x800 and large text, plus 1920x1080. Run focused checks and the full autonomous loop, inspect captures and score ten visual criteria with build/seed/hash provenance.

Verification: 81 focused supporting-menu checks and 32 title-flow checks pass. Full autonomous loop exits 0 with 1087 checks across 26 suites reporting zero failures, followed by automated playthroughs and captures. Scored evidence validation passes. Some existing fixtures still report ObjectDB shutdown leaks. Inspected all five large-text manual pages, normal/large Settings and Pause, binding prompt and 1920x1080 layout. All 17 supporting-menu captures retain the same paused simulation hash.

Limitation: keyboard/controller event tests and rendered fixtures do not certify physical controller usability or human comprehension.

Next task: give the Memory Crane and Foreman Engine painted bodies and state-driven mechanical animation.
