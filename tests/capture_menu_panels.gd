extends SceneTree
var g
const OUT = "res://artifacts/menu-panels"
func _initialize(): call_deferred("run")
func shot(label):
	g.build_ui()
	var before = g.sim.state_hash()
	g.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"/"+label+".png")
	assert(before == g.sim.state_hash())
	print("MENU CAPTURE: ",label," hash=",before)
func run():
	DirAccess.make_dir_recursive_absolute(OUT)
	g = load("res://game/main.tscn").instantiate()
	root.add_child(g)
	await process_frame
	g.set_process(false)
	g.set_physics_process(false)
	g.sound.muted = true
	g.debug_visible = false
	g.sim.start(0,147,"optional")
	g.sim.command("pause")
	g.previous_screen = "game"
	for scale in [1.0,1.15]:
		g.ui_scale = scale
		g.settings.state.ui_scale = scale
		var suffix = "LARGE" if scale > 1 else "NORMAL"
		g.screen = "tutorial"
		for i in range(5):
			g.tutorial_page = i
			await shot("MANUAL_%d_%s" % [i,suffix])
		g.screen = "settings"
		await shot("SETTINGS_"+suffix)
		g.awaiting_binding = "move_left"
		await shot("BINDING_"+suffix)
		g.awaiting_binding = ""
		g.screen = "game"
		await shot("PAUSE_"+suffix)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.content_scale_size = Vector2i(1920,1080)
	root.size = Vector2i(1920,1080)
	g.scale = Vector2.ONE*1.35
	g.position = Vector2(96,0)
	g.screen = "settings"
	await shot("SETTINGS_1920")
	g.queue_free()
	await process_frame
	quit()
