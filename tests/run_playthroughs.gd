extends SceneTree
const Sim = preload("res://game/simulation.gd")

func _initialize():
	var results = []
	var optional = "--optional" in OS.get_cmdline_user_args()
	var unfinished = false
	for run_index in range(12):
		var variant = run_index % 4
		var seed_value = [147, 104729, 104730][int(run_index / 4)]
		var doctrine = variant % 3
		var sim = Sim.new()
		sim.start(doctrine, seed_value, "optional" if optional else "relay")
		var visits = 0
		while sim.state.phase not in ["won", "lost"] and sim.state.tick < sim.config.wave_ticks * sim.config.wave_count + 60:
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
			var move = sim.arena.direction_to(s.position, desired, sim.config.saint.radius)
			for enemy in s.enemies:
				var diff = s.position - enemy.p
				if diff.length() < 72: move += diff.normalized() * 3.0
			for hazard in s.hazards:
				var diff = s.position - hazard.p
				if diff.length() < hazard.radius + 28: move += diff.normalized() * 4.0
			sim.step(move.limit_length())
		unfinished = unfinished or sim.state.phase != "won"
		results.append({"mode": sim.state.mode, "repairs_completed": sim.state.machines.filter(func(m): return m.complete).size(), "seed": seed_value, "backup_absorbed": sim.state.backup_absorbed, "relay_damage_sources": sim.state.relay_damage_sources, "doctrine": doctrine, "evolution_policy": variant == 0, "outcome": sim.state.phase, "wave": sim.state.wave, "seconds": sim.state.tick / 60.0, "hp": sim.state.hp, "relay": sim.state.relay_hp, "progress": sim.state.progress / sim.config.relay.required_ticks, "kills": sim.state.kills, "shops": visits, "reason": sim.state.last_reason})
	print(JSON.stringify(results, "  "))
	DirAccess.make_dir_recursive_absolute("res://artifacts/agent-iteration")
	var file = FileAccess.open(("res://artifacts/agent-iteration/optional_playthroughs.json" if optional else "res://artifacts/agent-iteration/playthroughs.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(results, "  "))
	quit(1 if unfinished else 0)
