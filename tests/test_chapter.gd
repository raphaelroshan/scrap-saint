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
		var node = sim.current_road_node()
		var free_choice = node.choices.filter(func(choice): return int(choice.cost) == 0)[0]
		check(sim.command("choose_road_option", free_choice.id) == "OK", "authored road choice advances")

func _initialize():
	var sim = Sim.new()
	sim.start(0, 147, "optional")
	sim.hurt_saint(4, "test.workshop")
	sim.record_scrap("test_income", 1)
	check(sim.command("choose_route", "route.brass_choir") == "OUTSIDE_WINDOW", "route choice rejected before Foreman victory")
	reach_route(sim)
	check(sim.state.phase == "route" and sim.routes.size() == 5 and sim.available_routes().map(func(route): return route.id) == ["route.brass_choir", "route.rootworks"] and sim.state.scrap >= 8, "Foreman victory opens exactly the two affordable mid-site routes")
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
	check(sim.command("advance_travel") == "ROAD_CHOICE_REQUIRED", "travel cannot bypass an in-between area")
	check(sim.command("choose_road_option", "choice.brass.splice") == "OK", "first road encounter resolves through its authored choice")
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
	check(sim.state.hp == sim.saint_max_structure() * 0.6, "road rest repairs only to the authored floor without erasing road consequences")
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
	check(sim.state.road_history.size() == 2 and sim.state.assignment_statuses["route.brass_choir"] == "accepted", "mid-site memory preserves the accepted assignment and every road decision")
	var scrap_before_mid_memory = sim.state.scrap
	check(sim.command("accept_memory") == "OK" and sim.state.phase == "route" and not sim.state.chapter_complete, "accepting a mid-site memory continues the pilgrimage")
	check(sim.state.memory_ids == ["memory.borrowed_bell"] and sim.state.scrap == scrap_before_mid_memory, "mid-site memory and previously granted road salvage persist")
	check(sim.available_routes().map(func(route): return route.id) == ["route.pale_archive", "route.red_foundry"], "Brass Choir opens only Pale Archive and Red Foundry")
	var before_disconnected = sim.snapshot()
	check(sim.command("choose_route", "route.null_assembly") == "ROUTE_NOT_CONNECTED" and sim.snapshot() == before_disconnected, "disconnected terminal route rejects without mutation")
	check(sim.command("choose_route", "route.pale_archive") == "OK", "Pale Archive accepts the Brass road")
	finish_travel(sim)
	check(sim.state.site_id == "site.pale_archive" and sim.arena.data.id == "arena.pale_archive" and sim.current_boss_id() == "boss.archivist_prime", "Pale Archive arrival loads authored site and boss")
	var archive_objective = sim.objective_data()
	var origin_record = Vector2(archive_objective.nodes[0].position[0], archive_objective.nodes[0].position[1])
	var purpose_record = Vector2(archive_objective.nodes[1].position[0], archive_objective.nodes[1].position[1])
	sim.state.position = purpose_record
	sim.update_destination_objective()
	check(sim.state.objective[1].progress == 0, "Archive rejects a record recovered out of order")
	sim.state.position = origin_record
	for i in range(int(archive_objective.required_ticks)): sim.update_destination_objective()
	check(sim.state.objective[0].complete and sim.active_destination_node_index() == 1, "Archive advances to the next ordered record")
	sim.state.enemies.clear()
	sim.state.hazards.clear()
	sim.state.evolutions = ["evolution.great_toll"]
	sim.spawn(sim.current_boss_id())
	var archivist = sim.state.enemies[-1]
	archivist.hp = archivist.max_hp * 0.5
	var archive_phase = sim.bosses[archivist.type].phases[1]
	sim.state.tick = int(archivist.spawn_tick) + int(archive_phase.interval)
	sim.update_enemies()
	check(sim.state.hazards.size() == 1 and sim.state.hazards[0].copy and sim.state.hazards[0].copy_shape == "radial", "Archivist copies the latest explicit evolution geometry")
	for node in sim.state.objective: node.complete = true
	sim.state.objective_complete = true
	sim.state.enemies.clear()
	sim.state.hazards.clear()
	sim.state.wave = sim.current_wave_count()
	sim.state.boss_dead = true
	sim.step(Vector2.ZERO)
	check(sim.state.phase == "memory" and sim.state.memory_id == "memory.borrowed_lens", "Pale Archive opens its terminal memory")
	check(sim.command("accept_memory") == "OK" and sim.state.phase == "won" and sim.state.chapter_complete, "accepting a terminal memory completes the chapter")
	check(sim.state.result_summary.completed_site_ids == ["site.collapsed_workshop", "site.brass_choir_relay", "site.pale_archive"] and sim.state.result_summary.defeated_boss_ids == ["boss.foreman_engine", "boss.choir_regent", "boss.archivist_prime"], "Results expose all three completed sites and bosses")
	check(sim.state.result_summary.memory_ids == ["memory.borrowed_bell", "memory.borrowed_lens"] and sim.state.result_summary.route_ids == ["route.brass_choir", "route.pale_archive"], "Results preserve the complete route and memory history")
	check(sim.state.result_summary.route_id == "route.brass_choir" and sim.state.result_summary.terminal_route_id == "route.pale_archive", "Results retain the profile-compatible first route and explicit terminal route")
	check(sim.state.result_summary.road_history.size() == 4 and sim.state.result_summary.assignment_ids == ["assignment.brass_choir", "assignment.pale_archive"], "terminal Results preserve both assignments and every road decision")

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
	check(root.command("accept_memory") == "OK" and root.state.phase == "route", "Rootworks memory continues to a terminal route choice")
	check(root.available_routes().map(func(route): return route.id) == ["route.red_foundry", "route.null_assembly"], "Rootworks opens only Red Foundry and Null Assembly")
	check(root.command("choose_route", "route.pale_archive") == "ROUTE_NOT_CONNECTED", "Pale Archive rejects the disconnected Rootworks road")
	check(root.command("choose_route", "route.null_assembly") == "OK", "Null Assembly accepts the Rootworks road")
	finish_travel(root)
	check(root.state.site_id == "site.null_assembly" and root.arena.data.id == "arena.null_assembly" and root.current_boss_id() == "boss.null_auditor", "Null Assembly arrival loads authored site and boss")
	var null_objective = root.objective_data()
	var null_anchor = Vector2(null_objective.nodes[0].position[0], null_objective.nodes[0].position[1])
	root.state.position = null_anchor
	root.state.weapons[0].ready = 0
	root.spawn("enemy.scrap_mite")
	root.state.enemies[-1].p = null_anchor + Vector2(35, 0)
	var mite_hp = root.state.enemies[-1].hp
	root.update_weapons()
	check(root.state.enemies[-1].hp == mite_hp and root.state.weapons[0].ready == 0, "Null anchor work authoritatively quiets relic weapons")
	root.state.position = null_anchor + Vector2(float(null_objective.radius) + 30, 0)
	root.update_weapons()
	check((root.state.enemies.is_empty() or root.state.enemies[-1].hp < mite_hp) and root.state.weapons[0].ready > root.state.tick, "leaving the Null work ring immediately restores automatic weapons")
	root.state.enemies.clear()
	root.state.hazards.clear()
	root.spawn(root.current_boss_id())
	var auditor = root.state.enemies[-1]
	auditor.hp = auditor.max_hp * 0.2
	var auditor_phase = root.bosses[auditor.type].phases[2]
	root.state.tick = int(auditor.spawn_tick) + int(auditor_phase.interval)
	root.update_enemies()
	check(root.state.hazards.size() == 3 and root.state.weapon_lock_until > root.state.tick and root.state.objective_lock_until > root.state.tick, "Null Auditor final phase marks player and anchors while locking work and relic cycles")
	for node in root.state.objective: node.complete = true
	root.state.objective_complete = true
	root.state.enemies.clear()
	root.state.hazards.clear()
	root.state.wave = root.current_wave_count()
	root.state.boss_dead = true
	root.step(Vector2.ZERO)
	check(root.state.phase == "memory" and root.state.memory_id == "memory.unwritten_instruction", "Null Assembly opens its terminal memory")
	check(root.command("accept_memory") == "OK" and root.state.phase == "won" and root.state.memory_ids == ["memory.borrowed_arm", "memory.unwritten_instruction"], "Null terminal memory completes the full route history")

	var red = Sim.new()
	red.start(0, 147, "optional")
	red.state.phase = "route"
	red.state.site_id = "site.brass_choir_relay"
	red.state.route_history = ["route.brass_choir"]
	red.state.memory_ids = ["memory.borrowed_bell"]
	red.state.completed_site_ids = ["site.collapsed_workshop", "site.brass_choir_relay"]
	red.state.defeated_boss_ids = ["boss.foreman_engine", "boss.choir_regent"]
	red.state.scrap = 30
	check(red.command("choose_route", "route.red_foundry") == "OK", "Red Foundry accepts the Brass road")
	finish_travel(red)
	var red_destination_save = red.snapshot()
	var red_restored = Sim.new()
	check(red_restored.restore(red_destination_save) and red_restored.state_hash() == red.state_hash(), "terminal destination and full route history save deterministically")
	check(red.state.site_id == "site.red_foundry" and red.arena.data.id == "arena.red_foundry" and red.current_boss_id() == "boss.red_cardinal", "Red Foundry arrival loads authored site and boss")
	var foundry_objective = red.objective_data()
	var first_vent = Vector2(foundry_objective.nodes[0].position[0], foundry_objective.nodes[0].position[1])
	var second_vent = Vector2(foundry_objective.nodes[1].position[0], foundry_objective.nodes[1].position[1])
	red.state.position = second_vent
	red.update_destination_objective()
	check(red.state.objective[1].progress == 0 and red.active_destination_node_index() == 0, "Foundry accepts work only at the active vent")
	red.state.position = first_vent
	for i in range(int(foundry_objective.required_ticks)): red.update_destination_objective()
	red.state.wave_tick = int(foundry_objective.active_interval)
	check(red.state.objective[0].complete and red.active_destination_node_index() == 1, "Foundry rotation advances to the next unfinished vent")
	red.state.enemies.clear()
	red.state.hazards.clear()
	red.state.position = Vector2(470, 650)
	red.spawn(red.current_boss_id())
	var cardinal = red.state.enemies[-1]
	cardinal.hp = cardinal.max_hp * 0.2
	var cardinal_phase = red.bosses[cardinal.type].phases[2]
	red.state.tick = int(cardinal.spawn_tick) + int(cardinal_phase.interval)
	red.update_enemies()
	check(red.state.hazards.size() == 4 and red.state.hazards.all(func(hazard): return hazard.kind == "quota"), "Red Cardinal final quota ignites the Saint and three authored furnace anchors")
	check(red.state.enemies.any(func(enemy): return enemy.type == "enemy.cinder_spitter" and enemy.worker), "Red Cardinal calls a trace-labelled Cinder Spitter")
	for node in red.state.objective: node.complete = true
	red.state.objective_complete = true
	red.state.enemies.clear()
	red.state.hazards.clear()
	red.state.wave = red.current_wave_count()
	red.state.boss_dead = true
	red.step(Vector2.ZERO)
	check(red.state.phase == "memory" and red.state.memory_id == "memory.borrowed_shell", "Red Foundry opens its authored terminal memory")
	check(red.command("accept_memory") == "OK" and red.state.phase == "won" and red.state.result_summary.route_ids == ["route.brass_choir", "route.red_foundry"], "Red Foundry completes with deterministic route history")
	var red_from_root = Sim.new()
	red_from_root.start(0, 147, "optional")
	red_from_root.state.phase = "route"
	red_from_root.state.site_id = "site.rootworks_pump"
	red_from_root.state.scrap = 30
	check(red_from_root.command("choose_route", "route.red_foundry") == "OK", "shared Red Foundry node also accepts the Rootworks road")

	print("CHAPTER TESTS: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
