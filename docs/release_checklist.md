# Scrap Saint release checklist

The project uses local release builds. GitHub Actions is intentionally not required.

## Build

1. Use the pinned Godot 4.5.1 executable with export templates installed.
2. Start from a clean, reviewed commit.
3. Run `GODOT_BIN=/path/to/godot ./scripts/build_release.sh windows`.
4. Confirm the versioned directory contains `ScrapSaint.exe`, its `.pck`, `BUILD.txt`, `SHA256SUMS.txt`, `tests.log`, and the versioned Windows `.zip`.
5. Confirm `SHA256SUMS.txt` covers both the executable and its required PCK.

## Smoke test

- Launch without editor or development flags.
- Start each available frame and Blessing.
- Complete or resume an expedition through each route.
- Exercise shop purchase, combine, Gift, evolution, pause, settings, save/load, defeat, victory, same-seed retry, and return to title.
- Confirm controller navigation and keyboard movement.
- Confirm debug and fixture labels are absent in the player build.

## Release gate

- Content validation and every deterministic suite pass.
- No known save-loss or progression blocker.
- Natural-run captures are inspected at the declared viewport.
- Peak-density performance is measured on declared minimum hardware.
- Windows hardware smoke test is recorded; Wine-only testing is labelled as partial.
- The release description advertises only implemented content.
- Signing, store metadata, pricing, privacy, and support ownership are explicitly decided before a public commercial release.
