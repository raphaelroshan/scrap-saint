extends SceneTree
const Sim = preload("res://game/simulation.gd")
var checks = 0
var failures = 0

func check(ok: bool, label: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", label)

func enemy(s, kind: String, p: Vector2, hp = -1.0):
	s.spawn(kind)
	var e = s.state.enemies.back()
	e.p = p
	if hp >= 0:
		e.hp = hp
		e.max_hp = maxf(e.max_hp, hp)
	return e

func evolved_weapon(s, base_id: String, evolution_id: String):
	var w = s.make_weapon(base_id, 3)
	w.evolution = evolution_id
	return w

func evolve_fixture(recipe_id: String):
	var s = Sim.new()
	s.start(0, 147, "optional")
	s.enter_shop()
	var recipe = s.evolution_recipes[recipe_id]
	s.state.weapons = [s.make_weapon(recipe.base_item_id, 3)]
	s.state.catalysts = [recipe.required_catalyst_id]
	check(s.command("evolve", recipe_id) == "OK", "%s accepts its data-owned recipe" % recipe_id)
	check(s.weapon_evolution_id(s.state.weapons[0]) == recipe_id and recipe.required_catalyst_id not in s.state.catalysts, "%s records per-weapon identity and consumes exactly one catalyst" % recipe_id)
	return s

func _initialize():
	var catalogue = Sim.new()
	check(catalogue.config.evolutions.size() == 10 and catalogue.evolution_recipes.size() == 10, "the enabled catalogue contains ten stable Evolutions")
	for recipe_id in catalogue.config.evolutions:
		var s = Sim.new()
		s.start(0, 147, "optional")
		s.enter_shop()
		var before = [s.state.weapons.duplicate(true), s.state.catalysts.duplicate(), s.state.scrap, s.state.shards, s.state.rng, s.state.tick]
		var result = s.command("evolve", recipe_id)
		var after = [s.state.weapons.duplicate(true), s.state.catalysts.duplicate(), s.state.scrap, s.state.shards, s.state.rng, s.state.tick]
		check(result == "MISSING_INGREDIENT" and after == before, "%s rejects atomically without ingredients" % recipe_id)

	# The ledger reports active and reserve recipes, so its public action must assemble either location.
	var reserve_evolution_recipe = catalogue.evolution_recipes["evolution.quiet_sermon"]
	var reserve_sim = Sim.new()
	reserve_sim.start(0, 147, "optional")
	reserve_sim.enter_shop()
	reserve_sim.state.weapons = [reserve_sim.make_weapon("weapon.nailer_small_mercies")]
	reserve_sim.state.reserve = [reserve_sim.make_weapon(reserve_evolution_recipe.base_item_id, 3)]
	reserve_sim.state.catalysts = [reserve_evolution_recipe.required_catalyst_id]
	check(reserve_sim.command("evolve", reserve_evolution_recipe.id) == "OK" and reserve_sim.weapon_evolution_id(reserve_sim.state.reserve[0]) == reserve_evolution_recipe.id, "a ready reserve weapon evolves through the same public ledger action")

	# Ashen Benediction moves its smoke away from the Saint toward damaged work and turns close defeats into seeking motes.
	var s = evolve_fixture("evolution.ashen_benediction")
	s.command("continue")
	var machine = Vector2(s.config.optional_repairs.machines[0].position[0], s.config.optional_repairs.machines[0].position[1])
	s.state.position = machine + Vector2(-180, 0)
	var ash_target = enemy(s, "enemy.rivet_hound", s.state.position + Vector2(105, 0), 1)
	s.update_weapons()
	var ash_attack = s.events.filter(func(e): return e.kind == "attack" and e.shape == "ashen_censer")
	check(not ash_attack.is_empty() and ash_attack[0].to != ash_attack[0].from and ash_target.slow > s.state.tick, "Ashen Benediction projects an offset slow zone toward damaged work")
	enemy(s, "enemy.rivet_hound", s.state.position + Vector2(105, 0), 1)
	s.state.weapons[0].ready = 0
	s.update_weapons()
	check(s.state.pickups.any(func(p): return p.kind == "mote" and p.get("seeking", false) and p.get("source", "") == "evolution.ashen_benediction"), "Ashen Benediction converts its second close defeat into a seeking Mourn mote")

	# The Long Hand changes the point hook into a corridor that controls several aligned threats.
	s = evolve_fixture("evolution.long_hand")
	s.command("continue")
	s.state.position = Vector2(200, 800)
	var long_near = enemy(s, "enemy.rivet_hound", s.state.position + Vector2(180, 8))
	var long_far = enemy(s, "enemy.forklift_brute", s.state.position + Vector2(430, 0))
	var near_before = long_near.p
	var far_before = long_far.p
	s.update_weapons()
	check(long_near.hp < long_near.max_hp and long_far.hp < long_far.max_hp and long_near.bound > s.state.tick and long_far.bound > s.state.tick, "The Long Hand damages and binds multiple threats along its routed corridor")
	check(long_near.p.distance_to(s.state.position) < near_before.distance_to(s.state.position) and long_far.p.distance_to(s.state.position) < far_before.distance_to(s.state.position), "The Long Hand visibly pulls every corridor target")

	# Halo of Repairs has two opposed contacts and closes the machine-to-Saint circuit.
	s = evolve_fixture("evolution.halo_of_repairs")
	s.command("continue")
	s.state.position = machine + Vector2(-70, 0)
	s.state.hp = 70
	var halo_rule = s.config.evolution_rules["evolution.halo_of_repairs"]
	var halo_a = enemy(s, "enemy.rivet_hound", s.state.position + Vector2(halo_rule.range, 0))
	var halo_b = enemy(s, "enemy.rivet_hound", s.state.position - Vector2(halo_rule.range, 0))
	s.update_weapons()
	check(halo_a.hp < halo_a.max_hp and halo_b.hp < halo_b.max_hp, "Halo of Repairs replaces one contact with two opposed damage contacts")
	check(s.state.machines[0].progress == halo_rule.repair_progress and s.state.hp == 70 + halo_rule.circuit_heal, "Halo of Repairs chains current objective progress back into Saint repair")

	# Candle for the Unreturned selects three weak threats and gives its funeral motes a visible destination.
	s = evolve_fixture("evolution.candle_unreturned")
	s.command("continue")
	s.state.position = Vector2(550, 530)
	for i in range(3):
		var target = enemy(s, "enemy.choir_drone" if i == 0 else "enemy.rivet_hound", s.state.position + Vector2(90 + i * 45, i * 10), 1)
		if i == 0: target.marked = s.state.tick + 100
	s.update_weapons()
	check(s.state.enemies.is_empty() and s.state.kills == 3, "Candle for the Unreturned executes the three weakest reachable targets")
	check(s.state.pickups.filter(func(p): return p.get("source", "") == "evolution.candle_unreturned" and p.get("seeking", false)).size() == 4, "Candle for the Unreturned creates seeking motes plus a marked-support remembrance")

	# Quiet Sermon broadens the beam and suppresses authored support actions.
	s = evolve_fixture("evolution.quiet_sermon")
	s.command("continue")
	s.state.position = Vector2(550, 530)
	var wounded = enemy(s, "enemy.rivet_hound", s.state.position + Vector2(260, 0))
	wounded.hp -= 10
	var pilgrim = enemy(s, "enemy.rust_pilgrim", s.state.position + Vector2(150, 0))
	var spitter = enemy(s, "enemy.cinder_spitter", s.state.position + Vector2(240, 8))
	s.update_weapons()
	check(pilgrim.quieted > s.state.tick and spitter.quieted > s.state.tick and s.events.any(func(e): return e.kind == "attack" and e.shape == "sermon"), "Quiet Sermon creates a wide authoritative silence lane")
	var wounded_after_sermon = wounded.hp
	s.events.clear()
	s.update_enemies()
	check(wounded.hp == wounded_after_sermon and s.state.hazards.is_empty(), "Quieted support machines cannot heal or schedule a ranged blast")

	# Workshop Benediction can choose damaged work instead of requiring an enemy cluster.
	s = evolve_fixture("evolution.workshop_benediction")
	s.command("continue")
	s.state.position = machine + Vector2(-120, 0)
	s.update_weapons()
	check(s.state.machines[0].progress == s.config.evolution_rules["evolution.workshop_benediction"].repair_progress and s.events.any(func(e): return e.kind == "attack" and e.shape == "consecrated"), "Workshop Benediction fires a consecrated objective shot when no threat is present")
	var mortar_target = enemy(s, "enemy.forklift_brute", s.state.position + Vector2(140, 0))
	s.state.weapons[0].ready = 0
	s.update_weapons()
	check(mortar_target.hp < mortar_target.max_hp and s.events.any(func(e): return e.kind == "attack" and e.shape == "benediction"), "Workshop Benediction retains a distinct damaging cluster resolve when threats are present")

	# The Maintenance Parade changes one contact into two counter-rotating pairs and extends after real repair work.
	s = evolve_fixture("evolution.maintenance_parade")
	s.command("continue")
	s.state.position = Vector2(550, 530)
	var parade_rule = s.config.evolution_rules["evolution.maintenance_parade"]
	var inner_a = enemy(s, "enemy.rivet_hound", s.state.position + Vector2(parade_rule.inner_range, 0))
	var inner_b = enemy(s, "enemy.rivet_hound", s.state.position - Vector2(parade_rule.inner_range, 0))
	var outer_direction = Vector2.from_angle(PI / 3.0)
	var outer_a = enemy(s, "enemy.rivet_hound", s.state.position + outer_direction * parade_rule.range)
	var outer_b = enemy(s, "enemy.rivet_hound", s.state.position - outer_direction * parade_rule.range)
	s.update_weapons()
	check([inner_a, inner_b, outer_a, outer_b].all(func(target): return target.hp < target.max_hp), "Maintenance Parade resolves two distinct escort rings in one attack")
	check(s.events.any(func(e): return e.kind == "attack" and e.shape == "parade" and e.points.size() == 2), "Maintenance Parade emits its four-contact geometry")
	var repair_position = Vector2(s.config.optional_repairs.machines[0].position[0], s.config.optional_repairs.machines[0].position[1])
	s.state.machines[0].progress = s.config.optional_repairs.required_ticks - 1
	s.advance_optional_machine(0, 1, repair_position)
	check(s.state.parade_until == s.state.tick + parade_rule.extension_ticks and s.events.any(func(e): return e.kind == "parade_extended"), "restoring a machine visibly extends the Parade's outer route")
	s.state.enemies.clear()
	s.state.weapons[0].ready = 0
	var extended_target = enemy(s, "enemy.rivet_hound", s.state.position + outer_direction * parade_rule.extended_range)
	s.update_weapons()
	check(extended_target.hp < extended_target.max_hp and s.events.any(func(e): return e.kind == "attack" and e.shape == "parade" and e.extended), "the restored-machine window expands authoritative outer-ring contact")
	var parade_restored = Sim.new()
	check(parade_restored.restore(s.snapshot()) and parade_restored.state.parade_until == s.state.parade_until and parade_restored.weapon_evolution_id(parade_restored.state.weapons[0]) == "evolution.maintenance_parade", "Maintenance Parade and its active extension survive exact save restoration")

	# Contrition Lattice replaces a loose cone with three authored cable edges.
	s = evolve_fixture("evolution.contrition_lattice")
	s.command("continue")
	s.state.position = Vector2(550, 530)
	var lattice_rule = s.config.evolution_rules["evolution.contrition_lattice"]
	var apex = enemy(s, "enemy.forklift_brute", s.state.position + Vector2(250, 0))
	var edge_crossing = enemy(s, "enemy.rivet_hound", s.state.position + Vector2(140, lattice_rule.half_width * 0.5))
	var inside = enemy(s, "enemy.scrap_mite", s.state.position + Vector2(90, 0))
	var apex_before = apex.p
	var crossing_before = edge_crossing.p
	s.update_weapons()
	var lattice_attack = s.events.filter(func(e): return e.kind == "attack" and e.shape == "lattice")
	check(apex.hp < apex.max_hp and edge_crossing.hp < edge_crossing.max_hp and inside.hp == inside.max_hp, "Contrition Lattice affects crossing edges rather than filling its triangle")
	check(apex.bound > s.state.tick and edge_crossing.bound > s.state.tick and apex.p != apex_before and edge_crossing.p != crossing_before, "Contrition Lattice binds and laterally redirects every crossing threat")
	check(not lattice_attack.is_empty() and lattice_attack[0].points.size() == 3, "Contrition Lattice emits a visible three-anchor boundary")

	var final_snapshot = s.snapshot()
	var final_restored = Sim.new()
	check(final_restored.restore(final_snapshot) and final_restored.weapon_evolution_id(final_restored.state.weapons[0]) == "evolution.contrition_lattice", "Contrition Lattice survives exact save restoration")

	# A feasible five-item loadout preserves independent identities through save and restore.
	s.start(0, 147, "optional")
	var coexist_ids = catalogue.config.evolutions.slice(2, 7)
	s.state.weapons.clear()
	for recipe_id in coexist_ids.slice(0, 4):
		var recipe = s.evolution_recipes[recipe_id]
		s.state.weapons.append(evolved_weapon(s, recipe.base_item_id, recipe_id))
	var reserve_recipe = s.evolution_recipes[coexist_ids[4]]
	s.state.reserve = [evolved_weapon(s, reserve_recipe.base_item_id, coexist_ids[4])]
	s.state.evolutions = coexist_ids.duplicate()
	var restored = Sim.new()
	check(restored.restore(s.snapshot()) and restored.state.evolutions == coexist_ids, "five distinct Evolutions coexist across active and reserve slots after save/restore")
	check(restored.state.weapons.map(func(w): return restored.weapon_evolution_id(w)) + restored.state.reserve.map(func(w): return restored.weapon_evolution_id(w)) == coexist_ids, "save restoration preserves each per-weapon Evolution identity")

	print("EVOLUTIONS: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
