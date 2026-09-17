extends SceneTree

var game

func _initialize():
	call_deferred("capture")

func output_directory() -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="): return argument.trim_prefix("--capture-dir=")
	return "res://artifacts/game-feel"

func save_frame(filename: String, label: String):
	game.capture_label = "FIXTURE / P20 / " + label
	game.build_ui()
	game.queue_redraw()
	await RenderingServer.frame_post_draw
	var destination = output_directory().path_join(filename)
	root.get_texture().get_image().save_png(destination)
	print("CAPTURE ", destination)

func add_enemy(id: String, position: Vector2, hp = 700.0):
	game.sim.spawn(id)
	var enemy = game.sim.state.enemies.back()
	enemy.p = position
	enemy.hp = hp
	enemy.max_hp = maxf(enemy.max_hp, hp)
	return enemy

func evolved_weapon(base_id: String, evolution_id: String):
	var weapon = game.sim.make_weapon(base_id, 3)
	weapon.evolution = evolution_id
	return weapon

func configure_combat(weapons: Array, enemies: Array):
	game.reduced_fx = false
	game.evolution_showcase.clear()
	game.sim.start(0, 147, "optional")
	game.sim.state.wave = 6
	game.sim.state.tick = 900
	game.sim.state.position = Vector2(550, 500)
	game.sim.state.weapons = weapons
	game.sim.state.evolutions = weapons.map(func(weapon): return str(weapon.get("evolution", ""))).filter(func(id): return id != "")
	game.sim.state.parade_until = 1200 if "evolution.maintenance_parade" in game.sim.state.evolutions else 0
	for enemy_data in enemies: add_enemy(enemy_data[0], game.sim.state.position + enemy_data[1])
	for weapon in game.sim.state.weapons: weapon.ready = 0
	game.sim.events.clear()
	game.sim.update_weapons()
	game.fx.clear()
	game.visual_clock_override = 3000
	for event in game.sim.events: game.present(event)
	game.screen = "game"

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

	game.screen = "title"
	game.visual_clock_override = 1000
	game.title_transition_started = -1
	await save_frame("P20_MEDITATION_TITLE.png", "MEDITATION IDLE")

	game.title_transition_started = 1000
	game.visual_clock_override = 1950
	await save_frame("P20_CITY_REVEAL.png", "EYES OPEN / CITY REVEAL")

	game.title_transition_started = -1
	game.screen = "game"
	game.sim.start(0, 147, "optional")
	game.sim.state.tick = 600
	game.sim.state.position = Vector2(550, 500)
	var brute = add_enemy("enemy.forklift_brute", Vector2(720, 500))
	brute.windup = 648
	brute.charge = (game.sim.state.position - brute.p).normalized()
	var hound = add_enemy("enemy.rivet_hound", Vector2(610, 430))
	hound.relay_strike_at = 650
	game.visual_clock_override = 2200
	await save_frame("P20_ENEMY_WINDUP.png", "ENEMY WINDUP / BRACED")

	game.fx.clear()
	game.visual_clock_override = 3000
	game.present({"kind": "attack", "shape": "rail", "weapon": "weapon.nailer_small_mercies", "from": game.sim.state.position, "to": brute.p, "range": 620, "width": 19, "rank": 3, "color": "efb966", "tick": 600})
	game.present({"kind": "hit", "weapon": "weapon.nailer_small_mercies", "position": brute.p, "color": "efb966", "tick": 600})
	brute.flash = 606
	game.visual_clock_override = 3130
	await save_frame("P20_IMPACT_REACTION.png", "IMPACT / ENEMY REACTION")

	game.sim.start(0, 147, "optional")
	game.sim.enter_shop()
	game.sim.state.weapons = [game.sim.make_weapon("weapon.nailer_small_mercies", 3)]
	game.sim.state.catalysts = ["catalyst.saints_rivet"]
	game.screen = "game"
	game.visual_clock_override = 4000
	game.act("evolve", "evolution.mercy_rail")
	game.visual_clock_override = 4680
	await save_frame("P20_EVOLUTION_REVEAL.png", "PREMIUM EVOLUTION REVEAL")

	game.evolution_showcase.clear()
	game.notification = ""
	game.notice_until = 0
	game.sim.start(0, 147, "optional")
	game.sim.state.tick = 1260
	game.sim.state.position = Vector2(550, 500)
	game.screen = "game"
	game.visual_clock_override = 5200
	await save_frame("P20_LIVING_WORKSHOP.png", "LIVING WORKSHOP")

	configure_combat(
		[evolved_weapon("weapon.procession_gear", "evolution.maintenance_parade"), evolved_weapon("weapon.candle_nailer", "evolution.candle_unreturned"), evolved_weapon("weapon.hymn_coil", "evolution.quiet_sermon"), evolved_weapon("weapon.altar_mortar", "evolution.workshop_benediction")],
		[["enemy.choir_drone", Vector2(140, -22)], ["enemy.scrap_mite", Vector2(88, 0)], ["enemy.rust_pilgrim", Vector2(240, 10)], ["enemy.forklift_brute", Vector2(330, 30)]]
	)
	game.visual_clock_override = 3400
	await save_frame("P20_COMBAT_FULL.png", "FOUR-FAMILY COMBAT")
	game.reduced_fx = true
	await save_frame("P20_COMBAT_REDUCED.png", "REDUCED EFFECTS")

	game.queue_free()
	await process_frame
	print("P20 game-feel fixtures: configured executable states, seed147, Godot %s, 1280x800; not human playtests" % Engine.get_version_info().string)
	quit()
