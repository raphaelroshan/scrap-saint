extends SceneTree
const Sim = preload("res://game/simulation.gd")
var failures = 0
var checks = 0

func check(ok: bool, message: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("FRAME/PROGRESSION FAIL: ", message)

func _initialize():
	var pilgrim = Sim.new()
	pilgrim.start(0, 147, "optional", "frame.pilgrim", "frames-pilgrim")
	check(pilgrim.state.max_hp == 100 and pilgrim.state.move_speed == 225, "Pilgrim uses balanced frame data")
	var surveyor = Sim.new()
	surveyor.start(0, 147, "optional", "frame.surveyor", "frames-surveyor")
	check(surveyor.state.max_hp == 85 and surveyor.state.move_speed == 250, "Surveyor trades structure for movement")
	var keeper = Sim.new()
	keeper.start(0, 147, "optional", "frame.keeper", "frames-keeper")
	check(keeper.state.max_hp == 120 and keeper.state.move_speed == 200, "Keeper trades movement for structure")
	var fallback = Sim.new()
	fallback.start(0, 147, "optional", "frame.missing")
	check(fallback.state.frame_id == "frame.pilgrim", "unknown frame falls back safely")

	var repair_data = surveyor.config.optional_repairs.machines[0]
	surveyor.state.position = Vector2(repair_data.position[0], repair_data.position[1])
	surveyor.step(Vector2.ZERO)
	var started = surveyor.state.machines[0].progress
	surveyor.state.position += Vector2(surveyor.config.optional_repairs.radius + 20, 0)
	for i in range(20): surveyor.step(Vector2.ZERO)
	check(surveyor.state.machines[0].progress > started, "Surveyor repair grace continues after leaving the ring")
	for i in range(60): surveyor.step(Vector2.ZERO)
	var expired = surveyor.state.machines[0].progress
	for i in range(10): surveyor.step(Vector2.ZERO)
	check(surveyor.state.machines[0].progress == expired and surveyor.state.active_machine == "", "Surveyor grace expires and pauses work")

	var procession = Sim.new()
	procession.start(3, 147, "relay", "frame.pilgrim", "frames-procession")
	check(procession.state.doctrine == 3 and procession.state.weapons[0].id == "weapon.procession_gear", "Procession starts with its authored Gear")
	procession.state.weapons.append(procession.make_weapon("weapon.foundry_censer"))
	procession.update_fulfilment()
	check(procession.state.fulfilled, "two Orbit weapons fulfil Procession")
	procession.enter_shop()
	procession.state.scrap = 100
	procession.state.offers[5] = "service.doctrine"
	check(procession.command("buy", 5) == "OK" and procession.state.service_active, "Procession service is purchasable")

	var ordinary = Sim.new()
	ordinary.start(3, 147, "optional")
	ordinary.spawn("enemy.rivet_hound")
	var ordinary_target = ordinary.state.position + Vector2.from_angle(0.045) * 105
	ordinary.state.enemies[0].p = ordinary_target
	ordinary.state.enemies[0].stun = 999
	var ordinary_hp = ordinary.state.enemies[0].hp
	ordinary.step(Vector2.ZERO)
	var escorted = Sim.new()
	escorted.start(3, 147, "optional")
	escorted.state.service_active = true
	escorted.spawn("enemy.rivet_hound")
	escorted.state.enemies[0].p = ordinary_target
	escorted.state.enemies[0].stun = 999
	var escorted_hp = escorted.state.enemies[0].hp
	escorted.step(Vector2.ZERO)
	check(ordinary.state.enemies[0].hp == ordinary_hp and escorted.state.enemies[0].hp < escorted_hp, "Escort formation visibly widens orbit reach")

	procession.state.route = "route.rootworks"
	procession.enter_destination(procession.current_route())
	procession.state.completed_site_ids = ["site.collapsed_workshop", "site.rootworks_pump"]
	procession.state.defeated_boss_ids = ["boss.foreman_engine", "boss.factory_heart"]
	procession.state.memory_id = "memory.borrowed_arm"
	procession.state.evolutions = ["evolution.great_toll"]
	procession.finish(true, "Recorded.")
	var summary = procession.state.result_summary
	check(summary.run_id == "frames-procession" and summary.won, "Results expose stable run identity and outcome")
	check(summary.completed_site_ids.size() == 2 and summary.defeated_boss_ids.size() == 2, "Results expose complete expedition history")
	check(summary.memory_ids == ["memory.borrowed_arm"] and summary.evolution_ids == ["evolution.great_toll"], "Results expose durable discoveries")

	var restored = Sim.new()
	check(restored.restore(procession.snapshot()), "integrated frame save restores")
	check(restored.state.frame_id == "frame.pilgrim" and restored.state.run_id == "frames-procession", "frame and run identity survive save")

	print("FRAMES/PROGRESSION: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
