#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT_BIN="${GODOT_BIN:-godot}"
python3 scripts/validate_content.py
mkdir -p artifacts/agent-iteration
"$GODOT_BIN" --headless --path . --script res://tests/test_relay.gd | tee artifacts/agent-iteration/relay.log
"$GODOT_BIN" --headless --path . --script res://tests/test_arena.gd | tee artifacts/agent-iteration/arena.log
"$GODOT_BIN" --headless --path . --script res://tests/test_simulation.gd | tee artifacts/agent-iteration/simulation.log
"$GODOT_BIN" --headless --path . --script res://tests/test_chapter.gd | tee artifacts/agent-iteration/chapter.log
"$GODOT_BIN" --headless --path . --script res://tests/test_ui.gd | tee artifacts/agent-iteration/ui.log
"$GODOT_BIN" --headless --path . --script res://tests/run_playthroughs.gd | tee artifacts/agent-iteration/playthroughs.log
"$GODOT_BIN" --path . -- --capture-dir="$PWD/artifacts/agent-iteration" | tee artifacts/agent-iteration/capture.log
"$GODOT_BIN" --path . --script res://tests/capture_chapter.gd -- --capture-dir="$PWD/artifacts/agent-iteration" | tee artifacts/agent-iteration/chapter-capture.log
python3 scripts/write_provenance.py "$GODOT_BIN"
