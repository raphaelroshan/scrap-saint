extends SceneTree

var game
var origin = Vector2(550, 500)

func _initialize(): call_deferred("capture")

func output_directory() -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="): return argument.trim_prefix("--capture-dir=")
	return "res://artifacts/remaining-manifested-relics"

func evolved_weapon(base_id: String, evolution_id: String) -> Dictionary:
	var weapon = game.sim.make_weapon(base_id, 3)
	weapon.evolution = evolution_id
	return weapon

func add_enemy(id: String, offset: Vector2):
	game.sim.spawn(id)
	var enemy = game.sim.state.enemies.back()
	enemy.p = origin + offset
	enemy.hp = 900
	enemy.max_hp = 900

func configure(weapons: Array):
	game.reduced_fx = false
	game.sim.start(0, 147, "optional")
	game.sim.state.wave = 5
	game.sim.state.tick = 900
	game.sim.state.position = origin
	game.sim.state.weapons = weapons
	game.sim.state.evolutions = weapons.map(func(weapon): return str(weapon.get("evolution", ""))).filter(func(id): return id != "")
	game.fx.clear()
	game.screen = "game"
	game.visual_clock_override = 1000
	add_enemy("enemy.rivet_hound", Vector2(145, -70))
	add_enemy("enemy.choir_drone", Vector2(210, 5))
	add_enemy("enemy.forklift_brute", Vector2(285, 70))

func emit(weapon: String, shape: String, target: Vector2, range_value: float, width: float, extra = {}):
	var event = {"kind":"attack", "weapon":weapon, "shape":shape, "from":origin, "to":target, "range":range_value, "width":width, "rank":3, "color":str(game.sim.config.weapons[weapon].color), "tick":900}
	event.merge(extra, true)
	game.present(event)

func save_frame(name: String, label: String, elapsed: int):
	game.capture_label = "FIXTURE / P23 / " + label
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

	configure([game.sim.make_weapon("weapon.candle_nailer", 3)])
	emit("weapon.candle_nailer", "shot", origin + Vector2(225, -20), 225, 0)
	await save_frame("P23_CANDLE_NAILER.png", "CANDLE-NAILER / WICK LAUNCH", 170)

	configure([evolved_weapon("weapon.candle_nailer", "evolution.candle_unreturned")])
	emit("weapon.candle_nailer", "funeral_shots", origin + Vector2(225, -20), 225, 0, {"targets":[origin + Vector2(145, -70), origin + Vector2(210, 5), origin + Vector2(285, 70)]})
	await save_frame("P23_CANDLE_UNRETURNED.png", "UNRETURNED / THREE WICKS", 260)

	configure([game.sim.make_weapon("weapon.hymn_coil", 3)])
	emit("weapon.hymn_coil", "beam", origin + Vector2(250, -35), 250, 7)
	await save_frame("P23_HYMN_COIL.png", "HYMN COIL / TUNED BEAM", 130)

	configure([evolved_weapon("weapon.hymn_coil", "evolution.quiet_sermon")])
	emit("weapon.hymn_coil", "sermon", origin + Vector2(250, -35), 250, 18)
	await save_frame("P23_QUIET_SERMON.png", "QUIET SERMON / WIDE LANES", 225)

	configure([game.sim.make_weapon("weapon.altar_mortar", 3)])
	emit("weapon.altar_mortar", "blast", origin + Vector2(245, 55), 58, 0)
	await save_frame("P23_ALTAR_MORTAR.png", "ALTAR MORTAR / SHELL ARC", 320)

	configure([evolved_weapon("weapon.altar_mortar", "evolution.workshop_benediction")])
	emit("weapon.altar_mortar", "benediction", origin + Vector2(245, 55), 78, 0)
	await save_frame("P23_WORKSHOP_BENEDICTION.png", "BENEDICTION / GROUND SEAL", 520)

	configure([game.sim.make_weapon("weapon.penance_winch", 3)])
	emit("weapon.penance_winch", "winch", origin + Vector2(235, 35), 235, 0)
	await save_frame("P23_PENANCE_WINCH.png", "PENANCE WINCH / DRUM", 250)

	configure([evolved_weapon("weapon.penance_winch", "evolution.long_hand")])
	emit("weapon.penance_winch", "long_hand", origin + Vector2(275, 35), 275, 0)
	await save_frame("P23_LONG_HAND.png", "LONG HAND / HEAVY REACH", 310)

	configure([
		evolved_weapon("weapon.candle_nailer", "evolution.candle_unreturned"),
		evolved_weapon("weapon.hymn_coil", "evolution.quiet_sermon"),
		evolved_weapon("weapon.altar_mortar", "evolution.workshop_benediction"),
		evolved_weapon("weapon.penance_winch", "evolution.long_hand"),
	])
	emit("weapon.candle_nailer", "funeral_shots", origin + Vector2(220, -85), 236, 0, {"targets":[origin + Vector2(145, -70), origin + Vector2(210, 5), origin + Vector2(285, 70)]})
	emit("weapon.hymn_coil", "sermon", origin + Vector2(230, 100), 250, 18)
	emit("weapon.altar_mortar", "benediction", origin + Vector2(-210, 90), 78, 0)
	emit("weapon.penance_winch", "long_hand", origin + Vector2(-235, -90), 252, 0)
	await save_frame("P23_FOUR_RELIC_OVERLAP.png", "FOUR RELIC OVERLAP", 240)
	game.reduced_fx = true
	await save_frame("P23_FOUR_RELIC_REDUCED.png", "FOUR RELIC / REDUCED", 240)

	game.queue_free(); await process_frame
	print("P23 remaining-manifested-relic fixtures: configured states, seed147, Godot %s, 1280x800; not human playtests" % Engine.get_version_info().string)
	quit()
