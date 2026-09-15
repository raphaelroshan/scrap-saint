extends SceneTree
const Sim = preload("res://game/simulation.gd")

func weapon(sim, id: String, rank: int):
	return sim.make_weapon(id, rank)

func route_tick_budget(sim, site_id: String) -> int:
	var longest = 0
	for route in sim.chapter.routes:
		if site_id not in route.from_sites: continue
		longest = max(longest, int(route.wave_ticks) * int(route.wave_count) + route_tick_budget(sim, route.site_id))
	return longest

func authored_tick_budget(sim) -> int:
	return int(sim.config.wave_ticks) * int(sim.config.wave_count) + route_tick_budget(sim, "site.collapsed_workshop") + int(sim.config.tick_rate) * 30

func next_route(sim, route_path: Array) -> String:
	var route_index = sim.state.route_history.size()
	return route_path[route_index] if route_index < route_path.size() else ""

func choose_free_road_option(sim) -> String:
	var free = sim.current_road_node().get("choices", []).filter(func(choice): return int(choice.cost) == 0)
	return "NO_FREE_ROAD_OPTION" if free.is_empty() else sim.command("choose_road_option", free[0].id)

func honest_scale_purchase(sim) -> bool:
	var index = -1
	for candidate in range(4):
		if sim.state.offers[candidate] in sim.config.weapons:
			index = candidate
			break
	if index < 0: return false
	var hash_before = sim.state_hash()
	var events_before = sim.events.duplicate(true)
	var preview = sim.purchase_preview(index)
	if sim.state_hash() != hash_before or sim.events != events_before: return false
	var result = sim.command("buy", index)
	if result != preview.result: return false
	if result != "OK": return false
	var actual_combines: Array = []
	for event in sim.events.filter(func(event): return event.kind == "rank_up"):
		actual_combines.append({"weapon": event.weapon, "rank": int(event.rank)})
	return int(preview.active_count) == sim.state.weapons.size() \
		and int(preview.reserve_count) == sim.state.reserve.size() \
		and int(preview.scrap_after) == sim.state.scrap \
		and preview.combines == actual_combines

func desired_position(sim, scenario: Dictionary) -> Vector2:
	if sim.is_destination() and not sim.state.objective_complete:
		var objective_index = sim.active_destination_node_index()
		if objective_index >= 0:
			var node = sim.objective_data().nodes[objective_index]
			return Vector2(node.position[0], node.position[1])
	if scenario.gift == "gift.loose_spring" and not sim.is_destination():
		for i in range(sim.state.machines.size()):
			if not sim.state.machines[i].complete:
				var machine = sim.config.optional_repairs.machines[i]
				return Vector2(machine.position[0], machine.position[1])
	for target in sim.state.enemies:
		if target.major:
			return target.p + Vector2.from_angle(sim.state.tick * 0.013) * 92
	return sim.state.position + Vector2.from_angle(sim.state.tick * 0.011) * 80

func movement(sim, desired: Vector2) -> Vector2:
	var move = sim.arena.direction_to(sim.state.position, desired, sim.config.saint.radius)
	for target in sim.state.enemies:
		var away = sim.state.position - target.p
		if away.length() < 76: move += away.normalized() * 3.0
	for hazard in sim.state.hazards:
		var away = sim.state.position - hazard.p
		if away.length() < hazard.radius + 30: move += away.normalized() * 4.0
	return move.limit_length()

func _initialize():
	var scenarios = [
		{"id": "HONEST_SCALE_SHOP", "gift": "gift.honest_scale", "metric": "", "doctrine": 0, "route_path": ["route.brass_choir", "route.pale_archive"], "weapons": [["weapon.nailer_small_mercies", 1], ["weapon.candle_nailer", 1]]},
		{"id": "LOOSE_SPRING_REPAIR", "gift": "gift.loose_spring", "metric": "loose_spring_triggers", "doctrine": 0, "route_path": ["route.brass_choir", "route.red_foundry"], "weapons": [["weapon.nailer_small_mercies", 1], ["weapon.welded_halo", 1]]},
		{"id": "CHOIR_FILTER_QUIET", "gift": "gift.choir_filter", "metric": "choir_filter_applications", "doctrine": 2, "route_path": ["route.brass_choir", "route.pale_archive"], "weapons": [["weapon.hymn_coil", 3], ["weapon.altar_mortar", 1]]},
		{"id": "BRASS_FUSE_CONTROL", "gift": "gift.brass_fuse", "metric": "brass_fuse_triggers", "doctrine": 1, "route_path": ["route.rootworks", "route.null_assembly"], "weapons": [["weapon.bell_last_shift", 1], ["weapon.nailer_small_mercies", 1]]}
	]
	var requested = ""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--scenario="): requested = argument.trim_prefix("--scenario=")
	var failed = false
	var results: Array = []
	for scenario in scenarios:
		if requested != "" and requested != scenario.id: continue
		var sim = Sim.new()
		sim.start(int(scenario.doctrine), 147, "optional")
		sim.state.weapons = scenario.weapons.map(func(spec): return weapon(sim, spec[0], int(spec[1])))
		sim.state.gifts = [scenario.gift]
		var transition_failed = false
		var scale_exercised = false
		while sim.state.phase not in ["won", "lost"] and sim.state.tick < authored_tick_budget(sim):
			if sim.state.phase == "route":
				if sim.command("choose_route", next_route(sim, scenario.route_path)) != "OK": transition_failed = true; break
				continue
			if sim.state.phase == "travel":
				if choose_free_road_option(sim) != "OK": transition_failed = true; break
				continue
			if sim.state.phase == "memory":
				if sim.command("accept_memory") != "OK": transition_failed = true; break
				continue
			if sim.state.phase == "shop":
				if sim.state.hp < sim.saint_max_structure() * 0.7: sim.command("buy", 4)
				if scenario.gift == "gift.honest_scale" and not scale_exercised:
					scale_exercised = honest_scale_purchase(sim)
				else:
					sim.command("buy", 0)
				sim.command("continue")
				continue
			sim.step(movement(sim, desired_position(sim, scenario)))
		var metric_value = 1 if scenario.gift == "gift.honest_scale" and scale_exercised else int(sim.state.gift_metrics.get(scenario.metric, 0))
		var causal_exercised = metric_value > 0
		var passed = not transition_failed \
			and sim.state.phase == "won" \
			and sim.state.chapter_complete \
			and sim.state.route_history == scenario.route_path \
			and scenario.gift in sim.state.gifts \
			and causal_exercised
		failed = failed or not passed
		results.append({
			"id": scenario.id,
			"gift": scenario.gift,
			"route_history": sim.state.route_history,
			"outcome": sim.state.phase,
			"chapter_complete": sim.state.chapter_complete,
			"seconds": snappedf(sim.state.tick / float(sim.config.tick_rate), 0.01),
			"hp": snappedf(float(sim.state.hp), 0.1),
			"kills": sim.state.kills,
			"causal_metric": metric_value,
			"causal_exercised": causal_exercised,
			"passed": passed
		})
	print(JSON.stringify(results, "  "))
	DirAccess.make_dir_recursive_absolute("res://artifacts/agent-iteration")
	var file = FileAccess.open("res://artifacts/agent-iteration/gift_playthroughs.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(results, "  "))
	quit(1 if failed or results.size() != scenarios.size() else 0)
