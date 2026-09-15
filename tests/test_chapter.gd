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
	sim.hurt_saint(4, "test.workshop")
	sim.record_scrap("test_income", 1)
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
	sim.state.service_used = true
	sim.state.service_active = true
	sim.state.calibrated = true
	sim.state.motes_left = 4
	sim.state.forecast = true
	sim.state.hp = 10
	finish_travel(sim)
	check(sim.state.site_id == "site.brass_choir_relay" and sim.arena.data.id == "arena.brass_choir_relay", "Brass Choir arrival loads authored arena")
	check(sim.state.hp == sim.saint_max_structure(), "road rest repairs structure to the authored arrival floor")
	check(not sim.state.service_used and not sim.state.service_active and not sim.state.calibrated and sim.state.motes_left == 0 and not sim.state.forecast, "arrival clears prior-wave services and timers")
	check(sim.state.weapons == carried_weapons and sim.state.reserve == carried_reserve and sim.state.catalysts == carried_catalysts, "build carries into destination unchanged")
	check(sim.current_enemy_pool() == ["enemy.choir_drone", "enemy.cinder_spitter", "enemy.rivet_hound"] and sim.current_boss_id() == "boss.choir_regent", "Brass route owns enemy pool and boss")
	check(sim.wave_profile().name == "OUT-OF-TIME ESCORT" and sim.wave_profile(2).primary == "enemy.cinder_spitter", "Brass route exposes authored wave identities")
	sim.state.tick = 73
	sim.spawn(sim.current_boss_id())
	var regent = sim.state.enemies[-1]
	sim.state.tick = int(sim.config.boss_rules.hazard_interval)
	sim.update_enemies()
	check(sim.state.hazards.is_empty(), "destination boss cadence ignores unrelated global tick multiple")
	var regent_phases = sim.bosses[sim.current_boss_id()].phases
	sim.state.tick = int(regent.spawn_tick) + int(regent_phases[0].interval)
	sim.update_enemies()
	check(sim.state.hazards.size() == 1 and sim.state.hazards[0].kind == "measure", "Regent measure begins with one player-centred warning relative to boss spawn")
	check(sim.state.pressure_until > sim.state.tick and sim.state.pressure_multiplier == 1.2, "Regent measure applies its authored weapon-cycle pressure")
	check(sim.events.any(func(event): return event.kind == "boss_contract" and event.phase_id == "measure"), "Regent measure emits its authoritative phase contract")
	var legacy_pressure_save = sim.snapshot()
	legacy_pressure_save.erase("pressure_multiplier")
	check(restored.restore(legacy_pressure_save) and restored.state.pressure_multiplier == sim.current_route().pressure.cooldown_multiplier, "pre-contract destination saves migrate the active route pressure multiplier")
	sim.state.hazards.clear()
	sim.events.clear()
	regent.hp = regent.max_hp * 0.5
	sim.state.tick = int(regent.spawn_tick) + int(regent_phases[1].interval) * 2
	sim.update_enemies()
	check(regent.phase == 1 and sim.state.hazards.size() == 3 and sim.state.hazards.all(func(hazard): return hazard.kind == "toll"), "Regent toll rings all three authored relay nodes")
	check(sim.events.any(func(event): return event.kind == "boss_phase" and event.name == "THE GRAND TOLL"), "Regent reports its data-owned second phase")
	sim.state.hazards.clear()
	sim.events.clear()
	regent.hp = regent.max_hp * 0.2
	sim.state.tick = int(regent.spawn_tick) + int(regent_phases[2].interval) * 3
	sim.update_enemies()
	check(regent.phase == 2 and sim.state.hazards.size() == 4 and sim.state.pressure_multiplier == 1.5, "Regent answer pressures the Saint and all three relay nodes at its strongest cadence")
	check(not sim.state.enemies.any(func(enemy): return enemy.get("worker", false)), "Regent never inherits the Foreman's worker contract")
	sim.state.enemies.clear()
	sim.state.tick += 1000
	sim.hurt_saint(3, "test.destination")
	sim.record_scrap("test_income", 2)
	check(sim.state.damage_by_wave.has("site.collapsed_workshop:wave_1") and sim.state.damage_by_wave.has("site.brass_choir_relay:wave_1"), "damage metrics separate identically numbered site waves")
	check(sim.state.scrap_by_segment.has("site.collapsed_workshop:wave_1") and sim.state.scrap_by_segment.has("site.brass_choir_relay:wave_1"), "economy metrics separate identically numbered site waves")

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
	check(sim.state.result_summary.completed_site_ids == ["site.collapsed_workshop", "site.brass_choir_relay"] and sim.state.result_summary.defeated_boss_ids == ["boss.foreman_engine", "boss.choir_regent"], "Results expose completed sites and defeated bosses")
	check("other road" in sim.state.result_summary.replay_cue, "chapter Results proposes the alternate route")

	var root = Sim.new()
	root.start(2, 104729, "optional")
	reach_route(root)
	root.state.scrap = 30
	check(root.command("choose_route", "route.rootworks") == "OK", "Rootworks route accepted")
	finish_travel(root)
	check(root.state.site_id == "site.rootworks_pump" and root.current_boss_id() == "boss.factory_heart", "Rootworks arrival owns arena and boss")
	check(root.wave_profile().name == "GRAFTED HANDS" and root.wave_profile(4).name == "THE HEART'S QUOTA", "Rootworks route exposes authored wave identities")
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
	root.state.enemies.clear()
	root.state.hazards.clear()
	root.spawn(root.current_boss_id())
	var heart = root.state.enemies[-1]
	var heart_phases = root.bosses[root.current_boss_id()].phases
	root.state.tick = int(heart.spawn_tick) + int(heart_phases[0].interval)
	root.update_enemies()
	check(root.state.hazards.size() == 1 and root.state.hazards[0].kind == "pulse" and root.state.hazards[0].p == pump, "Factory Heart pulse travels through the visible pump")
	check(root.state.objective_lock_until > root.state.tick and not root.destination_node_valid(0, pump, float(root_objective.radius)), "Factory Heart pulse temporarily suspends pump work")
	root.state.tick = root.state.objective_lock_until
	check(root.destination_node_valid(0, pump, float(root_objective.radius)), "pump work resumes at the authored lock boundary")
	root.state.hazards.clear()
	root.events.clear()
	heart.hp = heart.max_hp * 0.5
	root.state.tick = int(heart.spawn_tick) + int(heart_phases[1].interval) * 2
	root.update_enemies()
	check(heart.phase == 1 and root.state.enemies.any(func(enemy): return enemy.type == "enemy.rust_pilgrim" and enemy.worker), "Factory Heart graft-feed phase calls one trace-labelled repairer")
	check(root.events.any(func(event): return event.kind == "boss_contract" and event.phase_id == "feed") and root.events.any(func(event): return event.kind == "worker_called"), "Factory Heart feed emits contract and summon events")
	root.state.hazards.clear()
	root.events.clear()
	root.state.position = pump + Vector2(150, 0)
	heart.hp = heart.max_hp * 0.2
	root.state.tick = int(heart.spawn_tick) + int(heart_phases[2].interval) * 3
	root.update_enemies()
	check(heart.phase == 2 and root.state.hazards.size() == 2 and root.state.hazards.all(func(hazard): return hazard.kind == "choice"), "Factory Heart redline phase makes pump work compete with personal safety")
	var boss_save = root.snapshot()
	check(root_restored.restore(boss_save) and root_restored.state_hash() == root.state_hash(), "destination boss phase, objective lock and hazards save deterministically")
	root.state.enemies.clear()
	root.state.hazards.clear()
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
