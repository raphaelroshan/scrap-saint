extends SceneTree
const Sim = preload("res://game/simulation.gd")
var results = []

func _initialize():
	var args = OS.get_cmdline_user_args()
	var label = "after" if "--after" in args else "baseline"
	DirAccess.make_dir_recursive_absolute("res://artifacts/roaming-audit/" + label)
	if "--diagnose" in args:
		run_case(104730, 2, "coverage", label)
		quit()
		return
	for seed_value in [147, 104729, 104730]:
		for doctrine in range(3):
			for policy in ["baseline", "repair"]:
				run_case(seed_value, doctrine, policy, label)
	write_json("res://artifacts/roaming-audit/%s/summary.json" % label, results)
	quit()

func write_json(path, value):
	FileAccess.open(path, FileAccess.WRITE).store_string(JSON.stringify(value, "  "))

func movement(sim, policy):
	var s = sim.state
	var desired = sim.relay_position() + Vector2.from_angle(s.tick * 0.013) * 62
	var nearest = 170.0
	for e in s.enemies:
		var distance = e.p.distance_to(sim.relay_position())
		if not e.major and distance < nearest:
			nearest = distance
			desired = e.p.lerp(sim.relay_position(), 0.35)
	if policy == "repair":
		# Seek the guaranteed economic reward early; only seek recovery when useful.
		for i in range(s.machines.size()):
			var data = sim.config.optional_repairs.machines[i]
			if s.machines[i].complete: continue
			if data.reward == "scrap" or (data.reward == "heal" and s.hp <= 70):
				desired = Vector2(data.position[0], data.position[1])
				break
	for e in s.enemies:
		if e.major:
			desired = e.p + Vector2.from_angle(s.tick * 0.013) * 84
			break
	var move = sim.arena.direction_to(s.position, desired, sim.config.saint.radius)
	for e in s.enemies:
		var diff = s.position - e.p
		if diff.length() < 72: move += diff.normalized() * 3.0
	for h in s.hazards:
		var diff = s.position - h.p
		if diff.length() < h.radius + 28: move += diff.normalized() * 4.0
	return move.limit_length()

func buy_logged(sim, index, log):
	var id = sim.state.offers[index]
	var before = sim.state.scrap
	var result = sim.command("buy", index)
	log.append({"tick": sim.state.tick, "id": id, "result": result, "scrap_before": before, "scrap_after": sim.state.scrap})

func run_case(seed_value, doctrine, policy, label):
	var sim = Sim.new()
	sim.start(doctrine, seed_value, "optional")
	var rows = []
	var purchases = []
	var major_damage = {}
	var major_healing = 0.0
	var damage_by_target = {}
	var repairs = []
	var distance = 0.0
	var gap = 0
	var longest_gap = 0
	var density_sum = 0
	var first_contact = -1
	var first_damage = -1
	var wave_damage = 0.0
	while sim.state.phase not in ["won", "lost"] and sim.state.tick < 33660:
		if sim.state.phase == "shop":
			if policy == "coverage":
				buy_coverage(sim, purchases)
			else:
				if sim.state.hp < 65 or sim.state.relay_hp < 110: buy_logged(sim, 4, purchases)
				for index in [0, 1, 2, 3]: buy_logged(sim, index, purchases)
			sim.command("reroll")
			if policy == "coverage": buy_coverage(sim, purchases)
			else:
				for index in [0, 1]: buy_logged(sim, index, purchases)
			sim.command("continue")
			gap = 0
			wave_damage = 0
		var p = sim.state.position
		sim.step(movement(sim, policy))
		distance += p.distance_to(sim.state.position)
		for event in sim.events:
			if event.kind == "hurt":
				wave_damage += event.amount
				if first_damage < 0: first_damage = sim.state.tick
			if event.kind == "machine_restored": repairs.append(event.duplicate(true))
			if event.kind == "hit":
				var key = event.weapon + "/" + event.target_type
				damage_by_target[key] = damage_by_target.get(key, 0.0) + event.effective
				if event.target_type == sim.config.boss:
					major_damage[event.weapon] = major_damage.get(event.weapon, 0.0) + event.effective
			if event.kind == "repair" and event.get("target_type", "") == sim.config.boss: major_healing += event.amount
		if sim.state.tick % 60 == 0:
			var near = sim.state.enemies.filter(func(e): return e.p.distance_to(sim.state.position) <= 240).size()
			density_sum += near
			if near == 0: gap += 1
			else:
				gap = 0
				if first_contact < 0: first_contact = sim.state.tick
			longest_gap = maxi(longest_gap, gap)
			var bosses = sim.state.enemies.filter(func(e): return e.major)
			rows.append({"tick": sim.state.tick, "wave": sim.state.wave, "position": [sim.state.position.x, sim.state.position.y], "hp": sim.state.hp, "enemies": sim.state.enemies.size(), "within_240": near, "boss_hp": bosses[0].hp if not bosses.is_empty() else 0, "boss_distance": bosses[0].p.distance_to(sim.state.position) if not bosses.is_empty() else 0, "wave_damage_taken": wave_damage})
		# Natural simulation snapshot for later renderer; never configure its state.
		if policy == "repair" and seed_value == 147 and doctrine == 0 and sim.state.tick in [60, 240, 360]:
			FileAccess.open("res://artifacts/roaming-audit/%s/natural_%d.save" % [label, sim.state.tick], FileAccess.WRITE).store_var(sim.snapshot())
	var summary = {"seed": seed_value, "doctrine": doctrine, "policy": policy, "outcome": sim.state.phase, "reason": sim.state.last_reason, "seconds": sim.state.tick / 60.0, "hp": sim.state.hp, "first_nearby_second": first_contact / 60.0, "first_damage_second": first_damage / 60.0 if first_damage >= 0 else -1, "longest_no_nearby_seconds": longest_gap, "mean_nearby_enemies": float(density_sum) / maxi(1, rows.size()), "travel_pixels": distance, "repairs": repairs, "weapons": sim.state.weapons, "reserve": sim.state.reserve, "scrap": sim.state.scrap, "boss_damage": major_damage, "boss_healing": major_healing, "damage_by_target": damage_by_target, "final_hash": sim.state_hash()}
	results.append(summary)
	write_json("res://artifacts/roaming-audit/%s/%d_%d_%s.json" % [label, seed_value, doctrine, policy], {"summary": summary, "samples": rows, "purchases": purchases})
	print("AUDIT ", seed_value, " / ", doctrine, " / ", policy, ": ", sim.state.phase, " repairs=", repairs.size())

func buy_coverage(sim, purchases):
	# Use every visible card. Establish four distinct mechanisms before stockpiling.
	for pass_index in range(2):
		for index in range(sim.state.offers.size()):
			var id = sim.state.offers[index]
			if id not in sim.config.weapons: continue
			var owned = (sim.state.weapons + sim.state.reserve).filter(func(w): return w.id == id)
			if owned.any(func(w): return w.rank == 3): continue
			if pass_index == 0 and not owned.is_empty(): continue
			buy_logged(sim, index, purchases)
	for index in range(sim.state.offers.size()):
		if sim.state.offers[index] in sim.config.catalysts: buy_logged(sim, index, purchases)
