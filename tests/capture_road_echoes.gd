extends SceneTree
var g
const OUT = "res://artifacts/road-echoes"
func _initialize(): call_deferred("run")
func clear_site():
	g.sim.state.wave = g.sim.current_wave_count()
	g.sim.state.boss_dead = true
	g.sim.step(Vector2.ZERO)
	g.sim.command("continue_site_clear")
func shot(label):
	g.build_ui()
	var before = g.sim.state_hash()
	g.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"/"+label+".png")
	assert(before == g.sim.state_hash())
	print("STORY CAPTURE: ",label," hash=",before)
func run():
	DirAccess.make_dir_recursive_absolute(OUT)
	g = load("res://game/main.tscn").instantiate()
	root.add_child(g)
	await process_frame
	g.set_process(false)
	g.set_physics_process(false)
	g.sound.muted = true
	g.debug_visible = false
	g.screen = "game"
	for scale in [1.0,1.15]:
		g.ui_scale = scale
		for splice in [true,false]:
			for route in ["route.pale_archive","route.red_foundry"]:
				g.sim.start(0,147,"optional")
				clear_site()
				g.sim.state.scrap = 40
				g.sim.command("choose_route","route.brass_choir")
				g.sim.command("choose_road_option","choice.brass.splice" if splice else "choice.brass.cross")
				var suffix = ("SPLICE" if splice else "CROSS")+("_LARGE" if scale > 1 else "_NORMAL")
				if route == "route.pale_archive": await shot("ADA_"+suffix)
				g.sim.command("choose_road_option","choice.brass.pass")
				g.sim.command("begin_site")
				clear_site()
				g.sim.command("choose_route",route)
				await shot(("ARCHIVE_" if route == "route.pale_archive" else "FOUNDRY_")+suffix)
	g.queue_free()
	await process_frame
	quit()
