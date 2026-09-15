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
	a.start(1,147,"optional")
	a.state.wave = 8
	a.state.boss_dead = true
	a.state.relay_hp = 0
	a.step(Vector2.ZERO)
	check(a.state.phase == "route" and a.state.machines.all(func(m): return not m.complete), "Foreman victory opens routes without any repairs or relay integrity")
	a.start(1,147,"optional")
	a.state.hp = 0
	a.step(Vector2.ZERO)
	check(a.state.phase == "lost", "Saint death still loses")
	a.start(1,147,"optional")
	a.state.position = Vector2(-70,450)
	for i in range(90): a.step(Vector2.ZERO)
	var progress = a.state.machines[0].progress
	a.state.position = Vector2(550,450)
	a.step(Vector2.ZERO)
	check(a.state.machines[0].progress == progress, "partial repair persists outside zone")
	a.command("pause")
	a.state.position = Vector2(-70,450)
	a.step(Vector2.ZERO)
	check(a.state.machines[0].progress == progress, "pause stops repair")
	a.command("pause")
	b.restore(a.snapshot())
	for i in range(90):
		a.step(Vector2.ZERO)
		b.step(Vector2.ZERO)
	check(a.state_hash() == b.state_hash() and a.state.machines[0].complete, "save and replay preserve completion")
	var scrap = a.state.scrap
	for i in range(60): a.step(Vector2.ZERO)
	check(a.state.scrap == scrap, "completed repair cannot reward twice")
	a.start(1,147,"optional")
	a.state.hp = 50
	a.state.position = Vector2(550,70)
	for i in range(180): a.update_optional_repairs()
	check(a.state.hp == 80, "pump restores 30 integrity")
	a.state.position = Vector2(1150,560)
	a.spawn("enemy.rivet_hound")
	for i in range(180): a.update_optional_repairs()
	check(a.state.enemies[0].stun == a.state.tick + 180, "bell machine staggers existing enemies")
	a.enter_shop()
	a.state.position = Vector2(-70,450)
	a.step(Vector2.ZERO)
	check(a.state.machines[0].progress == 0, "shop stops repair")
	a.start(0,147,"optional")
	b.start(0,147,"optional")
	a.spawn("enemy.rivet_hound")
	b.spawn("enemy.rivet_hound")
	check(a.state.enemies[0].p == b.state.enemies[0].p, "same seed reproduces roaming spawn")
	a.damage_relay(999,"test")
	check(a.state.relay_damage_sources.is_empty(), "optional machines take no relay damage")
	b.start(0,147,"relay")
	var legacy = b.snapshot()
	legacy.erase("mode")
	legacy.erase("machines")
	check(a.restore(legacy) and not a.optional_mode(), "legacy saves remain defence mode")
	print("OPTIONAL REPAIRS: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
