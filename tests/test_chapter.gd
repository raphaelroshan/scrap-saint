extends SceneTree
const Sim = preload("res://game/simulation.gd")
var failures = 0
var checks = 0

func check(ok: bool, message: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("CHAPTER FAIL: ", message)

func reach_route(sim):
	sim.state.wave = 8
	sim.state.boss_dead = true
	sim.step(Vector2.ZERO)

func finish_travel(sim):
	while sim.state.phase == "travel":
		check(sim.command("advance_travel") == "OK", "travel beat advances")

func _initialize():
	var sim = Sim.new()
	sim.start(0, 147, "optional")
	check(sim.command("choose_route", "route.brass_choir") == "OUTSIDE_WINDOW", "route choice rejected before Foreman victory")
	reach_route(sim)
	check(sim.state.phase == "route" and sim.routes.size() == 2 and sim.state.scrap >= 8, "Foreman victory opens exactly two affordable routes")
	var before_invalid = sim.snapshot()
	check(sim.command("choose_route", "route.unknown") == "INVALID_ROUTE", "unknown route rejected")
	check(sim.snapshot() == before_invalid, "invalid route does not mutate state")

	sim.state.scrap = 40
	sim.state.weapons.append(sim.make_weapon("weapon.bell_last_shift", 2))
	sim.state.reserve.append(sim.make_weapon("weapon.procession_gear"))
	sim.state.catalysts.append("catalyst.quiet_gear")
	var carried_weapons = sim.state.weapons.duplicate(true)
	var carried_reserve = sim.state.reserve.duplicate(true)
	var carried_catalysts = sim.state.catalysts.duplicate(true)
	check(sim.command("choose_route", "route.brass_choir") == "OK", "Brass Choir route accepted")
	check(sim.state.phase == "travel" and sim.state.scrap == 32, "route cost is authoritative")
	check(sim.command("choose_route", "route.rootworks") == "OUTSIDE_WINDOW", "route cannot be changed during travel")
	check(sim.command("advance_travel") == "OK", "first travel beat advances")
	var travel_save = sim.snapshot()
	var restored = Sim.new()
	check(restored.restore(travel_save), "travel save restores")
	check(restored.state_hash() == sim.state_hash() and restored.arena.data.id == "arena.collapsed_workshop", "travel save preserves deterministic pre-arrival arena and route")
	finish_travel(sim)
	check(sim.state.site_id == "site.brass_choir_relay" and sim.arena.data.id == "arena.brass_choir_relay", "Brass Choir arrival loads authored arena")
	check(sim.state.weapons == carried_weapons and sim.state.reserve == carried_reserve and sim.state.catalysts == carried_catalysts, "build carries into destination unchanged")
	check(sim.current_enemy_pool() == ["enemy.choir_drone", "enemy.cinder_spitter", "enemy.rivet_hound"] and sim.current_boss_id() == "boss.choir_regent", "Brass route owns enemy pool and boss")

	var brass_objective = sim.objective_data()
	var brass_node = Vector2(brass_objective.nodes[0].position[0], brass_objective.nodes[0].position[1])
	sim.state.position = brass_node
	sim.spawn("enemy.rivet_hound")
	sim.state.enemies[-1].p = brass_node + Vector2(30, 0)
	sim.update_destination_objective()
	check(sim.state.objective[0].progress == 0, "Brass calibration pauses while the relay ring is unsafe")
	sim.state.enemies.clear()
	for i in range(int(brass_objective.required_ticks)): sim.update_destination_objective()
	check(sim.state.objective[0].complete and not sim.state.objective_complete, "Brass nodes persist independently")
	for node in sim.state.objective: node.complete = true
	sim.state.objective_complete = true
	sim.state.wave = sim.current_wave_count()
	sim.state.boss_dead = true
	sim.step(Vector2.ZERO)
	check(sim.state.phase == "memory" and sim.state.memory_id == "memory.borrowed_bell", "Brass completion opens its authored memory")
	var brass_memory_save = sim.snapshot()
	check(restored.restore(brass_memory_save) and restored.state.phase == "memory", "memory state saves and restores")
	check(sim.command("accept_memory") == "OK" and sim.state.phase == "won" and sim.state.chapter_complete, "accepting memory completes chapter")

	var root = Sim.new()
	root.start(2, 104729, "optional")
	reach_route(root)
	root.state.scrap = 30
	check(root.command("choose_route", "route.rootworks") == "OK", "Rootworks route accepted")
	finish_travel(root)
	check(root.state.site_id == "site.rootworks_pump" and root.current_boss_id() == "boss.factory_heart", "Rootworks arrival owns arena and boss")
	var root_objective = root.objective_data()
	var pump = Vector2(root_objective.nodes[0].position[0], root_objective.nodes[0].position[1])
	root.state.position = pump
	root.spawn("enemy.forklift_brute")
	root.state.enemies[-1].p = pump + Vector2(25, 0)
	root.update_destination_objective()
	check(root.state.objective[0].progress > 0, "Rootworks repair advances under nearby pressure")
	var destination_save = root.snapshot()
	var root_restored = Sim.new()
	check(root_restored.restore(destination_save), "destination save restores")
	check(root_restored.state_hash() == root.state_hash() and root_restored.arena.data.id == "arena.rootworks_pump", "destination save preserves route, arena and objective state")
	root.state.wave = root.current_wave_count()
	root.state.boss_dead = true
	root.step(Vector2.ZERO)
	check(root.state.phase == "combat", "boss defeat cannot bypass unfinished destination objective")
	for node in root.state.objective: node.complete = true
	root.state.objective_complete = true
	root.step(Vector2.ZERO)
	check(root.state.phase == "memory" and root.state.memory_id == "memory.borrowed_arm", "Rootworks completion opens its authored memory")

	print("CHAPTER TESTS: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
