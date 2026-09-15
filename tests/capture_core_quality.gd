extends SceneTree

var game
var visits = 0

func _initialize(): call_deferred("capture")

func policy_step(seek_repair: bool = true):
	if game.sim.state.phase == "shop":
		visits += 1
		if game.sim.state.hp < 65: game.sim.command("buy", 4)
		for index in [0, 1, 2, 3]: game.sim.command("buy", index)
		game.sim.command("reroll")
		for index in [0, 1]: game.sim.command("buy", index)
		game.sim.command("continue")
		return
	var state = game.sim.state
	var desired = game.sim.relay_position() + Vector2.from_angle(state.tick * 0.013) * 62
	var major = state.enemies.filter(func(enemy): return enemy.major)
	if not major.is_empty():
		desired = major[0].p + Vector2.from_angle(state.tick * 0.013) * 84
	elif seek_repair and not state.machines[0].complete:
		var data = game.sim.config.optional_repairs.machines[0]
		desired = Vector2(data.position[0], data.position[1])
	var movement = game.sim.arena.direction_to(state.position, desired, game.sim.config.saint.radius)
	for enemy in state.enemies:
		var diff = state.position - enemy.p
		if diff.length() < 62: movement += diff.normalized() * 2.4
	for hazard in state.hazards:
		var diff = state.position - hazard.p
		if diff.length() < hazard.radius + 28: movement += diff.normalized() * 4.0
	game.fx.clear()
	game.sim.step(movement.limit_length())
	for event in game.sim.events: game.present(event)

func save_state(name: String):
	game.build_ui()
	game.queue_redraw()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(game.capture_dir.path_join(name + ".png"))

func capture():
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.set_physics_process(false)
	await process_frame
	game.screen = "game"
	game.debug_visible = true
	game.capture_dir = "res://artifacts/core-quality"
	game.capture_label = "NATURAL POLICY TRACE"
	game.seed_value = 147
	DirAccess.make_dir_recursive_absolute(game.capture_dir)
	game.sim.start(0, 147, "optional")
	while game.sim.state.phase == "combat" and (game.sim.state.tick < 220 or game.sim.state.machines[0].progress < 50 or game.sim.state.active_machine == ""):
		policy_step()
		if game.sim.state.tick > 2000: break
	await save_state("NATURAL_REPAIR_DECISION")
	while game.sim.state.phase == "combat" and not game.sim.state.machines[0].complete:
		policy_step()
		if game.sim.state.tick > 4000: break
	await save_state("NATURAL_REPAIR_REWARD")
	while game.sim.state.phase not in ["won", "lost"] and game.sim.state.tick < game.sim.config.wave_ticks * game.sim.config.wave_count + 60:
		policy_step()
	await save_state("NATURAL_RESULTS")
	print("Core quality natural policy: seed147, Workshop Gospel, repair-seeking, normal economy, %d shops, %s" % [visits, game.sim.state.phase])
	var won = game.sim.state.phase == "won"
	game.queue_free()
	await process_frame
	quit(0 if won else 1)
