# Task packet: EA-R01 — Local release packaging

## Player-facing objective

Players receive a versioned Windows build that launches directly into Scrap Saint without development tooling or fixture flags.

## Authoritative owner

Godot export presets and the local release script own packaging only. They do not alter simulation state, content, saves, input, or presentation.

## Exact files

- `export_presets.cfg`
- `scripts/build_release.sh`
- `docs/release_checklist.md`

## Preserved contracts

- Godot 4.5.1 remains pinned for release output.
- The deterministic simulation and content files are unchanged.
- Builds are produced locally; no GitHub Actions workflow is introduced.
- Version and source commit are recorded beside every build.

## Non-goals

- Store submission, code signing, notarization, platform certification, and claiming human QA.
- Uploading a release before the integrated gameplay branch passes its release gate.

## Deterministic acceptance tests

1. Content validation and the headless Godot suite pass before export.
2. A missing Godot binary or export template fails with a clear message.
3. A successful build contains the executable, PCK, SHA-256 manifest, version, commit, and test log.
4. The script refuses a dirty working tree unless `ALLOW_DIRTY_BUILD=1` is explicitly set.
5. Repeating the script from the same clean commit uses the same versioned output directory.

## Evidence states

- Local release directory and manifest from Godot 4.5.1.
- Windows executable smoke-tested through the available compatibility environment or classified as awaiting Windows hardware.

## Remaining limitation

Unsigned Windows builds may trigger operating-system reputation warnings until signing and store distribution are configured.

## Exactly one next task

Build and smoke-test the integrated Early Access candidate after all gameplay branches merge.
