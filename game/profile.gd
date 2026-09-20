extends RefCounted
## Durable option and memory progression. Combat never mutates this object directly.

const SaveStore = preload("res://game/save_store.gd")
const CURRENT_VERSION = 3
const DEFAULT_PATH = "user://scrap_saint_profile.save"

var definition: Dictionary
var state: Dictionary
var storage = SaveStore.new()

func _init():
	definition = JSON.parse_string(FileAccess.get_file_as_string("res://content/progression/first_chapter.json"))
	reset()

func reset():
	state = {
		"version": CURRENT_VERSION,
		"next_run_serial": 1,
		"memory_fragments": 0,
		"completed_runs": [],
		"unlocked_frames": definition.starting_unlocks.frames.duplicate(),
		"unlocked_blessings": definition.starting_unlocks.blessings.duplicate(),
		"unlocked_sites": definition.starting_unlocks.sites.duplicate(),
		"discovered_recipes": definition.starting_unlocks.recipes.duplicate(),
		"memories": [],
		"challenge_modifiers": [],
		"completed_sites": [],
		"site_clear_receipts": []
	}

func claim_run_id(seed_value: int, frame_id: String) -> String:
	var serial = int(state.next_run_serial)
	state.next_run_serial = serial + 1
	return "run-%d-%d-%s" % [serial, seed_value, frame_id]

func record_progress(result: Dictionary) -> Array:
	var run_id = str(result.get("run_id", ""))
	if run_id == "": return []
	var unlocked: Array = []
	var site_id = str(result.get("site_id", ""))
	var won = bool(result.get("won", false))
	var completed_site_ids: Array = result.get("completed_site_ids", []).duplicate()
	if won and site_id != "" and site_id not in completed_site_ids:
		completed_site_ids.append(site_id)
	for completed_site_id in completed_site_ids:
		var receipt = "%s|%s" % [run_id, completed_site_id]
		if receipt in state.site_clear_receipts: continue
		state.site_clear_receipts.append(receipt)
		if completed_site_id not in state.completed_sites:
			state.completed_sites.append(completed_site_id)
			state.memory_fragments += 1
			for memory in definition.memories:
				if memory.site_id == completed_site_id and memory.id not in state.memories:
					state.memories.append(memory.id)
					unlocked.append(memory.id)
	for memory_id in result.get("memory_ids", []):
		if memory_id not in state.memories:
			state.memories.append(memory_id)
			unlocked.append(memory_id)
	for evolution_id in result.get("evolution_ids", []):
		if evolution_id not in state.discovered_recipes:
			state.discovered_recipes.append(evolution_id)
			unlocked.append(evolution_id)
	var defeated_boss_ids: Array = result.get("defeated_boss_ids", []).duplicate()
	var boss_id = str(result.get("boss_id", ""))
	if won and boss_id != "" and boss_id not in defeated_boss_ids:
		defeated_boss_ids.append(boss_id)
	var route_ids: Array = result.get("route_ids", result.get("route_history", [])).duplicate()
	for fallback_key in ["route_id", "terminal_route_id"]:
		var fallback_id = str(result.get(fallback_key, ""))
		if fallback_id != "" and fallback_id not in route_ids: route_ids.append(fallback_id)
	var facts = {
		"complete_optional_repair": int(result.get("optional_repairs", 0)) > 0,
		"defeat_foreman": "boss.foreman_engine" in defeated_boss_ids,
		"choose_brass_route": "route.brass_choir" in route_ids,
		"choose_rootworks_route": "route.rootworks" in route_ids,
		"complete_destination": completed_site_ids.any(func(id): return id in ["site.brass_choir_relay", "site.rootworks_pump"])
	}
	for rule in definition.unlocks:
		if facts.get(rule.condition, false):
			var key = _collection_for(str(rule.reward_type))
			if key != "" and rule.reward_id not in state[key]:
				state[key].append(rule.reward_id)
				unlocked.append(rule.reward_id)
	return unlocked

func record_run(result: Dictionary) -> Array:
	var unlocked = record_progress(result)
	var run_id = str(result.get("run_id", ""))
	if run_id == "" or run_id in state.completed_runs: return unlocked
	state.completed_runs.append(run_id)
	return unlocked

func _collection_for(reward_type: String) -> String:
	match reward_type:
		"frame": return "unlocked_frames"
		"blessing": return "unlocked_blessings"
		"site": return "unlocked_sites"
		"recipe": return "discovered_recipes"
	return ""

func save_to(path: String = DEFAULT_PATH) -> bool:
	return storage.write_atomic(path, state)

func load_from(path: String = DEFAULT_PATH) -> bool:
	for loaded in storage.load_dictionaries(path):
		var migrated = _migrate(loaded)
		if not migrated.is_empty():
			state = migrated
			return true
	return false

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
	for required in definition.starting_unlocks.recipes:
		if required not in fresh.discovered_recipes: fresh.discovered_recipes.append(required)
	if version < 3:
		for site_id in fresh.completed_sites:
			var receipt = "legacy|%s" % site_id
			if receipt not in fresh.site_clear_receipts: fresh.site_clear_receipts.append(receipt)
		fresh.next_run_serial = maxi(int(fresh.next_run_serial), fresh.completed_runs.size() + 1)
	return fresh
