extends SceneTree

var game
var origin = Vector2(550, 500)

func _initialize():
	call_deferred("capture")

func output_directory() -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="): return argument.trim_prefix("--capture-dir=")
	return "res://artifacts/manifested-nailer"

func evolved_nailer():
	var weapon = game.sim.make_weapon("weapon.nailer_small_mercies", 3)
	weapon.evolution = "evolution.mercy_rail"
	weapon.rail = true
	return weapon

func add_enemy(id: String, offset: Vector2, hp = 800.0):
	game.sim.spawn(id)
	var enemy = game.sim.state.enemies.back()
	enemy.p = origin + offset
	enemy.hp = hp
	enemy.max_hp = maxf(enemy.max_hp, hp)
	return enemy

func configure(weapon: Dictionary):
	game.reduced_fx = false
	game.sim.start(0, 147, "optional")
	game.sim.state.wave = 5
	game.sim.state.tick = 900
	game.sim.state.position = origin
	game.sim.state.facing = Vector2.RIGHT
	game.sim.state.weapons = [weapon]
	game.sim.state.evolutions = ["evolution.mercy_rail"] if str(weapon.get("evolution", "")) != "" else []
	game.fx.clear()
	game.screen = "game"
	game.visual_clock_override = 1000
	add_enemy("enemy.rust_pilgrim", Vector2(145, 0))
	add_enemy("enemy.choir_drone", Vector2(255, 0))
	add_enemy("enemy.forklift_brute", Vector2(390, 0), 1200.0)

func emit_attack(shape: String):
	game.present({
		"kind": "attack",
		"shape": shape,
		"weapon": "weapon.nailer_small_mercies",
		"from": origin,
		"to": origin + Vector2(410 if shape == "rail" else 300, 0),
		"range": 620 if shape == "rail" else 330,
		"width": 19 if shape == "rail" else 10,
		"rank": 3,
		"color": "efb966",
		"tick": 900,
	})

func save_frame(filename: String, label: String, elapsed_ms: int):
	game.capture_label = "FIXTURE / P21 / " + label
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
	game.debug_visible = true
	game.fixture_label = true
	game.seed_value = 147
	game.sound.muted = true
	DirAccess.make_dir_recursive_absolute(output_directory())

	configure(game.sim.make_weapon("weapon.nailer_small_mercies", 3))
	game.sim.state.weapons[0].ready = game.sim.state.tick + 9
	await save_frame("P21_NAILER_PREPARE.png", "NAILER / PREPARE", 0)

	configure(game.sim.make_weapon("weapon.nailer_small_mercies", 3))
	emit_attack("line")
	await save_frame("P21_NAILER_COMMIT.png", "NAILER / COMMIT", 105)

	configure(evolved_nailer())
	emit_attack("rail")
	await save_frame("P21_MERCY_UNFOLD.png", "MERCY RAIL / UNFOLD", 125)

	game.sim.state.position = origin + Vector2(-92, 72)
	game.sim.state.facing = Vector2.LEFT
	await save_frame("P21_MERCY_MOVING_RESOLVE.png", "MERCY / RECORDED ORIGIN", 285)

	configure(evolved_nailer())
	var brute = game.sim.state.enemies[-1]
	brute.windup = 950
	brute.charge = Vector2.LEFT
	emit_attack("rail")
	await save_frame("P21_MERCY_OVERLAP.png", "MERCY / THREAT OVERLAP", 230)
	game.reduced_fx = true
	await save_frame("P21_MERCY_REDUCED.png", "MERCY / REDUCED EFFECTS", 230)

	game.queue_free()
	await process_frame
	print("P21 manifested-Nailer fixtures: configured executable states, seed147, Godot %s, 1280x800; not human playtests" % Engine.get_version_info().string)
	quit()
