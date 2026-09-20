#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT_BIN="${GODOT_BIN:-godot}"
python3 scripts/validate_content.py
python3 -m unittest tests/test_slice_manifest.py
mkdir -p artifacts/agent-iteration
"$GODOT_BIN" --headless --path . --script res://tests/test_main_menu.gd | tee artifacts/agent-iteration/main-menu.log
"$GODOT_BIN" --headless --path . --script res://tests/test_dev_speed.gd | tee artifacts/agent-iteration/dev-speed.log
"$GODOT_BIN" --headless --path . --script res://tests/test_frames_progression.gd | tee artifacts/agent-iteration/frames-progression.log
"$GODOT_BIN" --headless --path . --script res://tests/test_profile.gd | tee artifacts/agent-iteration/profile.log
"$GODOT_BIN" --headless --path . --script res://tests/test_settings.gd | tee artifacts/agent-iteration/settings.log
"$GODOT_BIN" --headless --path . --script res://tests/test_sync_contract.gd | tee artifacts/agent-iteration/sync-contract.log
"$GODOT_BIN" --path . --script res://tests/capture_sync_contract.gd | tee artifacts/agent-iteration/sync-capture.log
"$GODOT_BIN" --headless --path . --script res://tests/test_relay.gd | tee artifacts/agent-iteration/relay.log
"$GODOT_BIN" --headless --path . --script res://tests/test_arena.gd | tee artifacts/agent-iteration/arena.log
"$GODOT_BIN" --headless --path . --script res://tests/test_simulation.gd | tee artifacts/agent-iteration/simulation.log
"$GODOT_BIN" --headless --path . --script res://tests/test_chapter.gd | tee artifacts/agent-iteration/chapter.log
"$GODOT_BIN" --headless --path . --script res://tests/test_expedition_map.gd | tee artifacts/agent-iteration/expedition-map.log
"$GODOT_BIN" --headless --path . --script res://tests/test_optional_repairs.gd | tee artifacts/agent-iteration/optional-repairs.log
"$GODOT_BIN" --headless --path . --script res://tests/test_shop.gd | tee artifacts/agent-iteration/shop.log
"$GODOT_BIN" --headless --path . --script res://tests/test_variety.gd | tee artifacts/agent-iteration/variety.log
"$GODOT_BIN" --headless --path . --script res://tests/test_roaming_quality.gd | tee artifacts/agent-iteration/roaming-quality.log
"$GODOT_BIN" --headless --path . --script res://tests/test_ui.gd | tee artifacts/agent-iteration/ui.log
"$GODOT_BIN" --headless --path . --script res://tests/test_flow_input.gd | tee artifacts/agent-iteration/flow-input.log
"$GODOT_BIN" --headless --path . --script res://tests/test_save_flow.gd | tee artifacts/agent-iteration/save-flow.log
"$GODOT_BIN" --headless --path . --script res://tests/test_checkpoint_lifecycle.gd | tee artifacts/agent-iteration/checkpoint-lifecycle.log
"$GODOT_BIN" --headless --path . --script res://tests/test_assembly.gd | tee artifacts/agent-iteration/assembly.log
"$GODOT_BIN" --headless --path . --script res://tests/test_acquisition.gd | tee artifacts/agent-iteration/acquisition.log
"$GODOT_BIN" --headless --path . --script res://tests/test_evolutions.gd | tee artifacts/agent-iteration/evolutions.log
"$GODOT_BIN" --headless --path . --script res://tests/test_weapon_ranks.gd | tee artifacts/agent-iteration/weapon-ranks.log
"$GODOT_BIN" --headless --path . --script res://tests/test_weapon_presentation.gd | tee artifacts/agent-iteration/weapon-presentation.log
"$GODOT_BIN" --headless --path . --script res://tests/test_presentation_quality.gd | tee artifacts/agent-iteration/presentation-quality.log
"$GODOT_BIN" --headless --path . --script res://tests/test_gift_breadth.gd | tee artifacts/agent-iteration/gift-breadth.log
"$GODOT_BIN" --headless --path . --script res://tests/run_playthroughs.gd -- --optional | tee artifacts/agent-iteration/optional-playthroughs.log
"$GODOT_BIN" --headless --path . --script res://tests/run_assembly_playthroughs.gd | tee artifacts/agent-iteration/assembly-playthroughs.log
"$GODOT_BIN" --headless --path . --script res://tests/run_evolution_playthroughs.gd | tee artifacts/agent-iteration/evolution-playthroughs.log
"$GODOT_BIN" --headless --path . --script res://tests/run_gift_playthroughs.gd | tee artifacts/agent-iteration/gift-playthroughs.log
"$GODOT_BIN" --headless --path . --script res://tests/run_four_path_pacing.gd | tee artifacts/agent-iteration/four-path-pacing.log
"$GODOT_BIN" --path . -- --capture-dir="$PWD/artifacts/agent-iteration" | tee artifacts/agent-iteration/capture.log
"$GODOT_BIN" --path . --script res://tests/capture_chapter.gd -- --capture-dir="$PWD/artifacts/agent-iteration" | tee artifacts/agent-iteration/chapter-capture.log
"$GODOT_BIN" --path . --script res://tests/capture_expedition_map.gd -- --capture-dir="$PWD/artifacts/agent-iteration" | tee artifacts/agent-iteration/expedition-map-capture.log
"$GODOT_BIN" --path . --script res://tests/capture_core_quality.gd | tee artifacts/agent-iteration/core-quality-capture.log
"$GODOT_BIN" --path . --script res://tests/capture_assembly.gd | tee artifacts/agent-iteration/assembly-capture.log
"$GODOT_BIN" --path . --script res://tests/capture_evolutions.gd | tee artifacts/agent-iteration/evolution-capture.log
"$GODOT_BIN" --path . --script res://tests/capture_weapon_ranks.gd -- --capture-dir="$PWD/artifacts/agent-iteration" | tee artifacts/agent-iteration/weapon-rank-capture.log
"$GODOT_BIN" --path . --script res://tests/capture_weapon_animation.gd -- --capture-dir="$PWD/artifacts/weapon-animation" | tee artifacts/agent-iteration/weapon-animation-capture.log
"$GODOT_BIN" --path . --script res://tests/capture_manifested_nailer.gd -- --capture-dir="$PWD/artifacts/manifested-nailer" | tee artifacts/agent-iteration/manifested-nailer-capture.log
"$GODOT_BIN" --path . --script res://tests/capture_manifested_relics.gd -- --capture-dir="$PWD/artifacts/manifested-relics" | tee artifacts/agent-iteration/manifested-relics-capture.log
"$GODOT_BIN" --path . --script res://tests/capture_remaining_manifested_relics.gd -- --capture-dir="$PWD/artifacts/remaining-manifested-relics" | tee artifacts/agent-iteration/remaining-manifested-relics-capture.log
"$GODOT_BIN" --path . --script res://tests/capture_game_feel.gd -- --capture-dir="$PWD/artifacts/game-feel" | tee artifacts/agent-iteration/game-feel-capture.log
"$GODOT_BIN" --path . --script res://tests/capture_gift_breadth.gd | tee artifacts/agent-iteration/gift-breadth-capture.log
"$GODOT_BIN" --path . --script res://tests/capture_main_menu.gd | tee artifacts/agent-iteration/main-menu-capture.log
python3 scripts/write_provenance.py "$GODOT_BIN"
