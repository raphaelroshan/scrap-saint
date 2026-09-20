extends SceneTree

func _initialize(): call_deferred("run_capture")

func capture(game, directory: String, name: String, selected_route: String = ""):
	game.build_ui()
	# Map construction deliberately focuses the first legal node; fixture-specific
	# captures move focus to the requested stable destination after controls exist.
	if selected_route != "":
		var site_id = str(game.sim.routes[selected_route].site_id)
		var selected_name = str(game.map_site_data(site_id).name).to_upper()
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
	game.sim.command("continue_site_clear")
	game.map_selection = "route.brass_choir"

func finish_travel(game, begin_combat: bool = true):
	while game.sim.state.phase == "travel":
		var free_choice = game.sim.current_road_node().choices.filter(func(choice): return int(choice.cost) == 0)[0]
		game.sim.command("choose_road_option", free_choice.id)
	if begin_combat and game.sim.state.phase == "arrival": game.sim.command("begin_site")

func force_site_clear(game):
	game.sim.state.wave = game.sim.current_wave_count()
	game.sim.state.boss_dead = true
	game.sim.step(Vector2.ZERO)

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
	game.screen = "departure_map"
	game.capture_label = "M1 DEPARTURE MAP / CONFIGURED FIXTURE"
	game.departure_selection = "site.collapsed_workshop"
	await capture(game, directory, "M1_DEPARTURE_WORKSHOP")
	await capture(game, directory, "M1_DEPARTURE_NULL_PREVIEW", "route.null_assembly")
	game.ui_scale = 1.15
	await capture(game, directory, "M1_DEPARTURE_LARGE_TEXT", "route.null_assembly")
	game.ui_scale = 1.0

	game.screen = "game"
	game.capture_label = "M1 ROUTE MAP / CONFIGURED FIXTURE"
	open_map(game)
	await capture(game, directory, "EXPEDITION_MAP_AVAILABLE")
	game.ui_scale = 1.15
	await capture(game, directory, "M1_ROUTE_LARGE_TEXT", "route.brass_choir")
	game.ui_scale = 1.0

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
	finish_travel(game, false)
	game.capture_label = "M3 ARRIVAL / CONFIGURED FIXTURE"
	await capture(game, directory, "M3_ROOTWORKS_ARRIVAL")

	configure_second_tier_board(game, "site.brass_choir_relay", "route.red_foundry")
	game.capture_label = "SCRIPTED SECOND-TIER BOARD / BRASS"
	await capture(game, directory, "SECOND_TIER_BRASS_RED_SELECTED", "route.red_foundry")
	configure_second_tier_board(game, "site.rootworks_pump", "route.red_foundry", true)
	game.capture_label = "SCRIPTED SECOND-TIER BOARD / ROOTWORKS"
	await capture(game, directory, "SECOND_TIER_ROOT_RED_ACCEPTED", "route.red_foundry")

	game.capture_label = "M2 SITE CLEAR / CONFIGURED FIXTURE"
	game.sim.start(0, 147, "optional", "frame.pilgrim", "capture-m2-clear")
	game.sim.state.machines[0].complete = true
	force_site_clear(game)
	await capture(game, directory, "M2_WORKSHOP_SITE_CLEAR")
	game.ui_scale = 1.15
	await capture(game, directory, "M2_WORKSHOP_SITE_CLEAR_LARGE_TEXT")
	game.ui_scale = 1.0
	game.sim.command("continue_site_clear")
	game.sim.state.scrap = 40
	game.sim.command("choose_route", "route.brass_choir")
	finish_travel(game, false)
	game.capture_label = "M3 ARRIVAL / CONFIGURED FIXTURE"
	await capture(game, directory, "M3_BRASS_ARRIVAL")
	game.ui_scale = 1.15
	await capture(game, directory, "M3_BRASS_ARRIVAL_LARGE_TEXT")
	game.ui_scale = 1.0
	game.sim.command("begin_site")
	game.sim.state.objective[0].complete = true
	game.sim.state.objective[0].progress = float(game.sim.objective_data().required_ticks)
	force_site_clear(game)
	await capture(game, directory, "M2_MIDDLE_SITE_CLEAR")
	game.sim.command("continue_site_clear")
	game.sim.command("choose_route", "route.pale_archive")
	finish_travel(game, false)
	game.capture_label = "M3 ARRIVAL / CONFIGURED FIXTURE"
	await capture(game, directory, "M3_PALE_ARCHIVE_ARRIVAL")
	game.sim.command("begin_site")
	for node in game.sim.state.objective:
		node.complete = true
		node.progress = float(game.sim.objective_data().required_ticks)
	game.sim.state.objective_complete = true
	force_site_clear(game)
	await capture(game, directory, "M2_TERMINAL_SITE_CLEAR")
	game.queue_free()
	await process_frame
	quit()
