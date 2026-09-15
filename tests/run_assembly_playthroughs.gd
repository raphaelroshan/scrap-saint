extends SceneTree
const Sim = preload("res://game/simulation.gd")

func choose_road(sim):
	var options = sim.current_road_node().get("choices", [])
	var affordable = options.filter(func(choice): return int(choice.cost) <= int(sim.state.scrap))
	if not affordable.is_empty(): sim.command("choose_road_option", affordable[-1].id)

func weapon(id: String, rank = 1, toll = false):
	return {"id": id, "rank": rank, "rail": false, "toll": toll, "ready": 0}

func route_tick_budget(sim, site_id: String) -> int:
	var longest = 0
	for route in sim.chapter.routes:
		if site_id not in route.from_sites: continue
		var route_ticks = int(route.wave_ticks) * int(route.wave_count)
		longest = max(longest, route_ticks + route_tick_budget(sim, route.site_id))
	return longest

func authored_tick_budget(sim) -> int:
	return int(sim.config.wave_ticks) * int(sim.config.wave_count) + route_tick_budget(sim, "site.collapsed_workshop") + int(sim.config.tick_rate) * 30

func next_route(sim, route_path: Array) -> String:
	var route_index = sim.state.route_history.size()
	return route_path[route_index] if route_index < route_path.size() else ""

func _initialize():
	var scenarios = [
		{"id": "CENSER_CLOSE_CONTROL", "doctrine": 0, "route_path": ["route.brass_choir", "route.pale_archive"], "weapons": [weapon("weapon.nailer_small_mercies"), weapon("weapon.foundry_censer")], "gifts": []},
		{"id": "WINCH_PRIORITY_CONTROL", "doctrine": 1, "route_path": ["route.rootworks", "route.null_assembly"], "weapons": [weapon("weapon.bell_last_shift"), weapon("weapon.penance_winch")], "gifts": []},
		{"id": "HALO_REPAIR_ROAMING", "doctrine": 0, "route_path": ["route.brass_choir", "route.red_foundry"], "weapons": [weapon("weapon.nailer_small_mercies"), weapon("weapon.welded_halo")], "gifts": ["gift.spare_hand"]},
		{"id": "GREAT_TOLL_INFORMATION", "doctrine": 1, "route_path": ["route.rootworks", "route.red_foundry"], "weapons": [weapon("weapon.bell_last_shift", 3, true), weapon("weapon.altar_mortar")], "gifts": ["gift.inspection_lens", "gift.black_ledger"]}
	]
	var failed = false
	var results = []
	var requested = ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--scenario="): requested = arg.trim_prefix("--scenario=")
	for scenario in scenarios:
		if requested != "" and scenario.id != requested: continue
		var sim = Sim.new()
		sim.start(scenario.doctrine, 147, "optional")
		sim.state.weapons = scenario.weapons.duplicate(true)
		sim.state.gifts = scenario.gifts.duplicate()
		if sim.state.weapons.any(func(w): return w.get("toll", false)):
			sim.state.evolutions = ["evolution.great_toll"]
			sim.state.evolved = true
		var max_ticks = authored_tick_budget(sim)
		while sim.state.phase not in ["won", "lost"] and sim.state.tick < max_ticks:
			if sim.state.phase == "route":
				sim.command("choose_route", next_route(sim, scenario.route_path))
				continue
			if sim.state.phase == "travel":
				choose_road(sim)
				continue
			if sim.state.phase == "memory":
				sim.command("accept_memory")
				continue
			if sim.state.phase == "shop":
				if sim.state.hp < 70: sim.command("buy", 4)
				# A bounded natural policy improves the current build, then considers one new direction.
				sim.command("buy", 0)
				if sim.state.weapons.size() + sim.state.reserve.size() < 4: sim.command("buy", 1)
				sim.command("continue")
			var desired = sim.state.position + Vector2.from_angle(sim.state.tick * 0.011) * 80
			var pursuing_objective = sim.is_destination() and not sim.state.objective_complete
			if pursuing_objective:
				var objective_index = sim.active_destination_node_index()
				if objective_index >= 0:
					var node = sim.objective_data().nodes[objective_index]
					desired = Vector2(node.position[0], node.position[1])
			if not pursuing_objective:
				for enemy in sim.state.enemies:
					if enemy.major:
						desired = enemy.p + Vector2.from_angle(sim.state.tick * 0.013) * 92
						break
			var move = sim.arena.direction_to(sim.state.position, desired, sim.config.saint.radius)
			for enemy in sim.state.enemies:
				var diff = sim.state.position - enemy.p
				if diff.length() < 76: move += diff.normalized() * 3.0
			for hazard in sim.state.hazards:
				var diff = sim.state.position - hazard.p
				if diff.length() < hazard.radius + 30: move += diff.normalized() * 4.0
			sim.step(move.limit_length())
		failed = failed or sim.state.phase != "won"
		results.append({"id": scenario.id, "route": sim.state.route, "route_history": sim.state.route_history, "chapter_complete": sim.state.chapter_complete, "outcome": sim.state.phase, "wave": sim.state.wave, "seconds": sim.state.tick / 60.0, "hp": sim.state.hp, "kills": sim.state.kills, "repairs": sim.state.machines.filter(func(m): return m.complete).size(), "damage": sim.state.damage, "gifts": sim.state.gifts, "evolutions": sim.state.evolutions})
	print(JSON.stringify(results, "  "))
	DirAccess.make_dir_recursive_absolute("res://artifacts/agent-iteration")
	var file = FileAccess.open("res://artifacts/agent-iteration/assembly_playthroughs.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(results, "  "))
	quit(1 if failed else 0)
