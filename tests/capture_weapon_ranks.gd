extends SceneTree

var game

func _initialize(): call_deferred("capture")

func output_directory() -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="): return argument.trim_prefix("--capture-dir=")
	return "res://artifacts/weapon-ranks"

func add_enemy(id: String, position: Vector2, hp = 500.0):
	game.sim.spawn(id)
	var target = game.sim.state.enemies.back()
	target.p = position
	target.hp = hp
	target.max_hp = hp
	return target

func configure_rank(rank: int):
	game.sim.start(0, 147, "optional")
	game.sim.state.wave = 5
	game.sim.state.position = Vector2(550, 530)
	game.sim.state.weapons = [
		game.sim.make_weapon("weapon.nailer_small_mercies", rank),
		game.sim.make_weapon("weapon.bell_last_shift", rank),
		game.sim.make_weapon("weapon.procession_gear", rank),
		game.sim.make_weapon("weapon.candle_nailer", rank)
	]
	for distance in [82, 132, 182]: add_enemy("enemy.rust_pilgrim", game.sim.state.position + Vector2(distance, 0))
	add_enemy("enemy.rivet_hound", game.sim.state.position + Vector2.from_angle(0.96) * 118)
	add_enemy("enemy.scrap_mite", game.sim.state.position - Vector2(100 if rank == 3 else 80, 0))
	game.sim.update_weapons()
	game.fx.clear()
	for event in game.sim.events: game.present(event)
	game.capture_label = "FIXTURE / P15 / RANK %s" % ["I", "II", "III"][rank - 1]

func save_frame(path: String):
	game.build_ui()
	game.queue_redraw()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)
	print("CAPTURE ", path)

func capture():
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.set_physics_process(false)
	await process_frame
	game.screen = "game"
	game.debug_visible = true
	game.fixture_label = true
	game.seed_value = 147
	var output = output_directory()
	DirAccess.make_dir_recursive_absolute(output)
	for rank in [1, 2, 3]:
		configure_rank(rank)
		await save_frame(output.path_join("WEAPON_RANK_%s.png" % ["I", "II", "III"][rank - 1]))
	game.queue_free()
	await process_frame
	print("P15 rank fixtures: configured executable states, seed147, Godot %s, 1280x800; not human playtests" % Engine.get_version_info().string)
	quit()
