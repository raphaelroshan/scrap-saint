extends SceneTree

func _initialize():
	call_deferred("run_capture")

func capture(game, directory: String, name: String):
	game.build_ui()
	game.queue_redraw()
	await RenderingServer.frame_post_draw
	var path = directory.path_join(name + ".png")
	get_root().get_texture().get_image().save_png(path)
	print("CHAPTER CAPTURE ", path)

func finish_travel(sim):
	while sim.state.phase == "travel": sim.command("advance_travel")

func arrive_terminal(game, parent_site: String, first_route: String, first_memory: String, terminal_route: String):
	game.sim.start(0, 147, "optional")
	game.sim.state.phase = "route"
	game.sim.state.site_id = parent_site
	game.sim.state.route_history = [first_route]
	game.sim.state.memory_ids = [first_memory]
	game.sim.state.scrap = 42
	game.sim.command("choose_route", terminal_route)
	finish_travel(game.sim)

func stage_terminal_contract(game, hp_fraction: float, phase_index: int):
	game.sim.state.wave = game.sim.current_wave_count()
	game.sim.spawn(game.sim.current_boss_id())
	var boss = game.sim.state.enemies[-1]
	boss.p = Vector2(680, 390)
	boss.hp = boss.max_hp * hp_fraction
	var phase = game.sim.bosses[boss.type].phases[phase_index]
	game.sim.state.tick = int(boss.spawn_tick) + int(phase.interval)
	game.sim.update_enemies()
	for event in game.sim.events: game.present(event)

func run_capture():
	var directory = "res://artifacts/chapter"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture-dir="): directory = arg.trim_prefix("--capture-dir=")
	DirAccess.make_dir_recursive_absolute(directory)
	var game = load("res://game/main.tscn").instantiate()
	get_root().add_child(game)
	await process_frame
	game.set_physics_process(false)
	game.capture_dir = ""
	game.fixture_label = true
	game.debug_visible = true
	game.screen = "game"
	game.sim.start(0, 147, "optional")
	game.sim.state.scrap = 42
	game.sim.state.wave = 8
	game.sim.state.boss_dead = true
	game.sim.step(Vector2.ZERO)
	await capture(game, directory, "ROUTE_CHOICE")

	game.sim.command("choose_route", "route.brass_choir")
	game.sim.command("advance_travel")
	await capture(game, directory, "TRAVEL_BRASS")
	finish_travel(game.sim)
	game.sim.state.position = Vector2(50, 170)
	game.sim.state.objective[0].progress = 92
	game.sim.spawn("enemy.choir_drone")
	game.sim.state.enemies[-1].p = Vector2(122, 170)
	await capture(game, directory, "BRASS_OBJECTIVE")
	game.sim.state.enemies.clear()
	game.sim.state.hazards.clear()
	game.sim.state.wave = game.sim.current_wave_count()
	game.sim.spawn(game.sim.current_boss_id())
	var regent = game.sim.state.enemies[-1]
	regent.p = Vector2(470, 360)
	regent.hp = regent.max_hp * 0.5
	game.sim.state.tick = int(regent.spawn_tick) + int(game.sim.bosses[regent.type].phases[1].interval)
	game.sim.update_enemies()
	for event in game.sim.events: game.present(event)
	await capture(game, directory, "CHOIR_REGENT_TOLL")

	game.sim.start(2, 147, "optional")
	game.sim.state.scrap = 42
	game.sim.state.phase = "route"
	game.sim.command("choose_route", "route.rootworks")
	finish_travel(game.sim)
	game.sim.state.position = Vector2(470, 365)
	game.sim.state.objective[0].progress = 260
	game.sim.spawn("enemy.rust_pilgrim")
	game.sim.state.enemies[-1].p = Vector2(560, 365)
	await capture(game, directory, "ROOTWORKS_OBJECTIVE")
	game.sim.state.enemies.clear()
	game.sim.state.hazards.clear()
	game.sim.state.wave = game.sim.current_wave_count()
	game.sim.spawn(game.sim.current_boss_id())
	var heart = game.sim.state.enemies[-1]
	heart.p = Vector2(680, 365)
	heart.hp = heart.max_hp * 0.5
	game.sim.state.tick = int(heart.spawn_tick) + int(game.sim.bosses[heart.type].phases[1].interval)
	game.sim.update_enemies()
	for event in game.sim.events: game.present(event)
	await capture(game, directory, "FACTORY_HEART_FEED")

	game.sim.state.objective[0].complete = true
	game.sim.state.objective_complete = true
	game.sim.state.wave = game.sim.current_wave_count()
	game.sim.state.boss_dead = true
	game.sim.step(Vector2.ZERO)
	await capture(game, directory, "CHAPTER_MEMORY")

	arrive_terminal(game, "site.brass_choir_relay", "route.brass_choir", "memory.borrowed_bell", "route.pale_archive")
	game.sim.state.evolutions = ["evolution.great_toll"]
	game.sim.state.objective[0].complete = true
	game.sim.state.objective[0].progress = game.sim.objective_data().required_ticks
	game.sim.state.position = Vector2(475, 315)
	stage_terminal_contract(game, 0.5, 1)
	await capture(game, directory, "PALE_ARCHIVE_INDEX")

	arrive_terminal(game, "site.brass_choir_relay", "route.brass_choir", "memory.borrowed_bell", "route.red_foundry")
	game.sim.state.wave_tick = int(game.sim.objective_data().active_interval)
	game.sim.state.position = Vector2(745, 325)
	stage_terminal_contract(game, 0.2, 2)
	await capture(game, directory, "RED_FOUNDRY_VENTS")

	arrive_terminal(game, "site.rootworks_pump", "route.rootworks", "memory.borrowed_arm", "route.null_assembly")
	game.sim.state.position = Vector2(210, 220)
	stage_terminal_contract(game, 0.2, 2)
	await capture(game, directory, "NULL_ASSEMBLY_QUIET")
	game.queue_free()
	await process_frame
	quit()
