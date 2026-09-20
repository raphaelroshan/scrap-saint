extends SceneTree
const Sim = preload("res://game/simulation.gd")
const Profile = preload("res://game/profile.gd")
const SaveStore = preload("res://game/save_store.gd")

var checks = 0
var failures = 0

func check(ok: bool, message: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("CHECKPOINT LIFECYCLE FAIL: ", message)

func cleanup(path: String):
	SaveStore.new().clear(path)

func finish_travel(game):
	while game.sim.state.phase == "travel":
		var free_choice = game.sim.current_road_node().choices.filter(func(choice): return int(choice.cost) == 0)[0]
		game.act("choose_road_option", free_choice.id)

func _initialize():
	call_deferred("run_checks")

func run_checks():
	var store_path = "user://m2_store_test.save"
	cleanup(store_path)
	var store = SaveStore.new()
	check(store.write_atomic(store_path, {"generation": 1}), "first atomic write succeeds")
	check(store.write_atomic(store_path, {"generation": 2}), "replacement write succeeds")
	check(store.load_dictionary(store_path).generation == 2, "primary returns the newest committed generation")
	store.fail_before_replace = true
	check(not store.write_atomic(store_path, {"generation": 3}), "injected pre-replacement failure is reported")
	check(store.load_dictionary(store_path).generation == 2, "failed write preserves the prior primary")
	var primary = FileAccess.open(store_path, FileAccess.WRITE)
	primary.store_var("corrupt")
	primary = null
	check(store.load_dictionary(store_path).generation == 1, "corrupt primary falls back to the last-known-good backup")
	store.clear(store_path)
	check(not store.has_valid_save(store_path), "clear removes primary, temporary and backup saves")

	var profile = Profile.new()
	var progress = {
		"run_id": "receipt-run",
		"site_id": "site.brass_choir_relay",
		"route_id": "route.red_foundry",
		"terminal_route_id": "route.red_foundry",
		"route_ids": ["route.brass_choir", "route.red_foundry"],
		"route_history": ["route.brass_choir", "route.red_foundry"],
		"completed_site_ids": ["site.collapsed_workshop", "site.brass_choir_relay"],
		"defeated_boss_ids": ["boss.foreman_engine", "boss.choir_regent"],
		"memory_ids": ["memory.first_shift", "memory.borrowed_bell"],
		"evolution_ids": [],
		"optional_repairs": 1,
	}
	var unlocked = profile.record_progress(progress)
	check(profile.state.memory_fragments == 2 and profile.state.site_clear_receipts.size() == 2, "run/site receipts grant each cleared site exactly once")
	check("site.brass_choir_relay" in profile.state.unlocked_sites and "site.rootworks_pump" not in profile.state.unlocked_sites, "route history unlocks the committed first branch, not an inspected alternative")
	check(profile.record_progress(progress).is_empty() and profile.state.memory_fragments == 2, "reloading the same progress cannot duplicate clear credit")
	var root_history = progress.duplicate(true)
	root_history.run_id = "root-history-run"
	root_history.route_ids = ["route.rootworks", "route.red_foundry"]
	root_history.route_history = root_history.route_ids.duplicate()
	root_history.completed_site_ids = ["site.collapsed_workshop"]
	root_history.site_id = "site.red_foundry"
	unlocked = profile.record_progress(root_history)
	check("site.rootworks_pump" in profile.state.unlocked_sites, "first-leg discovery comes from route history when the final route ID names a later leg")
	var fragments_before_death = profile.state.memory_fragments
	profile.record_run({"run_id": "receipt-run", "won": false, "completed_site_ids": progress.completed_site_ids, "route_ids": progress.route_ids})
	check(profile.state.memory_fragments == fragments_before_death and profile.state.completed_sites.has("site.brass_choir_relay"), "later defeat preserves earlier discoveries without duplicate fragments")

	var legacy_path = "user://m2_legacy_profile.save"
	cleanup(legacy_path)
	var legacy_file = FileAccess.open(legacy_path, FileAccess.WRITE)
	legacy_file.store_var({"version": 2, "memory_fragments": 2, "completed_sites": ["site.collapsed_workshop", "site.brass_choir_relay"]})
	legacy_file = null
	var migrated = Profile.new()
	check(migrated.load_from(legacy_path) and migrated.state.site_clear_receipts.size() == 2, "legacy completed sites initialize migration receipts")
	check(migrated.state.memory_fragments == 2, "receipt migration does not regrant fragments")
	cleanup(legacy_path)

	var save_path = "user://m2_checkpoint_test.save"
	var profile_path = "user://m2_checkpoint_profile.save"
	cleanup(save_path)
	cleanup(profile_path)
	var game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_physics_process(false)
	game.set_process(false)
	game.sound.muted = true
	game.save_path = save_path
	game.profile_path = profile_path
	game.profile = Profile.new()
	game.save_store.write_atomic(save_path, {"legacy": 1})
	game.save_store.write_atomic(save_path, {"legacy": 2})
	game.begin()
	var active_run_id = str(game.sim.state.run_id)
	check(game.save_store.has_valid_save(save_path) and not FileAccess.file_exists(save_path + ".bak"), "committing a new pilgrimage retires every generation of the previous run")
	game.last_phase = "combat"
	game.sim.state.wave = game.sim.current_wave_count()
	game.sim.state.boss_dead = true
	game._physics_process(0.0)
	check(game.sim.state.phase == "site_clear" and game.sim.state.site_clear_summary.site_id == "site.collapsed_workshop", "Workshop victory enters the unified site-clear phase")
	check(game.sim.state.site_clear_summary.boss_id == "boss.foreman_engine" and game.sim.state.site_clear_summary.memory_id == "memory.first_shift" and game.sim.state.site_clear_summary.route_salvage == 8, "Workshop summary owns its boss, memory and earned road salvage")
	check(game.save_store.load_dictionary(save_path) == game.sim.snapshot(), "site-clear transition checkpoints the exact simulation state")
	check(game.profile.state.site_clear_receipts == ["%s|site.collapsed_workshop" % active_run_id], "site-clear checkpoint records one durable discovery receipt")
	var receipt_count = game.profile.state.site_clear_receipts.size()
	game.commit_profile_progress()
	check(game.profile.state.site_clear_receipts.size() == receipt_count, "repeated site-clear persistence remains idempotent")
	game.act("continue_site_clear")
	check(game.sim.state.phase == "route" and game.save_store.load_dictionary(save_path) == game.sim.snapshot(), "continuing the summary checkpoints the route map")
	var continued_hash = game.sim.state_hash()
	check(game.sim.command("continue_site_clear") != "OK" and game.sim.state_hash() == continued_hash, "site-clear continuation cannot resolve twice")
	var invalid_primary = FileAccess.open(save_path, FileAccess.WRITE)
	invalid_primary.store_var({"version": 999, "weapons": [], "rng": 1})
	invalid_primary = null
	game.screen = "title"
	game.load_run()
	check(game.screen == "game" and game.sim.state.phase == "site_clear", "structurally invalid primary restores the last-known-good simulation checkpoint")
	game.act("continue_site_clear")
	var profile_before_preview = game.profile.state.duplicate(true)
	game.select_map_site("site.pale_archive")
	check(game.profile.state == profile_before_preview, "future-site inspection creates no discovery or reward")
	game.sim.state.scrap = 50
	game.act("choose_route", "route.rootworks")
	check(game.sim.state.phase == "travel" and game.save_store.load_dictionary(save_path) == game.sim.snapshot(), "route commitment checkpoints fare, route ID and first road node")
	check("site.rootworks_pump" in game.profile.state.unlocked_sites, "validated route commitment records the chosen branch discovery")
	game.act("choose_road_option", game.sim.current_road_node().choices.filter(func(choice): return int(choice.cost) == 0)[0].id)
	check(game.sim.state.phase == "travel" and game.save_store.load_dictionary(save_path) == game.sim.snapshot(), "accepted road choice checkpoints the remaining road node")
	finish_travel(game)
	check(game.sim.state.phase == "combat" and game.sim.state.site_id == "site.rootworks_pump", "second road choice reaches the destination")
	check(game.save_store.load_dictionary(save_path) == game.sim.snapshot(), "arrival checkpoint preserves the exact destination state")
	game.sim.finish(false, "Test defeat")
	game.last_phase = "combat"
	game._physics_process(0.0)
	check(not game.save_store.has_valid_save(save_path), "defeat removes every resumable expedition generation")
	check(game.profile.state.completed_sites.has("site.collapsed_workshop"), "defeat does not remove an earlier valid site discovery")
	cleanup(save_path)
	cleanup(profile_path)
	game.queue_free()
	await process_frame
	print("CHECKPOINT LIFECYCLE: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
