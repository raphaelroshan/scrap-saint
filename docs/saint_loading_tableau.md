# The Saint Beneath the Bodhi Tree

**Status:** `WIP / ART DIRECTION ONLY`

This is the intended title/loading tableau, not a shipped screen or generated gameplay capture.

## Core image

A small six-armed bronze machine saint meditates beneath an immense Bodhi tree. Four upper and middle arms hold humble repair tools; the lowest pair rests quietly in its lap. Soft white clouds conceal the horizon and most of the world. The Saint's eyes are closed.

When the player chooses **Play**, two lamp-like eyes open. The tools answer with small mechanical movements, the clouds divide, and the hidden horizon resolves into an industrial city in chaos. The calm was real, but it was never an escape from responsibility.

The image should communicate Scrap Saint before any tutorial text:

- many incompatible purposes held in one body;
- repair rather than conquest;
- devotional sincerity expressed through machinery;
- a moment of stillness before choosing to help;
- beauty and danger occupying the same world.

## Composition

Design the master at 16:9 while preserving a central 16:10 safe crop.

| Layer | Composition |
|---|---|
| Sky | Desaturated blue-grey dawn with a warm cream break behind the tree; no star field or fantasy rays. |
| City | Low on the horizon and initially hidden: factory roofs, water towers, cranes, relay spires, broken transit lines, warning lamps, controlled smoke, and electrical faults. No modern skyscraper skyline. |
| Bodhi tree | Trunk centred behind the Saint, canopy forming a natural halo. Roots grip old masonry and dead machinery without becoming cables themselves. Heart-shaped leaves catch sparse brass light. |
| Clouds | Three separable banks: left foreground, right foreground, and a thin central veil. They are soft white with soot-grey undersides and cover the city before Play. |
| Saint | Centred slightly below mid-frame, seated on a worn circular machine plinth. Bronze body, asymmetrical repairs, visible bolts, green enamel patches, cloth ties, solder seams, and one compact central torso. |
| Interface safe area | Title above the lower cloud line; primary actions below or to one side of the Saint. No button may cover the face, hands, or four tools. |

The Saint should feel small beneath the tree, not gigantic above the city. The city reveal therefore reads as a place it must enter, not a world it rules.

## Six-arm silhouette

The six shoulders must be visibly connected to one compact mechanical torso. Avoid overlapping hands or tools so the arm count reads immediately.

| Arm pair | Rest pose | Tool and meaning | Play response |
|---|---|---|---|
| Upper left | Raised outward, elbow gently bent | Long brass **inspection lamp** with a glass lens: witness and diagnosis | Lens iris opens and casts one thin cyan sweep toward the city |
| Upper right | Raised outward in counterbalance | Heavy **open-ended spanner**: practical repair and force | Spanner turns a quarter rotation with one restrained ratchet click |
| Middle left | Held beside the torso | Compact **welding torch** with cream ceramic grip: restoration | Pilot light catches and releases three cream sparks |
| Middle right | Held beside the torso | **Cable clamp and blue-wire spool**: connection and restraint | Clamp closes while a short blue wire draws taut |
| Lower left | Forearm resting across the lap | Empty bronze hand, palm upward | Remains still |
| Lower right | Mirrored across the lap | Empty bronze hand, palm upward, fingertips almost touching the other hand | Remains still |

The four tools are visibly maintenance implements, never swords, guns, ritual staffs, or generic glowing artefacts. Their arrangement makes a broad, calm silhouette rather than a threatening fan of weapons.

## Face and posture

- Use one repaired sensor housing containing two narrow lamp apertures so the requested eyes remain compatible with the Saint's established lens identity.
- Closed eyes are dark horizontal seams, not a human face painted onto metal.
- Open eyes glow warm cream at the centre with a restrained oxidised-green rim. They should signal attention, not rage.
- The spine is straight but slightly uneven; the shoulders are relaxed; the two lap hands form a simple machine interpretation of a meditation pose.
- The head performs a two-degree lift on Play. It does not snap forward or adopt a combat stance.

## Title state: stillness

The title screen uses a slow, living hold rather than a completely static illustration:

- 8–12 second cloud drift loop with no visible seam;
- occasional leaf turn and one falling leaf at most;
- very slow warm light travel across repaired bronze plates;
- tiny servo settling in one tool arm every 5–8 seconds;
- closed eyes and motionless lap hands;
- low wind, distant machinery, leaves, and a barely audible bell-hum chord.

The **Play** button remains immediately available. The tableau must never delay menu navigation.

## Play transition

The full first-view transition targets 1.35 seconds. Simulation time has not begun during it.

| Time | Image and motion | Sound |
|---:|---|---|
| 0–100 ms | Button confirms and surrounding UI settles to 70% opacity. | Dry brass confirmation click. |
| 100–280 ms | Eye seams separate; warm points ignite and the head lifts slightly. | Two small relay ticks resolving into one tone. |
| 220–480 ms | Inspection iris opens, spanner ratchets, welder catches, cable clamp closes. Lap hands remain still. | Four quiet material sounds, staggered rather than simultaneous. |
| 320–900 ms | Central cloud veil thins; left and right banks peel away along the tree roots. | Wind opens, low city machinery enters. |
| 600–1100 ms | City crisis becomes legible: warning lamps, a stalled crane, smoke from one foundry, electrical arcing on a relay, and moving silhouettes on a broken transit line. | Distant alarm bell and uneven industrial pulse, below menu-volume limits. |
| 950–1350 ms | Camera eases through the opening clouds toward the selected route; tree and Saint silhouette align with the first gameplay frame before the scene handoff. | One restrained low chord; no cinematic boom. |

