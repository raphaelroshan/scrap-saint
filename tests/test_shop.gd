extends SceneTree
const Sim = preload("res://game/simulation.gd")
var checks = 0
var failures = 0
func check(ok: bool, label: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", label)
func _initialize():
	var a = Sim.new()
	var b = Sim.new()
	a.start()
	a.enter_shop()
	var rng = a.state.rng
	var tick = a.state.tick
	a.command("reroll")
	check(a.state.rng == rng and a.state.tick == tick, "shop randomness never consumes combat RNG or time")
	b.restore(a.snapshot())
	a.command("reroll")
	b.command("reroll")
	check(a.state.offers == b.state.offers, "saved context repeats offers")
	check(a.state.offers.size() == 6 and a.config.shop_rules.roles.size() == 6, "six explicit roles")
	a.start()
	a.enter_shop()
	a.state.weapons[0].rank = 3
	a.state.evolved = true
	a.state.weapons[0].rail = true
	for id in a.config.catalysts: a.state.catalysts.append(id)
	a.roll_shop()
	check(a.state.offers.slice(0, 4).count("service.calibrate") <= 1, "fallback calibration is never duplicated")
	check(a.state.offers.slice(0, 4).all(func(id): return id not in a.config.catalysts), "owned catalysts excluded")
	a.start(2, 104729, "optional")
	a.enter_shop()
	check(a.state.offers[0] in a.catalogue and a.catalogue[a.state.offers[0]].get("cost_scrap", 999) <= a.state.scrap, "normal shop guarantees affordable build action")
	var forecast = a.forecast_data()
	check(forecast.primary != "" and not forecast.counters.is_empty(), "shop forecast exposes authored pressure and counters")
	for doctrine in range(3):
		a.start(doctrine)
		a.enter_shop()
		a.state.scrap = 0
		var before = a.state_hash()
		check(a.buy(5) == "INSUFFICIENT_SCRAP" and a.state_hash() == before, "service rejects atomically")
		a.state.scrap = 50
		a.state.hp = 50
		a.state.relay_hp = 100
		check(a.command("buy", 5) == "OK", "doctrine service buys")
		a.state.offers[5] = "service.doctrine"
		check(a.command("buy", 5) == "SERVICE_USED", "doctrine service once per visit")
		a.command("continue")
		if doctrine == 0: check(a.state.hp == 70 and a.state.relay_hp == 145, "Workshop restores both structures")
		if doctrine == 1: check(a.warning_multiplier() == 1.5, "Bell extends actual warnings")
		if doctrine == 2:
			a.spawn("enemy.rivet_hound")
			a.state.enemies[0].p = a.state.position + Vector2(50, 0)
			a.state.enemies[0].hp = 1
			a.update_weapons()
			check(a.state.motes_left == 5 and a.state.pickups.any(func(p): return p.kind == "mote"), "Mourner service spends a charge on real defeat")
		a.enter_shop()
		check(not a.state.service_active and a.state.motes_left == 0 and a.warning_multiplier() == 1.0, "service expires at next workshop")
	a.state.offers[0] = "service.calibrate"
	a.state.scrap = 50
	check(a.command("buy", 0) == "OK" and a.state.calibrated, "calibration fallback applies")
	a.state.offers[0] = "service.calibrate"
	check(a.command("buy", 0) == "SERVICE_USED", "calibration cannot stack")
	print("SHOP: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
