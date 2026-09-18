extends SceneTree

var game
var origin = Vector2(550, 500)

func _initialize(): call_deferred("capture")

func output_directory() -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="): return argument.trim_prefix("--capture-dir=")
	return "res://artifacts/manifested-relics"

func add_enemy(id: String, offset: Vector2):
	game.sim.spawn(id)
	var enemy = game.sim.state.enemies.back()
	enemy.p = origin + offset
	enemy.hp = 900
	enemy.max_hp = 900

func configure(ids: Array):
	game.reduced_fx = false
	game.sim.start(0, 147, "optional")
	game.sim.state.wave = 5
	game.sim.state.tick = 900
	game.sim.state.position = origin
	game.sim.state.weapons = ids.map(func(id): return game.sim.make_weapon(id, 3))
	game.fx.clear()
	game.screen = "game"
	game.visual_clock_override = 1000
	add_enemy("enemy.rivet_hound", Vector2(135, -55))
	add_enemy("enemy.choir_drone", Vector2(205, 0))
	add_enemy("enemy.forklift_brute", Vector2(285, 60))

func emit(weapon: String, shape: String, target: Vector2, range_value: float, width: float):
	game.present({"kind":"attack", "weapon":weapon, "shape":shape, "from":origin, "to":target, "range":range_value, "width":width, "rank":3, "color":"efcf83", "tick":900})

func save_frame(name: String, label: String, elapsed: int):
	game.capture_label = "FIXTURE / P22 / " + label
	game.visual_clock_override = 1000 + elapsed
	game.build_ui(); game.queue_redraw()
	await RenderingServer.frame_post_draw
	var path = output_directory().path_join(name)
	root.get_texture().get_image().save_png(path)
	print("CAPTURE ", path)

func capture():
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false); game.set_physics_process(false)
	await process_frame
	game.debug_visible = true; game.fixture_label = true; game.sound.muted = true
	DirAccess.make_dir_recursive_absolute(output_directory())

	configure(["weapon.bell_last_shift"])
	emit("weapon.bell_last_shift", "cone", origin + Vector2(180, 0), 155, 1.04)
	await save_frame("P22_BELL_STRIKE.png", "BELL / HAMMER STRIKE", 145)

	configure(["weapon.bell_last_shift"])
	emit("weapon.bell_last_shift", "radial", origin, 215, 0)
	await save_frame("P22_GREAT_TOLL.png", "GREAT TOLL / RADIAL", 270)

	configure(["weapon.cable_contrition"])
	emit("weapon.cable_contrition", "tether", origin + Vector2(250, 45), 250, 0.7)
	await save_frame("P22_CABLE_CLAMP.png", "CABLE / CLAMP", 190)

	configure(["weapon.foundry_censer"])
	emit("weapon.foundry_censer", "censer", origin + Vector2.RIGHT, 92, 0)
	await save_frame("P22_CENSER_VENT.png", "CENSER / FILTER VENT", 210)

	configure(["weapon.bell_last_shift", "weapon.cable_contrition", "weapon.foundry_censer"])
	emit("weapon.bell_last_shift", "cone", origin + Vector2(180, 0), 155, 1.04)
	emit("weapon.cable_contrition", "tether", origin + Vector2(250, 45), 250, 0.7)
	emit("weapon.foundry_censer", "censer", origin + Vector2.RIGHT, 92, 0)
	await save_frame("P22_THREE_RELIC_OVERLAP.png", "THREE RELIC OVERLAP", 190)
	game.reduced_fx = true
	await save_frame("P22_THREE_RELIC_REDUCED.png", "THREE RELIC / REDUCED", 190)

	game.queue_free(); await process_frame
	print("P22 manifested-relic fixtures: configured states, seed147, Godot %s, 1280x800; not human playtests" % Engine.get_version_info().string)
	quit()
