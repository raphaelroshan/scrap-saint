extends SceneTree

func _initialize(): call_deferred("run_capture")

func capture(game, directory: String, name: String):
	game.build_ui()
	game.queue_redraw()
	await RenderingServer.frame_post_draw
	var path = directory.path_join(name + ".png")
	get_root().get_texture().get_image().save_png(path)
	print("EXPEDITION CAPTURE ", path)

func open_map(game, scrap: int = 28):
	game.sim.start(0, 147, "optional")
	game.sim.state.scrap = scrap
	game.sim.state.wave = game.sim.current_wave_count()
	game.sim.state.boss_dead = true
	game.sim.step(Vector2.ZERO)
	game.map_selection = "route.brass_choir"

func run_capture():
	var directory = "res://artifacts/expedition-map"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture-dir="): directory = arg.trim_prefix("--capture-dir=")
	DirAccess.make_dir_recursive_absolute(directory)
	var game = load("res://game/main.tscn").instantiate()
	get_root().add_child(game)
	await process_frame
	game.set_physics_process(false)
	game.capture_dir = ""
	game.fixture_label = true
	game.capture_label = "SCRIPTED MAP FIXTURE"
	game.debug_visible = true
	game.screen = "game"
	open_map(game)
	await capture(game, directory, "EXPEDITION_MAP_AVAILABLE")

	game.sim.command("choose_route", "route.brass_choir")
	await capture(game, directory, "BRASS_ROAD_ENCOUNTER")
	game.sim.command("choose_road_option", "choice.brass.cross")
	await capture(game, directory, "BRASS_ROADSIDE_SERVICE")
	game.sim.state.phase = "route" # labelled fixture: inspect accepted graph styling before departure resolves
	game.map_selection = "route.brass_choir"
	await capture(game, directory, "EXPEDITION_MAP_ACCEPTED")

	open_map(game)
	game.map_selection = "route.rootworks"
	game.sim.command("choose_route", "route.rootworks")
	await capture(game, directory, "ROOTWORKS_ROAD_ENCOUNTER")
	game.queue_free()
	await process_frame
	quit()
