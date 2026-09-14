extends SceneTree
func _initialize(): call_deferred("capture")
func capture():
	var game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.set_physics_process(false)
	await process_frame
	game.screen = "game"
	game.debug_visible = false
	game.capture_dir = "res://artifacts/variety"
	DirAccess.make_dir_recursive_absolute(game.capture_dir)
	for stage in range(3):
		game.sim.start(0,147,"optional")
		game.sim.state.wave = 5
		game.sim.state.position = [Vector2(550,530),Vector2(1050,350),Vector2(-50,650)][stage]
		var p = game.sim.state.position
		game.sim.state.weapons = [{"id": "weapon.hymn_coil" if stage == 0 else "weapon.altar_mortar", "rank": 1,"rail":false,"ready":0}]
		var ids = game.sim.config.enemies.keys()
		for i in range(ids.size()):
			game.sim.spawn(ids[i])
			game.sim.state.enemies.back().p = p + Vector2.from_angle(i * TAU / ids.size()) * 160
		game.sim.update_enemies()
		game.sim.update_weapons()
		game.fx.clear()
		for event in game.sim.events: game.present(event)
		game.build_ui()
		game.queue_redraw()
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(game.capture_dir.path_join(["BEAM","EAST_MORTAR","WEST_ROAMING"][stage] + ".png"))
	game.queue_free()
	await process_frame
	print("Variety fixtures: real simulation attacks; explicit enemy/loadout placements, seed147, 1280x800")
	quit()
