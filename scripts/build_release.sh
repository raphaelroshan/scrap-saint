#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot}"
TARGET="${1:-windows}"

case "$TARGET" in
  windows)
    PRESET="Windows Desktop"
    ARTIFACT_NAME="ScrapSaint.exe"
    ;;
  macos)
    PRESET="macOS"
    ARTIFACT_NAME="Scrap Saint.zip"
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

for test_script in test_variety.gd test_optional_repairs.gd test_shop.gd test_relay.gd test_arena.gd test_simulation.gd test_ui.gd test_dev_speed.gd test_profile.gd test_settings.gd; do
  "$GODOT_BIN" --headless --path . --script "tests/$test_script" | tee -a "$OUTPUT_DIR/tests.log"
done

"$GODOT_BIN" --headless --path . --export-release "$PRESET" "$OUTPUT_PATH"

{
  echo "version=$VERSION"
  echo "commit=$COMMIT"
  echo "godot=$($GODOT_BIN --version | head -n 1)"
  echo "target=$TARGET"
  echo "artifact=$ARTIFACT_NAME"
} > "$OUTPUT_DIR/BUILD.txt"

if command -v shasum >/dev/null 2>&1; then
  (cd "$OUTPUT_DIR" && shasum -a 256 "$ARTIFACT_NAME" > SHA256SUMS.txt)
else
  (cd "$OUTPUT_DIR" && sha256sum "$ARTIFACT_NAME" > SHA256SUMS.txt)
fi

echo "Release built: $OUTPUT_PATH"
