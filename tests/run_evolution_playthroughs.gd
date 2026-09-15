extends SceneTree
const Sim = preload("res://game/simulation.gd")

func weapon(s, id: String, rank = 1, evolution = ""):
	var w = s.make_weapon(id, rank)
	w.evolution = evolution
	return w

func _initialize():
	var scenarios = [
		{"id": "ASHEN_MOURN_ZONE", "recipe": "evolution.ashen_benediction", "support": "weapon.nailer_small_mercies", "route": "route.brass_choir"},
		{"id": "LONG_HAND_CORRIDOR", "recipe": "evolution.long_hand", "support": "weapon.bell_last_shift", "route": "route.rootworks"},
		{"id": "HALO_REPAIR_CIRCUIT", "recipe": "evolution.halo_of_repairs", "support": "weapon.nailer_small_mercies", "route": "route.rootworks"},
		{"id": "UNRETURNED_EXECUTION", "recipe": "evolution.candle_unreturned", "support": "weapon.bell_last_shift", "route": "route.brass_choir"},
		{"id": "QUIET_SUPPORT_LANE", "recipe": "evolution.quiet_sermon", "support": "weapon.altar_mortar", "route": "route.brass_choir"},
		{"id": "WORKSHOP_BENEDICTION", "recipe": "evolution.workshop_benediction", "support": "weapon.bell_last_shift", "route": "route.rootworks"}
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
		while sim.state.phase not in ["won", "lost"] and sim.state.tick < sim.config.wave_ticks * sim.config.wave_count + 18000:
			if sim.state.phase == "route":
				sim.command("choose_route", scenario.route)
				continue
			if sim.state.phase == "travel":
				sim.command("advance_travel")
				continue
			if sim.state.phase == "memory":
				sim.command("accept_memory")
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
		var passed = sim.state.phase == "won" and sim.state.chapter_complete and sim.has_evolution(scenario.recipe)
		failed = failed or not passed
		results.append({"id": scenario.id, "recipe": scenario.recipe, "route": sim.state.route, "chapter_complete": sim.state.chapter_complete, "outcome": sim.state.phase, "seconds": sim.state.tick / 60.0, "hp": sim.state.hp, "kills": sim.state.kills, "damage": sim.state.damage})
	print(JSON.stringify(results, "  "))
	DirAccess.make_dir_recursive_absolute("res://artifacts/agent-iteration")
	var file = FileAccess.open("res://artifacts/agent-iteration/evolution_playthroughs.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(results, "  "))
	quit(1 if failed else 0)
