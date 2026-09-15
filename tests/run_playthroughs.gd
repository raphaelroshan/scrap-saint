extends SceneTree
const Sim = preload("res://game/simulation.gd")

func route_tick_budget(sim, site_id: String) -> int:
	var longest = 0
	for route in sim.chapter.routes:
		if site_id not in route.from_sites: continue
		var route_ticks = int(route.wave_ticks) * int(route.wave_count)
		longest = max(longest, route_ticks + route_tick_budget(sim, route.site_id))
	return longest

func authored_tick_budget(sim) -> int:
	return int(sim.config.wave_ticks) * int(sim.config.wave_count) + route_tick_budget(sim, "site.collapsed_workshop") + int(sim.config.tick_rate) * 30

func policy_route(sim, first_route: String, variant: int) -> String:
	if sim.state.site_id == "site.collapsed_workshop": return first_route
	if sim.state.site_id == "site.brass_choir_relay": return "route.pale_archive" if variant % 2 == 0 else "route.red_foundry"
	if sim.state.site_id == "site.rootworks_pump": return "route.red_foundry" if variant % 2 == 0 else "route.null_assembly"
	return ""

func choose_road(sim):
	var options = sim.current_road_node().get("choices", [])
	var affordable = options.filter(func(choice): return int(choice.cost) <= int(sim.state.scrap))
	if not affordable.is_empty(): sim.command("choose_road_option", affordable[-1].id)

