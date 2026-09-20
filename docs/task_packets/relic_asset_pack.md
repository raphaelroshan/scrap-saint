# Relic asset pack

Objective: deliver reusable illustrated relic art and exact transparent pixel animation strips for existing manifested weapons.

Scope: assets/relic-pack (art, PNG atlases, SpriteFrames resources, manifest and preview), tools/relic_asset_canvas.gd and bake_relic_assets.gd, tests/test_relic_assets.gd, docs/asset_provenance.md and this packet. No gameplay renderer or Saint replacement. Native animation export reuses existing authored geometry; generated UI art remains separate.

Acceptance: alpha verified, fixed 128x128 cells and stable origins, 12 frames per animation, normal/reduced variants, valid SpriteFrames resources, no clipped nontransparent pixels at cell edges, actual rendered preview. Export durations from existing presentation constants. No hit resolution is driven by sprite frames.

Evidence: asset manifest with source hashes, Godot version, pixel dimensions, clip duration and origins; rendered contact sheet and browser animation gallery. These are isolated asset previews, not gameplay captures. Content validation and asset-specific tests; no runtime change requiring full gameplay loop.

Limitation: baked right-facing sprite animation does not replace directional/procedural targeting; painted illustration and low-resolution mechanism art are different asset tiers.

Exactly one next task: integrate and compare the Nailer art/sprite options in one actual shop and combat view before replacing procedural rendering.

Verification: ten animation resources load with 120 correct atlas regions and matching authored durations. All 120 cells have transparent borders; first/last frames are empty and intermediate frames populated. Contact sheet inspected. Both illustration files have RGBA alpha. No runtime gameplay code changed.
