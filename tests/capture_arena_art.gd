extends SceneTree
var game
var directory = "res://artifacts/arena-art/after"

func _initialize(): call_deferred("capture")

func save_frame(label: String):
	game.build_ui()
	game.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(directory.path_join(label + ".png"))
	print("ARENA ART: ", label, " hash=", game.sim.state_hash())

func capture():
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture-dir="): directory = arg.trim_prefix("--capture-dir=")
	DirAccess.make_dir_recursive_absolute(directory)
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.set_physics_process(false)
	game.sound.muted = true
	game.fixture_label = true
	game.capture_label = "ARENA MATERIAL FIXTURE"
	game.visual_clock_override = 1200
	game.screen = "game"
	game.sim.start(0, 147, "optional")
	game.sim.state.tick = 360
	game.sim.state.pickups = [{"p":Vector2(510,480),"kind":"scrap","amount":1},{"p":Vector2(600,485),"kind":"repair_kit","amount":12},{"p":Vector2(590,580),"kind":"mote","amount":3}]
	await save_frame("WORKSHOP_CENTRE")
	for i in range(18):
		game.sim.spawn(["enemy.scrap_mite", "enemy.rivet_hound", "enemy.choir_drone"][i % 3])
		game.sim.state.enemies[-1].p = Vector2(500, 490) + Vector2.from_angle(i * TAU / 18) * (170 + (i % 3) * 26)
	game.sim.state.hazards.append({"p":Vector2(620,550),"radius":60.0,"until":420,"copy":false,"kind":"kindling","warning_ticks":120})
	await save_frame("WORKSHOP_COMBAT")
	game.reduced_fx = true
	await save_frame("WORKSHOP_REDUCED")
	game.reduced_fx = false
	game.sim.state.position = Vector2(-140, 100)
	await save_frame("WORKSHOP_EDGE")
	game.sim.start(0,147,"optional")
	game.sim.state.phase = "route"
	game.sim.state.scrap = 42
	game.sim.command("choose_route", "route.rootworks")
	while game.sim.state.phase == "travel":
		var choices = game.sim.current_road_node().choices.filter(func(c): return int(c.cost) == 0)
		game.sim.command("choose_road_option",choices[0].id)
	if game.sim.state.phase == "arrival": game.sim.command("begin_site")
	game.sim.state.position = Vector2(470, 365)
	await save_frame("ROOTWORKS")
	game.queue_free()
	await process_frame
	quit()
