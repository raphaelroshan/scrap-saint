extends SceneTree
var checks = 0
var failures = 0

func check(ok: bool, message: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("FLOW INPUT FAIL: ", message)

func button_with(game, label: String, prefix := false):
	for child in game.ui.get_children():
		if child is Button and ((prefix and child.text.begins_with(label)) or (not prefix and child.text == label)):
			return child
	return null

func activate(control: Control):
	check(control != null, "requested flow control exists")
	if control == null: return
	control.grab_focus()
	await process_frame
	var press = InputEventAction.new()
	press.action = "ui_accept"
	press.pressed = true
	var release = InputEventAction.new()
	release.action = "ui_accept"
	release.pressed = false
	root.push_input(press)
	root.push_input(release)
	await process_frame

func send_key(keycode: Key):
	var press = InputEventKey.new()
	press.pressed = true
	press.keycode = keycode
	press.physical_keycode = keycode
	var release = press.duplicate()
	release.pressed = false
	root.push_input(press)
	root.push_input(release)
	await process_frame

func controller_start(game):
	var event = InputEventJoypadButton.new()
	event.pressed = true
	event.button_index = JOY_BUTTON_START
	game._input(event)
	await process_frame

func _initialize():
	call_deferred("run_checks")

func run_checks():
	for path in ["user://first_shift.save", "user://scrap_saint_profile.save", "user://scrap_saint_settings.save"]:
		if FileAccess.file_exists(path): DirAccess.remove_absolute(path)
	var game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame

	await activate(button_with(game, "Settings"))
	check(game.screen == "settings", "controller-style accept opens Settings from title")
	await activate(button_with(game, "Effects:", true))
	check(game.settings.state.reduced_effects and game.reduced_fx, "settings action updates persisted presentation state")
	await activate(button_with(game, "Move up:", true))
	check(game.awaiting_binding == "move_up", "binding control enters capture mode")
	await send_key(KEY_I)
	check(game.settings.state.controls.move_up == KEY_I and game.awaiting_binding == "", "synthetic key completes remapping")
	await activate(button_with(game, "Back"))
	check(game.screen == "title", "Settings returns to title")

	await activate(button_with(game, "BEGIN A PILGRIMAGE"))
	check(game.screen == "menu", "controller-style accept opens setup")
	await activate(button_with(game, "Choose Mourner"))
	check(game.chosen == 2, "setup Blessing button changes the selected doctrine")
	await activate(button_with(game, "BEGIN THE FIRST SHIFT", true))
	check(game.screen == "game" and game.sim.state.phase == "combat", "setup begins the authoritative run")

	await controller_start(game)
	check(game.sim.state.paused, "controller Start pauses combat")
	await controller_start(game)
	check(not game.sim.state.paused, "controller Start resumes combat")

	game.sim.state.scrap = 200
	game.sim.enter_shop()
	game.last_phase = game.sim.state.phase
	game.build_ui()
	await process_frame
	var transactions_before = game.sim.state.transactions.size()
	await activate(button_with(game, "BUY / COMBINE"))
	check(game.sim.state.transactions.size() == transactions_before + 1, "controller-style shop input purchases an authoritative offer")
	var shop_focus = root.gui_get_focus_owner()
	check(shop_focus is Button and shop_focus.text == "NEXT WAVE  →", "shop exposes a controller-focused continuation")
	await activate(shop_focus)
	check(game.sim.state.phase == "combat", "shop continuation returns to combat")

	game.sim.state.wave = game.sim.current_wave_count()
	game.sim.state.boss_dead = true
	game.sim.step(Vector2.ZERO)
	game.build_ui()
	await process_frame
	check(game.sim.state.phase == "route", "Foreman completion reaches route selection")
	check(root.gui_get_focus_owner() is Button and root.gui_get_focus_owner().text.begins_with("CHOOSE "), "route selection has a controller focus target")
	await activate(root.gui_get_focus_owner())
	check(game.sim.state.phase == "travel", "focused route card accepts controller-style input")

	while game.sim.state.phase == "travel":
		check(root.gui_get_focus_owner() is Button, "each travel beat has a focused continuation")
		await activate(root.gui_get_focus_owner())
	check(game.sim.state.phase == "combat" and game.sim.is_destination(), "travel input reaches the selected destination")

	for node in game.sim.state.objective: node.complete = true
	game.sim.state.objective_complete = true
	game.sim.state.wave = game.sim.current_wave_count()
	game.sim.state.boss_dead = true
	game.sim.step(Vector2.ZERO)
	game.build_ui()
	await process_frame
	var memory_button = button_with(game, "CARRY THIS MEMORY", true)
	check(game.sim.state.phase == "memory" and memory_button != null, "completed destination exposes a focused memory action")
	await activate(memory_button)
	check(game.sim.state.phase == "won" and not game.sim.state.result_summary.is_empty(), "memory input reaches causal Results")
	var result_button = button_with(game, "RETURN TO THE WORKSHOP")
	check(result_button != null and result_button.has_focus(), "Results has a focused replay action")
	await activate(result_button)
	check(game.screen == "menu", "Results action returns to setup")

	for path in ["user://first_shift.save", "user://scrap_saint_profile.save", "user://scrap_saint_settings.save"]:
		if FileAccess.file_exists(path): DirAccess.remove_absolute(path)
	game.queue_free()
	await process_frame
	print("FLOW INPUT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
