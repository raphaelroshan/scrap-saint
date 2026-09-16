extends SceneTree
func _initialize():call_deferred("capture")
func capture():
	var game=load("res://game/main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.set_physics_process(false)
	await process_frame
	game.screen="game"
	game.capture_dir="res://artifacts/winch"
	DirAccess.make_dir_recursive_absolute(game.capture_dir)
	game.sim.start(0,147,"optional")
	game.sim.state.position=Vector2(900,420)
	game.sim.state.weapons=[game.sim.make_weapon("weapon.penance_winch",2)]
	game.sim.spawn("enemy.forklift_brute")
	game.sim.state.enemies[0].p=Vector2(1200,420)
	for tick in range(75):
		game.sim.state.tick=tick
		game.sim.update_weapons()
		if tick not in [10,25,30,52,69]:continue
		game.build_ui()
		game.queue_redraw()
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(game.capture_dir.path_join("WINCH_%02d.png"%tick))
	game.sim.enter_shop()
	game.build_ui()
	game.queue_redraw()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(game.capture_dir.path_join("SHOP.png"))
	game.queue_free()
	await process_frame
	print("Winch fixtures: explicit stationary enemy/weapon positions; real simulation phases at ticks10,25,30,52,69")
	quit()
