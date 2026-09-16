extends SceneTree
func _initialize(): call_deferred("capture")
func capture():
	var game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.set_physics_process(false)
	await process_frame
	game.screen = "game"
	var output = "res://artifacts/roaming-audit/after"
	for tick in [60,240,360]:
		var snapshot = FileAccess.open(output.path_join("natural_%d.save" % tick),FileAccess.READ).get_var()
		assert(game.sim.restore(snapshot))
		for scale in [1.0, 1.15]:
			game.ui_scale = scale
			await frame(game,output,"NATURAL_%d_%s" % [tick,str(scale)])
	game.ui_scale = 1.0
	game.sim.start(1,147,"optional")
	game.sim.state.position = Vector2(550,70)
	await frame(game,output,"FIXTURE_PUMP_DEFER")
	game.sim.state.position = Vector2(-70,450)
	game.sim.state.machines[0].progress = 90
	game.sim.hurt_saint(7)
	await frame(game,output,"FIXTURE_HIT_PAUSE")
	game.sim.state.position = Vector2(1150,560)
	await frame(game,output,"FIXTURE_EMPTY_BELL")
	game.queue_free()
	await process_frame
	quit()
func frame(game,output,label):
	var before = game.sim.state_hash()
	game.build_ui()
	game.queue_redraw()
	await RenderingServer.frame_post_draw
	assert(game.sim.state_hash() == before, "Renderer mutated simulation")
	assert(root.get_texture().get_image().save_png(output.path_join(label + ".png")) == OK)
	FileAccess.open(output.path_join(label + ".json"),FileAccess.WRITE).store_string(JSON.stringify({"state_hash":before,"tick":game.sim.state.tick,"seed":game.sim.state.seed,"viewport":[1280,800],"scale":game.ui_scale,"provenance":"natural policy snapshot" if label.begins_with("NATURAL") else "configured fixture"}))
