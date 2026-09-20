extends SceneTree
var checks = 0
var failures = 0
func check(ok,label):
	checks += 1
	if not ok:
		failures += 1
		printerr("MENU PANELS FAIL: ",label)
func control(g,label):
	for child in g.ui.get_children():
		if child is Button and child.text == label: return child
	return null
func _initialize(): call_deferred("run")
func run():
	var g = load("res://game/main.tscn").instantiate()
	root.add_child(g)
	await process_frame
	g.set_process(false)
	g.set_physics_process(false)
	var original_settings = g.settings.state.duplicate(true)
	g.sim.start(0,147,"optional")
	g.screen = "game"
	g.sim.command("pause")
	g.build_ui()
	var before = g.sim.state_hash()
	control(g,"How to play").pressed.emit()
	for scale in [1.0,1.15]:
		g.ui_scale = scale
		for i in range(g.manual_pages.size()):
			g.tutorial_page = i
			g.build_ui()
			check(control(g,"Previous").disabled == (i == 0),"previous disabled only on first page")
			for child in g.ui.get_children(): check(Rect2(0,0,1280,800).encloses(child.get_rect()),"manual control fits")
			g.advance_simulation(Vector2.RIGHT)
			check(g.sim.state_hash() == before,"manual preserves paused run")
	control(g,"Return to pause").pressed.emit()
	check(g.screen == "game" and g.sim.state.paused,"manual completion returns to pause")
	control(g,"Settings").pressed.emit()
	for scale in [1.0,1.15]:
		g.ui_scale = scale
		g.build_ui()
		for child in g.ui.get_children(): check(Rect2(0,0,1280,800).encloses(child.get_rect()),"settings control fits")
	var volume = g.ui.get_node("MasterVolume")
	volume.value = 35
	check(is_equal_approx(g.settings.state.master_volume,0.35),"volume control updates preference")
	var loaded = g.Settings.new()
	loaded.load_from()
	check(is_equal_approx(loaded.state.master_volume,0.35),"volume survives reload")
	check(g.sim.state_hash() == before,"settings do not mutate run")
	g.awaiting_binding = "move_left"
	var escape = InputEventKey.new()
	escape.pressed = true
	escape.keycode = KEY_ESCAPE
	g._unhandled_key_input(escape)
	check(g.screen == "settings" and g.awaiting_binding == "","Escape cancels binding without leaving settings")
	g.awaiting_binding = "move_up"
	var back = InputEventJoypadButton.new()
	back.button_index = JOY_BUTTON_B
	back.pressed = true
	g._input(back)
	check(g.screen == "settings" and g.awaiting_binding == "","controller cancels binding before closing")
	g._input(back)
	check(g.screen == "game" and g.sim.state.paused,"controller returns to paused game")
	control(g,"Resume").pressed.emit()
	check(not g.sim.state.paused,"resume dispatches pause command")
	g.screen = "title"
	g.open_panel("tutorial")
	g.tutorial_page = 4
	g.build_ui()
	control(g,"Begin setup").pressed.emit()
	check(g.screen == "menu","title manual completes into setup")
	g.settings.state = original_settings
	g.settings.apply_presentation()
	g.settings.save_to()
	g.queue_free()
	await process_frame
	print("MENU PANELS: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
