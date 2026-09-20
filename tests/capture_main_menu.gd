extends SceneTree
var game
var out = "res://artifacts/main-menu"
func _initialize(): call_deferred("run")
func shot(label):
	game.build_ui()
	game.queue_redraw()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out + "/" + label + ".png")
func run():
	DirAccess.make_dir_recursive_absolute(out)
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_physics_process(false)
	game.set_process(false)
	game.sound.muted = true
	game.save_path = "user://main_menu_capture.save"
	game.save_store.clear(game.save_path)
	game.profile.state.memory_fragments = 0
	game.debug_visible = false
	for size in [Vector2i(1280,800),Vector2i(1920,1080)]:
		root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
		root.content_scale_size = size
		root.size = size
		game.scale = Vector2.ONE * (float(size.y) / 800.0)
		game.position = Vector2((size.x - 1280 * game.scale.x) / 2.0, 0)
		game.screen = "title"
		game.title_transition_started = -1
		game.ui_scale = 1.0
		await shot("TITLE_%dx%d" % [size.x,size.y])
		game.ui_scale = 1.15
		await shot("TITLE_LARGE_%dx%d" % [size.x,size.y])
		game.ui_scale = 1.0
		game.open_panel("settings")
		await shot("SETTINGS_%dx%d" % [size.x,size.y])
		game.close_panel()
		game.open_panel("quit_confirm")
		await shot("QUIT_%dx%d" % [size.x,size.y])
		game.close_panel()
		game.reduced_fx = false
		game.title_transition_started = 1000
		game.visual_clock_override = 1900
		await shot("AWAKE_%dx%d" % [size.x,size.y])
	game.title_transition_started = -1
	game.sim.start(0,147,"optional")
	game.sim.enter_shop()
	game.save_run()
	game.notification = ""
	await shot("CONTINUE_1920x1080")
	game.save_store.clear(game.save_path)
	game.queue_free()
	await process_frame
	print("MAIN MENU: 11 configured captures; normal and large text, 1280x800 and 1920x1080. Not human testing.")
	quit()
