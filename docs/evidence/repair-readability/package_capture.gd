# External QA harness adapted from tests/capture_core_quality.gd.
# Adds capture points, runs existing non-combat lifecycle callbacks, and verifies
# the real Results action; combat policy and authoritative outcomes are unchanged.
extends SceneTree

var game
var visits = 0
var captured_phases = {}
var package_output = "user://package-native"

func _initialize(): call_deferred("capture")

func route_tick_budget(site_id: String) -> int:
	var longest = 0
	for route in game.sim.chapter.routes:
		if site_id not in route.from_sites: continue
		var route_ticks = int(route.wave_ticks) * int(route.wave_count)
		longest = max(longest, route_ticks + route_tick_budget(route.site_id))
	return longest

func authored_tick_budget() -> int:
	return int(game.sim.config.wave_ticks) * int(game.sim.config.wave_count) + route_tick_budget("site.collapsed_workshop") + int(game.sim.config.tick_rate) * 30

func policy_step(seek_repair: bool = true):
	if game.sim.state.phase == "route":
		game.sim.command("choose_route", "route.brass_choir" if game.sim.state.site_id == "site.collapsed_workshop" else "route.pale_archive")
		return
	if game.sim.state.phase == "travel":
		var free_choice = game.sim.current_road_node().choices.filter(func(choice): return int(choice.cost) == 0)[0]
		game.sim.command("choose_road_option", free_choice.id)
		return
	if game.sim.state.phase == "arrival":
		game.sim.command("begin_site")
		return
	if game.sim.state.phase == "site_clear":
		game.sim.command("continue_site_clear")
		return
	if game.sim.state.phase == "shop":
		visits += 1
		if game.sim.state.hp < 65: game.sim.command("buy", 4)
		for index in [0, 1, 2, 3]: game.sim.command("buy", index)
		game.sim.command("evolve")
		game.sim.command("reroll")
		for index in [0, 1]: game.sim.command("buy", index)
		game.sim.command("continue")
		return
	var state = game.sim.state
	var desired = game.sim.relay_position() + Vector2.from_angle(state.tick * 0.013) * 62
	var pursuing_objective = game.sim.is_destination() and not state.objective_complete
	if pursuing_objective:
		var objective_index = game.sim.active_destination_node_index()
		if objective_index >= 0:
			var node = game.sim.objective_data().nodes[objective_index]
			desired = Vector2(node.position[0], node.position[1])
	var major = state.enemies.filter(func(enemy): return enemy.major)
	if not pursuing_objective and not major.is_empty():
		desired = major[0].p + Vector2.from_angle(state.tick * 0.013) * 84
	elif seek_repair and not game.sim.is_destination() and not state.machines[0].complete:
		var data = game.sim.config.optional_repairs.machines[0]
		desired = Vector2(data.position[0], data.position[1])
	var movement = game.sim.arena.direction_to(state.position, desired, game.sim.config.saint.radius)
	for enemy in state.enemies:
		var diff = state.position - enemy.p
		if diff.length() < 72: movement += diff.normalized() * 3.0
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
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--package-output="): package_output = arg.trim_prefix("--package-output=")
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.set_physics_process(false)
	await process_frame
	game.capture_dir = package_output
	DirAccess.make_dir_recursive_absolute(game.capture_dir)
	await save_state("EXPORTED_TITLE")
	game.screen = "game"
	game.debug_visible = true
	game.capture_dir = package_output
	game.capture_label = "NATURAL POLICY TRACE"
	game.seed_value = 147
	DirAccess.make_dir_recursive_absolute(game.capture_dir)
	game.chosen = 0
	game.run_mode = "optional"
	game.begin()
	while game.sim.state.phase == "combat" and (game.sim.state.tick < 220 or game.sim.state.machines[0].progress < 50 or game.sim.state.active_machine == ""):
		policy_step()
		if game.sim.state.tick > 2000: break
	await save_state("NATURAL_REPAIR_DECISION")
	while game.sim.state.phase == "combat" and not game.sim.state.machines[0].complete:
		policy_step()
		if game.sim.state.tick > 4000: break
	await save_state("NATURAL_REPAIR_REWARD")
	while game.sim.state.phase not in ["won", "lost"] and game.sim.state.tick < authored_tick_budget():
		if game.sim.state.phase != "combat": game._physics_process(0.0)
		if game.sim.state.phase == "shop" and game.sim.state.gifts.size() == 2 and not captured_phases.has("two_gifts"):
			await save_state("EXPORTED_TWO_GIFT_SHOP")
			captured_phases["two_gifts"] = true
		var phase = str(game.sim.state.phase)
		if phase in ["shop", "site_clear", "route", "travel", "arrival"] and not captured_phases.has(phase):
			await save_state("EXPORTED_" + phase.to_upper())
			captured_phases[phase] = true
		policy_step()
	game._physics_process(0.0)
	await save_state("NATURAL_RESULTS")
	print("Core quality natural policy: seed147, Workshop Gospel, repair-seeking, normal economy, %d shops, %s" % [visits, game.sim.state.phase])
	var won = game.sim.state.phase == "won"
	if won:
		var restarted = false
		for control in game.ui.get_children():
			if control is Button and control.text == "RETURN TO THE WORKSHOP":
				control.pressed.emit()
				restarted = true
				break
		assert(restarted and game.screen == "menu")
		await create_timer(3.0).timeout
		await save_state("EXPORTED_RESTART")
		print("PACKAGED RESTART: Results button returned to setup")
	game.queue_free()
	await process_frame
	quit(0 if won else 1)
