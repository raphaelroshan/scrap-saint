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
		if child is Button and child.text == "New pilgrimage": child.pressed.emit(); break
	game.visual_clock_override = game.title_transition_started + game.TITLE_TRANSITION_MS
	game._process(0.0)
	game.visual_clock_override = -1
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
	check("EVOLUTION LEDGER · 10" in labels and "Dism." in labels, "shop exposes distinct Evolution and Gift management controls")
	check(game.sim.config.gifts.size() == 7 and game.sim.config.gift_slots == 2, "shop presentation reads the seven-Gift pool while preserving two carried slots")
	game.sim.state.gifts = ["gift.honest_scale"]
	game.sim.state.weapons = [game.sim.make_weapon("weapon.nailer_small_mercies")]
	game.sim.state.reserve = []
	game.sim.state.scrap = 100
	game.sim.state.offers[0] = "weapon.nailer_small_mercies"
	var before_preview = game.sim.state_hash()
	var scale_preview = game.honest_scale_preview_text(0)
	check("2 ACTIVE" not in scale_preview and "1 ACTIVE" in scale_preview and "COMBINE Nailer II" in scale_preview, "Honest Scale renders exact capacity and automatic Combine result")
	check(game.sim.state_hash() == before_preview, "rendering the Honest Scale preview cannot mutate the authoritative shop")
	game.sim.state.tick = 50
	game.sim.state.loose_spring_until = 110
	game.sim.state.gifts = ["gift.loose_spring", "gift.brass_fuse"]
	check(game.gift_activity_label("gift.loose_spring") == "BURST · 1.0s" and game.gift_activity_label("gift.brass_fuse") == "FUSE READY", "Gift HUD distinguishes active Spring timing from ready Fuse state")
	game.sound.muted = true
	game.present({"kind": "brass_fuse_lit", "gift": "gift.brass_fuse", "position": game.sim.state.position, "tick": game.sim.state.tick})
	check(game.gift_fx_active("gift.brass_fuse") and "FIRST STAGGER MARKED" in game.notification, "Brass Fuse trigger receives a visible effect and plain-language notice")
	for child in game.ui.get_children():
		if child is Button and child.text == "EVOLUTION LEDGER · 10": child.pressed.emit(); break
	labels = game.ui.get_children().filter(func(child): return child is Button).map(func(child): return child.text)
	check(labels.count("EVOLVE") == 10 and game.sim.evolution_recipes.size() == 10, "Evolution Ledger exposes all ten data-owned recipes")
	game.evolution_ledger_open = false
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
	game.sim.state.hp = 10
	game.build_ui()
	for child in game.ui.get_children():
		if child is Button and child.text == "ROOTWORKS PUMP": child.pressed.emit(); break
	for child in game.ui.get_children():
		if child is Button and child.text.begins_with("ACCEPT ASSIGNMENT"): child.pressed.emit(); break
	check(game.sim.state.phase == "travel" and game.sim.state.route == "route.rootworks", "route button sends authoritative choice")
	while game.sim.state.phase == "travel":
		for child in game.ui.get_children():
			if child is Button and child.text.contains("· FREE"):
				child.pressed.emit()
				break
	check(game.sim.state.phase == "combat" and game.sim.state.site_id == "site.rootworks_pump", "travel buttons arrive at selected destination")
	check(game.notification == "ROAD REST / 59 structure restored", "arrival explains recovery without erasing the road consequence")
	var red_edges = game.sim.chapter.expedition_map.edges.filter(func(edge): return edge.route_id == "route.red_foundry")
	var brass_red_edge = red_edges.filter(func(edge): return edge.from_site_id == "site.brass_choir_relay")[0]
	var rootworks_red_edge = red_edges.filter(func(edge): return edge.from_site_id == "site.rootworks_pump")[0]
	game.sim.state.phase = "route"
	game.sim.state.site_id = "site.brass_choir_relay"
	game.sim.state.route = "route.brass_choir"
	game.sim.state.route_origin_site_id = "site.collapsed_workshop"
	game.sim.refresh_assignments()
	game.map_selection = "route.red_foundry"
	check(game.map_board_title() == "PILGRIMAGE BOARD / BRASS CHOIR", "second-tier Brass board derives its title from the current site")
	check(game.map_edge_emphasis(brass_red_edge) == "selected" and game.map_edge_emphasis(rootworks_red_edge) == "available", "Brass board selects only its own Red Foundry incoming edge")
	game.sim.state.site_id = "site.rootworks_pump"
	game.sim.refresh_assignments()
	check(game.map_board_title() == "PILGRIMAGE BOARD / ROOTWORKS", "second-tier Rootworks board derives its title from the current site")
	check(game.map_edge_emphasis(brass_red_edge) == "available" and game.map_edge_emphasis(rootworks_red_edge) == "selected", "Rootworks board selects only its own Red Foundry incoming edge")
	game.sim.state.route = "route.red_foundry"
	game.sim.state.route_history = ["route.rootworks", "route.red_foundry"]
	game.sim.state.route_origin_site_id = "site.rootworks_pump"
	game.sim.state.assignment_statuses["route.red_foundry"] = "accepted"
	check(game.map_edge_emphasis(brass_red_edge) == "available" and game.map_edge_emphasis(rootworks_red_edge) == "accepted", "accepted shared route uses its persisted authored origin")
	var workshop_root_edge = game.sim.chapter.expedition_map.edges.filter(func(edge): return edge.route_id == "route.rootworks")[0]
	check(game.map_edge_emphasis(workshop_root_edge) == "accepted", "completed first leg remains visible as accepted route history")
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
