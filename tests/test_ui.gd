extends SceneTree
var failures = 0
var checks = 0

func check(ok, label):
	checks += 1
	if not ok:
		failures += 1
		printerr("UI FAIL: ", label)

func _initialize():
	call_deferred("run_checks")

func run_checks():
	for path in ["user://ui_test.save", "user://scrap_saint_profile.save", "user://scrap_saint_settings.save"]:
		if FileAccess.file_exists(path): DirAccess.remove_absolute(path)
	var game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	check(game.screen == "title", "game title boots before setup")
	for child in game.ui.get_children():
		if child is Button and child.text == "Settings": child.pressed.emit(); break
	check(game.screen == "settings", "settings opens from title")
	for child in game.ui.get_children():
		if child is Button and child.text.begins_with("Move up"):
			child.pressed.emit()
			break
	var binding = InputEventKey.new()
	binding.pressed = true
	binding.keycode = KEY_I
	binding.physical_keycode = KEY_I
	game._unhandled_key_input(binding)
	check(game.settings.state.controls.move_up == KEY_I, "movement remapping is applied")
	game.close_panel()
	for child in game.ui.get_children():
		if child is Button and child.text == "How to play": child.pressed.emit(); break
	check(game.screen == "tutorial" and game.tutorial_page == 0, "field manual opens")
	game.close_panel()
	for child in game.ui.get_children():
		if child is Button and child.text == "BEGIN A PILGRIMAGE": child.pressed.emit(); break
	check(game.screen == "menu", "new pilgrimage opens setup")
	for child in game.ui.get_children():
		if child is Button and child.text == "Choose Mourner": child.pressed.emit(); break
	check(game.chosen == 2, "Blessing button selects doctrine")
	for child in game.ui.get_children():
		if child is Button and child.text.begins_with("BEGIN"): child.pressed.emit(); break
	check(game.screen == "game" and game.sim.state.doctrine == 2 and game.sim.state.frame_id == "frame.pilgrim", "start button starts chosen build and frame")
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
	game.sim.state.phase = "route"
	game.sim.state.scrap = 20
	game.sim.state.hp = 10
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
	check(game.notification == "ROAD REST / 90 structure restored", "arrival explains the between-site recovery")
	game.profile.state.unlocked_frames.append("frame.keeper")
	game.profile.state.unlocked_blessings.append("blessing.procession")
	game.screen = "menu"
	game.build_ui()
	for child in game.ui.get_children():
		if child is Button and child.text.contains("Keeper Frame"): child.pressed.emit(); break
	for child in game.ui.get_children():
		if child is Button and child.text == "Choose Procession": child.pressed.emit(); break
	check(game.chosen_frame == "frame.keeper" and game.chosen == 3, "unlocked frame and fourth Blessing are selectable")
	game.begin()
	check(game.sim.state.frame_id == "frame.keeper" and game.sim.state.doctrine == 3 and game.sim.state.weapons[0].id == "weapon.procession_gear", "selected frame and Procession reach authoritative start")
	DirAccess.remove_absolute(path)
	for cleanup in ["user://scrap_saint_profile.save", "user://scrap_saint_settings.save"]:
		if FileAccess.file_exists(cleanup): DirAccess.remove_absolute(cleanup)
	game.queue_free()
	await process_frame
	print("UI TESTS: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
