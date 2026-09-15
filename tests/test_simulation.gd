extends SceneTree
const Sim = preload("res://game/simulation.gd")
var failures = 0
var checks = 0

func check(ok: bool, message: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", message)

func _initialize():
	var a = Sim.new()
	var b = Sim.new()
	a.start(0, 147)
	b.start(0, 147)
	for i in range(1200):
		var movement = Vector2.from_angle(i * 0.013)
		a.step(movement)
		b.step(movement)
	check(a.state_hash() == b.state_hash(), "same seed and movement replay")
	a.command("pause")
	var tick = a.state.tick
	a.step(Vector2.ONE)
	check(a.state.tick == tick, "pause freezes authoritative time")
	a.command("pause")
	b.restore(a.snapshot())
	for i in range(240):
		a.step(Vector2.LEFT)
		b.step(Vector2.LEFT)
	check(a.state_hash() == b.state_hash(), "restored state continues identically")
	a.start()
	for i in range(600): a.step(Vector2(-20, 0))
	check(a.state.position.x >= a.config.arena[0], "movement clamped")
	a.state.position = a.relay_position()
	a.step(Vector2.ZERO)
	var progress = a.state.progress
	a.state.position = Vector2(150, 300)
	a.step(Vector2.ZERO)
	check(a.state.progress == progress, "repair progress persists outside radius")
	a.enter_shop()
	a.state.scrap = 0
	var before = a.state.weapons.duplicate(true)
	check(a.command("buy", 0) == "INSUFFICIENT_SCRAP", "overspend rejected")
	check(a.state.weapons == before and a.state.scrap == 0, "rejection preserves inventory and funds")
	a.state.scrap = 100
	for i in range(3):
		a.state.offers[0] = "weapon.nailer_small_mercies"
		check(a.command("buy", 0) == "OK", "duplicate purchase %d" % i)
	check(a.state.weapons.size() == 1 and a.state.weapons[0].rank == 3, "four copies combine to rank III")
	check(a.command("evolve") == "MISSING_INGREDIENT", "rank alone cannot evolve")
	a.state.shards = 2
	a.state.offers[2] = "catalyst.saints_rivet"
	check(a.command("buy", 2) == "OK", "buy catalyst")
	check(a.command("evolve") == "OK", "recipe evolves")
	check(a.state.weapons[0].rail and a.state.shards == 0 and a.state.catalysts.is_empty(), "evolution consumes catalyst once")
	check(a.command("evolve") == "MISSING_INGREDIENT", "cannot repeat evolution")
	a.start()
	a.enter_shop()
	a.state.scrap = 100
	for id in ["weapon.bell_last_shift", "weapon.procession_gear", "weapon.candle_nailer"]: a.state.weapons.append(a.make_weapon(id))
	a.state.reserve.append(a.make_weapon("weapon.nailer_small_mercies", 2))
	check(a.command("buy", 0) == "OK", "full slots purchase and combine validates final capacity")
	check(a.state.weapons.size() == 4 and a.state.reserve.is_empty() and a.state.weapons[0].rank == 3, "chain combination frees reserve")
	var saved = a.snapshot()
	b.restore(saved)
	check(a.command("reroll") == "OK" and b.command("reroll") == "OK", "free refresh accepted")
	check(a.state.offers == b.state.offers, "save/load preserves next shop roll")
	a.command("reroll")
	a.command("reroll")
	check(a.command("reroll") == "NO_REFRESHES", "refresh cap enforced")
	a.start()
	a.state.wave = 8
	a.state.progress = a.config.relay.required_ticks
	a.state.boss_dead = true
	a.step(Vector2.ZERO)
	check(a.state.phase == "route" and not a.state.evolved, "Foreman victory opens routes without requiring Mercy Rail")
	a.start()
	a.state.hp = 0
	a.step(Vector2.ZERO)
	check(a.state.phase == "lost", "death resolves run")
	a.start()
	a.state.wave = 6
	for i in range(220): a.step(Vector2.ZERO)
	check(a.has_major() and not a.state.evolved, "elite functions without evolution")
	a.start()
	a.state.relay_hp = 150
	a.state.position = a.relay_position()
	for i in range(60): a.step(Vector2.ZERO)
	check(a.state.relay_hp > 150 and a.state.repairs > 0, "repair causes measurable restoration")
	a.start()
	a.spawn("enemy.rivet_hound")
	a.state.enemies[0].p = a.state.position + Vector2(100, 0)
	a.state.enemies[0].stun = 9999
	var hp_before = a.state.enemies[0].hp
	a.step(Vector2.ZERO)
	check(a.state.enemies[0].hp < hp_before and a.events.any(func(e): return e.kind == "hit"), "authoritative hit emits feedback event")
	var hp_after = a.state.enemies[0].hp
	a.step(Vector2.ZERO)
	check(a.state.enemies[0].hp == hp_after, "cooldown prevents duplicate damage")
	a.start(1)
	a.spawn("enemy.rivet_hound")
	a.state.enemies[0].p = a.state.position + Vector2(70, 0)
	a.step(Vector2.ZERO)
	check(a.state.enemies[0].stun > a.state.tick, "Bell applies real stagger")
	a.start()
	a.state.hp = 70
	a.state.pickups.append({"p": a.state.position, "kind": "mote", "amount": 4})
	a.step(Vector2.ZERO)
	a.step(Vector2.ZERO)
	check(a.state.hp == 74 and a.state.pickups.is_empty(), "mote heals exactly once")
	a.enter_shop()
	a.state.weapons = [a.make_weapon("weapon.nailer_small_mercies", 3), a.make_weapon("weapon.nailer_small_mercies", 3)]
	a.state.catalysts = ["catalyst.saints_rivet"]
	a.command("evolve")
	check(a.state.weapons.filter(func(w): return w.rail).size() == 1, "one catalyst evolves only one weapon")
	a.start()
	b.start()
	b.state.evolved = true
	a.spawn("enemy.rivet_hound")
	b.spawn("enemy.rivet_hound")
	check(a.state.enemies[0].p == b.state.enemies[0].p, "ordinary spawn location independent of evolution")
	print("TESTS: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
