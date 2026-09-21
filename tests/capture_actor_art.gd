extends SceneTree
var game
const OUT = "res://artifacts/actor-art"
func _initialize(): call_deferred("capture")
func save_frame(label: String):
	game.build_ui()
	var before = game.sim.state_hash()
	game.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT.path_join(label+".png"))
	assert(before == game.sim.state_hash())
	print("ACTOR CAPTURE: ",label," hash=",before)
func capture():
	DirAccess.make_dir_recursive_absolute(OUT)
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.set_physics_process(false)
	game.sound.muted = true
	game.debug_visible = false
	game.screen = "game"
	game.visual_clock_override = 1200
	game.sim.start(0,147,"optional")
	game.sim.state.tick = 360
	var ids = game.sim.config.enemies.keys()
	for i in range(18):
		game.sim.spawn(ids[i % ids.size()])
		var enemy = game.sim.state.enemies[-1]
		enemy.p = Vector2(550,530) + Vector2.from_angle(i*TAU/18)*(165+(i%3)*35)
		if enemy.type == "enemy.forklift_brute":
			enemy.windup = 400
			enemy.charge = (game.sim.state.position-enemy.p).normalized()
		if i == 1: enemy.marked = 450
		if i == 2: enemy.quieted = 450
		if i == 3: enemy.flash = 365
	await save_frame("ROSTER_COMBAT")
	game.reduced_fx = true
	await save_frame("ROSTER_REDUCED")
	game.reduced_fx = false
	game.sim.start(0,147,"optional")
	game.sim.state.wave = 6
	game.sim.spawn("elite.memory_crane")
	var crane = game.sim.state.enemies[-1]
	crane.p = Vector2(590,420)
	game.sim.state.position = Vector2(790,500)
	await save_frame("MEMORY_CRANE_IDLE")
	game.sim.state.hazards = [{"p":Vector2(790,500),"from":crane.p,"until":game.sim.state.tick+90,"warning_ticks":90,"radius":62,"source":crane.type,"source_id":crane.id,"copy":true,"copy_evolution":"evolution.mercy_rail","copy_shape":"rail","copy_range":230.0,"copy_width":12.0}]
	await save_frame("MEMORY_CRANE_COPY")
	game.reduced_fx = true
	await save_frame("MEMORY_CRANE_COPY_REDUCED")
	game.reduced_fx = false
	game.sim.start(0,147,"optional")
	game.sim.state.wave = 8
	game.sim.spawn("boss.foreman_engine")
	var foreman = game.sim.state.enemies[-1]
	foreman.p = Vector2(590,410)
	game.sim.state.position = Vector2(760,515)
	for phase in range(3):
		foreman.phase = phase
		foreman.hp = foreman.max_hp*[0.9,0.5,0.2][phase]
		game.sim.state.hazards = []
		for i in range(phase+2):
			game.sim.state.hazards.append({"p":Vector2(490+i*95,520+(i%2)*70),"from":foreman.p,"until":game.sim.state.tick+90,"warning_ticks":90,"radius":62,"source":foreman.type,"source_id":foreman.id,"copy":false})
		await save_frame(["FOREMAN_SCHEDULE","FOREMAN_WORKERS","FOREMAN_FINAL_ORDERS"][phase])
	game.reduced_fx = true
	await save_frame("FOREMAN_FINAL_REDUCED")
	game.reduced_fx = false
	for i in range(3):
		game.sim.start(0,147,"optional")
		game.notification = ""
		game.notice_until = 0
		game.sim.state.hp = 50
		var data = game.sim.config.optional_repairs.machines[i]
		game.sim.state.position = Vector2(data.position[0]+40,data.position[1])
		await save_frame("REPAIR_%d_BROKEN" % i)
		for tick in range(90):
			game.sim.update_optional_repairs()
			game.sim.state.tick += 1
		await save_frame("REPAIR_%d_WORKING" % i)
		for tick in range(90):
			game.sim.update_optional_repairs()
			game.sim.state.tick += 1
		for event in game.sim.events: game.present(event)
		await save_frame("REPAIR_%d_RESTORED" % i)
		game.fx.clear()
	game.queue_free()
	await process_frame
	quit()
