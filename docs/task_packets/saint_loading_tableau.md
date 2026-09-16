# Task packet: P17.2 — Saint loading tableau

## Player-facing objective

Turn the title-to-game transition into a concise statement of Scrap Saint's identity: a six-armed bronze maintenance saint meditates beneath a Bodhi tree, then wakes as white clouds part to reveal an industrial city in crisis.

## Authority and command boundary

This is an art-direction task only. Presentation will eventually own layered art, animation, audio, reduced-motion behaviour, loading progress, and scene transition. The deterministic simulation continues to own starting frame, Blessing, seed, run creation, and accepted commands. The animation may conceal loading but cannot start or advance the run early.

## Files

- `docs/task_packets/saint_loading_tableau.md`
- `docs/saint_loading_tableau.md`
- `docs/art_direction.md`
- `README.md`

## Preserved contracts and non-goals

- Preserve the small, asymmetrical maintenance-machine identity and warm industrial-devotional palette.
- Show exactly six arms: four visibly holding different repair tools and two resting in the lap in a meditation pose.
- Treat the Bodhi-tree imagery sincerely and avoid generic fantasy deity, warrior, or military-mech styling.
- Keep the city readable as industrial crisis without gore or indiscriminate spectacle.
- Do not replace the current title screen, add runtime loading logic, generate a final production asset, or claim an art capture in this task.

## Acceptance checks

1. The still composition, arm/tool arrangement, tree, clouds, city layers, palette, and safe areas are explicit.
2. The Play transition has timed eyes-open, tool-response, cloud-parting, city-reveal, and scene-handoff beats.
3. Fast load, slow load, repeated play, reduced motion, photosensitivity, ultrawide crop, and low-resolution behaviour are covered.
4. The layered asset list supports animation without relying on a single flattened image.
5. A production-ready concept-art prompt exists with no text, watermark, weapons, extra arms, or anatomy ambiguity.
6. Current runtime status and generated-art limitations are stated honestly.

## Screenshot states and provenance

A future implementation must capture the closed-eye title tableau, eyes-open commitment frame, cloud-parting midpoint, and revealed-city handoff at 1280×800 and 1920×1080. Captures must name the exact build commit and be labelled `TITLE TRANSITION FIXTURE`. No screenshot is claimed by this design-only task.

## Remaining limitation

No bitmap concept or layered production asset was generated because the built-in image-generation tool was unavailable. Motion, silhouette readability, loading synchronization, and cultural tone remain untested in the running game.

## Exactly one next task

Generate and review two matching concept keyframes—closed-eye meditation and eyes-open city reveal—before selecting a layered production approach.
