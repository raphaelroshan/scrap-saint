extends SceneTree

var game

func _initialize():
	call_deferred("capture")

func output_directory() -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="): return argument.trim_prefix("--capture-dir=")
	return "res://artifacts/weapon-animation"

func evolved_weapon(base_id: String, evolution_id: String):
	var weapon = game.sim.make_weapon(base_id, 3)
	weapon.evolution = evolution_id
	weapon.rail = evolution_id == "evolution.mercy_rail"
	weapon.toll = evolution_id == "evolution.great_toll"
	return weapon

func add_enemy(id: String, position: Vector2, hp = 500.0):
	game.sim.spawn(id)
	var enemy = game.sim.state.enemies.back()
	enemy.p = position
	enemy.hp = hp
	enemy.max_hp = maxf(enemy.max_hp, hp)
	return enemy

func configure(weapons: Array, enemies: Array):
	game.sim.start(0, 147, "optional")
	game.sim.state.wave = 5
	game.sim.state.position = Vector2(550, 500)
	game.sim.state.weapons = weapons
	game.sim.state.evolutions = weapons.map(func(weapon): return str(weapon.get("evolution", ""))).filter(func(id): return id != "")
	game.sim.state.evolved = not game.sim.state.evolutions.is_empty()
	for enemy_data in enemies:
		add_enemy(enemy_data[0], game.sim.state.position + enemy_data[1])
	game.sim.events.clear()
	game.sim.update_weapons()
	game.fx.clear()
	game.visual_clock_override = 1000
	for event in game.sim.events: game.present(event)

func save_frame(filename: String, label: String, elapsed_ms: int):
	game.capture_label = "FIXTURE / P18 / " + label
	game.visual_clock_override = 1000 + elapsed_ms
	game.build_ui()
	game.queue_redraw()
	await RenderingServer.frame_post_draw
	var destination = output_directory().path_join(filename)
	root.get_texture().get_image().save_png(destination)
	print("CAPTURE ", destination)

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
	game.sound.muted = true
	DirAccess.make_dir_recursive_absolute(output_directory())

	configure(
		[game.sim.make_weapon("weapon.nailer_small_mercies", 3)],
		[["enemy.rust_pilgrim", Vector2(125, 0)], ["enemy.choir_drone", Vector2(220, 0)], ["enemy.rivet_hound", Vector2(305, 0)]]
	)
	await save_frame("P18_NAILER_COMMIT.png", "NAILER COMMIT", 110)

	configure(
		[evolved_weapon("weapon.nailer_small_mercies", "evolution.mercy_rail")],
		[["enemy.rust_pilgrim", Vector2(130, 0)], ["enemy.choir_drone", Vector2(240, 0)], ["enemy.forklift_brute", Vector2(365, 0)]]
	)
	await save_frame("P18_MERCY_RAIL_RESOLVE.png", "MERCY RAIL RESOLVE", 290)

	configure(
		[game.sim.make_weapon("weapon.bell_last_shift", 3)],
		[["enemy.rivet_hound", Vector2.from_angle(-0.42) * 115], ["enemy.scrap_mite", Vector2(130, 0)], ["enemy.rivet_hound", Vector2.from_angle(0.42) * 115]]
	)
	await save_frame("P18_BELL_COMMIT.png", "BELL COMMIT", 145)

	configure(
		[evolved_weapon("weapon.bell_last_shift", "evolution.great_toll")],
		[["enemy.rivet_hound", Vector2(125, 0)], ["enemy.scrap_mite", Vector2(-125, 0)], ["enemy.choir_drone", Vector2(0, -125)], ["enemy.forklift_brute", Vector2(0, 125)]]
	)
	await save_frame("P18_GREAT_TOLL_RESOLVE.png", "GREAT TOLL RESOLVE", 335)

	configure(
		[game.sim.make_weapon("weapon.nailer_small_mercies", 3), game.sim.make_weapon("weapon.bell_last_shift", 3)],
		[["enemy.rust_pilgrim", Vector2(120, 0)], ["enemy.choir_drone", Vector2(225, 0)], ["enemy.rivet_hound", Vector2.from_angle(-0.55) * 115], ["enemy.scrap_mite", Vector2.from_angle(0.55) * 125]]
	)
	await save_frame("P18_NAILER_BELL_OVERLAP.png", "NAILER + BELL OVERLAP", 185)
	game.reduced_fx = true
	await save_frame("P18_REDUCED_OVERLAP.png", "REDUCED FX OVERLAP", 185)

	game.queue_free()
	await process_frame
	print("P18 weapon-animation fixtures: configured executable states, seed147, Godot %s, 1280x800; not human playtests" % Engine.get_version_info().string)
	quit()
