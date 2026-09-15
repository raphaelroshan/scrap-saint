extends SceneTree
const Sim = preload("res://game/simulation.gd")
var checks = 0
var failures = 0

func check(ok: bool, label: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", label)

func buy_configured(s, id: String) -> String:
	s.state.offers[0] = id
	return s.command("buy", 0)

func visit(s, pickup_income = 5):
	# Five Scrap per wave is inside the measured ordinary-enemy income band.
	s.record_scrap("pickups", pickup_income)
	s.enter_shop()

func defeat_elite_for_shards(s):
	s.spawn(s.config.elite)
	var elite = s.state.enemies.back()
	elite.p = s.state.position + Vector2(40, 0)
	elite.hp = 1
	for weapon_state in s.state.weapons: weapon_state.ready = 0
	s.update_weapons()
	check(s.state.shards >= 2, "elite defeat awards its ordinary Relic Shards")

func assemble_two_evolutions(first: String):
	var s = Sim.new()
	var first_is_toll = first == "evolution.great_toll"
	s.start(1 if first_is_toll else 0, 147, "optional")
	var first_base = "weapon.bell_last_shift" if first_is_toll else "weapon.nailer_small_mercies"
	var second_base = "weapon.nailer_small_mercies" if first_is_toll else "weapon.bell_last_shift"
	var first_catalyst = "catalyst.cracked_bell_clapper" if first_is_toll else "catalyst.saints_rivet"
	var second_catalyst = "catalyst.saints_rivet" if first_is_toll else "catalyst.cracked_bell_clapper"
	var second_recipe = "evolution.mercy_rail" if first_is_toll else "evolution.great_toll"
	var second_copies = 4
	for visit_index in range(1, 7):
		if visit_index == 6: defeat_elite_for_shards(s)
		visit(s)
		if visit_index <= 3:
			check(buy_configured(s, first_base) == "OK", "%s base copy %d bought through shop" % [first, visit_index])
		if visit_index == 1 or visit_index >= 4:
			if second_copies > 0:
				check(buy_configured(s, second_base) == "OK", "%s second base bought through shop" % first)
				second_copies -= 1
		if visit_index == 4:
			check(buy_configured(s, first_catalyst) == "OK", "%s catalyst bought with earned Shards" % first)
			check(s.command("evolve", first) == "OK", "%s evolves first through command boundary" % first)
		if visit_index == 6:
			check(buy_configured(s, second_catalyst) == "OK", "%s catalyst bought after elite income" % second_recipe)
			check(s.command("evolve", second_recipe) == "OK", "%s evolves second through command boundary" % second_recipe)
		else:
			s.command("continue")
	check(s.has_evolution("evolution.mercy_rail") and s.has_evolution("evolution.great_toll"), "both evolution IDs coexist after %s-first assembly" % first)
	check(s.state.weapons.any(func(w): return w.get("rail", false)) and s.state.weapons.any(func(w): return w.get("toll", false)), "both transformed weapon forms coexist after %s-first assembly" % first)
	return s

func _initialize():
	var weapon_ids = Sim.new().config.weapons.keys()
	var discovered_weapons = {}
	var acquired_weapons = {}
	for seed_value in range(1, 257):
		for doctrine in range(3):
			var s = Sim.new()
			s.start(doctrine, seed_value, "optional")
			visit(s)
			for roll_index in range(2):
				for slot in range(s.state.offers.size()):
					var id = s.state.offers[slot]
					if id in s.config.weapons:
						discovered_weapons[id] = true
						if id not in acquired_weapons and s.command("buy", slot) == "OK":
							acquired_weapons[id] = true
				if roll_index == 0:
					s.command("reroll")
	check(discovered_weapons.size() == weapon_ids.size(), "all ten weapons are discoverable through deterministic ordinary shop rolls")
	for id in weapon_ids:
		check(id in acquired_weapons, "%s is affordable and acquirable from its generated shop offer" % id)

	var acquired_gifts = {}
	for target in Sim.new().config.gifts:
		for seed_value in range(1, 129):
			if target in acquired_gifts: break
			var s = Sim.new()
			s.start(0, seed_value, "optional")
			for visit_index in range(1, 8):
				visit(s)
				for slot in [2, 3]:
					if s.state.offers[slot] == target:
						if s.command("buy", slot) == "OK": acquired_gifts[target] = true
						break
					if s.state.offers[slot] in s.config.catalysts and s.catalogue[s.state.offers[slot]].cost_relic_shards <= s.state.shards:
						s.command("buy", slot)
				if target in acquired_gifts: break
				s.command("reroll")
				for slot in range(4):
					if s.state.offers[slot] == target and s.command("buy", slot) == "OK":
						acquired_gifts[target] = true
						break
				if target in acquired_gifts: break
				s.command("continue")
	check(acquired_gifts.size() == 3, "all three Gifts are discoverable and affordable through deterministic shop flow")

	var toll_first = assemble_two_evolutions("evolution.great_toll")
	var mercy_first = assemble_two_evolutions("evolution.mercy_rail")
	for s in [toll_first, mercy_first]:
		if s.state.phase == "shop":
			s.command("continue")
		s.state.tick = int(s.config.boss_rules.hazard_interval)
		s.spawn(s.config.elite)
		s.state.tick += int(s.config.boss_rules.hazard_interval)
		s.update_enemies()
		var copies = s.state.hazards.filter(func(h): return h.copy)
		check(copies.size() == 1 and copies[0].copy_evolution == "evolution.mercy_rail" and copies[0].copy_shape == "rail", "dual-evolution Crane explicitly copies Mercy Rail's line geometry")
		if copies.is_empty():
			continue
		s.events.clear()
		s.state.tick = copies[0].until
		s.update_hazards()
		check(s.events.any(func(e): return e.kind == "attack" and e.weapon == "elite.memory_crane" and e.shape == "rail"), "Memory Crane resolves the copied identity as rail attack geometry")

	print("ACQUISITION: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
