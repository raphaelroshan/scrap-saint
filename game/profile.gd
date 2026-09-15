extends RefCounted
## Durable option and memory progression. Combat never mutates this object directly.

const CURRENT_VERSION = 2
const DEFAULT_PATH = "user://scrap_saint_profile.save"

var definition: Dictionary
var state: Dictionary

func _init():
	definition = JSON.parse_string(FileAccess.get_file_as_string("res://content/progression/first_chapter.json"))
	reset()

func reset():
	state = {
		"version": CURRENT_VERSION,
		"memory_fragments": 0,
		"completed_runs": [],
		"unlocked_frames": definition.starting_unlocks.frames.duplicate(),
		"unlocked_blessings": definition.starting_unlocks.blessings.duplicate(),
		"unlocked_sites": definition.starting_unlocks.sites.duplicate(),
		"discovered_recipes": definition.starting_unlocks.recipes.duplicate(),
		"memories": [],
		"challenge_modifiers": [],
		"completed_sites": []
	}

func record_run(result: Dictionary) -> Array:
	var run_id = str(result.get("run_id", ""))
	if run_id == "" or run_id in state.completed_runs:
		return []
	state.completed_runs.append(run_id)
	var unlocked: Array = []
	var site_id = str(result.get("site_id", ""))
	var won = bool(result.get("won", false))
	if won and site_id != "" and site_id not in state.completed_sites:
		state.completed_sites.append(site_id)
		state.memory_fragments += 1
		for memory in definition.memories:
			if memory.site_id == site_id and memory.id not in state.memories:
				state.memories.append(memory.id)
				unlocked.append(memory.id)
	for evolution_id in result.get("evolution_ids", []):
		if evolution_id not in state.discovered_recipes:
			state.discovered_recipes.append(evolution_id)
			unlocked.append(evolution_id)
	var facts = {
		"complete_optional_repair": int(result.get("optional_repairs", 0)) > 0,
		"defeat_foreman": won and result.get("boss_id", "") == "boss.foreman_engine",
		"choose_brass_route": result.get("route_id", "") == "route.brass_choir",
		"choose_rootworks_route": result.get("route_id", "") == "route.rootworks",
		"complete_destination": won and site_id in ["site.brass_choir_relay", "site.rootworks_pump"]
	}
	for rule in definition.unlocks:
		if facts.get(rule.condition, false):
			var key = _collection_for(str(rule.reward_type))
			if key != "" and rule.reward_id not in state[key]:
				state[key].append(rule.reward_id)
				unlocked.append(rule.reward_id)
	return unlocked

func _collection_for(reward_type: String) -> String:
	match reward_type:
		"frame": return "unlocked_frames"
		"blessing": return "unlocked_blessings"
		"site": return "unlocked_sites"
		"recipe": return "discovered_recipes"
	return ""

func save_to(path: String = DEFAULT_PATH) -> bool:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_var(state)
	return true

func load_from(path: String = DEFAULT_PATH) -> bool:
	if not FileAccess.file_exists(path):
		return false
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	var loaded = file.get_var(false)
	if not loaded is Dictionary:
		return false
	var migrated = _migrate(loaded)
	if migrated.is_empty():
		return false
	state = migrated
	return true

func _migrate(loaded: Dictionary) -> Dictionary:
	var version = int(loaded.get("version", 1))
	if version < 1 or version > CURRENT_VERSION:
		return {}
	var fresh = state.duplicate(true)
	for key in fresh.keys():
		if loaded.has(key):
			fresh[key] = loaded[key].duplicate(true) if loaded[key] is Array or loaded[key] is Dictionary else loaded[key]
	fresh.version = CURRENT_VERSION
	for required in definition.starting_unlocks.frames:
		if required not in fresh.unlocked_frames: fresh.unlocked_frames.append(required)
	for required in definition.starting_unlocks.blessings:
		if required not in fresh.unlocked_blessings: fresh.unlocked_blessings.append(required)
	for required in definition.starting_unlocks.sites:
		if required not in fresh.unlocked_sites: fresh.unlocked_sites.append(required)
	return fresh
