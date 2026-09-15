extends SceneTree
const Sim = preload("res://game/simulation.gd")
var checks = 0
var failures = 0

func check(ok: bool, label: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("WEAPON RANK FAIL: ", label)

func weapon(sim, id: String, rank: int):
	return sim.make_weapon(id, rank)

func enemy(sim, id: String, position: Vector2, hp = -1.0):
	sim.spawn(id)
	var target = sim.state.enemies.back()
	target.p = position
	if hp >= 0:
		target.hp = hp
		target.max_hp = maxf(target.max_hp, hp)
	return target

func combat_fixture(id: String, rank: int):
	var sim = Sim.new()
	sim.start(0, 147, "optional")
	sim.state.position = Vector2(550, 530)
	sim.state.weapons = [weapon(sim, id, rank)]
	return sim

func _initialize():
	var catalogue = Sim.new()
	var rule_cases = [
		{"id": "weapon.nailer_small_mercies", "rank2": "pierce_targets", "value2": 3, "rank3": "mark_counter_ticks", "value3": 75},
		{"id": "weapon.bell_last_shift", "rank2": "width", "value2": 1.04, "rank3": "control_ticks", "value3": 72},
		{"id": "weapon.procession_gear", "rank2": "orbit_contacts", "value2": 2, "rank3": "range", "value3": 100},
		{"id": "weapon.candle_nailer", "rank2": "target_count", "value2": 2, "rank3": "seeking_motes", "value3": true},
		{"id": "weapon.cable_contrition", "rank2": "bind_ticks", "value2": 126, "rank3": "pull_distance", "value3": 28},
		{"id": "weapon.hymn_coil", "rank2": "width", "value2": 10, "rank3": "quiet_ticks", "value3": 60},
		{"id": "weapon.altar_mortar", "rank2": "width", "value2": 90, "rank3": "cooldown", "value3": 78},
		{"id": "weapon.foundry_censer", "rank2": "slow_ticks", "value2": 63, "rank3": "scrap_every", "value3": 2},
		{"id": "weapon.penance_winch", "rank2": "range", "value2": 610, "rank3": "bind_ticks", "value3": 135},
		{"id": "weapon.welded_halo", "rank2": "repair_progress", "value2": 24, "rank3": "saint_repair", "value3": 1.5}
	]
	check(catalogue.config.rank_damage_multipliers == [1.0, 1.6, 2.2], "rank damage scaling is explicit global content")
	for rank_case in rule_cases:
		var rank_one = catalogue.resolved_weapon_rule(weapon(catalogue, rank_case.id, 1))
		var rank_two_weapon = weapon(catalogue, rank_case.id, 2)
		var rank_three_weapon = weapon(catalogue, rank_case.id, 3)
		var rank_two = catalogue.resolved_weapon_rule(rank_two_weapon)
		var rank_three = catalogue.resolved_weapon_rule(rank_three_weapon)
		check(rank_one.get(rank_case.rank2) != rank_case.value2 and rank_two.get(rank_case.rank2) == rank_case.value2, "%s Rank II changes %s" % [rank_case.id, rank_case.rank2])
		check(rank_three.get(rank_case.rank2) == rank_case.value2 and rank_three.get(rank_case.rank3) == rank_case.value3, "%s Rank III keeps Rank II and adds %s" % [rank_case.id, rank_case.rank3])
		check(catalogue.weapon_rank_behavior_ids(rank_two_weapon).size() == 1 and catalogue.weapon_rank_behavior_ids(rank_three_weapon).size() == 2, "%s reports cumulative stable rank behavior IDs" % rank_case.id)
	var evolved_nailer = weapon(catalogue, "weapon.nailer_small_mercies", 3)
	evolved_nailer.evolution = "evolution.mercy_rail"
	check(catalogue.resolved_weapon_rule(evolved_nailer).shape == "rail" and not catalogue.resolved_weapon_rule(evolved_nailer).has("pierce_targets") and catalogue.weapon_rank_behavior_ids(evolved_nailer).is_empty(), "Evolution resolution replaces rather than leaks base-rank overlays")

	var sim = combat_fixture("weapon.nailer_small_mercies", 2)
	var nail_targets = []
	for distance in [90, 135, 180]: nail_targets.append(enemy(sim, "enemy.rust_pilgrim", sim.state.position + Vector2(distance, 0)))
	sim.update_weapons()
	check(nail_targets.all(func(target): return target.hp < target.max_hp), "Rank II Nailer pierces three aligned machines")
	sim = combat_fixture("weapon.nailer_small_mercies", 3)
	var marked_support = enemy(sim, "enemy.choir_drone", sim.state.position + Vector2(100, 0))
	sim.update_weapons()
	check(marked_support.marked == sim.state.tick + 75, "Rank III Nailer marks its support-priority target")
	var nail_attack = sim.events.filter(func(event): return event.kind == "attack").back()
	check(nail_attack.rank_behaviors == ["rank.nailer.triple_pin", "rank.nailer.foreman_notch"], "attack traces expose cumulative stable rank behavior IDs")

	sim = combat_fixture("weapon.bell_last_shift", 2)
	var bell_primary = enemy(sim, "enemy.rivet_hound", sim.state.position + Vector2(70, 0))
	var bell_edge = enemy(sim, "enemy.rivet_hound", sim.state.position + Vector2.from_angle(0.95) * 110)
	sim.update_weapons()
	check(bell_primary.hp < bell_primary.max_hp and bell_edge.hp < bell_edge.max_hp, "Rank II Bell catches an off-centre threat with its wider mouth")
	sim = combat_fixture("weapon.bell_last_shift", 3)
	var bell_target = enemy(sim, "enemy.rivet_hound", sim.state.position + Vector2(90, 0))
	var bell_before = bell_target.p
	sim.update_weapons()
	check(bell_target.stun == sim.state.tick + 72 and bell_target.p.distance_to(sim.state.position) > bell_before.distance_to(sim.state.position), "Rank III Bell applies its longer, stronger control beat")

	sim = combat_fixture("weapon.procession_gear", 2)
	var gear_a = enemy(sim, "enemy.scrap_mite", sim.state.position + Vector2(80, 0))
	var gear_b = enemy(sim, "enemy.scrap_mite", sim.state.position - Vector2(80, 0))
	sim.update_weapons()
	check(gear_a.hp < gear_a.max_hp and gear_b.hp < gear_b.max_hp, "Rank II Gear owns two opposed orbit contacts")
	check(sim.resolved_weapon_rule(weapon(sim, "weapon.procession_gear", 3)).range == 100, "Rank III Gear widens the close-defence route")

	sim = combat_fixture("weapon.candle_nailer", 2)
	var candle_a = enemy(sim, "enemy.rivet_hound", sim.state.position + Vector2(90, 0), 20)
	var candle_b = enemy(sim, "enemy.rivet_hound", sim.state.position + Vector2(120, 0), 25)
	sim.update_weapons()
	check(candle_a.hp < 20 and candle_b.hp < 25, "Rank II Candle fires at the two weakest reachable machines")
	sim = combat_fixture("weapon.candle_nailer", 3)
	enemy(sim, "enemy.rivet_hound", sim.state.position + Vector2(90, 0), 1)
	sim.update_weapons()
	check(sim.state.pickups.any(func(p): return p.get("source", "") == "rank.candle.returning_motes" and p.get("seeking", false)), "Rank III Candle creates a seeking recovery mote")

	sim = combat_fixture("weapon.cable_contrition", 3)
	var cable_target = enemy(sim, "enemy.rivet_hound", sim.state.position + Vector2(100, 0))
	cable_target.relay_strike_at = sim.state.tick + 40
	var cable_before = cable_target.p
	sim.update_weapons()
	check(cable_target.bound == sim.state.tick + 126 and cable_target.p.distance_to(sim.state.position) < cable_before.distance_to(sim.state.position) and cable_target.relay_strike_at == 0, "Rank III Cable preserves the braid and adds its return-pulley interrupt")

	sim = combat_fixture("weapon.hymn_coil", 3)
	var quiet_target = enemy(sim, "enemy.rust_pilgrim", sim.state.position + Vector2(150, 0))
	sim.update_weapons()
	check(quiet_target.quieted == sim.state.tick + 60, "Rank III Hymn briefly quiets support actions in its widened lane")

	sim = combat_fixture("weapon.altar_mortar", 2)
	var mortar_primary = enemy(sim, "enemy.rivet_hound", sim.state.position + Vector2(100, 0))
	var mortar_edge = enemy(sim, "enemy.rivet_hound", mortar_primary.p + Vector2(98, 0))
	sim.update_weapons()
	check(mortar_edge.hp < mortar_edge.max_hp, "Rank II Mortar catches collateral in its larger blast")
	check(sim.resolved_weapon_rule(weapon(sim, "weapon.altar_mortar", 3)).cooldown == 78, "Rank III Mortar has its authored echo cadence")

	sim = combat_fixture("weapon.foundry_censer", 3)
	var censer_target = enemy(sim, "enemy.rivet_hound", sim.state.position + Vector2(60, 0))
	sim.update_weapons()
	check(censer_target.slow == sim.state.tick + 63, "Rank II Censer's thicker smoke persists at Rank III")
	sim.state.enemies.clear()
	for i in range(2): enemy(sim, "enemy.scrap_mite", sim.state.position + Vector2(40 + i * 20, 0), 1)
	sim.state.weapons[0].ready = 0
	sim.update_weapons()
	check(sim.state.pickups.any(func(p): return p.kind == "scrap" and p.get("source", "") == "censer"), "Rank III Censer leaves Scrap after every second close defeat")

	sim = combat_fixture("weapon.penance_winch", 2)
	var winch_far = enemy(sim, "enemy.rivet_hound", sim.state.position + Vector2(570, 0))
	sim.update_weapons()
	check(winch_far.hp < winch_far.max_hp, "Rank II Winch reaches beyond its Rank I drum")
	sim = combat_fixture("weapon.penance_winch", 3)
	var winch_target = enemy(sim, "enemy.rivet_hound", sim.state.position + Vector2(200, 0))
	sim.update_weapons()
	check(winch_target.bound == sim.state.tick + 135, "Rank III Winch ratchet holds its priority target longer")

	sim = combat_fixture("weapon.welded_halo", 2)
	var machine = Vector2(sim.config.optional_repairs.machines[0].position[0], sim.config.optional_repairs.machines[0].position[1])
	sim.state.position = machine + Vector2(70, 0)
	sim.update_weapons()
	check(sim.state.machines[0].progress == 24, "Rank II Halo applies the stronger objective stitch")
	sim = combat_fixture("weapon.welded_halo", 3)
	sim.state.hp = 70
	sim.update_weapons()
	check(sim.state.hp == 71.5, "Rank III Halo repairs more Saint Structure when no objective accepts the stitch")

	var explicit = Sim.new()
	explicit.start(0, 147, "optional")
	explicit.enter_shop()
	explicit.state.weapons = [weapon(explicit, "weapon.nailer_small_mercies", 2), weapon(explicit, "weapon.nailer_small_mercies", 1), weapon(explicit, "weapon.nailer_small_mercies", 1)]
	for owned in explicit.state.weapons: owned.ready = 777
	check(explicit.command("combine") == "OK" and explicit.command("combine") == "OK", "explicit combines produce Rank III")
	var automatic = Sim.new()
	automatic.start(0, 147, "optional")
	automatic.enter_shop()
	automatic.state.scrap = 100
	automatic.state.weapons = [weapon(automatic, "weapon.nailer_small_mercies", 2), weapon(automatic, "weapon.nailer_small_mercies", 1)]
	for owned in automatic.state.weapons: owned.ready = 777
	automatic.state.offers[0] = "weapon.nailer_small_mercies"
	check(automatic.command("buy", 0) == "OK", "purchase auto-combine produces Rank III")
	check(explicit.state.weapons == automatic.state.weapons and explicit.state.weapons[0].ready == 0, "explicit and purchase combines produce identical canonical weapon state and readiness")
	check(explicit.weapon_rank_behavior_ids(explicit.state.weapons[0]) == automatic.weapon_rank_behavior_ids(automatic.state.weapons[0]) and explicit.evolution_recipe_state("evolution.mercy_rail") == automatic.evolution_recipe_state("evolution.mercy_rail"), "combine paths expose identical Rank III behaviors and Evolution readiness")
	var explicit_rank_events = explicit.events.filter(func(event): return event.kind == "rank_up")
	var automatic_rank_events = automatic.events.filter(func(event): return event.kind == "rank_up")
	check(explicit_rank_events.map(func(event): return event.behaviors) == automatic_rank_events.map(func(event): return event.behaviors), "explicit and purchase combines emit identical rank behavior traces")

	print("WEAPON RANKS: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
