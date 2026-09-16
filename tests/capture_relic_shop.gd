extends SceneTree
func _initialize(): call_deferred("capture")
func capture():
	var game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.set_physics_process(false)
	await process_frame
	game.screen="game"
	game.capture_dir="res://artifacts/relic-shop"
	DirAccess.make_dir_recursive_absolute(game.capture_dir)
	for stage in range(4):
		game.sim.start(0,147,"optional")
		game.sim.enter_shop()
		if stage==1:
			game.sim.state.scrap=80
			game.sim.state.shards=4
			game.sim.command("buy",0)
		if stage==2: game.ui_scale=1.15
		if stage==3:
			game.ui_scale=1
			game.sim.start(0,147,"optional")
			game.sim.state.kills=11
			game.sim.spawn("enemy.rivet_hound")
			game.sim.state.enemies[0].p=game.sim.state.position+Vector2(55,0)
			game.sim.state.enemies[0].hp=1
			game.sim.update_weapons()
		game.build_ui()
		game.queue_redraw()
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(game.capture_dir.path_join(["SHOP","PURCHASED","LARGE_TEXT","REPAIR_DROP"][stage]+".png"))
	game.queue_free()
	await process_frame
	print("P14 fixtures: normal first-shop budget; purchased variant grants80 Scrap/4Shards; kit produced by configured twelfth kill")
	quit()
