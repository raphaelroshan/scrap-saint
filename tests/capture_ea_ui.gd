extends SceneTree

func _initialize():
	call_deferred("run_capture")

func capture(game, directory: String, name: String):
	game.build_ui()
	game.queue_redraw()
	await RenderingServer.frame_post_draw
	var path = directory.path_join(name + ".png")
	get_root().get_texture().get_image().save_png(path)
	print("EA UI CAPTURE ", path, " | Godot ", Engine.get_version_info().string, " | 1280x800 | seed 147 | FIXTURE")

func run_capture():
	var directory = "res://artifacts/ea-ui"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture-dir="): directory = arg.trim_prefix("--capture-dir=")
	DirAccess.make_dir_recursive_absolute(directory)
	var game = load("res://game/main.tscn").instantiate()
	get_root().add_child(game)
	await process_frame
	game.capture_dir = ""
	game.debug_visible = false
	game.screen = "title"
	await capture(game, directory, "TITLE")

	game.profile.state.unlocked_frames = ["frame.pilgrim", "frame.surveyor", "frame.keeper"]
	game.profile.state.unlocked_blessings = game.sim.config.blessings.duplicate()
	game.screen = "menu"
	game.chosen_frame = "frame.surveyor"
	game.chosen = 3
	await capture(game, directory, "FRAME_AND_BLESSING_SETUP")

	game.previous_screen = "title"
	game.screen = "tutorial"
	game.tutorial_page = 3
	await capture(game, directory, "FIELD_MANUAL_ASSEMBLY")

	game.screen = "settings"
	game.awaiting_binding = "move_up"
	await capture(game, directory, "SETTINGS_REMAP")

	game.screen = "game"
	game.sim.start(3, 147, "optional", "frame.surveyor", "capture-ea-results")
	game.sim.state.route = "route.rootworks"
	game.sim.enter_destination(game.sim.current_route())
	game.sim.state.completed_site_ids = ["site.collapsed_workshop", "site.rootworks_pump"]
	game.sim.state.defeated_boss_ids = ["boss.foreman_engine", "boss.factory_heart"]
	game.sim.state.memory_id = "memory.borrowed_arm"
	game.sim.state.chapter_complete = true
	game.sim.state.evolutions = ["evolution.great_toll"]
	game.sim.state.damage = {"weapon.bell_last_shift": 1842.0, "weapon.procession_gear": 917.0}
	game.sim.state.kills_by_weapon = {"weapon.bell_last_shift": 73, "weapon.procession_gear": 28}
	game.sim.state.kills = 112
	game.sim.state.machines[0].complete = true
	game.sim.finish(true, "Water returns by the low road. The Rootworks keeps its own purpose.")
	game.recent_unlocks = ["frame.keeper", "blessing.procession"]
	await capture(game, directory, "CHAPTER_RESULTS_UNLOCKS")

	game.queue_free()
	await process_frame
	quit()
