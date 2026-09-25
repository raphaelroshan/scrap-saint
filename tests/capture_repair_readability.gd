extends SceneTree
var game
const OUT = "res://artifacts/repair-readability"

func output_dir() -> String:
	var size = root.size
	return OUT.path_join("%dx%d" % [size.x, size.y])

func _initialize(): call_deferred("capture")

func frame(label: String):
	game.build_ui()
	var before = game.sim.state_hash()
	game.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	assert(before == game.sim.state_hash())
	var captured_image = root.get_texture().get_image()
	if label == "SALVAGE_IDLE_NORMAL_FULL": print("REPAIR SAVED IMAGE size=", captured_image.get_size())
	captured_image.save_png(output_dir().path_join(label + ".png"))
	print("REPAIR CAPTURE: ", label, " hash=", before)

func capture():
	var target = Vector2i(1280, 800)
	for arg in OS.get_cmdline_user_args():
		if arg == "--capture-size=1920x1080": target = Vector2i(1920, 1080)
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	root.size = target
	DisplayServer.window_set_size(target)
	await process_frame
	print("REPAIR VIEWPORT requested=", target, " window=", DisplayServer.window_get_size(), " root=", root.size)
	assert(root.size == target)
	DirAccess.make_dir_recursive_absolute(output_dir())
	game.set_process(false)
	game.set_physics_process(false)
	game.sound.muted = true
	game.screen = "game"
	game.debug_visible = false
	game.visual_clock_override = 1200
	for scale in [1.0, 1.15]:
		game.ui_scale = scale
		for reduced in [false, true]:
			game.reduced_fx = reduced
			var suffix = ("LARGE" if scale > 1.0 else "NORMAL") + ("_REDUCED" if reduced else "_FULL")
			for index in range(3):
				game.sim.start(0, 147, "optional")
				game.sim.state.hp = 50
				var data = game.sim.config.optional_repairs.machines[index]
				var p = Vector2(data.position[0], data.position[1])
				game.sim.state.position = p + Vector2(40, 0)
				await frame("%s_IDLE_%s" % [data.id.replace("repair.", "").to_upper(), suffix])
				for tick in range(90):
					game.sim.update_optional_repairs()
					game.sim.state.tick += 1
				await frame("%s_ACTIVE_%s" % [data.id.replace("repair.", "").to_upper(), suffix])
				game.sim.state.position = p + Vector2(180, 0)
				game.sim.update_optional_repairs()
				await frame("%s_DEPARTED_%s" % [data.id.replace("repair.", "").to_upper(), suffix])
				game.sim.state.position = p + Vector2(40, 0)
				for tick in range(90):
					game.sim.update_optional_repairs()
					game.sim.state.tick += 1
				await frame("%s_RESTORED_%s" % [data.id.replace("repair.", "").to_upper(), suffix])
			game.sim.start(0, 147, "optional")
			game.sim.state.position = Vector2(590, 70)
			game.sim.update_optional_repairs()
			await frame("PUMP_DEFERRED_%s" % suffix)
			game.sim.state.hp = 50
			game.sim.update_optional_repairs()
			await frame("PUMP_ELIGIBLE_%s" % suffix)
			game.sim.start(0, 147, "optional")
			game.sim.state.wave = 8
			game.sim.spawn("boss.foreman_engine")
			var foreman = game.sim.state.enemies[-1]
			foreman.p = Vector2(590, 410)
			foreman.phase = 2
			foreman.hp = foreman.max_hp * 0.2
			game.sim.state.position = Vector2(1110, 560)
			for i in range(4):
				game.sim.state.hazards.append({"p": Vector2(780 + i * 95, 520 + (i % 2) * 70), "from": foreman.p, "until": game.sim.state.tick + 90, "warning_ticks": 90, "radius": 62, "source": foreman.type, "source_id": foreman.id, "copy": false})
			await frame("BELL_FOREMAN_%s" % suffix)
	game.queue_free()
	await process_frame
	quit()
