extends SceneTree
func _initialize(): call_deferred("capture")
func capture():
	var game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.set_physics_process(false)
	await process_frame
	game.sound.muted = true
	game.debug_visible = true
	game.fixture_label = true
	game.capture_label = "SYNC / CONFIGURED FIXTURE / SEED 147"
	await frame(game,"TITLE")
	game.open_ledger()
	await frame(game,"ORIGIN")
	game.close_ledger()
	assert(game.screen == "title")
	game.sim.start(0,147,"optional")
	game.screen = "game"
	game.sim.enter_shop()
	var before = game.sim.state_hash()
	game.open_ledger()
	for scale in [1.0,1.15]:
		game.ui_scale = scale
		for section in ["origin","relics","creatures"]:
			game.change_ledger(section)
			for page in range(game.ledger_entries().size()):
				game.ledger_page = page
				game._physics_process(1.0/60)
				assert(game.sim.state_hash() == before)
				await frame(game,"%s_%d_%s" % [section,page,str(scale)])
	game.close_ledger()
	assert(game.screen == "game" and game.sim.state_hash() == before)
	await frame(game,"SHOP_LARGE")
	game.ui_scale = 1.0
	await frame(game,"SHOP")
	game.sim.command("continue")
	game.sim.state.pickups.append({"p":game.sim.state.position+Vector2(50,0),"kind":"repair_kit","amount":15})
	await frame(game,"FIELD_KIT")
	print("SYNC CAPTURES: 34 lore page/scale states preserve run; title and shop returns pass")
	game.queue_free()
	await process_frame
	quit()
func frame(game,label):
	DirAccess.make_dir_recursive_absolute("res://artifacts/sync-review")
	game.build_ui()
	game.queue_redraw()
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png("res://artifacts/sync-review/"+label+".png") == OK)
