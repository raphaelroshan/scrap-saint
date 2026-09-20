extends SceneTree
const Sim = preload("res://game/simulation.gd")

func weapon(s, id: String, rank = 1, evolution = ""):
	var w = s.make_weapon(id, rank)
	w.evolution = evolution
	return w

func route_tick_budget(sim, site_id: String) -> int:
	var longest = 0
	for route in sim.chapter.routes:
		if site_id not in route.from_sites: continue
		longest = max(longest, int(route.wave_ticks) * int(route.wave_count) + route_tick_budget(sim, route.site_id))
	return longest

func authored_tick_budget(sim) -> int:
	return int(sim.config.wave_ticks) * int(sim.config.wave_count) + route_tick_budget(sim, "site.collapsed_workshop") + int(sim.config.tick_rate) * 30

func scenario_route(sim, scenario: Dictionary) -> String:
	return str(scenario.first_route) if sim.state.site_id == "site.collapsed_workshop" else str(scenario.terminal_route)

func choose_free_road_option(sim) -> String:
	var options = sim.current_road_node().get("choices", [])
	var affordable = options.filter(func(choice): return int(choice.cost) <= int(sim.state.scrap))
	if affordable.is_empty(): return "NO_AFFORDABLE_ROAD_OPTION"
	return sim.command("choose_road_option", affordable[-1].id)

func _initialize():
	var scenarios = [
		{"id": "MERCY_RAIL_LINE", "recipe": "evolution.mercy_rail", "support": "weapon.bell_last_shift", "first_route": "route.brass_choir", "terminal_route": "route.pale_archive"},
		{"id": "GREAT_TOLL_FIELD", "recipe": "evolution.great_toll", "support": "weapon.nailer_small_mercies", "first_route": "route.rootworks", "terminal_route": "route.red_foundry"},
		{"id": "ASHEN_MOURN_ZONE", "recipe": "evolution.ashen_benediction", "support": "weapon.nailer_small_mercies", "first_route": "route.brass_choir", "terminal_route": "route.red_foundry"},
		{"id": "LONG_HAND_CORRIDOR", "recipe": "evolution.long_hand", "support": "weapon.bell_last_shift", "first_route": "route.rootworks", "terminal_route": "route.red_foundry"},
		{"id": "HALO_REPAIR_CIRCUIT", "recipe": "evolution.halo_of_repairs", "support": "weapon.nailer_small_mercies", "first_route": "route.rootworks", "terminal_route": "route.null_assembly"},
		{"id": "UNRETURNED_EXECUTION", "recipe": "evolution.candle_unreturned", "support": "weapon.bell_last_shift", "first_route": "route.brass_choir", "terminal_route": "route.pale_archive"},
		{"id": "QUIET_SUPPORT_LANE", "recipe": "evolution.quiet_sermon", "support": "weapon.altar_mortar", "first_route": "route.brass_choir", "terminal_route": "route.red_foundry"},
		{"id": "WORKSHOP_BENEDICTION", "recipe": "evolution.workshop_benediction", "support": "weapon.bell_last_shift", "first_route": "route.rootworks", "terminal_route": "route.null_assembly"},
		{"id": "MAINTENANCE_PARADE", "recipe": "evolution.maintenance_parade", "support": "weapon.nailer_small_mercies", "first_route": "route.brass_choir", "terminal_route": "route.pale_archive"},
		{"id": "CONTRITION_LATTICE", "recipe": "evolution.contrition_lattice", "support": "weapon.altar_mortar", "first_route": "route.rootworks", "terminal_route": "route.red_foundry"}
	]
	var failed = false
	var results = []
	for scenario in scenarios:
		var sim = Sim.new()
		sim.start(0, 147, "optional")
		var recipe = sim.evolution_recipes[scenario.recipe]
		sim.state.weapons = [weapon(sim, recipe.base_item_id, 3, scenario.recipe), weapon(sim, scenario.support)]
		sim.state.evolutions = [scenario.recipe]
		sim.state.evolved = true
		var transition_failed = false
		while sim.state.phase not in ["won", "lost"] and sim.state.tick < authored_tick_budget(sim):
			if sim.state.phase == "route":
				if sim.command("choose_route", scenario_route(sim, scenario)) != "OK":
					transition_failed = true
					break
				continue
			if sim.state.phase == "travel":
				if choose_free_road_option(sim) != "OK":
					transition_failed = true
					break
				continue
			if sim.state.phase == "arrival":
				if sim.command("begin_site") != "OK": transition_failed = true; break
				continue
			if sim.state.phase == "site_clear":
				sim.command("continue_site_clear")
				continue
			if sim.state.phase == "shop":
				if sim.state.hp < sim.saint_max_structure() * 0.7: sim.command("buy", 4)
				sim.command("buy", 0)
				sim.command("continue")
				continue
			var desired = sim.state.position + Vector2.from_angle(sim.state.tick * 0.011) * 80
			if sim.is_destination() and not sim.state.objective_complete:
				for i in range(sim.state.objective.size()):
					if not sim.state.objective[i].complete:
						var node = sim.objective_data().nodes[i]
						desired = Vector2(node.position[0], node.position[1])
						break
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
		var passed = not transition_failed and sim.state.phase == "won" and sim.state.chapter_complete and sim.has_evolution(scenario.recipe) and sim.state.route_history == [scenario.first_route, scenario.terminal_route]
		failed = failed or not passed
		results.append({"id": scenario.id, "recipe": scenario.recipe, "route": sim.state.route, "route_history": sim.state.route_history, "chapter_complete": sim.state.chapter_complete, "transition_failed": transition_failed, "outcome": sim.state.phase, "seconds": sim.state.tick / 60.0, "hp": sim.state.hp, "kills": sim.state.kills, "damage": sim.state.damage})
	print(JSON.stringify(results, "  "))
	DirAccess.make_dir_recursive_absolute("res://artifacts/agent-iteration")
	var file = FileAccess.open("res://artifacts/agent-iteration/evolution_playthroughs.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(results, "  "))
	quit(1 if failed else 0)
