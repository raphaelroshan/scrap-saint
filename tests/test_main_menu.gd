extends SceneTree
var checks = 0
var failures = 0
func check(ok, label):
	checks += 1
	if not ok:
		failures += 1
		printerr("MAIN MENU FAIL: ", label)
func control(game, label):
	for child in game.ui.get_children():
		if child is Button and child.text == label: return child
	return null
func _initialize(): call_deferred("run")
func run():
	var game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_physics_process(false)
	game.set_process(false)
	game.sound.muted = true
	game.save_path = "user://main_menu_test.save"
	game.save_store.clear(game.save_path)
	game.build_ui()
	check(control(game,"Continue").disabled, "Continue unavailable without a save")
	check(root.gui_get_focus_owner() == control(game,"New pilgrimage"), "new player focus starts on New pilgrimage")
	for label in ["Continue","New pilgrimage","Settings","How to play","Sacred histories","Quit"]:
		check(control(game,label) != null, "menu exposes " + label)
	for scale in [1.0,1.15]:
		game.ui_scale = scale
		game.build_ui()
		for child in game.ui.get_children():
			check(Rect2(0,0,1280,800).encloses(child.get_rect()), "menu control fits viewport")
	control(game,"Settings").pressed.emit()
	check(game.screen == "settings", "Settings opens")
	game.close_panel()
	control(game,"Sacred histories").pressed.emit()
	check(game.screen == "ledger", "histories opens")
	game.close_ledger()
	control(game,"Quit").pressed.emit()
	check(game.screen == "quit_confirm" and root.gui_get_focus_owner() == control(game,"Stay"), "Quit requires deliberate action with Stay focused")
	var cancel = InputEventJoypadButton.new()
	cancel.pressed = true
	cancel.button_index = JOY_BUTTON_B
	game._input(cancel)
	check(game.screen == "title", "controller cancel returns from Quit")
	game.reduced_fx = true
	game.visual_clock_override = 1000
	control(game,"New pilgrimage").pressed.emit()
	check(game.sim.state.is_empty(), "new-run commitment does not start simulation")
	game.visual_clock_override = 1300
	game._process(0)
	check(game.screen == "menu" and game.sim.state.is_empty(), "reduced-motion handoff takes 300ms and reaches setup")
	control(game,"REVIEW THE PILGRIMAGE  →").pressed.emit()
	check(game.screen == "departure_map" and game.sim.state.is_empty(), "setup review opens departure without creating a run")
	game._input(cancel)
	check(game.screen == "menu" and game.sim.state.is_empty(), "controller cancel returns from departure preview without erasing setup")
	game._input(cancel)
	check(game.screen == "title", "controller cancel returns from setup")
	game.sim.start(0,147,"optional")
	game.sim.enter_shop()
	var saved_hash = game.sim.state_hash()
	game.save_run()
	game.screen = "title"
	game.build_ui()
	check(not control(game,"Continue").disabled and root.gui_get_focus_owner() == control(game,"Continue"), "returning player focus starts on Continue")
	control(game,"Continue").pressed.emit()
	check(game.screen == "game" and game.sim.state_hash() == saved_hash, "Continue restores exact shop state")
	var file = FileAccess.open(game.save_path,FileAccess.WRITE)
	file.store_var("invalid test save")
	file.close()
	game.screen = "title"
	game.load_run()
	check(game.screen == "title" and game.sim.state_hash() == saved_hash, "invalid save keeps title and current state intact")
	game.save_store.clear(game.save_path)
	game.queue_free()
	await process_frame
	print("MAIN MENU: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
