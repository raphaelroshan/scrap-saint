# Arena material pass

Objective: make the playfield feel like a worn industrial workshop while keeping movement, pickups and danger readable.

Authority: presentation in game/main.gd and game/arena_art.gd; simulation geometry, outcomes and command ownership unchanged.

Files: assets/environment/**; assets/supporting-art/README.md; game/arena_art.gd; game/main.gd; tests/test_arena_art.gd; tests/capture_arena_art.gd; docs/task_packets/arena_material_pass.md; docs/art_direction.md; docs/asset_provenance.md; docs/runtime_status.md; roadmap.md.

Plan: a matte painted floor material, three overhead machinery cutouts, subdued service lanes and obstacle-footprint trim; integrate existing painted Scrap and Repair Kit field icons plus Scrap/Relic Shard HUD icons. Keep floor texture low contrast, shapes world anchored, machinery inside collision rectangles, one light direction and consistent material scale. Palette variants support existing destinations. No new fake collision, glowing decorative rewards or decorative warning circles.

Non-goals: balance, collision/navigation changes, Saint replacement, enemy replacement, weapon rigging, new arena content. The decorative floor cannot define hazards or conceal gaps.

Acceptance: visual assets load, obstacle display bounds remain inside physical footprints, rendering leaves simulation hash unchanged; full autonomous loop and content validation pass. Capture Workshop centre, edge, active combat, reduced effects and destination at 1280x800 with seed147 and source hashes. Compare matched before/after states.

Remaining limitation: enemy silhouettes and some objective machines still use the existing procedural renderer.

Next task: integrate the painted enemy roster with directional poses and combat-scale readability checks.


Visual iteration: the first rendered pass exposed oversized floor plates and miniature machine banks on wide obstacles. The final pass uses fixed material tiles and a dedicated horizontal manifold. Five matched fixture states preserve exactly the same simulation hashes before and after. All 61 focused checks pass across six arena layouts. The comparison HTML and source/build provenance are in assets/environment/evidence and review.html. The earlier capture has the diagnostic build footer enabled by its capture-directory flag; the after capture shows normal-play presentation. Neither is a natural human run.

Validation complete: full scripts/agent_iteration.ps1 finished with exit 0, including 34 Python manifest tests, content validation, Godot regression suites, automated policy runs and native captures. The scored render-evidence validator passes. Baseline ObjectDB leak warnings remain in some UI fixtures. Focused asset checks: 61/61. No human playtest or minimum-spec rendering benchmark is claimed.
