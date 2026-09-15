extends SceneTree

func _initialize(): call_deferred("capture")

func save_frame(game, path: String):
	game.build_ui()
	game.queue_redraw()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)
	print("CAPTURE ", path)

func evolved_weapon(sim, base_id: String, evolution_id: String):
	var w = sim.make_weapon(base_id, 3)
	w.evolution = evolution_id
	return w

func add_enemy(sim, id: String, position: Vector2, hp = -1.0):
	sim.spawn(id)
	var target = sim.state.enemies.back()
	target.p = position
	if hp >= 0:
		target.hp = hp
		target.max_hp = maxf(target.max_hp, hp)
	return target

func capture():
	var game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.set_physics_process(false)
	await process_frame
	var output = "res://artifacts/evolutions"
	DirAccess.make_dir_recursive_absolute(output)
	game.screen = "game"
	game.debug_visible = true
	game.fixture_label = true
	game.capture_label = "FIXTURE / P15"
	game.seed_value = 147

	game.sim.start(0, 147, "optional")
	game.sim.enter_shop()
	game.sim.state.scrap = 72
	game.sim.state.shards = 6
	game.sim.state.weapons = [game.sim.make_weapon("weapon.procession_gear", 3), game.sim.make_weapon("weapon.cable_contrition", 3)]
	game.sim.state.catalysts = ["catalyst.pilgrim_spindle", "catalyst.blue_wire_from_pump"]
	game.evolution_ledger_open = true
	await save_frame(game, output.path_join("EVOLUTION_LEDGER.png"))

	game.evolution_ledger_open = false
	game.sim.start(0, 147, "optional")
	game.sim.state.wave = 5
	game.sim.state.position = Vector2(550, 530)
	game.sim.state.weapons = [
		evolved_weapon(game.sim, "weapon.foundry_censer", "evolution.ashen_benediction"),
		evolved_weapon(game.sim, "weapon.penance_winch", "evolution.long_hand"),
		evolved_weapon(game.sim, "weapon.welded_halo", "evolution.halo_of_repairs")
	]
	game.sim.state.evolutions = game.sim.state.weapons.map(func(w): return w.evolution)
	add_enemy(game.sim, "enemy.rivet_hound", game.sim.state.position + Vector2(102, 0))
	add_enemy(game.sim, "enemy.scrap_mite", game.sim.state.position - Vector2(102, 0))
	add_enemy(game.sim, "enemy.forklift_brute", game.sim.state.position + Vector2(390, 8))
	add_enemy(game.sim, "enemy.rivet_hound", game.sim.state.position + Vector2(220, 4))
	game.sim.update_weapons()
	game.fx.clear()
	for event in game.sim.events: game.present(event)
	await save_frame(game, output.path_join("EVOLVED_GEOMETRIES_A.png"))

	game.sim.start(2, 147, "optional")
	game.sim.state.wave = 7
	game.sim.state.position = Vector2(550, 530)
	game.sim.state.weapons = [
		evolved_weapon(game.sim, "weapon.candle_nailer", "evolution.candle_unreturned"),
		evolved_weapon(game.sim, "weapon.hymn_coil", "evolution.quiet_sermon"),
		evolved_weapon(game.sim, "weapon.altar_mortar", "evolution.workshop_benediction")
	]
	game.sim.state.evolutions = game.sim.state.weapons.map(func(w): return w.evolution)
	for i in range(6):
		var kind = ["enemy.choir_drone", "enemy.cinder_spitter", "enemy.rust_pilgrim"][i % 3]
		add_enemy(game.sim, kind, game.sim.state.position + Vector2(100 + i * 45, (i - 2) * 14))
	game.sim.update_weapons()
	game.fx.clear()
	for event in game.sim.events: game.present(event)
	await save_frame(game, output.path_join("EVOLVED_GEOMETRIES_B.png"))

	game.sim.start(3, 147, "optional")
	game.sim.state.wave = 6
	game.sim.state.position = Vector2(550, 530)
	game.sim.state.weapons = [
		evolved_weapon(game.sim, "weapon.procession_gear", "evolution.maintenance_parade"),
		evolved_weapon(game.sim, "weapon.cable_contrition", "evolution.contrition_lattice")
	]
	game.sim.state.evolutions = game.sim.state.weapons.map(func(w): return w.evolution)
	game.sim.state.parade_until = 240
	add_enemy(game.sim, "enemy.rivet_hound", game.sim.state.position + Vector2(72, 0))
	add_enemy(game.sim, "enemy.forklift_brute", game.sim.state.position + Vector2(270, 0))
	add_enemy(game.sim, "enemy.rivet_hound", game.sim.state.position + Vector2(150, 52))
	game.sim.update_weapons()
	game.fx.clear()
	for event in game.sim.events: game.present(event)
	await save_frame(game, output.path_join("EVOLVED_GEOMETRIES_C.png"))

	game.queue_free()
	await process_frame
	print("P15 fixtures: configured executable states, seed147, Godot %s, 1280x800; not human playtests" % Engine.get_version_info().string)
	quit()
