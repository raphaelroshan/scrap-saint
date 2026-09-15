extends SceneTree
const Sim = preload("res://game/simulation.gd")

func _initialize():
	var sim = Sim.new()
	sim.start(3, 147, "optional", "frame.surveyor", "benchmark-peak-density")
	sim.state.hp = 1_000_000.0
	sim.state.max_hp = 1_000_000.0
	sim.state.weapons = [
		sim.make_weapon("weapon.foundry_censer", 3),
		sim.make_weapon("weapon.penance_winch", 3),
		sim.make_weapon("weapon.welded_halo", 3),
		sim.make_weapon("weapon.altar_mortar", 3)
	]
	var roster = ["enemy.rivet_hound", "enemy.choir_drone", "enemy.scrap_mite", "enemy.rust_pilgrim", "enemy.forklift_brute", "enemy.cinder_spitter"]
	for i in range(int(sim.config.combat.enemy_limit)):
		sim.spawn(roster[i % roster.size()])
		sim.state.enemies[-1].hp = 1_000_000.0
		sim.state.enemies[-1].max_hp = 1_000_000.0
	var ticks = 1800
	var started = Time.get_ticks_usec()
	for tick in range(ticks):
		sim.step(Vector2.from_angle(tick * 0.017))
	var elapsed_seconds = maxf(0.000001, (Time.get_ticks_usec() - started) / 1_000_000.0)
	var result = {
		"benchmark": "65 persistent threats / four Rank III weapons / 1800 simulation ticks",
		"processor": OS.get_processor_name(),
		"godot": Engine.get_version_info().string,
		"elapsed_seconds": elapsed_seconds,
		"simulation_ticks_per_second": ticks / elapsed_seconds,
		"realtime_multiple_at_60hz": (ticks / elapsed_seconds) / 60.0,
		"enemy_count": sim.state.enemies.size(),
		"hazard_count": sim.state.hazards.size()
	}
	DirAccess.make_dir_recursive_absolute("res://artifacts/agent-iteration")
	var output = FileAccess.open("res://artifacts/agent-iteration/peak_density_benchmark.json", FileAccess.WRITE)
	output.store_string(JSON.stringify(result, "  "))
	print("PEAK DENSITY BENCHMARK: ", JSON.stringify(result))
	quit(0 if sim.state.enemies.size() <= int(sim.config.combat.enemy_limit) and float(result.realtime_multiple_at_60hz) >= 1.0 else 1)
