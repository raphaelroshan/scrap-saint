# Repair and end-to-end delivery review

Status: implemented and runtime verified; human acceptance remains open. [Validation](validation.json), [source/capture hashes](provenance.json), [visual rubric](visual_review.json), [exact commands](commands.md).

The initial audit found clipped repair text. Independent review caught a warning-ring/title collision in the first correction; final placement selects bounded candidates while penalizing overlap with live warning footprints and the Saint. It does not alter authoritative state. Read-only layout checks, real repair-state transitions and native captures verify the interaction.

The exported run revealed Save & Title covering travel confirmation and Gift actions. The follow-up packet moves it to the footer and separates both Gift names from their controls. [Final route](EXPORTED_ROUTE.png) and [two-Gift shop](EXPORTED_TWO_GIFT_SHOP.png) show the corrected controls.

| State | Evidence |
| --- | --- |
| Approach / active / departure | [Idle](REPAIR_IDLE.png), [active](REPAIR_ACTIVE.png), [retained progress](REPAIR_DEPARTED_LARGE.png) |
| Healing deferral / reward | [Deferred](PUMP_DEFERRED.png), [restored](PUMP_RESTORED.png) |
| Boss pressure | [Large text](BELL_FOREMAN_LARGE.png), [reduced effects](BELL_FOREMAN_REDUCED.png), [larger window](BELL_FOREMAN_LARGER_WINDOW.png) |
| Exported main flow | [Title](EXPORTED_TITLE.png), [shop](EXPORTED_SHOP.png), [route](EXPORTED_ROUTE.png), [road](EXPORTED_TRAVEL.png), [arrival](EXPORTED_ARRIVAL.png) |
| Exported completion | [Results](NATURAL_RESULTS.png), [restart and earned unlocks](EXPORTED_RESTART.png) |

All 33 Godot suites passed (2009 counted assertions across 31 suites plus two asset validators), and 34 Python tests passed. Policy results: 12/12 normal-economy, 4/4 assembly, 10/10 Evolution, 4/4 Gift and 4/4 route-pacing runs won. Route-pacing fixtures start with configured Rank III builds and decline repairs; they are not fresh-player economy runs. The final exported policy independently wins through Brass and Pale Archive with normal economy, 12 shops and actual Results-button restart.

The full iteration includes legacy relay comparison fixtures. They do not define the default game; the final exported screenshots use optional repairs and six relic offers. The first loop spanned a presentation correction; final focused tests and captures supersede its repair-layout frames. All simulation/data files remain unchanged.

Still-image review score: 42/50. Not a release certification. The layout falls back to the least-overlapping candidate when every location is crowded; this is not a guarantee against every possible effect overlap. Existing fixture ObjectDB exit warnings and occasional Windows certificate-store warnings remain. Ordinary packaged boot and final natural-run logs have no script/resource errors. Human testing, physical controller, final audio and minimum-hardware rendering remain unverified.

Exactly one next small task: run the [uncoached Workshop acceptance session](../../playtests/workshop_acceptance.md).
