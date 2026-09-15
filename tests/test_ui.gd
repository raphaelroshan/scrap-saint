extends SceneTree
var failures = 0

func check(ok, label):
	if not ok:
		failures += 1
		printerr("UI FAIL: ", label)

func _initialize():
	call_deferred("run_checks")

func run_checks():
	var game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	check(game.screen == "menu", "title boots")
	for child in game.ui.get_children():
		if child is Button and child.text == "Choose Mourner": child.pressed.emit(); break
	check(game.chosen == 2, "Blessing button selects doctrine")
	for child in game.ui.get_children():
		if child is Button and child.text.begins_with("BEGIN"): child.pressed.emit(); break
	check(game.screen == "game" and game.sim.state.doctrine == 2, "start button starts chosen build")
	var event = InputEventKey.new()
	event.pressed = true
	event.keycode = KEY_ESCAPE
	game._unhandled_key_input(event)
	check(game.sim.state.paused, "Escape pauses combat")
	game._unhandled_key_input(event)
	check(not game.sim.state.paused, "Escape resumes")
	game.sim.enter_shop()
	game.build_ui()
	game._unhandled_key_input(event)
	check(not game.sim.state.paused, "shop Escape cannot strand next combat paused")
	var path = "user://ui_test.save"
	game.save_path = path
	game.save_run()
	var before = game.sim.state_hash()
	game.load_run()
	check(game.sim.state_hash() == before, "actual file save/load preserves shop")
	game.sim.state.phase = "route"
	game.sim.state.scrap = 20
	game.build_ui()
	for child in game.ui.get_children():
		if child is Button and child.text == "CHOOSE ROOTWORKS PUMP": child.pressed.emit(); break
	check(game.sim.state.phase == "travel" and game.sim.state.route == "route.rootworks", "route button sends authoritative choice")
	for beat in range(3):
		for child in game.ui.get_children():
			if child is Button and (child.text == "CONTINUE ALONG THE ROAD" or child.text == "ENTER ROOTWORKS PUMP"):
				child.pressed.emit()
				break
	check(game.sim.state.phase == "combat" and game.sim.state.site_id == "site.rootworks_pump", "travel buttons arrive at selected destination")
	DirAccess.remove_absolute(path)
	game.queue_free()
	await process_frame
	print("UI TESTS: 9 checks, %d failures" % failures)
	quit(1 if failures else 0)
