extends SceneTree
const Sim = preload("res://game/simulation.gd")
var checks = 0
var failures = 0
func check(ok, label):
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", label)
func _initialize():
	for seed_value in [147,104729,104730]:
		for doctrine in range(4):
			var a = Sim.new()
			a.start(doctrine,seed_value,"optional")
			a.enter_shop()
			check(a.state.offers.size() == 6 and a.state.offers.all(func(id): return id in a.catalogue), "six relics")
			var unique = {}
			for id in a.state.offers: unique[id] = true
			check(unique.size() == 6, "no duplicate offers")
			check(a.purchase_preview(0).result == "OK", "affordable first improvement")
			a.command("lock", 1)
			var held = a.state.locked
			var b = Sim.new()
			b.restore(a.snapshot())
			a.command("reroll")
			b.command("reroll")
			check(a.state_hash() == b.state_hash() and held in a.state.offers, "lock and reload repeat")
	var sim = Sim.new()
	sim.start(0,147,"optional")
	sim.enter_shop()
	sim.state.offers[0] = "service.repair"
	var before = sim.state_hash()
	check(sim.purchase_preview(0).result == "INVALID_OFFER" and sim.buy(0) == "INVALID_OFFER" and before == sim.state_hash(), "main-mode services reject atomically")
	var migrated = Sim.new()
	check(migrated.restore(sim.snapshot()) and migrated.state.offers.all(func(id): return not id.begins_with("service.")), "legacy service shops migrate")
	sim.start(0,147,"optional")
	sim.state.pickups = [{"p":sim.state.position,"kind":"repair_kit","amount":15}]
	sim.update_pickups()
	check(sim.state.pickups.size() == 1, "full health preserves kit")
	sim.state.hp = 93
	sim.update_pickups()
	check(sim.state.hp == 100 and sim.state.pickups.is_empty(), "kit caps healing and consumes once")
	sim.state.hp = 80
	sim.update_pickups()
	check(sim.state.hp == 80, "no duplicate healing")
	sim.state.kills = 11
	sim.spawn("enemy.scrap_mite")
	sim.state.enemies[0].hp = 1
	sim.state.enemies[0].p = sim.state.position + Vector2(60,0)
	sim.update_weapons()
	check(sim.state.pickups.any(func(p): return p.kind == "repair_kit"), "twelfth defeat produces field kit")
	for route in sim.chapter.routes:
		var a = Sim.new()
		a.start(0,147,"optional")
		a.state.route = route.id
		a.enter_destination(route)
		a.state.wave = int(route.wave_count)
		a.state.boss_spawned = true
		a.state.boss_dead = true
		a.step(Vector2.ZERO)
		check(a.state.phase == "site_clear" and not a.state.objective_complete, "unfinished optional work never blocks destination")
		a.start(0,147,"optional")
		a.state.route = route.id
		a.enter_destination(route)
		var scrap = a.state.scrap
		a.advance_destination_node(0,9999,a.state.position)
		a.advance_destination_node(0,9999,a.state.position)
		check(a.state.scrap == scrap + a.config.optional_repairs.destination_node_scrap, "optional work rewards exactly once")
	print("SYNC CONTRACT: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
