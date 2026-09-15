#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot}"
TARGET="${1:-windows}"

case "$TARGET" in
  windows)
    PRESET="Windows Desktop"
    ARTIFACT_NAME="ScrapSaint.exe"
    COMPANION_NAME="ScrapSaint.pck"
    ;;
  macos)
    PRESET="macOS"
    ARTIFACT_NAME="Scrap Saint.zip"
    COMPANION_NAME=""
    ;;
  *)
    echo "Usage: GODOT_BIN=/path/to/godot $0 [windows|macos]" >&2
    exit 2
    ;;
esac

if ! command -v "$GODOT_BIN" >/dev/null 2>&1 && [ ! -x "$GODOT_BIN" ]; then
  echo "Godot executable not found: $GODOT_BIN" >&2
  exit 2
fi

if [ "${ALLOW_DIRTY_BUILD:-0}" != "1" ] && [ -n "$(git -C "$ROOT_DIR" status --porcelain)" ]; then
  echo "Refusing release from a dirty working tree. Commit changes or set ALLOW_DIRTY_BUILD=1." >&2
  exit 2
fi

cd "$ROOT_DIR"
VERSION="$(python3 -c 'import json, pathlib; print(json.loads(pathlib.Path("content/slices/first_shift.json").read_text())["version"])' 2>/dev/null)"
COMMIT="$(git -C "$ROOT_DIR" rev-parse --short=12 HEAD)"
OUTPUT_DIR="$ROOT_DIR/build/releases/scrap-saint-${VERSION}-${COMMIT}/${TARGET}"
OUTPUT_PATH="$OUTPUT_DIR/$ARTIFACT_NAME"
mkdir -p "$OUTPUT_DIR"

python3 scripts/validate_content.py | tee "$OUTPUT_DIR/tests.log"
python3 tests/test_slice_manifest.py | tee -a "$OUTPUT_DIR/tests.log"

for test_path in tests/test_*.gd; do
  "$GODOT_BIN" --headless --path . --script "$test_path" | tee -a "$OUTPUT_DIR/tests.log"
done

"$GODOT_BIN" --headless --path . --script tests/benchmark_peak_density.gd | tee -a "$OUTPUT_DIR/tests.log"

# Release builds also prove normal-economy completion rather than relying only on fixtures.
"$GODOT_BIN" --headless --path . --script tests/run_playthroughs.gd -- --optional | tee -a "$OUTPUT_DIR/tests.log"
"$GODOT_BIN" --headless --path . --script tests/run_playthroughs.gd -- --optional --ea-matrix | tee -a "$OUTPUT_DIR/tests.log"
"$GODOT_BIN" --headless --path . --script tests/run_assembly_playthroughs.gd | tee -a "$OUTPUT_DIR/tests.log"

"$GODOT_BIN" --headless --path . --export-release "$PRESET" "$OUTPUT_PATH"

{
  echo "version=$VERSION"
  echo "commit=$COMMIT"
  echo "godot=$($GODOT_BIN --version | head -n 1)"
  echo "target=$TARGET"
  echo "artifact=$ARTIFACT_NAME"
} > "$OUTPUT_DIR/BUILD.txt"

if command -v shasum >/dev/null 2>&1; then
  if [ -n "$COMPANION_NAME" ]; then
    (cd "$OUTPUT_DIR" && shasum -a 256 "$ARTIFACT_NAME" "$COMPANION_NAME" > SHA256SUMS.txt)
  else
    (cd "$OUTPUT_DIR" && shasum -a 256 "$ARTIFACT_NAME" > SHA256SUMS.txt)
  fi
else
  if [ -n "$COMPANION_NAME" ]; then
    (cd "$OUTPUT_DIR" && sha256sum "$ARTIFACT_NAME" "$COMPANION_NAME" > SHA256SUMS.txt)
  else
    (cd "$OUTPUT_DIR" && sha256sum "$ARTIFACT_NAME" > SHA256SUMS.txt)
  fi
fi

if [ "$TARGET" = "windows" ]; then
  PACKAGE_NAME="ScrapSaint-${VERSION}-windows-x86_64.zip"
  (cd "$OUTPUT_DIR" && zip -q "$PACKAGE_NAME" "$ARTIFACT_NAME" "$COMPANION_NAME" BUILD.txt SHA256SUMS.txt)
fi

echo "Release built: $OUTPUT_PATH"
