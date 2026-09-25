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

func controller_back(game):
	var event = InputEventJoypadButton.new()
	event.pressed = true
	event.button_index = JOY_BUTTON_B
	game._input(event)
	await process_frame

func _initialize():
	call_deferred("run_checks")

func run_checks():
	for path in ["user://first_shift.save", "user://scrap_saint_profile.save", "user://scrap_saint_settings.save"]:
		for suffix in ["", ".tmp", ".bak"]:
			if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)
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

	await activate(button_with(game, "New pilgrimage"))
	game.visual_clock_override = game.title_transition_started + game.TITLE_TRANSITION_MS
	game._process(0.0)
	game.visual_clock_override = -1
	check(game.screen == "menu", "controller-style accept opens setup")
	await activate(button_with(game, "Choose Mourner"))
	check(game.chosen == 2, "setup Blessing button changes the selected doctrine")
	await activate(button_with(game, "REVIEW THE PILGRIMAGE", true))
	check(game.screen == "departure_map" and game.sim.state.is_empty(), "setup opens a non-authoritative departure preview")
	check(root.gui_get_focus_owner() is Button and root.gui_get_focus_owner().text == "COLLAPSED WORKSHOP", "departure map focuses the only launchable site")
	await activate(root.gui_get_focus_owner())
	await activate(button_with(game, "BEGIN AT COLLAPSED WORKSHOP", true))
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
	game.sim.state.gifts = ["gift.spare_hand", "gift.inspection_lens"]
	for scale in [1.0, 1.15]:
		game.ui_scale = scale
		game.build_ui()
		var shop_save = button_with(game, "SAVE & TITLE")
		check(shop_save != null, "two-Gift shop exposes Save & Title at scale %s" % scale)
		var gift_names: Array[Rect2] = []
		for i in range(2):
			var name = str(game.sim.config.gifts[game.sim.state.gifts[i]].short)
			var size = int(10 * scale)
			var baseline = 660 + i * 44
			var extent = game.font.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
			gift_names.append(Rect2(1068, baseline - game.font.get_ascent(size), extent, game.font.get_ascent(size) + game.font.get_descent(size)))
			check(gift_names[i].position.y >= 645 and gift_names[i].end.x <= 1252, "Gift name fits shop sidebar at scale %s" % scale)
		var gift_actions = 0
		for child in game.ui.get_children():
			if child is Button and child.text in ["Sell", "Dism."] and child.position.y >= 667:
				gift_actions += 1
				check(child.get_rect().end.y <= 736, "Gift action stays inside shop sidebar at scale %s" % scale)
				check(shop_save != null and not shop_save.get_rect().intersects(child.get_rect()), "Save & Title does not cover two-Gift shop action")
				for name_rect in gift_names:
					check(not name_rect.intersects(child.get_rect()), "Gift name clears both action rows at scale %s: %s vs %s" % [scale, name_rect, child.get_rect()])
		check(gift_actions == 4, "two-Gift shop exposes both sell and dismantle rows")
	game.sim.state.gifts.clear()
	game.ui_scale = 1.0
	game.build_ui()
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
	game.last_phase = game.sim.state.phase
	game.build_ui()
	await process_frame
	check(game.sim.state.phase == "site_clear", "Foreman completion opens the unified site-clear summary")
	await activate(button_with(game, "OPEN THE PILGRIMAGE MAP", true))
	check(game.sim.state.phase == "route", "Foreman completion reaches route selection")
	check(root.gui_get_focus_owner() is Button and root.gui_get_focus_owner().text == "BRASS CHOIR", "expedition map has a controller focus target")
	var route_map_hash = game.sim.state_hash()
	await activate(button_with(game, "PALE ARCHIVE"))
	check(game.map_selection == "", "controller may inspect a future site without arming travel")
	await controller_back(game)
	check(game.map_inspection_site == game.sim.state.site_id and game.sim.state_hash() == route_map_hash, "controller Back returns to the current site without mutating the run")
	await activate(button_with(game, "BRASS CHOIR"))
	await activate(root.gui_get_focus_owner())
	check(game.map_selection == "route.brass_choir" and game.sim.state.phase == "route", "controller preview does not accept an assignment implicitly")
	var route_save = button_with(game, "SAVE & TITLE")
	var route_travel = button_with(game, "TRAVEL TO BRASS CHOIR", true)
	check(route_save != null and route_travel != null, "route map exposes Save & Title and Travel")
	if route_save != null and route_travel != null:
		check(not route_save.get_rect().intersects(route_travel.get_rect()), "Save & Title leaves route confirmation clear")
	await activate(button_with(game, "TRAVEL TO BRASS CHOIR", true))
	check(game.sim.state.phase == "travel", "focused route card accepts controller-style input")

	while game.sim.state.phase == "travel":
		check(root.gui_get_focus_owner() is Button and root.gui_get_focus_owner().text.contains(" · "), "each in-between area has a focused authored choice")
		await activate(root.gui_get_focus_owner())
	check(game.sim.state.phase == "arrival" and game.sim.is_destination(), "travel input reaches the selected destination briefing")
	await activate(button_with(game, "ENTER BRASS CHOIR", true))
	check(game.sim.state.phase == "combat", "controller-style arrival input deliberately starts combat")

	for node in game.sim.state.objective: node.complete = true
	game.sim.state.objective_complete = true
	game.sim.state.wave = game.sim.current_wave_count()
	game.sim.state.boss_dead = true
	game.sim.step(Vector2.ZERO)
	game.build_ui()
	await process_frame
	var memory_button = button_with(game, "CHOOSE THE NEXT DESTINATION", true)
	check(game.sim.state.phase == "site_clear" and memory_button != null, "completed destination exposes a focused site-clear action")
	await activate(memory_button)
	check(game.sim.state.phase == "route" and game.sim.state.memory_ids == ["memory.first_shift", "memory.borrowed_bell"], "mid-site clear preserves both site memories and reaches the terminal route choice")
	check(root.gui_get_focus_owner() is Button and root.gui_get_focus_owner().text in ["PALE ARCHIVE", "RED FOUNDRY", "NULL ASSEMBLY"], "terminal route selection has a controller focus target")
	await activate(root.gui_get_focus_owner())
	check(game.sim.state.phase == "route", "terminal route preview does not bypass assignment confirmation")
	await activate(button_with(game, "TRAVEL TO", true))
	while game.sim.state.phase == "travel":
		check(root.gui_get_focus_owner() is Button, "each terminal travel beat has a focused continuation")
		await activate(root.gui_get_focus_owner())
	check(game.sim.state.phase == "arrival" and game.sim.state.route_history.size() == 2, "terminal arrival preserves the two-route history")
	await activate(button_with(game, "ENTER ", true))
	check(game.sim.state.phase == "combat", "terminal arrival waits for explicit controller confirmation")
	for node in game.sim.state.objective: node.complete = true
	game.sim.state.objective_complete = true
	game.sim.state.wave = game.sim.current_wave_count()
	game.sim.state.boss_dead = true
	game.sim.step(Vector2.ZERO)
	game.build_ui()
	await process_frame
	memory_button = button_with(game, "COMPLETE THE CHAPTER", true)
	check(game.sim.state.phase == "site_clear" and memory_button != null, "terminal destination exposes its site-clear action")
	await activate(memory_button)
	check(game.sim.state.phase == "won" and not game.sim.state.result_summary.is_empty(), "terminal memory input reaches causal Results")
	var result_button = button_with(game, "RETURN TO THE WORKSHOP")
	check(result_button != null and result_button.has_focus(), "Results has a focused replay action")
	await activate(result_button)
	check(game.screen == "menu", "Results action returns to setup")

	for path in ["user://first_shift.save", "user://scrap_saint_profile.save", "user://scrap_saint_settings.save"]:
		for suffix in ["", ".tmp", ".bak"]:
			if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)
	game.queue_free()
	await process_frame
	print("FLOW INPUT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
