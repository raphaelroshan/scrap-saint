# Supporting painted asset pack

Objective: make enemies, currency, healing and upgrades recognizable as repaired industrial objects in the agreed painted diorama style.

Owner: presentation-only asset pack and isolated preview; no simulation commands or gameplay mutations.

Files: assets/supporting-art/**; tools/build_supporting_assets.py; tools/preview_supporting_assets.gd; tests/test_supporting_assets.gd; docs/task_packets/supporting_painted_assets.md; docs/asset_provenance.md; roadmap.md.

Plan: generate Scrap Mite (round scavenger), Rivet Hound (low charging wedge), Choir Drone (hovering speaker); Scrap (salvage metal), Relic Shard (broken ceramic/brass), field Repair Kit; Saint's Rivet, Spare Hand and Inspection Lens. Rust/iron enemies contrast with cream, enamel and brass useful objects. Single transparent cutouts, broad shading, high three-quarter view and upper-left lighting.

Animation: reusable Godot scenes with AnimationPlayer clips for whole-sprite scuttle, charge, hover, pickup bob/collect and upgrade reveal. These are motion studies, not articulated walk cycles. Reduced-motion preview is static. Preserve Saint and manifested weapon direction.

Non-goals: new enemies, currencies, balance, gameplay sprite replacement, new weapon attachments, full skeletal animation.

Acceptance: every manifest path resolves; transparent PNGs have visible alpha content; scene resources load; all animation tracks resolve and sampling changes intended visual properties; content validation passes. Review gallery at 1440x1000 with neutral dark background and small-size samples. Evidence is an isolated art preview, not gameplay or human playtesting.

Remaining limitation: directional poses and articulated limbs need a subsequent production pass.

Next task: integrate the approved pickup and enemy art into event-driven gameplay presentation with real combat-scale readability checks.

Verification: nine RGBA originals packaged unchanged; nine Godot scenes pass load, track-target, motion, collection opacity and reset checks. Native gallery captured at 1440x1000 at .12/.36/.72 seconds and reviewed. Full PowerShell autonomous loop completed with exit 0, including content validation, 34 Python manifest tests, Godot regression suites, policy runs and rendered fixtures. Existing ObjectDB leak warnings remain in some baseline UI fixtures. Review scores and source/build hashes are in the pack evidence directory. Art integration and human gameplay review are not claimed.
