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

func weapon(id: String, rank = 1):
	return {"id": id, "rank": rank, "rail": false, "toll": false, "ready": 0}

func _initialize():
	var s = Sim.new()
	var centre = Vector2(550, 530)

	# Foundry Censer owns close pressure, applies a visible slow, and pays a bounded cadence.
	s.start(0, 147, "optional")
	s.state.position = centre
	s.state.weapons = [weapon("weapon.foundry_censer")]
	var slowed = enemy(s, "enemy.forklift_brute", centre + Vector2(55, 0))
	s.update_weapons()
	check(slowed.hp < slowed.max_hp and slowed.slow > s.state.tick, "Censer damages and slows close pressure")
	s.state.enemies.clear()
	for i in range(3): enemy(s, "enemy.rivet_hound", centre + Vector2.from_angle(i * TAU / 3.0) * 45, 1)
	s.state.weapons[0].ready = 0
	s.update_weapons()
	check(s.state.censer_defeats == 3 and s.state.pickups.filter(func(p): return p.kind == "scrap" and p.get("source", "") == "censer").size() == 1, "Censer creates one deterministic ember per three close defeats")

	# Penance Winch cancels the objective attacker before choosing by distance.
	s.start(0, 147, "relay")
	s.state.position = centre
	s.state.weapons = [weapon("weapon.penance_winch")]
	var near_attacker = enemy(s, "enemy.rivet_hound", centre + Vector2(80, 0))
	var far_threat = enemy(s, "enemy.rivet_hound", centre + Vector2(300, 0))
	near_attacker.relay_strike_at = s.state.tick + 50
	var before = near_attacker.p
	s.update_weapons()
	check(near_attacker.hp < near_attacker.max_hp and far_threat.hp == far_threat.max_hp, "Winch prioritises an announced objective attacker")
	check(near_attacker.relay_strike_at == 0 and near_attacker.p.distance_to(centre) < before.distance_to(centre), "Winch cancels and visibly pulls its priority target")
	s.start(0, 147, "optional")
	s.state.position = centre
	s.state.weapons = [weapon("weapon.penance_winch")]
	var near_free = enemy(s, "enemy.rivet_hound", centre + Vector2(80, 0))
	var far_free = enemy(s, "enemy.rivet_hound", centre + Vector2(300, 0))
	s.update_weapons()
	check(far_free.hp < far_free.max_hp and near_free.hp == near_free.max_hp, "Winch chooses the farthest eligible threat without an objective strike")

	# Welded Halo turns proximity to an optional machine into automatic repair progress.
	s.start(0, 147, "optional")
	var machine_p = Vector2(s.config.optional_repairs.machines[0].position[0], s.config.optional_repairs.machines[0].position[1])
	s.state.position = machine_p + Vector2(70, 0)
	s.state.weapons = [weapon("weapon.welded_halo")]
	s.update_weapons()
	check(is_equal_approx(s.state.machines[0].progress, float(s.config.weapons["weapon.welded_halo"].repair_progress)), "Halo adds an authoritative nearby-machine stitch without a target")
	check(s.events.any(func(e): return e.kind == "repair") and s.events.any(func(e): return e.kind == "attack" and e.shape == "halo"), "Halo reports repair and rotating attack geometry separately")
	s.start(0, 147, "optional")
	s.state.site_id = "site.rootworks_pump"
	s.state.position = machine_p
	s.state.weapons = [weapon("weapon.welded_halo")]
	s.update_weapons()
	check(s.state.machines[0].progress == 0 and not s.working_optional_machine(), "destination state cannot operate carried Workshop machines")

	# Great Toll remains a catalyst Evolution, not Combine or Confluence.
	s.start(1, 147, "optional")
	s.enter_shop()
	s.state.weapons = [weapon("weapon.bell_last_shift", 3)]
	var build_before = s.state.weapons.duplicate(true)
	var currency_before = [s.state.scrap, s.state.shards, s.state.rng, s.state.tick]
	check(s.command("evolve", "evolution.great_toll") == "MISSING_INGREDIENT", "failed Great Toll reports its stable rejection reason")
	check(s.state.weapons == build_before and s.state.catalysts.is_empty() and [s.state.scrap, s.state.shards, s.state.rng, s.state.tick] == currency_before, "failed Great Toll does not mutate ingredients, currency, RNG, or time")
	s.state.catalysts.append("catalyst.cracked_bell_clapper")
	check(s.command("evolve", "evolution.great_toll") == "OK", "Bell Rank III plus Cracked Clapper evolves")
	check(s.state.weapons[0].toll and s.state.evolutions == ["evolution.great_toll"] and "catalyst.cracked_bell_clapper" not in s.state.catalysts, "Great Toll records its own ID and consumes exactly its catalyst")
	s.roll_shop()
	check(s.state.offers[2] == "catalyst.saints_rivet", "Toll-only build retains the independent Mercy Rail path")
	s.command("continue")
	s.state.tick = int(s.config.boss_rules.hazard_interval)
	s.spawn(s.config.elite)
	s.state.tick += int(s.config.boss_rules.hazard_interval)
	s.update_enemies()
	check(not s.state.hazards.is_empty() and s.state.hazards.all(func(h): return not h.copy), "Toll-only build does not trigger Memory Crane's Mercy Rail copy")
	s.state.enemies.clear()
	s.state.hazards.clear()
	s.state.evolutions = ["evolution.mercy_rail"]
	s.state.evolved = true
	s.spawn(s.config.elite)
	s.state.tick += int(s.config.boss_rules.hazard_interval)
	s.update_enemies()
	check(not s.state.hazards.is_empty() and s.state.hazards.any(func(h): return h.copy), "Memory Crane copy remains keyed to Mercy Rail")
	s.state.enemies.clear()
	s.state.hazards.clear()
	s.state.position = centre
	var left = enemy(s, "enemy.rivet_hound", centre + Vector2(-90, 0))
	var right = enemy(s, "enemy.rivet_hound", centre + Vector2(90, 0))
	s.update_weapons()
	check(left.hp < left.max_hp and right.hp < right.max_hp and left.marked > s.state.tick and right.stun > s.state.tick, "Great Toll is a radial marked stagger, not Bell's forward cone")
	check(s.events.any(func(e): return e.kind == "attack" and e.shape == "radial"), "Great Toll emits radial presentation geometry")

	# Gifts use two unique slots and retain their explicit trade-offs.
	s.start(0, 147, "optional")
	s.enter_shop()
	s.state.scrap = 100
	s.state.offers[3] = "gift.spare_hand"
	check(s.command("buy", 3) == "OK", "Spare Hand can be acquired from a relic offer")
	var duplicate_scrap = s.state.scrap
	s.state.offers[3] = "gift.spare_hand"
	check(s.command("buy", 3) == "ALREADY_OWNED" and s.state.scrap == duplicate_scrap, "identical Gifts cannot stack or spend Scrap")
	s.state.offers[3] = "gift.inspection_lens"
	check(s.command("buy", 3) == "OK", "Inspection Lens occupies the second Gift slot")
	s.state.offers[3] = "gift.black_ledger"
	check(s.command("buy", 3) == "GIFT_SLOTS_FULL" and s.state.gifts.size() == 2, "third Gift is rejected without spending")
	var saved = s.snapshot()
	var restored = Sim.new()
	check(restored.restore(saved) and restored.state.gifts == s.state.gifts, "Gift slots survive save and restore")
	var sale_before = restored.state.scrap
	check(restored.command("sell_gift", 1) == "OK" and restored.state.scrap > sale_before and restored.state.gifts == ["gift.spare_hand"], "Gift sale is explicit and leaves the other slot intact")
	var dismantle_before = restored.state.scrap
	check(restored.command("dismantle_gift", 0) == "OK" and restored.state.scrap > dismantle_before and restored.state.gifts.is_empty(), "Gift dismantle is explicit and deterministic")

	var baseline = Sim.new()
	baseline.start(0, 147, "optional")
	s.start(0, 147, "optional")
	s.state.gifts = ["gift.spare_hand"]
	baseline.state.position = machine_p
	s.state.position = machine_p
	baseline.step(Vector2.RIGHT)
	s.step(Vector2.RIGHT)
	check(s.state.machines[0].progress > baseline.state.machines[0].progress, "Spare Hand completes optional work faster")
	check(s.state.position.distance_to(machine_p) < baseline.state.position.distance_to(machine_p), "Spare Hand slows movement only during work exposure")

	# Destination ownership keeps carried Workshop machines inert and redirects Halo to visible route work.
	s.start(0, 147, "optional")
	s.state.wave = 8
	s.state.boss_dead = true
	s.step(Vector2.ZERO)
	s.command("continue_site_clear")
	s.state.scrap = 20
	s.command("choose_route", "route.rootworks")
	while s.state.phase == "travel":
		var free_choice = s.current_road_node().choices.filter(func(choice): return int(choice.cost) == 0)[0]
		s.command("choose_road_option", free_choice.id)
	if s.state.phase == "arrival": s.command("begin_site")
	var pump = Vector2(s.objective_data().nodes[0].position[0], s.objective_data().nodes[0].position[1])
	s.state.position = pump + Vector2(70, 0)
	s.state.weapons = [weapon("weapon.welded_halo")]
	var carried_machine_progress = s.state.machines[0].progress
	s.update_weapons()
	check(s.state.objective[0].progress == s.config.weapons["weapon.welded_halo"].repair_progress, "Halo repairs the current visible destination objective")
	check(s.state.machines[0].progress == carried_machine_progress, "Halo never mutates carried Workshop machines at a destination")
	s.state.gifts = ["gift.spare_hand"]
	var before_destination_move = s.state.position
	s.step(Vector2.RIGHT)
	check(is_equal_approx(s.state.position.distance_to(before_destination_move), float(s.config.saint.speed) / s.config.tick_rate), "Spare Hand does not apply invisible Workshop work slowdown at a destination")

	s.start(0, 147, "optional")
	s.state.gifts = ["gift.inspection_lens"]
	s.spawn(s.config.elite)
	check(s.state.enemies.back().inspected and s.state.inspection != "" and s.events.any(func(e): return e.kind == "inspection"), "Inspection Lens reveals and highlights the next major rule")
	var scrap_before = s.state.scrap
	s.collect_scrap(5)
	check(s.state.scrap == scrap_before + 4, "Inspection Lens spends exactly every fifth ordinary Scrap")

	s.start(0, 147, "optional")
	s.enter_shop()
	s.state.gifts = ["gift.black_ledger"]
	s.state.weapons.append(weapon("weapon.bell_last_shift"))
	var refund_before = s.state.scrap
	check(s.command("dismantle", 0) == "OK", "Black Ledger still uses the explicit dismantle command")
	check(s.state.scrap - refund_before == 3 and s.state.component_tag == "labour", "Black Ledger trades refund for a deterministic component tag")
	check(s.state.offers[1] in s.config.weapons and s.state.component_tag in s.catalogue[s.state.offers[1]].tags, "Black Ledger guarantees one matching workshop lead")

	print("ASSEMBLY: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
