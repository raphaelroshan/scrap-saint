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
	var sim = Sim.new()
	sim.start(0, 147, "optional")
	sim.state.weapons.clear()
	for i in range(300): sim.step(Vector2.ZERO)
	check(sim.state.enemies.size() >= 3, "wave one establishes contact promptly")
	check(sim.state.enemies.all(func(e): return e.type in ["enemy.scrap_mite", "enemy.rivet_hound"]), "wave one uses only authored primary and support families")
	check(sim.state.metrics.first_contact_tick > 0 and sim.state.metrics.first_contact_tick <= 100, "first-contact metric records the authored arrival")
	check(sim.state.metrics.longest_threat_gap <= 100, "opening travel gap remains bounded")

	for profile in sim.config.wave_profiles:
		check(profile.primary in sim.config.enemies and profile.support.all(func(id): return id in sim.config.enemies), profile.name + " references enabled enemies")
		check(not profile.pressure.is_empty() and not profile.counters.is_empty(), profile.name + " explains pressure and counter families")
	for id in sim.config.weapons:
		var weapon = sim.config.weapons[id]
		check(not weapon.role.is_empty() and not weapon.weakness.is_empty(), id + " has a role and preserved weakness")
		check(not weapon.counter_families.is_empty(), id + " names at least one intended matchup")

	sim.start(2, 104729, "optional")
	sim.state.position = Vector2(-70, 450)
	for i in range(180): sim.update_optional_repairs()
	check(sim.state.machines[0].complete and sim.state.metrics.useful_repairs == 1, "repair-seeking route earns one useful machine reward")
	check(sim.state.scrap_sources.optional_repair == 8, "repair economy records its source")

	sim.start(0, 147, "optional")
	sim.state.wave = 8
	sim.spawn(sim.config.boss)
	var boss = sim.state.enemies[0]
	sim.state.tick = int(sim.config.boss_rules.hazard_interval)
	sim.update_enemies()
	check(boss.phase == 0 and sim.state.hazards.size() == 3, "Foreman demolition phase marks a three-pocket route")
	sim.state.hazards.clear()
	boss.hp = boss.max_hp * 0.5
	sim.state.tick = int(sim.config.boss_rules.hazard_interval) * 2
	sim.update_enemies()
	check(boss.phase == 1 and sim.state.hazards.size() == 3, "Foreman worker phase changes its route geometry")
	sim.state.hazards.clear()
	boss.hp = boss.max_hp * 0.2
	sim.state.tick = int(sim.config.boss_rules.hazard_interval) * 3
	sim.update_enemies()
	check(boss.phase == 2 and sim.state.hazards.size() == 4, "Foreman final orders close one additional lane")
	sim.state.tick = int(sim.config.boss_rules.worker_interval) * 3
	sim.update_enemies()
	check(sim.state.enemies.any(func(e): return e.get("worker", false)), "Foreman workers are authoritative identifiable priority targets")

	sim.start(2, 104729, "optional")
	sim.state.wave = 5
	sim.state.damage["weapon.candle_nailer"] = 240.0
	sim.state.kills_by_weapon["weapon.candle_nailer"] = 12
	sim.state.hp = 8
	sim.state.tick = 100
	sim.hurt_saint(8, "enemy.cinder_spitter")
	sim.finish(false, "The Saint's structure failed.")
	check(sim.state.result_summary.failure_cause == "THREAT_RESPONSE", "ranged failure is classified from the authoritative damage source")
	check(sim.state.result_summary.top_weapon == "weapon.candle_nailer" and sim.state.result_summary.worst_damage_wave == 5, "Results identify contribution and largest-loss wave")
	check(not sim.state.result_summary.replay_cue.is_empty(), "Results name one grounded next experiment")

	print("ROAMING QUALITY: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
