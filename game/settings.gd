extends RefCounted
## Local presentation/input preferences. This service never changes authoritative gameplay.

const CURRENT_VERSION = 2
const DEFAULT_PATH = "user://scrap_saint_settings.save"
const ACTIONS = ["move_up", "move_down", "move_left", "move_right"]

var state: Dictionary

func _init():
	reset()

func reset():
	state = {
		"version": CURRENT_VERSION,
		"muted": false,
		"master_volume": 1.0,
		"reduced_effects": false,
		"ui_scale": 1.0,
		"screen_shake": true,
		"fullscreen": false,
		"controls": {
			"move_up": KEY_W,
			"move_down": KEY_S,
			"move_left": KEY_A,
			"move_right": KEY_D
		}
	}

func set_option(key: String, value) -> bool:
	if key not in state or key in ["version", "controls"]:
		return false
	match key:
		"muted", "reduced_effects", "screen_shake", "fullscreen":
			if not value is bool: return false
		"master_volume":
			if not (value is float or value is int) or float(value) < 0.0 or float(value) > 1.0: return false
			value = float(value)
		"ui_scale":
			if not (value is float or value is int) or float(value) < 0.9 or float(value) > 1.3: return false
			value = float(value)
	state[key] = value
	return true

func rebind(action: String, physical_keycode: int) -> bool:
	if action not in ACTIONS or physical_keycode <= 0:
		return false
	state.controls[action] = physical_keycode
	return true

func apply_input_map():
	var arrow_keys = {"move_up": KEY_UP, "move_down": KEY_DOWN, "move_left": KEY_LEFT, "move_right": KEY_RIGHT}
	for action in ACTIONS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for event in InputMap.action_get_events(action):
			if event is InputEventKey:
				InputMap.action_erase_event(action, event)
		var key_event = InputEventKey.new()
		key_event.physical_keycode = int(state.controls[action])
		InputMap.action_add_event(action, key_event)
		if int(state.controls[action]) != int(arrow_keys[action]):
			var arrow_event = InputEventKey.new()
			arrow_event.physical_keycode = int(arrow_keys[action])
			InputMap.action_add_event(action, arrow_event)

func apply_presentation():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), state.muted)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(maxf(0.0001, state.master_volume)))
	if not OS.has_feature("headless"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if state.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)

func save_to(path: String = DEFAULT_PATH) -> bool:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null: return false
	file.store_var(state)
	return true

func load_from(path: String = DEFAULT_PATH) -> bool:
	if not FileAccess.file_exists(path): return false
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null: return false
	var loaded = file.get_var(false)
	if not loaded is Dictionary: return false
	var migrated = _migrate(loaded)
	if migrated.is_empty(): return false
	state = migrated
	return true

func _migrate(loaded: Dictionary) -> Dictionary:
	var version = int(loaded.get("version", 1))
	if version < 1 or version > CURRENT_VERSION: return {}
	var fresh = state.duplicate(true)
	for key in fresh.keys():
		if key == "controls": continue
		if loaded.has(key): fresh[key] = loaded[key]
	if loaded.get("controls", {}) is Dictionary:
		for action in ACTIONS:
			if loaded.controls.has(action) and int(loaded.controls[action]) > 0:
				fresh.controls[action] = int(loaded.controls[action])
	fresh.version = CURRENT_VERSION
	return fresh
