extends SceneTree

func _initialize(): call_deferred("run_capture")

func capture(game, directory: String, name: String, selected_route: String = ""):
	game.build_ui()
	# Button focus deliberately selects the first assignment; fixture-specific captures
	# move focus to the requested assignment after controls have been built.
	if selected_route != "":
		var selected_name = str(game.sim.routes[selected_route].name).to_upper()
		for child in game.ui.get_children():
			if child is Button and child.text == selected_name:
				child.grab_focus()
				break
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

func configure_second_tier_board(game, site_id: String, selected_route: String, accepted: bool = false):
	game.sim.state.phase = "route"
	game.sim.state.site_id = site_id
	var first_route = "route.brass_choir" if site_id == "site.brass_choir_relay" else "route.rootworks"
	var first_route_data = game.sim.routes[first_route]
	game.sim.arena.load_file(first_route_data.arena_path)
	game.sim.state.arena_id = game.sim.arena.data.id
	game.sim.state.wave = int(first_route_data.wave_count)
	game.sim.state.objective = first_route_data.objective.nodes.map(func(node): return {"id": node.id, "progress": float(first_route_data.objective.required_ticks), "complete": true})
	game.sim.state.objective_complete = true
	game.sim.state.assignment_statuses = {first_route: "accepted"}
	game.sim.state.route = selected_route if accepted else first_route
	game.sim.state.route_history = [first_route, selected_route] if accepted else [first_route]
	game.sim.state.route_origin_site_id = site_id if accepted else "site.collapsed_workshop"
	game.sim.refresh_assignments()
	if accepted: game.sim.state.assignment_statuses[selected_route] = "accepted"
	game.map_selection = selected_route

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

	configure_second_tier_board(game, "site.brass_choir_relay", "route.red_foundry")
	game.capture_label = "SCRIPTED SECOND-TIER BOARD / BRASS"
	await capture(game, directory, "SECOND_TIER_BRASS_RED_SELECTED", "route.red_foundry")
	configure_second_tier_board(game, "site.rootworks_pump", "route.red_foundry", true)
	game.capture_label = "SCRIPTED SECOND-TIER BOARD / ROOTWORKS"
	await capture(game, directory, "SECOND_TIER_ROOT_RED_ACCEPTED", "route.red_foundry")
	game.queue_free()
	await process_frame
	quit()
