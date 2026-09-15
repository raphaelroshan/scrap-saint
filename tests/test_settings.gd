extends SceneTree
const Settings = preload("res://game/settings.gd")
var failures = 0
var checks = 0

func check(ok: bool, message: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("SETTINGS FAIL: ", message)

func _initialize():
	var settings = Settings.new()
	check(settings.state.ui_scale == 1.0 and not settings.state.reduced_effects, "defaults are readable")
	check(not settings.set_option("ui_scale", 2.0) and settings.state.ui_scale == 1.0, "invalid scale is rejected without mutation")
	check(not settings.set_option("simulation_speed", 5), "gameplay settings are rejected")
	check(settings.set_option("ui_scale", 1.2) and settings.set_option("reduced_effects", true), "presentation options update")
	check(settings.rebind("move_up", KEY_I) and not settings.rebind("fire", KEY_F), "known controls rebind and unknown controls reject")
	settings.apply_input_map()
	var key_events = InputMap.action_get_events("move_up").filter(func(event): return event is InputEventKey)
	check(key_events.any(func(event): return event.physical_keycode == KEY_I) and key_events.any(func(event): return event.physical_keycode == KEY_UP), "keyboard binding applies while arrows remain available")
	var path = "user://settings_test.save"
	check(settings.save_to(path), "settings save")
	var loaded = Settings.new()
	check(loaded.load_from(path) and loaded.state == settings.state, "settings roundtrip is exact")
	DirAccess.remove_absolute(path)
	var legacy_path = "user://settings_legacy_test.save"
	var file = FileAccess.open(legacy_path, FileAccess.WRITE)
	file.store_var({"version": 1, "muted": true, "controls": {"move_left": KEY_J}})
	file = null
	var migrated = Settings.new()
	check(migrated.load_from(legacy_path), "version-one settings migrate")
	check(migrated.state.version == Settings.CURRENT_VERSION and migrated.state.muted, "migration preserves known values")
	check(migrated.state.controls.move_left == KEY_J and migrated.state.controls.move_right == KEY_D, "migration restores missing controls")
	DirAccess.remove_absolute(legacy_path)
	var invalid_path = "user://settings_invalid_legacy_test.save"
	file = FileAccess.open(invalid_path, FileAccess.WRITE)
	file.store_var({"version": 1, "muted": "yes", "master_volume": -2.0, "ui_scale": 9.0, "controls": {"move_up": -1, "move_left": KEY_J}})
	file = null
	var bounded = Settings.new()
	check(bounded.load_from(invalid_path), "invalid legacy values migrate without rejecting the whole settings file")
	check(not bounded.state.muted and bounded.state.master_volume == 1.0 and bounded.state.ui_scale == 1.0, "invalid legacy presentation values retain safe defaults")
	check(bounded.state.controls.move_up == KEY_W and bounded.state.controls.move_left == KEY_J, "invalid legacy controls fall back independently")
	DirAccess.remove_absolute(invalid_path)
	print("SETTINGS: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