func _initialize():
	var results = []
	var args = OS.get_cmdline_user_args()
	var optional = "--optional" in args
	var scenarios: Array = []
	if "--ea-matrix" in args:
		for frame_id in ["frame.pilgrim", "frame.surveyor", "frame.keeper"]:
			for doctrine in range(4):
				for route_id in ["route.brass_choir", "route.rootworks"]:
					scenarios.append({"variant": doctrine, "seed": 147, "doctrine": doctrine, "frame_id": frame_id, "route_id": route_id})
	else:
		var run_count = 2 if "--quick" in args else 12
		for run_index in range(run_count):
			var variant = run_index % 4
			scenarios.append({"variant": variant, "seed": [147, 104729, 104730][int(run_index / 4)], "doctrine": variant % 3, "frame_id": "frame.pilgrim", "route_id": "route.brass_choir" if variant < 2 else "route.rootworks"})
	for arg in args:
		if arg.begins_with("--frame="):
			var frame_filter = arg.trim_prefix("--frame=")
			scenarios = scenarios.filter(func(scenario): return scenario.frame_id == frame_filter)
		elif arg.begins_with("--doctrine="):
			var doctrine_filter = int(arg.trim_prefix("--doctrine="))
			scenarios = scenarios.filter(func(scenario): return int(scenario.doctrine) == doctrine_filter)
		elif arg.begins_with("--route="):
			var route_filter = arg.trim_prefix("--route=")
			scenarios = scenarios.filter(func(scenario): return scenario.route_id == route_filter)
	var unfinished = false
	for scenario in scenarios:
		var variant = int(scenario.variant)
		var seed_value = int(scenario.seed)
		var doctrine = int(scenario.doctrine)
		var sim = Sim.new()
		sim.start(doctrine, seed_value, "optional" if optional else "relay", scenario.frame_id)
		var visits = 0
		var policy_name = ["evolution", "survival", "mourner", "repair_explorer"][variant]
		var max_ticks = authored_tick_budget(sim)
		while sim.state.phase not in ["won", "lost"] and sim.state.tick < max_ticks:
			if sim.state.phase == "route":
				sim.command("choose_route", policy_route(sim, scenario.route_id, variant))
				continue
			if sim.state.phase == "travel":
				choose_road(sim)
				continue
			if sim.state.phase == "memory":
				sim.command("accept_memory")
				continue
			if sim.state.phase == "shop":
				visits += 1
				if sim.state.hp < 65 or sim.state.relay_hp < 110: sim.command("buy", 4)
				for index in [0, 1, 2, 3]: sim.command("buy", index)
				if variant == 0: sim.command("evolve")
				sim.command("reroll")
				for index in [0, 1]: sim.command("buy", index)
				sim.command("continue")
			var s = sim.state
			var desired = sim.relay_position() + Vector2.from_angle(s.tick * 0.013) * 62
			var pursuing_objective = sim.is_destination() and not s.objective_complete
			if pursuing_objective:
				var objective_index = sim.active_destination_node_index()
				if objective_index >= 0:
					var node = sim.objective_data().nodes[objective_index]
					desired = Vector2(node.position[0], node.position[1])
			# Shared policy: intercept attackers at the relay rather than orbiting blindly.
			var nearest_threat = 170.0
			if not pursuing_objective:
				for enemy in s.enemies:
					var distance = enemy.p.distance_to(sim.relay_position())
					if not enemy.major and distance < nearest_threat:
						nearest_threat = distance
						desired = enemy.p.lerp(sim.relay_position(), 0.35)
			if not pursuing_objective and (optional or s.progress >= sim.config.relay.required_ticks):
				for enemy in s.enemies:
					if enemy.major:
						desired = enemy.p + Vector2.from_angle(s.tick * 0.013) * 84
						break
			if optional and not sim.is_destination() and variant == 3 and not s.machines[0].complete and not s.enemies.any(func(enemy): return enemy.major):
				var repair_data = sim.config.optional_repairs.machines[0]
				desired = Vector2(repair_data.position[0], repair_data.position[1])
			var move = sim.arena.direction_to(s.position, desired, sim.config.saint.radius)
			for enemy in s.enemies:
				var diff = s.position - enemy.p
				if diff.length() < 72: move += diff.normalized() * 3.0
			for hazard in s.hazards:
				var diff = s.position - hazard.p
				if diff.length() < hazard.radius + 28: move += diff.normalized() * 4.0
			sim.step(move.limit_length())
		unfinished = unfinished or sim.state.phase != "won"
		results.append({"mode": sim.state.mode, "frame_id": sim.state.frame_id, "route": sim.state.route, "route_history": sim.state.route_history, "chapter_complete": sim.state.chapter_complete, "objective": sim.state.objective, "policy": policy_name, "repairs_completed": sim.state.machines.filter(func(m): return m.complete).size(), "repair_metrics": sim.state.metrics, "seed": seed_value, "backup_absorbed": sim.state.backup_absorbed, "relay_damage_sources": sim.state.relay_damage_sources, "damage_taken": sim.state.damage_taken, "damage_by_wave": sim.state.damage_by_wave, "weapon_damage": sim.state.damage, "weapon_kills": sim.state.kills_by_weapon, "weapon_ranks": sim.state.weapons.map(func(w): return {"id": w.id, "rank": w.rank, "evolved": sim.weapon_evolution_id(w).trim_prefix("evolution.")}), "gifts": sim.state.gifts.duplicate(), "scrap_sources": sim.state.scrap_sources, "transactions": sim.state.transactions, "doctrine": doctrine, "evolution_policy": variant == 0, "outcome": sim.state.phase, "wave": sim.state.wave, "seconds": sim.state.tick / 60.0, "hp": sim.state.hp, "relay": sim.state.relay_hp, "progress": sim.state.progress / sim.config.relay.required_ticks, "kills": sim.state.kills, "shops": visits, "reason": sim.state.last_reason, "result_summary": sim.state.result_summary})
	print(JSON.stringify(results, "  "))
	DirAccess.make_dir_recursive_absolute("res://artifacts/agent-iteration")
	var output_name = "ea_matrix.json" if "--ea-matrix" in args else ("optional_playthroughs.json" if optional else "playthroughs.json")
	var file = FileAccess.open("res://artifacts/agent-iteration/" + output_name, FileAccess.WRITE)
	file.store_string(JSON.stringify(results, "  "))
	quit(1 if unfinished else 0)
