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
	game.sim.state.gifts = ["gift.spare_hand"]
	game.build_ui()
	var labels = game.ui.get_children().filter(func(child): return child is Button).map(func(child): return child.text)
	check("Mercy Rail" in labels and "Great Toll" in labels and "Dism." in labels, "shop exposes distinct Evolution and Gift management controls")
	game._unhandled_key_input(event)
	check(not game.sim.state.paused, "shop Escape cannot strand next combat paused")
	var path = "user://ui_test.save"
	game.save_path = path
	game.save_run()
	var before = game.sim.state_hash()
	game.load_run()
	check(game.sim.state_hash() == before, "actual file save/load preserves shop")
	DirAccess.remove_absolute(path)
	game.queue_free()
	await process_frame
	print("UI TESTS: 8 checks, %d failures" % failures)
	quit(1 if failures else 0)
