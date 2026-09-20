extends SceneTree
const Sim = preload("res://game/simulation.gd")

func weapon(sim, id: String) -> Dictionary:
	return sim.make_weapon(id, 3)

func route_tick_budget(sim, site_id: String) -> int:
	var longest = 0
	for route in sim.chapter.routes:
		if site_id not in route.from_sites: continue
		longest = max(longest, int(route.wave_ticks) * int(route.wave_count) + route_tick_budget(sim, route.site_id))
	return longest

func movement(sim) -> Vector2:
	var desired = sim.relay_position() + Vector2.from_angle(sim.state.tick * 0.011) * 100
	for enemy in sim.state.enemies:
		if enemy.major:
			desired = enemy.p + Vector2.from_angle(sim.state.tick * 0.013) * 92
			break
	var move = sim.arena.direction_to(sim.state.position, desired, sim.config.saint.radius)
	for enemy in sim.state.enemies:
		var diff = sim.state.position - enemy.p
		if diff.length() < 82: move += diff.normalized() * 3.5
	for hazard in sim.state.hazards:
		var diff = sim.state.position - hazard.p
		if diff.length() < hazard.radius + 34: move += diff.normalized() * 4.5
	# This policy deliberately declines optional work instead of disabling it.
	var optional_points: Array[Vector2] = []
	if sim.is_destination():
		for node in sim.objective_data().get("nodes", []): optional_points.append(Vector2(node.position[0], node.position[1]))
	else:
		for machine in sim.config.optional_repairs.machines: optional_points.append(Vector2(machine.position[0], machine.position[1]))
	for point in optional_points:
		var diff = sim.state.position - point
		if diff.length() < 145: move += diff.normalized() * 7.0
	return move.limit_length()

func _initialize():
	var scenarios = [
		{"id": "BRASS_TO_PALE", "routes": ["route.brass_choir", "route.pale_archive"]},
		{"id": "BRASS_TO_RED", "routes": ["route.brass_choir", "route.red_foundry"]},
		{"id": "ROOTWORKS_TO_RED", "routes": ["route.rootworks", "route.red_foundry"]},
		{"id": "ROOTWORKS_TO_NULL", "routes": ["route.rootworks", "route.null_assembly"]},
	]
	var results: Array = []
	var failed = false
	for scenario in scenarios:
		var sim = Sim.new()
		sim.start(0, 147, "optional", "frame.pilgrim", "m3-%s" % str(scenario.id).to_lower())
		sim.state.weapons = [
			weapon(sim, "weapon.nailer_small_mercies"),
			weapon(sim, "weapon.bell_last_shift"),
			weapon(sim, "weapon.foundry_censer"),
			weapon(sim, "weapon.penance_winch"),
		]
		var route_index = 0
		var site_started_at = 0
		var combat_ticks: Dictionary = {}
		var boss_entry_ticks: Dictionary = {}
		var shop_counts: Dictionary = {}
		var road_decisions = 0
		var zero_scrap_continuations = 0
		var optional_completions = 0
		var transition_failed = false
		var max_ticks = int(sim.config.wave_ticks) * int(sim.config.wave_count) + route_tick_budget(sim, "site.collapsed_workshop") + int(sim.config.tick_rate) * 30
		while sim.state.phase not in ["won", "lost"] and sim.state.tick < max_ticks:
			if sim.state.phase == "site_clear":
				combat_ticks[str(sim.state.site_id)] = int(sim.state.tick) - site_started_at
				optional_completions += int(sim.state.site_clear_summary.optional_completed)
				if sim.command("continue_site_clear") != "OK": transition_failed = true; break
				continue
			if sim.state.phase == "route":
				var route_id = str(scenario.routes[route_index])
				var route = sim.routes[route_id]
				if sim.state.scrap < int(route.cost) or sim.command("choose_route", route_id) != "OK": transition_failed = true; break
				route_index += 1
				# Stress the disclosed free-road guarantee after the fare is committed.
				sim.state.scrap = 0
				continue
			if sim.state.phase == "travel":
				var free = sim.current_road_node().choices.filter(func(choice): return int(choice.cost) == 0)
				if free.is_empty() or sim.command("choose_road_option", free[0].id) != "OK": transition_failed = true; break
				road_decisions += 1
				zero_scrap_continuations += 1
				continue
			if sim.state.phase == "arrival":
				var arrival_hash = sim.state_hash()
				sim.step(Vector2.RIGHT)
				if sim.state_hash() != arrival_hash or sim.command("begin_site") != "OK": transition_failed = true; break
				site_started_at = int(sim.state.tick)
				continue
			if sim.state.phase == "shop":
				var site_key = str(sim.state.site_id)
				shop_counts[site_key] = int(shop_counts.get(site_key, 0)) + 1
				if sim.command("continue") != "OK": transition_failed = true; break
				continue
			var before_boss = bool(sim.state.boss_spawned)
			sim.step(movement(sim))
			if not before_boss and sim.state.boss_spawned:
				boss_entry_ticks[str(sim.state.site_id)] = int(sim.state.tick) - site_started_at
		var passed = not transition_failed and sim.state.phase == "won" and sim.state.chapter_complete \
			and sim.state.route_history == scenario.routes and sim.state.evolutions.is_empty() \
			and optional_completions == 0 and zero_scrap_continuations == 4
		failed = failed or not passed
		var combat_seconds: Dictionary = {}
		for site_id in combat_ticks: combat_seconds[site_id] = snappedf(float(combat_ticks[site_id]) / float(sim.config.tick_rate), 0.01)
		results.append({
			"id": scenario.id,
			"simulation_speed": "1x fixed tick",
			"route_history": sim.state.route_history.duplicate(),
			"outcome": sim.state.phase,
			"passed": passed,
			"combat_ticks_by_site": combat_ticks,
			"combat_seconds_by_site": combat_seconds,
			"boss_entry_ticks_by_site": boss_entry_ticks,
			"shop_count_by_site": shop_counts,
			"road_decisions": road_decisions,
			"zero_scrap_continuations": zero_scrap_continuations,
			"optional_work_completed": optional_completions,
			"evolutions": sim.state.evolutions.duplicate(),
			"weapons": sim.state.weapons.map(func(owned): return {"id": owned.id, "rank": owned.rank}),
			"remaining_structure": sim.state.hp,
			"human_confusion": "NOT_MEASURED",
			"human_boss_readability": "NOT_MEASURED",
		})
	print(JSON.stringify(results, "  "))
	DirAccess.make_dir_recursive_absolute("res://artifacts/agent-iteration")
	var file = FileAccess.open("res://artifacts/agent-iteration/m3_four_path_pacing.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(results, "  "))
	quit(1 if failed else 0)
