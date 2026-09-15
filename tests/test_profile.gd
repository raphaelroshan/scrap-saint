extends SceneTree
const Profile = preload("res://game/profile.gd")
var failures = 0
var checks = 0

func check(ok: bool, message: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("PROFILE FAIL: ", message)

func _initialize():
	var profile = Profile.new()
	check(profile.state.unlocked_frames == ["frame.pilgrim"], "fresh profile has only Pilgrim Frame")
	check(profile.state.unlocked_blessings.size() == 3, "fresh profile has three starting Blessings")
	var first = {
		"run_id": "run-147-workshop",
		"won": true,
		"site_id": "site.collapsed_workshop",
		"boss_id": "boss.foreman_engine",
		"optional_repairs": 1,
		"route_id": "route.rootworks",
		"evolution_ids": ["evolution.great_toll"]
	}
	var unlocked = profile.record_run(first)
	check("frame.surveyor" in unlocked and "frame.keeper" in unlocked, "repair and Foreman unlock distinct frames")
	check("site.rootworks_pump" in unlocked, "route choice unlocks its destination")
	check(profile.state.memory_fragments == 1 and "memory.first_shift" in profile.state.memories, "first site grants one authored memory")
	check("evolution.great_toll" in profile.state.discovered_recipes, "completed result records discovered evolution")
	check(profile.record_run(first).is_empty() and profile.state.memory_fragments == 1, "duplicate result is idempotent")
	var destination = {
		"run_id": "run-148-rootworks",
		"won": true,
		"site_id": "site.rootworks_pump",
		"boss_id": "boss.root_tender",
		"optional_repairs": 0,
		"route_id": "",
		"evolution_ids": []
	}
	unlocked = profile.record_run(destination)
	check("blessing.procession" in unlocked, "destination completion unlocks Procession")
	check(profile.state.memory_fragments == 2 and "memory.rootworks" in profile.state.memories, "destination grants one authored memory")
	var path = "user://profile_test.save"
	check(profile.save_to(path), "profile saves")
	var loaded = Profile.new()
	check(loaded.load_from(path) and loaded.state == profile.state, "profile roundtrip is exact")
	DirAccess.remove_absolute(path)
	var legacy_path = "user://profile_legacy_test.save"
	var file = FileAccess.open(legacy_path, FileAccess.WRITE)
	file.store_var({"version": 1, "memory_fragments": 3, "unlocked_frames": ["frame.surveyor"], "memories": ["memory.first_shift"]})
	file = null
	var migrated = Profile.new()
	check(migrated.load_from(legacy_path), "version-one profile migrates")
	check(migrated.state.version == Profile.CURRENT_VERSION and "frame.pilgrim" in migrated.state.unlocked_frames, "migration restores required defaults")
	check(migrated.state.memory_fragments == 3 and "memory.first_shift" in migrated.state.memories, "migration preserves progress")
	DirAccess.remove_absolute(legacy_path)
	print("PROFILE: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
