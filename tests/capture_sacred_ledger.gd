extends SceneTree

func _initialize(): call_deferred("capture")

func capture():
	var game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.set_physics_process(false)
	await process_frame
	var output = "res://artifacts/sacred-ledger"
	DirAccess.make_dir_recursive_absolute(output)
	await frame(game,output,"TITLE")
	game.open_ledger()
	await frame(game,output,"ORIGIN")
	game.close_ledger()
	assert(game.screen == "menu")
	game.begin()
	game.sim.enter_shop()
	var before = var_to_bytes(game.sim.snapshot())
	game.open_ledger()
	for scale in [1.0,1.15]:
		game.ui_scale = scale
		for section in ["origin","relics","creatures"]:
			game.change_ledger(section)
			for page in range(game.ledger_entries().size()):
				game.ledger_page = page
				game.build_ui()
				game._physics_process(1.0/60.0)
				assert(var_to_bytes(game.sim.snapshot()) == before, "Reading changed simulation")
				await frame(game,output,"%s_%02d_%s" % [section,page,"large" if scale > 1 else "normal"])
	game.close_ledger()
	assert(game.screen == "game" and game.sim.state.phase == "shop")
	assert(var_to_bytes(game.sim.snapshot()) == before, "Return changed shop")
	await frame(game,output,"SHOP_RETURN")
	game.sim.state.phase = "won"
	game.sim.state.last_reason = "The Foreman is stopped."
	await frame(game,output,"MEMORY")
	print("PASS: 30 ledger page states preserve simulation; title and shop return verified. Rendered fixtures, not human playtesting.")
	game.queue_free()
	await process_frame
	quit()

func frame(game, output, name):
	game.build_ui()
	game.queue_redraw()
	await RenderingServer.frame_post_draw
	var result = root.get_texture().get_image().save_png(output.path_join(name + ".png"))
	assert(result == OK)
