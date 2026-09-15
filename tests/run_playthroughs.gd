extends SceneTree
const Sim = preload("res://game/simulation.gd")

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
			scenarios.append({"variant": variant, "seed": [147, 104729, 104730][int(run_index / 4)], "doctrine": variant % 3, "frame_id": "frame.pilgrim", "route_id": "route.brass_choir" if variant % 2 == 0 else "route.rootworks"})
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
		while sim.state.phase not in ["won", "lost"] and sim.state.tick < sim.config.wave_ticks * sim.config.wave_count + 16000:
			if sim.state.phase == "route":
				sim.command("choose_route", scenario.route_id)
				continue
			if sim.state.phase == "travel":
				sim.command("advance_travel")
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
			if sim.is_destination() and not s.objective_complete:
				for i in range(s.objective.size()):
					if not s.objective[i].complete:
						var node = sim.objective_data().nodes[i]
						desired = Vector2(node.position[0], node.position[1])
						break
			# Shared policy: intercept attackers at the relay rather than orbiting blindly.
			var nearest_threat = 170.0
			for enemy in s.enemies:
				var distance = enemy.p.distance_to(sim.relay_position())
				if not enemy.major and distance < nearest_threat:
					nearest_threat = distance
					desired = enemy.p.lerp(sim.relay_position(), 0.35)
			if optional or s.progress >= sim.config.relay.required_ticks:
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
		results.append({"mode": sim.state.mode, "frame_id": sim.state.frame_id, "route": sim.state.route, "chapter_complete": sim.state.chapter_complete, "policy": policy_name, "repairs_completed": sim.state.machines.filter(func(m): return m.complete).size(), "repair_metrics": sim.state.metrics, "seed": seed_value, "backup_absorbed": sim.state.backup_absorbed, "relay_damage_sources": sim.state.relay_damage_sources, "damage_taken": sim.state.damage_taken, "damage_by_wave": sim.state.damage_by_wave, "weapon_damage": sim.state.damage, "weapon_kills": sim.state.kills_by_weapon, "weapon_ranks": sim.state.weapons.map(func(w): return {"id": w.id, "rank": w.rank, "evolved": sim.weapon_evolution_id(w).trim_prefix("evolution.")}), "gifts": sim.state.gifts.duplicate(), "scrap_sources": sim.state.scrap_sources, "transactions": sim.state.transactions, "doctrine": doctrine, "evolution_policy": variant == 0, "outcome": sim.state.phase, "wave": sim.state.wave, "seconds": sim.state.tick / 60.0, "hp": sim.state.hp, "relay": sim.state.relay_hp, "progress": sim.state.progress / sim.config.relay.required_ticks, "kills": sim.state.kills, "shops": visits, "reason": sim.state.last_reason, "result_summary": sim.state.result_summary})
	print(JSON.stringify(results, "  "))
	DirAccess.make_dir_recursive_absolute("res://artifacts/agent-iteration")
	var output_name = "ea_matrix.json" if "--ea-matrix" in args else ("optional_playthroughs.json" if optional else "playthroughs.json")
	var file = FileAccess.open("res://artifacts/agent-iteration/" + output_name, FileAccess.WRITE)
	file.store_string(JSON.stringify(results, "  "))
	quit(1 if unfinished else 0)
