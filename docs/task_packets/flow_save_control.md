# Flow save control — 2026-09-25

Delivery status: implemented and verified; [final evidence](../evidence/repair-readability/review.md). Human acceptance remains open.

## Player objective

At the route map and in a two-Gift shop, the player can read and activate every primary choice, both Gift names and actions, and the Save & Title control without overlap.

## Owner and command boundary

`game/main.gd` owns the position of the global Save & Title presentation control and shop-only Gift labels/actions. The existing `save_and_return_to_title` and Gift callbacks and authoritative save/commerce paths stay unchanged. The simulation owns no part of this layout adjustment.

Expected files: `game/main.gd`, `tests/test_flow_input.gd`, and this packet. Preserve screen phases, button labels, focus, callbacks, save behavior, stable IDs and deterministic outcomes. No layout redesign, new panel, economy changes or repair-feedback changes.

## Acceptance

- Route map: Save & Title and Travel controls have nonintersecting rectangles and remain activatable.
- Two-Gift shop: Save & Title has no rectangle overlap with either Gift sell/dismantle row and remains activatable.
- Both shop Gift names fit visibly above their own action row and clear the other Gift row at normal and large text scale. The redundant shop-only GIFTS heading does not sit behind Equip reserve. Combat Gift presentation remains unchanged.
- Existing focused flow and save restoration tests pass with isolated `APPDATA`; parent will inspect fresh packaged captures to confirm the final pixels.

No new art is used. Screenshot states are route confirmation and two-Gift shop in the current 0.6.0-preview build at 1280×800, plus the parent's packaged flow. The focused test proves control geometry; it does not prove human reading or a full natural run.

Exactly one next small task: inspect the packaged route and two-Gift shop captures after these layout adjustments.
