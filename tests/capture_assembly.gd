extends SceneTree

func _initialize(): call_deferred("capture")

func save_frame(game, path: String):
	game.build_ui()
	game.queue_redraw()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)
	print("CAPTURE ", path)

func weapon(id: String, rank = 1, toll = false):
	return {"id": id, "rank": rank, "rail": false, "toll": toll, "ready": 0}

func capture():
	var game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.set_physics_process(false)
	await process_frame
	var output = "res://artifacts/assembly"
	DirAccess.make_dir_recursive_absolute(output)
	game.screen = "game"
	game.debug_visible = true
	game.seed_value = 147
	game.sim.start(0, 147, "optional")
	game.sim.state.wave = 5
	game.sim.state.position = Vector2(550, 530)
	game.sim.state.weapons = [weapon("weapon.foundry_censer"), weapon("weapon.penance_winch"), weapon("weapon.welded_halo")]
	for i in range(6):
		game.sim.spawn(game.sim.config.enemies.keys()[i])
		game.sim.state.enemies.back().p = game.sim.state.position + Vector2.from_angle(i * TAU / 6.0) * (70 + i * 35)
	game.sim.state.enemies[4].relay_strike_at = game.sim.state.tick + 50
	game.sim.update_weapons()
	game.fx.clear()
	for event in game.sim.events: game.present(event)
	await save_frame(game, output.path_join("P14_EXPANSION_A.png"))

	game.sim.start(1, 147, "optional")
	game.sim.state.position = Vector2(550, 530)
	game.sim.state.weapons = [weapon("weapon.bell_last_shift", 3, true)]
	for i in range(8):
		game.sim.spawn("enemy.rivet_hound")
		game.sim.state.enemies.back().p = game.sim.state.position + Vector2.from_angle(i * TAU / 8.0) * 145
	game.sim.update_weapons()
	game.fx.clear()
	for event in game.sim.events: game.present(event)
	await save_frame(game, output.path_join("P14_GREAT_TOLL.png"))

	game.sim.start(0, 147, "optional")
	game.sim.enter_shop()
	game.sim.state.scrap = 46
	game.sim.state.gifts = ["gift.spare_hand", "gift.inspection_lens"]
	game.sim.state.component_tag = "labour"
	game.sim.state.offers = ["weapon.welded_halo", "weapon.penance_winch", "catalyst.cracked_bell_clapper", "gift.black_ledger", "gift.spare_hand", "service.doctrine"]
	await save_frame(game, output.path_join("P14_GIFTS.png"))

	game.queue_free()
	await process_frame
	print("Assembly fixtures: configured executable states, seed147, Godot renderer, 1280x800; not human playtests")
	quit()
