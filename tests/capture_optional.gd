extends SceneTree
func _initialize(): call_deferred("capture")
func capture():
	var game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.set_physics_process(false)
	await process_frame
	game.debug_visible = true
	game.capture_dir = "res://artifacts/optional-comparison"
	DirAccess.make_dir_recursive_absolute(game.capture_dir)
	for stage in range(4):
		if stage == 0:
			game.screen = "menu"
			game.run_mode = "optional"
		elif stage == 1:
			game.screen = "game"
			game.sim.start(1,147,"optional")
			game.sim.state.position = Vector2(-70,450)
			for i in range(90): game.sim.step(Vector2.ZERO)
		elif stage == 2:
			for i in range(90): game.sim.step(Vector2.ZERO)
			for event in game.sim.events: game.present(event)
		else:
			game.sim.start(1,147,"relay")
		game.build_ui()
		game.queue_redraw()
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(game.capture_dir.path_join(["MODE_SELECT","OPTIONAL_WORK","OPTIONAL_RESTORED","RELAY_BASELINE"][stage] + ".png"))
	game.queue_free()
	await process_frame
	print("Comparison fixtures captured at seed147 / 1280x800")
	quit()
