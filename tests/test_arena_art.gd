extends SceneTree
var failures = 0
var checks = 0
func check(ok: bool, label: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("ARENA ART FAIL: ",label)
func _initialize(): call_deferred("run")
func run():
	var game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.set_physics_process(false)
	game.screen = "game"
	game.sim.start(0,147,"optional")
	var before = game.sim.state_hash()
	game.queue_redraw()
	await process_frame
	check(before == game.sim.state_hash(), "drawing does not mutate simulation")
	var art = game.arena_art
	for file in DirAccess.get_files_at("res://content/arenas"):
		if not file.ends_with(".json"): continue
		game.sim.arena.load_file("res://content/arenas/"+file)
		for machine in game.sim.arena.data.obstacles:
			var obstacle: Rect2 = game.sim.arena.rect(machine.rect)
			var key: String = art.machine_key(machine)
			check((key == "service_manifold") == (obstacle.size.x > obstacle.size.y), "horizontal machinery uses dedicated artwork")
			var target: Rect2 = art.fit_rect(obstacle,art.regions[key])
			check(obstacle.encloses(target),"painted silhouette inside collision footprint")
			check(is_equal_approx(target.size.aspect(),art.regions[key].size.aspect()),"art aspect ratio preserved")
	for key in ["scrap","repair_kit","relic_shard"]:
		check(art.regions[key].size.x > 0 and art.regions[key].size.y > 0,"pickup region exists")
	game.queue_free()
	await process_frame
	print("ARENA ART: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
