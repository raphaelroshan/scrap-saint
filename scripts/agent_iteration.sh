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
"$GODOT_BIN" --headless --path . --script res://tests/test_optional_repairs.gd | tee artifacts/agent-iteration/optional-repairs.log
"$GODOT_BIN" --headless --path . --script res://tests/test_shop.gd | tee artifacts/agent-iteration/shop.log
"$GODOT_BIN" --headless --path . --script res://tests/test_variety.gd | tee artifacts/agent-iteration/variety.log
"$GODOT_BIN" --headless --path . --script res://tests/test_roaming_quality.gd | tee artifacts/agent-iteration/roaming-quality.log
"$GODOT_BIN" --headless --path . --script res://tests/test_ui.gd | tee artifacts/agent-iteration/ui.log
"$GODOT_BIN" --headless --path . --script res://tests/test_flow_input.gd | tee artifacts/agent-iteration/flow-input.log
"$GODOT_BIN" --headless --path . --script res://tests/test_save_flow.gd | tee artifacts/agent-iteration/save-flow.log
"$GODOT_BIN" --headless --path . --script res://tests/test_assembly.gd | tee artifacts/agent-iteration/assembly.log
"$GODOT_BIN" --headless --path . --script res://tests/test_acquisition.gd | tee artifacts/agent-iteration/acquisition.log
"$GODOT_BIN" --headless --path . --script res://tests/run_playthroughs.gd -- --optional | tee artifacts/agent-iteration/optional-playthroughs.log
"$GODOT_BIN" --headless --path . --script res://tests/run_assembly_playthroughs.gd | tee artifacts/agent-iteration/assembly-playthroughs.log
"$GODOT_BIN" --path . -- --capture-dir="$PWD/artifacts/agent-iteration" | tee artifacts/agent-iteration/capture.log
"$GODOT_BIN" --path . --script res://tests/capture_chapter.gd -- --capture-dir="$PWD/artifacts/agent-iteration" | tee artifacts/agent-iteration/chapter-capture.log
"$GODOT_BIN" --path . --script res://tests/capture_core_quality.gd | tee artifacts/agent-iteration/core-quality-capture.log
"$GODOT_BIN" --path . --script res://tests/capture_assembly.gd | tee artifacts/agent-iteration/assembly-capture.log
python3 scripts/write_provenance.py "$GODOT_BIN"
