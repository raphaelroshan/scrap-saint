extends SceneTree
func _initialize():
	call_deferred("capture")
func capture():
	var game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	game.set_physics_process(false)
	game.set_process(false)
	await process_frame
	game.screen = "game"
	game.debug_visible = true
	game.capture_dir = "res://artifacts/agent-iteration"
	for doctrine in range(3):
		game.sim.start(doctrine, 147)
		game.sim.enter_shop()
		game.build_ui()
		game.queue_redraw()
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://artifacts/agent-iteration/SERVICE_%d.png" % doctrine)
	print("Three service fixtures captured; seeded shop states, not playthroughs")
	game.queue_free()
	await process_frame
	quit()

