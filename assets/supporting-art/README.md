# Supporting painted assets

Nine original generated cutouts for the painted industrial diorama direction. Enemy shells use rust and dark iron; useful objects use cream ceramic, green enamel and worn brass. Files preserve the generator's original alpha and resolution. No procedural pixel exports are presented as painted art.

Open `preview.html` for an animated review gallery. Open individual `scenes/*.tscn` in Godot to reuse their Sprite2D and AnimationPlayer. Run `godot --path . --script res://tools/preview_supporting_assets.gd` for the native gallery; hold Space for the static reduced-motion view. Append `-- --capture` for three fixed-time captures at 1440x1000.

## Delivered set

| Category | Asset | Motion study |
|---|---|---|
| Enemy | Scrap Mite | Short alternating body scuttle |
| Enemy | Rivet Hound | Compress, lunge, settle |
| Enemy | Choir Drone | Slow suspension hover |
| Field currency | Scrap | Restrained bob and collect |
| Field currency | Relic Shard | Restrained bob and collect |
| Field healing | Repair Kit | Restrained bob and collect |
| Catalyst | Saint's Rivet | Short reveal and settle |
| Gift | Spare Hand | Short reveal and settle |
| Gift | Inspection Lens | Short reveal and settle |

Each scene also includes `RESET` and a 240ms `collect` clip. Scenes do not autoplay: the caller plays clips in response to presentation events. Charge, reveal and collect are nonlooping; the gallery repeats them for inspection. The preview's small samples have 48px visible extent. The web gallery shows the entire original canvas at 48px, a stricter padding/readability check.

## Integration boundary

These are reusable art and whole-sprite motion studies, not articulated enemy walk cycles. Transforming a flattened image cannot move its legs independently. The animation scenes are not wired into gameplay yet. The arena material pass now uses the Scrap and Repair Kit textures for field pickups and Scrap/Relic Shard textures in the currency HUD; the Mite, Hound and Drone textures now render in combat through `game/actor_art.gd`, while upgrade images remain staged. Scene roots are visual centres, with a normalized 160px visible extent; gameplay must scale them to its own display size and position them relative to the simulation-owned footprint. The charge study moves only its visual child and must never supply collision or damage timing. Reduced effects should hold RESET or use a static sprite; collect animations must never delay simulation collection.

The three pickup IDs in this pack are presentation labels, not new simulation content IDs. Scrap and Relic Shards remain the existing currencies; Repair Kit is field healing, never a shop slot. Preserve the existing Saint and manifested relic renderer.

## Remaining coverage plan

Rust Pilgrim, Forklift Brute and Cinder Spitter are now delivered and integrated in [the actor pack](../actors/README.md). Memory Crane remains pending. Subsequently cover the remaining seven catalysts and five Gifts using their existing content IDs. Bosses, statuses, projectiles, route emblems and alternate poses need separate scoped passes. Do not mark the whole art catalogue complete from this first pack.

Source IDs, descriptions, sizes, alpha bounds and SHA-256 hashes live in `manifest.json` and `source-manifest.json`. `tools/build_supporting_assets.py` reproduces scenes, manifest and web gallery from the untouched PNGs. Pillow is used only to inspect bounds and alpha. Native previews are render evidence, not gameplay screenshots or human playtesting.