The city should not suddenly explode. Chaos is communicated through several readable failures already meaningful to this world: infrastructure has stopped, signals conflict, machinery is stranded, and repairs are urgently needed.

## Loading synchronization

The sequence has three presentation states:

```text
MEDITATION_IDLE
→ PLAY_COMMIT
→ CLOUD_PARTING
→ READY_HANDOFF
```

- If loading finishes early, complete the first-view 1.35-second sequence before handoff. Later runs may use a 450 ms shortened version after the eyes open.
- If loading is still active at 1.35 seconds, hold the revealed city with slow smoke, lamps, and clouds. Never close the eyes again or loop the reveal.
- When ready, the camera moves through one city light that match-cuts to the chosen starting site's entry lamp.
- If loading fails, keep the revealed tableau visible and present a readable retry/back panel; do not return silently to meditation.
- Loading status may read `REMEMBERING THE ROAD…` beneath the cloud line. Build/debug provenance appears only in development builds.

## Accessibility and layout

- **Reduced motion:** eyes fade open, tools brighten without moving, clouds dissolve over 300 ms, and there is no camera push.
- **Photosensitivity:** no full-screen flash; welding sparks occupy a tiny local area; warning lights pulse below 3 Hz and never alternate high-contrast red/white.
- **Skip:** after the first completed viewing, any confirm input completes the transition immediately once loading is ready.
- **Low effects:** use one cloud layer, static leaves, no sparks, and only the eye/tool state changes.
- **High contrast:** retain a dark edge around the Saint, tree trunk, tools, and city silhouette. White clouds may not erase the arm count.
- **Crop safety:** all six hands, four tool heads, both eyes, and the tree trunk remain inside the central 70% width and 80% height at 16:9 and 16:10.
- **Small display:** at 1280×720, tool heads must remain at least 24 pixels across and arm gaps at least 8 pixels.

## Layered production asset list

A single flattened painting is suitable only for concept approval. Runtime production should use separable layers:

1. sky gradient and far atmosphere;
2. city silhouette with independent warning lights, smoke, crane, relay arc, and transit movement;
3. Bodhi trunk and roots;
4. rear canopy;
5. Saint torso, head, eye shutters, six independent arms, four tools, lap hands, and small highlight masks;
6. foreground leaves;
7. left, right, and central cloud banks with clean alpha;
8. local welder sparks, lens beam, cable, and eye glow;
9. optional title-safe vignette and transition mask.

Keep the Saint and tool silhouettes vector-clean even if the final render uses painterly texture. Generated concept art should guide composition and material treatment, not be sliced blindly into production animation.

## Concept-art generation prompt

```text
Use case: stylized-concept
Asset type: landscape game title/loading-screen key art, first closed-eye meditation keyframe
Primary request: A small six-armed bronze maintenance robot saint meditates beneath a vast Bodhi tree above soft white clouds. Exactly four upper and middle hands each hold a different practical repair tool: a brass inspection lamp with glass lens, a heavy open-ended spanner, a compact welding torch, and a cable clamp with blue-wire spool. Exactly two lower arms rest empty and symmetrical in the lap in a calm meditation pose.
Scene/backdrop: white cloud banks conceal an industrial city below; only faint factory silhouettes and warm warning lights are suggested through the mist; enormous Bodhi trunk and heart-shaped leaves form a natural halo behind the Saint.
Style/medium: premium hand-painted 2D game key art with chunky industrial-diorama forms, readable silhouettes, restrained devotional iconography, tactile repaired machinery.
Composition/framing: 16:9 landscape, Saint centred slightly below mid-frame, full six-arm silhouette clearly separated, tree canopy framing the upper half, negative space reserved for game title and menu without covering the face or tools.
Lighting/mood: serene dawn, contemplative and tender, warm rim light on bronze against cool sky and clouds.
Color palette: aged bronze, brass, oxidised green enamel, cream repair light, soot blue, soft white clouds, very restrained cyan accents.
Materials/textures: visible bolts, mismatched plates, solder seams, small cloth ties, worn paint, glazed tool handles; repaired and humble rather than ornate.
Constraints: exactly six arms; exactly four different repair tools; exactly two empty lap hands; eyes closed as narrow mechanical shutters; one compact robot body; tools must read as repair implements; respectful meditation posture; no text; no logo; no watermark.
Avoid: weapons, swords, guns, extra arms, missing hands, human skin or face, gold fantasy armour, giant deity scale, photoreal person, cyberpunk neon, generic superhero robot, crowded particles, city skyscrapers, fireball explosions.
```

The second keyframe should preserve composition, anatomy, tools, tree, camera, and materials exactly; change only the open warm eyes, activated tools, parted clouds, and revealed industrial city crisis. That second image is an edit/continuity task rather than a fresh unrelated generation.

## Validation required before runtime implementation

1. Side-by-side keyframes preserve exactly six readable arms and the same tool placement.
2. At thumbnail scale, viewers identify “repairing machine in meditation” before reading copy.
3. At least five uncoached viewers distinguish the four tools and understand that the opened city is in need of repair, not under attack by the Saint.
4. The transition remains coherent with sound muted and in reduced-motion mode.
5. The final frame can match-cut into each starting site without contradicting route geography.

The desired emotional beat is: **stillness → attention → responsibility**, not **peace → rage → battle**.
