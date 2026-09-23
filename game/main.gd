extends Node2D
const Sim = preload("res://game/simulation.gd")
const ArenaArt = preload("res://game/arena_art.gd")
var arena_art = ArenaArt.new()
const MenuPanels = preload("res://game/menu_panels.gd")
var manual_pages = JSON.parse_string(FileAccess.get_file_as_string("res://content/ui/field_manual.json")).pages
const ActorArt = preload("res://game/actor_art.gd")
var actor_art = ActorArt.new()
const Sound = preload("res://game/sound.gd")
const Profile = preload("res://game/profile.gd")
const Settings = preload("res://game/settings.gd")
const SaveStore = preload("res://game/save_store.gd")
const INK = Color("101e23")
const PANEL = Color("17292d")
const PAPER = Color("e9dec2")
const MUTED = Color("8da49d")
const GOLD = Color("dfb56b")
const GREEN = Color("8ecdb2")
const RED = Color("e48b73")
var sim = Sim.new()
var profile = Profile.new()
var settings = Settings.new()
var save_store = SaveStore.new()
var frame_defs: Array = []
var sound
var screen = "title"
var previous_screen = "title"
var chosen = 0
var chosen_frame = "frame.pilgrim"
var run_mode = "optional"
var camera_offset = Vector2.ZERO
const WORLD_VIEW = Rect2(60, 158, 980, 578)
var ui: Control
var font = ThemeDB.fallback_font
var title_font = SystemFont.new()
var fx: Array = []
var notification = ""
var notice_until = 0
var reduced_fx = false
var debug_visible = false
var capture_dir = ""
var fixture_label = false
var capture_label = "FIXTURE CAPTURE"
var capture_step = 0
var rendered_frames = 0
var last_phase = ""
var seed_value = 147
var ui_scale = 1.0
var save_path = "user://first_shift.save"
var profile_path = Profile.DEFAULT_PATH
var dev_mode = false
var simulation_speed = 1
var tutorial_page = 0
var awaiting_binding = ""
var recent_unlocks: Array = []
var lore = JSON.parse_string(FileAccess.get_file_as_string("res://content/lore/first_shift.json"))
var ledger_return = "title"
var ledger_section = "origin"
var ledger_page = 0
var evolution_ledger_open = false
var map_selection = ""
var map_inspection_site = ""
var departure_selection = "site.collapsed_workshop"
var map_travel_button: Button
var departure_launch_button: Button
var visual_clock_override = -1
var title_transition_started = -1
var evolution_showcase: Dictionary = {}
var impulse_started = -1
var impulse_strength = 0.0
var impulse_angle = 0.0
const MENU_MEDITATION = preload("res://assets/title/meditation.png")
const MENU_AWAKENING = preload("res://assets/title/awakening.png")
var painted_menu = true
const TITLE_TRANSITION_MS = 1350
const EVOLUTION_SHOWCASE_MS = 1450

const WEAPON_FX_DURATION_MS = {
	"line": 380,
	"rail": 560,
	"cone": 460,
	"radial": 620,
	"orbit": 420,
	"parade": 680,
	"shot": 420,
	"funeral_shots": 620,
	"tether": 500,
	"lattice": 680,
	"beam": 320,
	"sermon": 560,
	"blast": 620,
	"benediction": 700,
	"consecrated": 700,
	"censer": 520,
	"ashen_censer": 680,
	"winch": 580,
	"long_hand": 720,
	"halo": 480,
	"repair_halo": 680,
}

func open_ledger():
	ledger_return = screen
	screen = "ledger"
	ledger_section = "relics" if ledger_return == "game" else "origin"
	ledger_page = 0
	build_ui()

func ledger_entries() -> Array:
	return [lore.origin] if ledger_section == "origin" else lore[ledger_section]

func change_ledger(section: String):
	ledger_section = section
	ledger_page = 0
	build_ui()

func close_ledger():
	screen = ledger_return
	build_ui()

func _ready():
	title_font.font_names = PackedStringArray(["Georgia", "DejaVu Serif"])
	frame_defs = JSON.parse_string(FileAccess.get_file_as_string("res://content/frames/first_chapter.json")).frames
	profile.load_from(profile_path)
	settings.load_from()
	settings.apply_input_map()
	settings.apply_presentation()
	reduced_fx = settings.state.reduced_effects
	ui_scale = settings.state.ui_scale
	sound = Sound.new()
	add_child(sound)
	sound.muted = settings.state.muted
	ui = Control.new()
	add_child(ui)
	for arg in OS.get_cmdline_user_args():
		if arg == "--dev-speed=5":
			dev_mode = true
			simulation_speed = 5
		if arg.begins_with("--capture-dir="):
			capture_dir = arg.trim_prefix("--capture-dir=")
			run_mode = "relay"
			screen = "menu"
			debug_visible = true
			DirAccess.make_dir_recursive_absolute(capture_dir)
	build_ui()

func _physics_process(_delta):
	if screen == "game" and not sim.state.is_empty():
		var movement = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		movement += Vector2(float(Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_LEFT)), float(Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_UP)))
		movement = movement.limit_length()
		if Input.get_connected_joypads().size() > 0:
			var pad = Input.get_connected_joypads()[0]
			var stick = Vector2(Input.get_joy_axis(pad, JOY_AXIS_LEFT_X), Input.get_joy_axis(pad, JOY_AXIS_LEFT_Y))
			if stick.length() > 0.2: movement = stick
		advance_simulation(movement)
		if sim.state.phase != last_phase:
			last_phase = sim.state.phase
			if last_phase == "site_clear":
				commit_profile_progress()
				checkpoint_run("site clear")
			if last_phase in ["won", "lost"]: commit_profile_result()
			build_ui()
	fx = fx.filter(func(e): return visual_now_ms() < int(e.expires))
	queue_redraw()

func advance_simulation(movement: Vector2):
	# Preserve fixed-tick rules and every substep's events. Never fast-forward menus.
	for substep in range(simulation_speed):
		if sim.state.is_empty() or sim.state.phase != "combat" or sim.state.paused: break
		sim.step(movement)
		for event in sim.events: present(event)

func _process(_delta):
	if title_transition_started >= 0 and title_transition_progress() >= 1.0:
		title_transition_started = -1
		screen = "menu"
		build_ui()
	if not evolution_showcase.is_empty() and visual_now_ms() >= int(evolution_showcase.expires):
		evolution_showcase.clear()
		build_ui()
	if capture_dir != "":
		rendered_frames += 1
		if rendered_frames in [3, 15, 27, 39, 51, 63, 75]:
			capture_sequence()

func _unhandled_key_input(event):
	if not event.pressed or event.echo: return
	if awaiting_binding != "":
		if event.keycode != KEY_ESCAPE and settings.rebind(awaiting_binding, event.physical_keycode if event.physical_keycode > 0 else event.keycode):
			settings.apply_input_map()
			settings.save_to()
		awaiting_binding = ""
		build_ui()
		return
	if event.keycode == KEY_ESCAPE and screen == "menu":
		screen = "title"
		build_ui()
		return
	if event.keycode == KEY_ESCAPE and screen == "departure_map":
		screen = "menu"
		build_ui()
		return
	if event.keycode == KEY_ESCAPE and screen == "ledger":
		close_ledger()
		return
	if event.keycode == KEY_ESCAPE and screen in ["settings", "tutorial", "quit_confirm"]:
		close_panel()
		return
	if event.keycode == KEY_ESCAPE and screen == "game" and evolution_ledger_open:
		evolution_ledger_open = false
		build_ui()
		return
	if event.keycode == KEY_ESCAPE and screen == "game" and not sim.state.is_empty() and sim.state.phase == "route":
		select_map_site(str(sim.state.site_id))
		return
	if event.keycode == KEY_F3: debug_visible = not debug_visible
	if event.keycode == KEY_F6 and dev_mode:
		simulation_speed = 1 if simulation_speed == 5 else 5
	if event.keycode == KEY_M:
		settings.set_option("muted", not settings.state.muted)
		settings.save_to()
		sound.muted = settings.state.muted
		build_ui()
	if event.keycode == KEY_ESCAPE and screen == "game":
		sim.command("pause")
		build_ui()
	if event.keycode == KEY_F5 and screen == "game": save_run()
	if event.keycode == KEY_F9: load_run()

func _input(event):
	if event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_B:
		if screen == "ledger":
			close_ledger()
			get_viewport().set_input_as_handled()
			return
		if screen == "menu":
			screen = "title"
			build_ui()
			get_viewport().set_input_as_handled()
			return
		if screen == "departure_map":
			screen = "menu"
			build_ui()
			get_viewport().set_input_as_handled()
			return
	if event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_B and screen in ["settings", "tutorial", "quit_confirm"]:
		if awaiting_binding != "":
			awaiting_binding = ""
			build_ui()
		else: close_panel()
		get_viewport().set_input_as_handled()
	if event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_B and screen == "game" and not sim.state.is_empty() and sim.state.phase == "route":
		select_map_site(str(sim.state.site_id))
		get_viewport().set_input_as_handled()
	if event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_START and screen == "game":
		sim.command("pause")
		build_ui()

func begin():
	# Fixed seed makes the two objective modes directly comparable.
	var run_id = profile.claim_run_id(seed_value, chosen_frame)
	profile.save_to(profile_path)
	# Committing a new pilgrimage retires every generation of the previous run.
	save_store.clear(save_path)
	sim.start(chosen, seed_value, run_mode, chosen_frame, run_id)
	screen = "game"
	recent_unlocks.clear()
	last_phase = "combat"
	fx.clear()
	checkpoint_run("departure")
	build_ui()

func open_departure_map():
	departure_selection = str(sim.chapter.expedition_map.origin_site_id)
	screen = "departure_map"
	build_ui()

func begin_title_transition():
	if title_transition_started >= 0: return
	title_transition_started = visual_now_ms()
	sound.play("title_commit")
	build_ui()

func title_transition_progress() -> float:
	if title_transition_started < 0: return 0.0
	return clampf(float(visual_now_ms() - title_transition_started) / float(300 if reduced_fx else TITLE_TRANSITION_MS), 0.0, 1.0)

func trigger_camera_impulse(strength: float, event: Dictionary):
	if reduced_fx or not bool(settings.state.screen_shake): return
	impulse_started = visual_now_ms()
	impulse_strength = maxf(impulse_strength, strength)
	impulse_angle = float(event.get("tick", sim.state.get("tick", 0))) * 1.618 + strength

func current_camera_impulse() -> Vector2:
	if reduced_fx or not bool(settings.state.screen_shake) or impulse_started < 0: return Vector2.ZERO
	var progress = clampf(float(visual_now_ms() - impulse_started) / 190.0, 0.0, 1.0)
	if progress >= 1.0:
		impulse_started = -1
		impulse_strength = 0.0
		return Vector2.ZERO
	var wave = sin(progress * PI * 5.0) * (1.0 - progress)
	return Vector2.from_angle(impulse_angle) * impulse_strength * wave

func act(action: String, value = null):
	sim.events.clear()
	notification = ""
	var before_phase = str(sim.state.get("phase", ""))
	var result = sim.command(action, value)
	for event in sim.events: present(event)
	if result != "OK":
		notification = result.replace("_", " ").capitalize()
		notice_until = Time.get_ticks_msec() + 2500
	if action == "evolve" and result == "OK":
		notification = sim.evolution_recipes[str(value)].name.to_upper() + " — the relic answers differently"
		notice_until = Time.get_ticks_msec() + 4500
		evolution_ledger_open = false
		evolution_showcase = {
			"recipe": str(value),
			"name": sim.evolution_recipes[str(value)].name,
			"started_at": visual_now_ms(),
			"expires": visual_now_ms() + EVOLUTION_SHOWCASE_MS,
		}
	if result == "OK": handle_checkpoint_boundary(action, before_phase)
	if sim.state.phase in ["won", "lost"]: commit_profile_result()
	last_phase = str(sim.state.phase)
	build_ui()

func handle_checkpoint_boundary(action: String, before_phase: String):
	if action == "continue_site_clear" or (action == "accept_memory" and before_phase == "site_clear"):
		checkpoint_run("route map" if sim.state.phase == "route" else "chapter complete")
	elif action == "choose_route":
		commit_profile_progress()
		checkpoint_run("route commitment")
	elif action == "choose_road_option":
		commit_profile_progress()
		checkpoint_run("destination arrival" if sim.state.phase == "arrival" else "road choice")
	elif action == "begin_site":
		checkpoint_run("site start")

func select_map_route(route_id: String):
	if sim.available_routes().any(func(route): return route.id == route_id):
		map_selection = route_id
		map_inspection_site = str(sim.routes[route_id].site_id)
		update_map_travel_button()
		queue_redraw()

func select_departure_site(site_id: String):
	departure_selection = site_id
	if departure_launch_button != null:
		var origin_id = str(sim.chapter.expedition_map.origin_site_id)
		departure_launch_button.disabled = site_id != origin_id
		departure_launch_button.text = "BEGIN AT COLLAPSED WORKSHOP  →" if site_id == origin_id else "RETURN TO WORKSHOP TO BEGIN"
	queue_redraw()

func select_map_site(site_id: String):
	map_inspection_site = site_id
	map_selection = ""
	for route in sim.available_routes():
		if str(route.site_id) == site_id:
			map_selection = str(route.id)
			break
	update_map_travel_button()
	queue_redraw()

func update_map_travel_button():
	if map_travel_button == null: return
	var selected = sim.routes.get(map_selection, {})
	if selected.is_empty():
		map_travel_button.text = "SELECT A REACHABLE DESTINATION"
		map_travel_button.disabled = true
		return
	var accepted = sim.assignment_status(map_selection) == "accepted"
	map_travel_button.text = "ASSIGNMENT ACCEPTED" if accepted else "TRAVEL TO %s  →" % str(selected.name).to_upper()
	map_travel_button.disabled = accepted or sim.state.scrap < int(selected.cost)

func build_map_node_buttons(departure: bool):
	var first_focus: Button = null
	var origin_id = str(sim.chapter.expedition_map.origin_site_id)
	var reachable_site_ids = sim.available_routes().map(func(route): return str(route.site_id)) if not departure else [origin_id]
	for site in sim.chapter.expedition_map.sites:
		var site_id = str(site.id)
		var position = map_site_position(site)
		var selected = site_id == (departure_selection if departure else map_inspection_site)
		var node_button = button(str(site.name).to_upper(), Rect2(position - Vector2(76, 17), Vector2(152, 34)), func():
			if departure: select_departure_site(site_id)
			else: select_map_site(site_id), selected)
		node_button.tooltip_text = "Inspect %s" % str(site.name)
		node_button.focus_entered.connect(func():
			if departure: select_departure_site(site_id)
			else: select_map_site(site_id))
		if first_focus == null and site_id in reachable_site_ids: first_focus = node_button
	if first_focus != null: first_focus.grab_focus()

func commit_profile_result():
	if sim.state.is_empty() or sim.state.result_summary.is_empty(): return
	for unlocked in profile.record_run(sim.state.result_summary):
		if unlocked not in recent_unlocks: recent_unlocks.append(unlocked)
	profile.save_to(profile_path)
	save_store.clear(save_path)

func commit_profile_progress():
	if sim.state.is_empty(): return
	for unlocked in profile.record_progress(sim.progress_summary()):
		if unlocked not in recent_unlocks: recent_unlocks.append(unlocked)
	profile.save_to(profile_path)

func open_panel(panel_name: String):
	previous_screen = screen
	screen = panel_name
	build_ui()

func close_panel():
	awaiting_binding = ""
	screen = previous_screen
	build_ui()

func toggle_setting(key: String):
	settings.set_option(key, not bool(settings.state[key]))
	settings.apply_presentation()
	settings.save_to()
	reduced_fx = settings.state.reduced_effects
	sound.muted = settings.state.muted
	build_ui()

func cycle_text_scale():
	settings.set_option("ui_scale", 1.15 if settings.state.ui_scale <= 1.0 else 1.0)
	ui_scale = settings.state.ui_scale
	settings.save_to()
	build_ui()

func save_run():
	if sim.state.is_empty() or sim.state.phase in ["won", "lost"]:
		save_store.clear(save_path)
		notification = "Completed expeditions cannot be resumed."
	elif save_store.write_atomic(save_path, sim.snapshot()):
		notification = "Shift saved. F9 to resume."
	else: notification = "Could not write save."
	notice_until = Time.get_ticks_msec() + 2500

func checkpoint_run(_reason: String) -> bool:
	if sim.state.is_empty() or sim.state.phase in ["won", "lost"]: return false
	return save_store.write_atomic(save_path, sim.snapshot())

func has_saved_expedition() -> bool:
	return save_store.has_valid_save(save_path)

func save_and_return_to_title():
	if checkpoint_run("return to title"):
		screen = "title"
		build_ui()
	else:
		notification = "Could not secure the pilgrimage."
		notice_until = Time.get_ticks_msec() + 4000

func load_run():
	for saved in save_store.load_dictionaries(save_path):
		if not sim.restore(saved): continue
		if sim.state.phase in ["won", "lost"]:
			commit_profile_result()
			screen = "title"
			notification = "That pilgrimage has already ended."
			notice_until = Time.get_ticks_msec() + 4000
		else:
			screen = "game"
			last_phase = str(sim.state.phase)
			fx.clear()
			commit_profile_progress()
			build_ui()
		return
	notification = "This save could not be restored. The last safe checkpoint was also checked."
	notice_until = Time.get_ticks_msec() + 6000

func present(event):
	var e = event.duplicate(true)
	var gift_id = gift_event_id(e)
	var duration = presentation_duration_ms(e)
	e.presented_at = visual_now_ms()
	e.duration_ms = duration
	e.expires = int(e.presented_at) + duration
	if fx.size() < (60 if reduced_fx else 160): fx.append(e)
	if e.kind == "machine_restored":
		notification = "RESTORED / " + e.reward
		notice_until = Time.get_ticks_msec() + 3000
	if e.kind == "destination_arrived":
		notification = "ROAD REST / %d structure restored" % int(e.arrival_repair)
		notice_until = Time.get_ticks_msec() + 3500
	if e.kind == "road_choice":
		notification = str(e.result)
		notice_until = Time.get_ticks_msec() + 3500
	if e.kind == "boss_contract":
		notification = str(e.phase_name) + " / " + str(e.rule).replace("_", " ").to_upper()
		notice_until = Time.get_ticks_msec() + 2600
	if gift_id != "":
		var gift_name = sim.config.gifts.get(gift_id, {}).get("short", gift_id.trim_prefix("gift.").replace("_", " ").capitalize())
		var cue = {
			"gift.loose_spring": "RELEASED / MOVE",
			"gift.choir_filter": "SUPPORT HELD QUIET",
			"gift.brass_fuse": "FIRST STAGGER MARKED",
		}.get(gift_id, "RULE ACTIVE")
		notification = "%s / %s" % [str(gift_name).to_upper(), cue]
		notice_until = Time.get_ticks_msec() + 1800
	if e.kind == "attack": sound.play(e.shape)
	elif e.kind in ["hurt", "relay_hurt", "repair", "pickup", "death", "evolution", "boss_contract", "machine_restored", "quieted"]: sound.play(e.kind)
	elif gift_id != "": sound.play("pickup")
	if e.kind in ["hurt", "relay_hurt"]: trigger_camera_impulse(3.2 if e.kind == "hurt" else 4.0, e)
	elif e.kind == "evolution": trigger_camera_impulse(5.0, e)
	elif e.kind == "boss_contract": trigger_camera_impulse(3.5, e)
	elif e.kind == "hit": trigger_camera_impulse(0.65, e)

func visual_now_ms() -> int:
	return visual_clock_override if visual_clock_override >= 0 else Time.get_ticks_msec()

func presentation_duration_ms(event: Dictionary) -> int:
	if gift_event_id(event) != "": return 900
	if event.get("kind", "") == "evolution": return 760
	if event.get("kind", "") == "attack": return int(WEAPON_FX_DURATION_MS.get(str(event.get("shape", "")), 230))
	if event.get("kind", "") == "hit" and str(event.get("weapon", "")) != "": return 500
	return 480 if event.get("kind", "") in ["repair", "death", "blast"] else 230

func presentation_progress(event: Dictionary) -> float:
	var duration = maxi(1, int(event.get("duration_ms", presentation_duration_ms(event))))
	var started = int(event.get("presented_at", int(event.get("expires", visual_now_ms() + duration)) - duration))
	return clampf(float(visual_now_ms() - started) / float(duration), 0.0, 1.0)

func presentation_fade(event: Dictionary) -> float:
	var progress = presentation_progress(event)
	if progress < 0.12: return smoothstep(0.0, 0.12, progress)
	return 1.0 - smoothstep(0.68, 1.0, progress)

func latest_weapon_attack(weapon_id: String):
	for index in range(fx.size() - 1, -1, -1):
		var effect = fx[index]
		if effect.get("kind", "") == "attack" and str(effect.get("weapon", "")) == weapon_id:
			return effect
	return null

func gift_event_id(event: Dictionary) -> String:
	var explicit = str(event.get("gift", event.get("gift_id", "")))
	if explicit != "": return explicit
	return {
		"loose_spring_released": "gift.loose_spring",
		"choir_filter_blocked": "gift.choir_filter",
		"brass_fuse_lit": "gift.brass_fuse",
	}.get(str(event.get("kind", "")), "")

func button(label: String, rect: Rect2, callback: Callable, primary = false):
	var b = Button.new()
	b.text = label
	b.position = rect.position
	b.size = rect.size
	b.add_theme_font_size_override("font_size", int(15 * ui_scale))
	b.add_theme_color_override("font_color", INK if primary else PAPER)
	b.add_theme_color_override("font_hover_color", INK if primary else PAPER)
	b.add_theme_color_override("font_focus_color", INK if primary else PAPER)
	b.add_theme_color_override("font_pressed_color", INK if primary else PAPER)
	for style_name in ["normal", "hover", "pressed", "focus"]:
		var style = StyleBoxFlat.new()
		style.bg_color = GOLD if primary else PANEL.lightened(0.08 if style_name == "hover" else 0.0)
		style.border_color = GOLD if style_name == "focus" or primary else Color("3b5150")
		style.set_border_width_all(2 if style_name == "focus" else 1)
		style.set_corner_radius_all(4)
		b.add_theme_stylebox_override(style_name, style)
	b.pressed.connect(callback)
	ui.add_child(b)
	return b

func build_ui():
	map_travel_button = null
	departure_launch_button = null
	for child in ui.get_children():
		ui.remove_child(child)
		child.queue_free()
	if screen == "game" and not evolution_showcase.is_empty(): return
	if screen == "ledger":
		for i in range(3):
			var section = ["origin", "relics", "creatures"][i]
			button(["The Saint", "Relic histories", "Corrupted machines"][i], Rect2(124+i*344, 174, 324, 42), func(): change_ledger(section), ledger_section == section)
		var entries = ledger_entries()
		var previous = button("← Previous", Rect2(124, 638, 190, 42), func(): ledger_page -= 1; build_ui())
		previous.disabled = ledger_page == 0
		var next = button("Next →", Rect2(330, 638, 190, 42), func(): ledger_page += 1; build_ui())
		next.disabled = ledger_page >= entries.size()-1
		button("Return to shop" if ledger_return == "game" else "Return to title", Rect2(808,638,348,42), close_ledger, true).grab_focus()
	elif screen == "title":
		if title_transition_started < 0:
			var has_save = has_saved_expedition()
			var resume = button("Continue", Rect2(80, 302, 350, 48), load_run, has_save)
			resume.disabled = not has_save
			resume.tooltip_text = "Resume your saved expedition." if has_save else "Save a shift from the pause menu to continue it here."
			var fresh = button("New pilgrimage", Rect2(80, 362, 350, 48), begin_title_transition, not has_save)
			if has_save: resume.grab_focus()
			else: fresh.grab_focus()
			button("Settings", Rect2(80, 434, 350, 42), func(): open_panel("settings"))
			button("How to play", Rect2(80, 486, 350, 42), func(): tutorial_page = 0; open_panel("tutorial"))
			button("Sacred histories", Rect2(80, 538, 350, 42), open_ledger)
			button("Quit", Rect2(80, 610, 350, 42), func(): open_panel("quit_confirm"))
	elif screen == "quit_confirm":
		button("Stay", Rect2(340, 470, 280, 46), close_panel, true).grab_focus()
		button("Quit game", Rect2(660, 470, 280, 46), func(): get_tree().quit())
	elif screen == "tutorial":
		button("Back", Rect2(100, 680, 180, 44), close_panel)
		var previous = button("Previous", Rect2(680, 680, 180, 44), func(): tutorial_page -= 1; build_ui())
		previous.disabled = tutorial_page == 0
		var last_page = tutorial_page == manual_pages.size()-1
		button(("Return to pause" if previous_screen == "game" else "Begin setup") if last_page else "Next", Rect2(880, 680, 300, 44), func():
			if last_page:
				if previous_screen == "game": close_panel()
				else:
					screen = "menu"
					build_ui()
			else:
				tutorial_page += 1
				build_ui(), true).grab_focus()
	elif screen == "settings":
		MenuPanels.build_settings(self)
	elif screen == "menu":
		if dev_mode: button("Optional repairs" if run_mode == "optional" else "Relay defence", Rect2(55, 166, 220, 32), func(): run_mode = "relay" if run_mode == "optional" else "optional"; build_ui())
		button("Seed %d / change" % seed_value, Rect2(790, 94, 200, 32), func(): seed_value = randi_range(1, 1000000); build_ui())
		button("Back", Rect2(1010, 94, 180, 32), func(): screen = "title"; build_ui())
		for i in range(frame_defs.size()):
			var frame = frame_defs[i]
			var unlocked = frame.id in profile.state.unlocked_frames
			var frame_button = button(("✓ " if chosen_frame == frame.id else "") + frame.name + ("" if unlocked else " · LOCKED"), Rect2(250 + i * 270, 292, 240, 34), func(): chosen_frame = frame.id; build_ui(), chosen_frame == frame.id and unlocked)
			frame_button.disabled = not unlocked
		var blessing_names = ["Workshop", "Bell Ward", "Mourner", "Procession"]
		var blessing_ids = sim.config.blessings
		for i in range(blessing_names.size()):
			var unlocked = blessing_ids[i] in profile.state.unlocked_blessings
			var blessing_button = button(("Choose " if unlocked else "Locked / ") + blessing_names[i], Rect2(56 + i * 292, 548, 276, 38), func(): chosen = i; build_ui(), chosen == i and unlocked)
			blessing_button.disabled = not unlocked
		button("REVIEW THE PILGRIMAGE  →", Rect2(436, 613, 408, 52), open_departure_map, true).grab_focus()
		if has_saved_expedition(): button("Resume saved expedition", Rect2(436, 678, 408, 36), load_run)
	elif screen == "departure_map":
		build_map_node_buttons(true)
		button("BACK TO SETUP", Rect2(44, 682, 220, 46), func(): screen = "menu"; build_ui())
		departure_launch_button = button("BEGIN AT COLLAPSED WORKSHOP  →", Rect2(850, 682, 386, 46), begin, true)
		departure_launch_button.disabled = departure_selection != str(sim.chapter.expedition_map.origin_site_id)
	elif sim.state.phase == "route":
		var route_options = sim.available_routes()
		if route_options.size() > 0 and not route_options.any(func(route): return route.id == map_selection):
			map_selection = str(route_options[0].id)
			map_inspection_site = str(route_options[0].site_id)
		elif map_inspection_site == "" and route_options.size() > 0:
			map_inspection_site = str(route_options[0].site_id)
		build_map_node_buttons(false)
		button("INSPECT CURRENT SITE", Rect2(44, 682, 250, 46), func(): select_map_site(str(sim.state.site_id)))
		map_travel_button = button("TRAVEL TO SELECTED DESTINATION  →", Rect2(850, 682, 386, 46), func():
			if map_selection != "": act("choose_route", map_selection), true)
		update_map_travel_button()
	elif sim.state.phase == "travel":
		var node = sim.current_road_node()
		var first_affordable: Button = null
		for i in range(node.get("choices", []).size()):
			var option = node.choices[i]
			var option_id = str(option.id)
			var option_button = button(str(option.label).to_upper() + " · " + road_choice_terms(option), Rect2(92, 548 + i * 54, 910, 42), func(): act("choose_road_option", option_id), i == 0)
			option_button.disabled = sim.state.scrap < int(option.cost)
			if first_affordable == null and not option_button.disabled: first_affordable = option_button
		if first_affordable != null: first_affordable.grab_focus()
	elif sim.state.phase == "arrival":
		button("ENTER %s  →" % str(sim.state.arrival_summary.site_name).to_upper(), Rect2(410, 615, 460, 48), func(): act("begin_site"), true).grab_focus()
	elif sim.state.phase == "site_clear":
		var continue_label = "COMPLETE THE CHAPTER  →" if bool(sim.state.site_clear_summary.get("terminal", false)) else ("OPEN THE PILGRIMAGE MAP  →" if str(sim.state.site_id) == str(sim.chapter.expedition_map.origin_site_id) else "CHOOSE THE NEXT DESTINATION  →")
		button(continue_label, Rect2(410, 615, 460, 48), func(): act("continue_site_clear"), true).grab_focus()
	elif sim.state.phase == "shop":
		if evolution_ledger_open:
			for i in range(sim.config.evolutions.size()):
				var recipe_id = sim.config.evolutions[i]
				var evolve_button = button("EVOLVE", Rect2(408 + (i % 2) * 470, 222 + int(i / 2) * 88, 92, 26), func(): act("evolve", recipe_id))
				evolve_button.disabled = sim.evolution_recipe_state(recipe_id) != "READY"
			button("BACK TO WORKSHOP", Rect2(742, 678, 250, 38), func(): evolution_ledger_open = false; build_ui(), true).grab_focus()
		else:
			for i in range(6):
				var col = i % 3
				var row = int(i / 3)
				var x = 94 + col * 302
				var y = 208 + row * 192
				var buy_button = button("BUY / COMBINE" if sim.state.offers[i] in sim.config.weapons else "ACQUIRE", Rect2(x + 14, y + 142, 182, 28), func(): act("buy", i))
				buy_button.disabled = sim.purchase_preview(i).result != "OK"
				button("◆" if sim.state.locked == sim.state.offers[i] and sim.state.offers[i] != "" else "Lock", Rect2(x + 205, y + 142, 66, 28), func(): act("lock", i))
			var costs = sim.config.economy.reroll_costs
			var refresh = "No refreshes left" if sim.state.rerolls >= costs.size() else ("Refresh · FREE" if costs[sim.state.rerolls] == 0 else "Refresh · %d Scrap" % costs[sim.state.rerolls])
			button(refresh, Rect2(108, 613, 220, 40), func(): act("reroll"))
			button("EVOLUTION LEDGER · %d" % sim.config.evolutions.size(), Rect2(344, 613, 250, 40), func(): evolution_ledger_open = true; build_ui())
			button("Histories", Rect2(610, 613, 108, 40), open_ledger)
			button("NEXT WAVE  →", Rect2(734, 613, 250, 40), func(): act("continue"), true).grab_focus()
			button("Combine pair", Rect2(1060, 573, 188, 32), func(): act("combine"))
			button("Equip reserve", Rect2(1060, 613, 188, 32), func(): act("equip"))
			for i in range(sim.state.weapons.size()):
				button("Sell", Rect2(1060, 243 + i * 79, 52, 26), func(): act("sell", i))
				button("Dism.", Rect2(1118, 243 + i * 79, 59, 26), func(): act("dismantle", i))
				button("Store", Rect2(1183, 243 + i * 79, 65, 26), func(): act("reserve", i))
			for i in range(sim.state.gifts.size()):
				button("Sell", Rect2(1068, 674 + i * 40, 78, 23), func(): act("sell_gift", i))
				button("Dism.", Rect2(1151, 674 + i * 40, 81, 23), func(): act("dismantle_gift", i))
	elif sim.state.phase in ["won", "lost"]:
		button("RETURN TO THE WORKSHOP", Rect2(410, 655, 460, 44), func(): screen = "menu"; build_ui(), true).grab_focus()
	elif sim.state.paused:
		button("Resume", Rect2(760, 252, 300, 46), func(): sim.command("pause"); build_ui(), true).grab_focus()
		button("Save shift", Rect2(760, 310, 300, 42), save_run)
		button("Settings", Rect2(760, 366, 300, 42), func(): open_panel("settings"))
		button("How to play", Rect2(760, 422, 300, 42), func(): tutorial_page = 0; open_panel("tutorial"))
		button("Save & return to title", Rect2(760, 494, 300, 42), save_and_return_to_title)
	if screen == "game" and not sim.state.is_empty() and sim.state.phase in ["route", "travel", "arrival", "shop", "site_clear"]:
		button("SAVE & TITLE", Rect2(1060, 710, 188, 30), save_and_return_to_title)
	if screen == "game":
		button("Sound " + ("off" if settings.state.muted else "on"), Rect2(28, 757, 117, 28), func(): toggle_setting("muted"))
		button("Effects " + ("low" if reduced_fx else "full"), Rect2(153, 757, 122, 28), func(): toggle_setting("reduced_effects"))
		button("Text " + ("large" if ui_scale > 1 else "normal"), Rect2(283, 757, 127, 28), cycle_text_scale)

func road_choice_terms(option: Dictionary) -> String:
	var terms: Array[String] = ["FREE" if int(option.get("cost", 0)) == 0 else "%d SCRAP" % int(option.cost)]
	if int(option.get("scrap_delta", 0)) != 0: terms.append("%+d SCRAP" % int(option.scrap_delta))
	if int(option.get("structure_delta", 0)) != 0: terms.append("%+d STRUCTURE" % int(option.structure_delta))
	return " / ".join(terms)

func text_at(value: String, p: Vector2, size = 16, color = PAPER, serif = false):
	draw_string(title_font if serif else font, p, value, HORIZONTAL_ALIGNMENT_LEFT, -1, int(size * ui_scale), color)

func panel(rect: Rect2, color = PANEL):
	draw_style_box(box(color), rect)

func box(color: Color):
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color("314346")
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	return style

func bar(rect: Rect2, fraction: float, color: Color):
	draw_rect(rect, Color("253a3d"))
	draw_rect(Rect2(rect.position, Vector2(rect.size.x * clampf(fraction, 0, 1), rect.size.y)), color)

func _draw():
	draw_rect(Rect2(0, 0, 1280, 800), INK)
	if screen == "ledger":
		camera_offset = Vector2.ZERO
		draw_ledger()
		return
	if screen == "title":
		camera_offset = Vector2.ZERO
		draw_title()
	elif screen == "menu":
		camera_offset = Vector2.ZERO
		draw_menu()
	elif screen == "departure_map":
		camera_offset = Vector2.ZERO
		draw_pilgrimage_map(true)
	elif screen == "game" and not sim.state.is_empty() and sim.state.phase == "route":
		camera_offset = Vector2.ZERO
		draw_pilgrimage_map(false)
	elif screen == "tutorial":
		camera_offset = Vector2.ZERO
		draw_title()
		draw_tutorial()
	elif screen == "quit_confirm":
		camera_offset = Vector2.ZERO
		draw_title()
		draw_rect(Rect2(0, 0, 1280, 800), Color(0.02, 0.04, 0.04, 0.72))
		panel(Rect2(280, 260, 720, 310))
		text_at("Leave the workshop?", Vector2(340, 337), 34, PAPER, true)
		wrapped("Your saved expedition and collected memories will be here when you return.", Vector2(340, 387), 590, 17, MUTED)
	elif screen == "settings":
		camera_offset = Vector2.ZERO
		draw_title()
		draw_settings()
	else:
		if sim.state.phase == "travel":
			camera_offset = Vector2.ZERO
			draw_travel_background()
		else:
			var half_view = WORLD_VIEW.size * 0.5
			var camera = sim.state.position.clamp(sim.arena.bounds.position + half_view, sim.arena.bounds.end - half_view)
			camera_offset = WORLD_VIEW.get_center() - camera + current_camera_impulse()
			draw_set_transform(camera_offset)
			draw_world()
			draw_set_transform(Vector2.ZERO)
		# Mask world rendering outside the gameplay window; HUD stays screen-space.
		draw_rect(Rect2(0, 0, 1280, 158), INK)
		draw_rect(Rect2(0, 736, 1280, 64), INK)
		draw_rect(Rect2(0, 158, 60, 578), INK)
		draw_rect(Rect2(1040, 158, 240, 578), INK)
		draw_header()
		draw_loadout()
		draw_boss_hud()
		if sim.state.phase == "combat": draw_minimap()
		if sim.state.phase == "shop":
			if evolution_ledger_open: draw_evolution_ledger()
			else: draw_shop()
		if sim.state.phase == "route": draw_route_choice()
		if sim.state.phase == "travel": draw_travel()
		if sim.state.phase == "arrival": draw_arrival()
		if sim.state.phase == "site_clear": draw_site_clear()
		if sim.state.phase in ["won", "lost"]: draw_results()
		if sim.state.paused and sim.state.phase == "combat":
			draw_rect(Rect2(0, 0, 1280, 745), Color(0.025, 0.05, 0.06, 0.87))
			MenuPanels.draw_pause(self)
	if not evolution_showcase.is_empty(): draw_evolution_showcase()
	if notification != "" and Time.get_ticks_msec() < notice_until:
		panel(Rect2(430, 699, 600, 34))
		text_at(notification, Vector2(444, 721), 15, GOLD)
	if dev_mode:
		panel(Rect2(924, 94, 328, 33))
		text_at("DEV %d× SPEED · F6 toggles 1× / 5×" % simulation_speed, Vector2(938, 116), 13, GOLD)
	if screen == "departure_map" or (screen == "game" and not sim.state.is_empty() and sim.state.phase == "route"):
		text_at("Select a landmark to inspect · confirm separately to travel", Vector2(430, 777), 12, MUTED)
	elif screen == "game": text_at("WASD / arrows · move     ESC · pause     F5 / F9 · save / load", Vector2(445, 777), 13, MUTED)
	if debug_visible:
		text_at("BUILD %s | Godot %s | 1280×800 | seed %d | tick %d | %s" % [sim.config.get("version", "dev"), Engine.get_version_info().string, seed_value, sim.state.get("tick", 0), capture_label if capture_dir != "" or fixture_label else "LIVE"], Vector2(28, 745), 11, GOLD)

func draw_ledger():
	text_at("THE WORKSHOP LEDGER", Vector2(124,89),15,GOLD)
	text_at("What the metal remembers",Vector2(120,143),38,PAPER,true)
	panel(Rect2(108,238,1064,374))
	var entry = ledger_entries()[ledger_page]
	if ledger_section == "relics":
		draw_gear(Vector2(163,291),20,GOLD,0)
	elif ledger_section == "creatures":
		draw_arc(Vector2(163,291),20,0.3,TAU-0.3,24,RED,3,true)
		draw_circle(Vector2(163,291),7,INK)
		draw_line(Vector2(153,270),Vector2(171,312),RED,2,true)
	else:
		draw_saint(Vector2(164,297),Vector2.RIGHT,1.0)
		draw_set_transform(Vector2.ZERO)
	text_at(entry.get("subtitle","RELIC / REMEMBERED SERVICE"),Vector2(212,276),12,GREEN)
	text_at(entry.name,Vector2(210,316),30,PAPER,true)
	wrapped(entry.history.replace("\n", " "),Vector2(148,365),968,18,PAPER)
	wrapped(entry.line,Vector2(148,543),968,19,GOLD)
	text_at("%d / %d" % [ledger_page+1,ledger_entries().size()],Vector2(596,665),16,MUTED)
	text_at("Read at your own pace. Your build and shop offers stay as you left them.",Vector2(148,717),14,MUTED)

func evolution_showcase_progress() -> float:
	if evolution_showcase.is_empty(): return 0.0
	return clampf(float(visual_now_ms() - int(evolution_showcase.started_at)) / float(EVOLUTION_SHOWCASE_MS), 0.0, 1.0)

func draw_evolution_showcase():
	var progress = evolution_showcase_progress()
	var recipe_id = str(evolution_showcase.recipe)
	var recipe = sim.evolution_recipes.get(recipe_id, {})
	var reveal = smoothstep(0.16, 0.48, progress)
	var fade_out = 1.0 - smoothstep(0.84, 1.0, progress)
	draw_rect(Rect2(0, 0, 1280, 800), Color(0.02, 0.04, 0.045, 0.82 * fade_out))
	var center = Vector2(640, 355)
	draw_evolution_reconfiguration({"position": center, "recipe": recipe_id}, progress, fade_out)
	text_at("THE RELIC ANSWERS DIFFERENTLY", Vector2(482, 196), 12, GOLD)
	text_at(str(evolution_showcase.name), Vector2(430, 276), 42, Color(PAPER, reveal), true)
	if not recipe.is_empty():
		var base_name = sim.config.weapons.get(str(recipe.base_item_id), {}).get("short", "RANK III RELIC")
		var geometry = str(recipe.get("result_geometry", "new geometry")).replace("_", " ").to_upper()
		text_at(str(base_name).to_upper() + "  →  " + geometry, Vector2(410, 488), 12, Color(GREEN, reveal))
		var effects = " · ".join(Array(recipe.get("result_effects", [])).map(func(value): return str(value).replace("_", " ").to_upper()))
		wrapped(effects, Vector2(390, 525), 500, 12, Color(MUTED, reveal))
	bar(Rect2(440, 612, 400, 4), progress, GOLD)

func draw_title():
	var transition = title_transition_progress()
	if painted_menu:
		# Preserve the image aspect ratio and all six hands in the 16:10 canvas.
		var target = Rect2(0, 40, 1280, 720)
		draw_texture_rect(MENU_MEDITATION, target, false)
		if transition > 0:
			draw_texture_rect(MENU_AWAKENING, target, false, Color(1, 1, 1, smoothstep(0.08, 0.84, transition)))
	else:
		for band in range(10):
			draw_rect(Rect2(0, band * 80, 1280, 82), Color("183039").lerp(Color("526b6b"), band / 14.0))
		draw_title_city(smoothstep(0.36, 0.84, transition))
		draw_bodhi_tree(transition)
		draw_title_saint(Vector2(900, 420), transition)
		draw_title_clouds(transition)
	# Quiet graded scrim protects the controls without a hard panel edge.
	var shade = Color(0.025, 0.055, 0.06, 0.72)
	var clear = Color(shade, 0.0)
	draw_rect(Rect2(0, 40, 320, 720), shade)
	draw_polygon(PackedVector2Array([Vector2(320,40),Vector2(620,40),Vector2(620,760),Vector2(320,760)]), PackedColorArray([shade,clear,clear,shade]))
	if screen != "title": return
	text_at("A PILGRIMAGE OF REPAIRS", Vector2(80, 113), 12, GOLD)
	text_at("Scrap", Vector2(76, 181), 54, PAPER, true)
	text_at("Saint", Vector2(76, 240), 54, PAPER, true)
	text_at("Small mercies. A world to mend.", Vector2(80, 272), 15, PAPER)
	text_at("THE FIRST CHAPTER", Vector2(80, 697), 11, GOLD)
	text_at("Memories gathered · %d" % profile.state.memory_fragments, Vector2(80, 719), 12, MUTED)
	text_at("%s · PREVIEW" % str(sim.config.get("version", "")).trim_suffix("-preview"), Vector2(1050, 784), 11, MUTED)
	if title_transition_started >= 0:
		text_at("REMEMBERING THE ROAD…", Vector2(80, 375), 14, PAPER)
		bar(Rect2(80, 397, 350, 3), transition, GOLD)

func draw_title_city(reveal: float):
	var horizon = 600.0
	for index in range(13):
		var width = 34 + (index * 17) % 55
		var height = 42 + (index * 31) % 125
		var x = 520 + index * 61
		draw_rect(Rect2(x, horizon - height, width, height), Color("17282d", reveal))
		if index % 3 == 0:
			draw_circle(Vector2(x + width * 0.5, horizon - height + 18), 3, Color(RED, reveal * (0.55 + 0.3 * sin(visual_now_ms() * 0.004 + index))))
	for crane_x in [665.0, 1080.0]:
		draw_line(Vector2(crane_x, 485), Vector2(crane_x, 595), Color("26383b", reveal), 5)
		draw_line(Vector2(crane_x, 490), Vector2(crane_x + 92, 490), Color("26383b", reveal), 4)
		draw_line(Vector2(crane_x + 72, 490), Vector2(crane_x + 72, 535), Color(GOLD, reveal * 0.55), 2)
	for smoke_index in range(4):
		var smoke = Vector2(620 + smoke_index * 170, 454 - smoke_index % 2 * 32)
		draw_circle(smoke, 22 + smoke_index * 3, Color("6c7772", reveal * 0.12))
		draw_circle(smoke + Vector2(12, -24), 17, Color("89908a", reveal * 0.09))

func draw_bodhi_tree(transition: float):
	var trunk = PackedVector2Array([Vector2(837, 605), Vector2(858, 196), Vector2(908, 152), Vector2(942, 604)])
	draw_colored_polygon(trunk, Color("3f382c"))
	for branch in [[Vector2(880, 300), Vector2(738, 210)], [Vector2(900, 270), Vector2(1040, 192)], [Vector2(888, 225), Vector2(890, 98)]]:
		draw_line(branch[0], branch[1], Color("504332"), 18, true)
	for index in range(26):
		var angle = index * TAU / 26.0
		var radius = 78 + (index * 29) % 130
		var leaf = Vector2(890, 155) + Vector2(cos(angle) * radius * 1.7, sin(angle) * radius * 0.58)
		var sway = 0.0 if reduced_fx else sin(visual_now_ms() * 0.0007 + index) * 3.0
		draw_colored_polygon(PackedVector2Array([leaf + Vector2(0, -8 + sway), leaf + Vector2(7, sway), leaf + Vector2(0, 9 + sway), leaf + Vector2(-7, sway)]), Color("526b55").lightened(0.12 if index % 5 == 0 else 0.0))
	if transition > 0.2: draw_arc(Vector2(890, 310), 155, -PI * 0.9, -PI * 0.1, 48, Color(GOLD, 0.08 + transition * 0.12), 10, true)

func draw_title_saint(center: Vector2, transition: float):
	var lift = -4.0 * smoothstep(0.08, 0.28, transition)
	var p = center + Vector2(0, lift)
	draw_circle(p + Vector2(0, 83), 98, Color(0.02, 0.04, 0.04, 0.35))
	draw_arc(p + Vector2(0, 70), 92, PI, TAU, 40, Color("7f6b4b"), 10)
	draw_rect(Rect2(p + Vector2(-34, -34), Vector2(68, 95)), Color("7b6547"))
	draw_rect(Rect2(p + Vector2(-27, -28), Vector2(54, 38)), Color("4e7568"))
	for bolt in [Vector2(-26, -25), Vector2(26, -25), Vector2(-26, 51), Vector2(26, 51)]: draw_circle(p + bolt, 3, PAPER)
	var shoulder_points = [Vector2(-28, -18), Vector2(28, -18), Vector2(-31, 7), Vector2(31, 7), Vector2(-26, 32), Vector2(26, 32)]
	var hand_points = [Vector2(-135, -76), Vector2(135, -76), Vector2(-128, 4), Vector2(128, 4), Vector2(-42, 76), Vector2(42, 76)]
	for index in range(6):
		var hand = p + hand_points[index]
		var elbow = p + shoulder_points[index].lerp(hand_points[index], 0.48) + Vector2(0, -12 if index < 4 else 10)
		draw_line(p + shoulder_points[index], elbow, Color("8f7049"), 12, true)
		draw_line(elbow, hand, Color("b08a58"), 10, true)
		draw_circle(hand, 7, Color("d0aa6a"))
	draw_inspection_lamp(p + hand_points[0], transition)
	draw_spanner(p + hand_points[1], transition)
	draw_welder(p + hand_points[2], transition)
	draw_cable_clamp(p + hand_points[3], transition)
	for lap_hand in [p + hand_points[4], p + hand_points[5]]: draw_arc(lap_hand, 12, PI, TAU, 14, Color("d0aa6a"), 5, true)
	draw_rect(Rect2(p + Vector2(-26, -67), Vector2(52, 38)), Color("826c4d"))
	draw_rect(Rect2(p + Vector2(-18, -56), Vector2(36, 12)), Color("18272a"))
	var eye_open = smoothstep(0.08, 0.24, transition)
	for side in [-1, 1]:
		var eye = p + Vector2(side * 10, -50)
		draw_line(eye + Vector2(-5, 0), eye + Vector2(5, 0), Color("2a312e"), 3)
		if eye_open > 0: draw_circle(eye, 3 + eye_open * 2, Color(0.93, 0.82, 0.52, eye_open))

func draw_inspection_lamp(hand: Vector2, transition: float):
	draw_line(hand, hand + Vector2(-34, -22), Color("c19a57"), 8, true)
	draw_circle(hand + Vector2(-40, -26), 12, Color("8edce0" if transition > 0.2 else "6b725f"))
	if transition > 0.22: draw_line(hand + Vector2(-46, -28), hand + Vector2(-115, -42), Color(0.55, 0.86, 0.88, 0.3), 3, true)

func draw_spanner(hand: Vector2, transition: float):
	var angle = -0.55 + smoothstep(0.18, 0.38, transition) * 0.28
	var end = hand + Vector2.from_angle(angle) * 52
	draw_line(hand, end, Color("c7b28c"), 10, true)
	draw_arc(end, 14, angle + 1.9, angle + 4.4, 16, Color("c7b28c"), 7, true)

func draw_welder(hand: Vector2, transition: float):
	draw_line(hand, hand + Vector2(-38, 18), Color("e4d6b5"), 10, true)
	var tip = hand + Vector2(-46, 23)
	draw_line(hand + Vector2(-38, 18), tip, Color("806249"), 4, true)
	if transition > 0.26:
		draw_circle(tip, 5, PAPER)
		if not reduced_fx:
			for index in range(3): draw_line(tip, tip + Vector2.from_angle(index * 1.4) * 16, Color(GOLD, 0.8), 2, true)

func draw_cable_clamp(hand: Vector2, transition: float):
	var jaw = 9.0 - smoothstep(0.22, 0.42, transition) * 5.0
	draw_circle(hand + Vector2(28, 12), 13, Color("426c78"))
	draw_line(hand, hand + Vector2(23, 8), Color("557d86"), 7, true)
	for side in [-1, 1]: draw_line(hand + Vector2(23, 8), hand + Vector2(40, 8 + side * jaw), Color("9bcad4"), 5, true)
	if transition > 0.35: draw_line(hand + Vector2(28, 12), hand + Vector2(78, 24), Color("81b8d0"), 3, true)

func draw_title_clouds(transition: float):
	var move = smoothstep(0.26, 0.78, transition)
	var drift = 0.0 if reduced_fx else sin(visual_now_ms() * 0.0004) * 8.0
	for side in [-1, 1]:
		var center = Vector2(640 + side * (320 + move * 270) + drift * side, 590)
		for index in range(8):
			var cloud = center + Vector2((index - 3.5) * 55, sin(index * 1.7) * 24)
			draw_circle(cloud, 72 + index % 3 * 16, Color(0.84, 0.86, 0.80, 0.92 - move * 0.28))

func draw_menu():
	for x in range(0, 1280, 48): draw_line(Vector2(x, 0), Vector2(x, 745), Color("15252a"))
	for y in range(0, 745, 48): draw_line(Vector2(0, y), Vector2(1280, y), Color("15252a"))
	text_at("ASSEMBLE THE SAINT", Vector2(56, 70), 13, GOLD)
	text_at("Choose a frame and a Blessing.", Vector2(52, 116), 34, PAPER, true)
	text_at("Frames change movement and recovery. Blessings shape the workshop, never the only viable route.", Vector2(56, 151), 14, MUTED)
	for i in range(frame_defs.size()):
		var frame = frame_defs[i]
		var x = 250 + i * 270
		var unlocked = frame.id in profile.state.unlocked_frames
		panel(Rect2(x, 188, 240, 92), Color("223733") if chosen_frame == frame.id and unlocked else PANEL)
		text_at(frame.name.to_upper(), Vector2(x + 12, 211), 11, GOLD if unlocked else MUTED)
		text_at("%d structure · %d speed" % [frame.structure, frame.speed], Vector2(x + 12, 234), 11, PAPER if unlocked else MUTED)
		wrapped(frame.tradeoff if unlocked else "WHY LOCKED / " + ("Restore a machine." if frame.id == "frame.surveyor" else "Defeat the Foreman."), Vector2(x + 12, 256), 215, 10, MUTED)
	var titles = ["The Workshop Gospel", "The Bell Ward", "The Mourner", "The Procession"]
	var lines = [["REPAIR · RELIABILITY", "Nailer guarantee.", "Faster restoration."], ["CONTROL · ANTICIPATION", "Bell guarantee.", "Earlier warnings."], ["REMNANTS · RECOVERY", "Candle guarantee.", "Defeats leave motes."], ["ORBIT · ESCORT", "Gear guarantee.", "Wider formations."]]
	for i in range(4):
		var x = 56 + i * 292
		var unlocked = sim.config.blessings[i] in profile.state.unlocked_blessings
		panel(Rect2(x, 342, 276, 206), Color("223733") if chosen == i and unlocked else PANEL)
		text_at("0%d / BLESSING" % (i + 1), Vector2(x + 14, 367), 11, GOLD if unlocked else MUTED)
		text_at(titles[i], Vector2(x + 14, 402), 19, PAPER if unlocked else MUTED, true)
		for j in range(3): text_at(lines[i][j], Vector2(x + 14, 433 + j * 22), 12, MUTED if j > 0 else GREEN)
		if not unlocked: text_at("COMPLETE A DESTINATION", Vector2(x + 14, 520), 10, GOLD)

func draw_tutorial():
	MenuPanels.draw_manual(self)

func draw_settings():
	MenuPanels.draw_settings(self)

func draw_header():
	text_at("SCRAP SAINT", Vector2(28, 42), 25, PAPER, true)
	var site_name = sim.arena.data.name.to_upper()
	text_at(site_name + " / " + ["WORKSHOP GOSPEL", "BELL WARD", "THE MOURNER", "THE PROCESSION"][sim.state.doctrine], Vector2(28, 68), 12, GOLD)
	text_at("STRUCTURE", Vector2(352, 31), 11, MUTED)
	bar(Rect2(352, 43, 175, 8), sim.state.hp / sim.saint_max_structure(), GREEN if sim.state.hp > 30 else RED)
	text_at("%d / %d" % [maxi(0, sim.state.hp), sim.saint_max_structure()], Vector2(352, 72), 13)
	if sim.is_destination():
		var complete = sim.state.objective.filter(func(node): return node.complete).size()
		text_at("OPTIONAL SITE WORK", Vector2(568, 31), 11, MUTED)
		bar(Rect2(568, 43, 175, 8), complete / float(maxi(1, sim.state.objective.size())), GREEN)
		text_at("%d / %d stations complete" % [complete, sim.state.objective.size()], Vector2(568, 72), 12)
	elif sim.optional_mode():
		var count = sim.state.machines.filter(func(m): return m.complete).size()
		text_at("OPTIONAL REPAIRS", Vector2(568, 31), 11, MUTED)
		bar(Rect2(568, 43, 175, 8), count / 3.0, GREEN)
		text_at("%d / 3 machines restored" % count, Vector2(568, 72), 12)
	else:
		text_at("RELAY", Vector2(568, 31), 11, MUTED)
		bar(Rect2(568, 43, 175, 8), sim.state.relay_hp / sim.config.relay.structure, RED if sim.state.relay_hp < sim.config.relay.structure * sim.config.relay.critical_fraction else GOLD)
		text_at("%d%% integrity · %d%% work" % [sim.state.relay_hp * 100 / sim.config.relay.structure, sim.state.progress * 100 / sim.config.relay.required_ticks], Vector2(568, 72), 13)
	arena_art.draw_icon(self, "scrap", Vector2(782,36), 20)
	arena_art.draw_icon(self, "relic_shard", Vector2(782,65), 16)
	text_at("%02d  SCRAP" % sim.state.scrap, Vector2(800, 43), 19, GOLD)
	text_at("%d  RELIC SHARDS" % sim.state.shards, Vector2(800, 69), 12, MUTED)
	var stage_label = "WAVE %02d / %02d" % [sim.state.wave, sim.current_wave_count()]
	if sim.state.phase == "route": stage_label = "ROUTE MAP"
	elif sim.state.phase == "travel": stage_label = "ROAD %02d / %02d" % [sim.state.travel_step + 1, sim.road_nodes_for(sim.current_route()).size()]
	text_at(stage_label, Vector2(1070, 43), 18)
	text_at("%02d:%02d" % [int(sim.state.tick / 3600), int(sim.state.tick / 60) % 60], Vector2(1070, 70), 14, MUTED)
	draw_line(Vector2(28, 89), Vector2(1252, 89), Color("3a4d48"))
	var instruction = "Stay in the work circle to repair. Weapons fire automatically."
	if sim.state.progress >= sim.config.relay.required_ticks: instruction = "RELAY ONLINE · Keep it standing. Finish the shift."
	if sim.state.wave == 8: instruction = "FOREMAN ENGINE · Watch the demolition circles. Protect the relay."
	if sim.state.phase == "shop": instruction = "A moment to rebuild. Choose what your machine becomes."
	if sim.optional_mode(): instruction = "Survive the shift. Defeat the Foreman. Repairs are optional rewards."
	if sim.state.phase == "combat" and sim.optional_mode(): instruction = sim.wave_profile().pressure
	if sim.state.wave == 8 and not sim.is_destination(): instruction = "FOREMAN / Keep moving. Avoid the demolition zones."
	if sim.is_destination(): instruction = sim.objective_data().description
	if sim.state.phase == "route": instruction = "Preview a grey assignment, then accept it. Gold marks your selection."
	if sim.state.phase == "travel": instruction = "Resolve this in-between area. No road node can be bypassed."
	if sim.state.phase == "arrival": instruction = "Read the site pressure. Combat waits for your signal."
	if sim.state.phase == "site_clear": instruction = "The site is clear. Review what the pilgrimage carries forward."
	if sim.state.phase in ["won", "lost"]: instruction = "SHIFT RECORDED / Read the cause. Choose one change. Return quickly."
	text_at(instruction, Vector2(60, 126), 16, GREEN)
	if sim.state.phase == "combat" and not sim.optional_mode():
		text_at("STARTUP BACKUP · Relay cannot break before the first workshop" if sim.state.wave == 1 else "BACKUP OFFLINE · Break enemy strike warnings to protect the relay", Vector2(60, 146), 11, GOLD if sim.state.wave == 1 else MUTED)

func draw_workshop_layout():
	arena_art.draw_layout(self, sim.arena, debug_visible)
	draw_workshop_atmosphere(sim.arena.bounds)

func draw_workshop_atmosphere(bounds: Rect2):
	# Quiet perimeter services stay away from the active combat field.
	for y in [bounds.position.y + 12, bounds.end.y - 12]:
		draw_line(Vector2(bounds.position.x+12,y), Vector2(bounds.end.x-12,y), Color("39453f"), 3)
		for x in range(int(bounds.position.x)+48, int(bounds.end.x)-24, 190):
			var lamp = Vector2(x,y)
			draw_circle(lamp,9,Color(0.7,0.5,0.22,0.055))
			draw_rect(Rect2(lamp-Vector2(4,2),Vector2(8,4)),Color("a08d62"))

func draw_world():
	var a = sim.config.arena
	panel(Rect2(a[0], a[1], a[2], a[3]), Color("1d3033"))
	draw_workshop_layout()
	var relay = sim.relay_position()
	if sim.is_destination(): draw_destination_objective()
	elif sim.optional_mode(): draw_optional_machines()
	else:
		var working = sim.state.position.distance_to(relay) < sim.config.relay.radius
		var threatened = sim.relay_threat_count()
		var critical = sim.state.relay_hp < sim.config.relay.structure * sim.config.relay.critical_fraction
		bar(Rect2(relay + Vector2(-40, 64), Vector2(80, 5)), sim.state.relay_hp / sim.config.relay.structure, RED if critical else GOLD)
		if threatened > 0:
			text_at("%d STRIKING · INTERRUPT" % threatened, relay + Vector2(-72, -72), 11, RED)
		elif critical:
			text_at("CRITICAL · RETURN TO REPAIR", relay + Vector2(-85, -72), 11, RED)
		if sim.state.tick - sim.state.relay_last_hit < 30:
			draw_arc(relay, 43, 0, TAU, 32, RED, 4)
		draw_circle(relay, sim.config.relay.radius, Color(0.45, 0.8, 0.64, 0.055 if working else 0.025))
		draw_arc(relay, sim.config.relay.radius, 0, TAU, 64, Color("54796b"), 1.5, true)
		draw_arc(relay, sim.config.relay.radius, -PI / 2, -PI / 2 + maxf(0.001, TAU * sim.state.progress / sim.config.relay.required_ticks), 64, GREEN, 4, true)
		for i in range(4):
			var to = relay + Vector2.from_angle(i * PI / 2) * 76
			draw_line(relay, to, Color("38544c"), 5)
			draw_circle(to, 5, GOLD)
		draw_circle(relay + Vector2(0, 10), 38, Color("132226"))
		panel(Rect2(relay - Vector2(27, 29), Vector2(54, 54)), Color("687d6b"))
		draw_rect(Rect2(relay - Vector2(16, 20), Vector2(32, 35)), Color("263f3b"))
		for i in range(3): draw_line(relay + Vector2(-10, -12 + i * 9), relay + Vector2(10, -12 + i * 9), GREEN if working else GOLD, 3)
		text_at("RELAY 07", relay + Vector2(-33, 49), 12, MUTED)
		if working:
			draw_line(sim.state.position, relay, Color(0.65, 0.95, 0.78, 0.5), 1.5, true)
			text_at("REPAIRING" if sim.state.progress < sim.config.relay.required_ticks else "MAINTAINING", relay + Vector2(-39, -47), 12, GREEN)
	for h in sim.state.hazards:
		var f = 1.0 - float(h.until - sim.state.tick) / h.get("warning_ticks", sim.config.boss_rules.hazard_warning_ticks * sim.warning_multiplier())
		if h.copy:
			var copy_shape = str(h.get("copy_shape", "rail"))
			var copy_range = float(h.get("copy_range", h.radius))
			var copy_width = float(h.get("copy_width", h.radius))
			var direction = (h.p - h.from).normalized()
			if direction == Vector2.ZERO: direction = Vector2.RIGHT
			if copy_shape == "radial":
				draw_circle(h.from, copy_range, Color(0.9, 0.4, 0.3, 0.08 + f * 0.12))
				draw_arc(h.from, copy_range, 0, TAU, 56, RED, 3)
			elif copy_shape in ["rail", "sermon", "long_hand"]:
				draw_line(h.from, h.from + direction * copy_range, Color(0.9, 0.4, 0.3, 0.15 + f * 0.3), maxf(8, copy_width * 2))
				draw_line(h.from, h.from + direction * copy_range, RED, 2, true)
			elif copy_shape == "repair_halo":
				for contact in [h.from + direction * copy_range, h.from - direction * copy_range]:
					draw_circle(contact, copy_width, Color(0.9, 0.4, 0.3, 0.08 + f * 0.12))
					draw_arc(contact, copy_width, 0, TAU, 36, RED, 2)
			elif copy_shape == "funeral_shots":
				for target in h.get("copy_points", []):
					draw_line(h.from, target, Color(0.9, 0.4, 0.3, 0.15 + f * 0.3), maxf(5, copy_width))
					draw_circle(target, maxf(8, copy_width), Color(0.9, 0.4, 0.3, 0.12))
			elif copy_shape == "parade":
				draw_arc(h.from, copy_range, 0, TAU, 56, Color(RED, 0.45 + f * 0.4), 3)
				draw_arc(h.from, float(h.get("copy_inner_range", copy_range * 0.58)), 0, TAU, 44, Color(PAPER, 0.25 + f * 0.35), 2)
			elif copy_shape == "lattice":
				var points = h.get("copy_points", [])
				if points.size() == 3:
					for index in range(3): draw_line(points[index], points[(index + 1) % 3], Color(0.9, 0.4, 0.3, 0.28 + f * 0.35), maxf(3, copy_width), true)
			else:
				var zone_radius = copy_width if copy_shape == "benediction" else copy_range
				draw_circle(h.p, zone_radius, Color(0.9, 0.4, 0.3, 0.08 + f * 0.12))
				draw_arc(h.p, zone_radius, 0, TAU, 48, RED, 3)
			text_at("COPIED " + copy_shape.replace("_", " ").to_upper(), h.from + Vector2(-52, -48), 11, RED)
			continue
		draw_circle(h.p, h.radius, Color(0.85, 0.3, 0.18, 0.13 + f * 0.1))
		draw_arc(h.p, h.radius, 0, TAU, 40, RED, 2)
		draw_arc(h.p, h.radius * f, 0, TAU, 40, GOLD, 2)
		if h.get("source", "") == "boss.factory_heart": draw_line(h.from, h.p, Color(0.89, 0.36, 0.24, 0.45), 3, true)
		var hazard_labels = {"measure": "BEAT", "toll": "TOLL", "answer": "III", "pulse": "PULSE", "feed": "FEED", "choice": "CHOOSE", "index": "INDEX", "duplicate": "COPY", "redact": "REDACT", "kindling": "HEAT", "overheat": "VENT", "quota": "QUOTA", "inventory": "LIST", "reject": "REJECT", "blank": "NULL"}
		var hazard_label = hazard_labels.get(h.get("kind", ""), "!")
		text_at(hazard_label, h.p + Vector2(-font.get_string_size(hazard_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x * 0.5, 5), 10, GOLD)
	for p in sim.state.pickups:
		if p.kind in ["repair_kit", "scrap"]:
			arena_art.draw_pickup(self, p)
		else:
			# Healing motes keep their distinct spectral identity; they are not Shards.
			draw_circle(p.p, 5, Color("cbb8ed"))
			draw_arc(p.p, 9, 0, TAU, 16, Color("84759e"), 1)
	for e in sim.state.enemies: draw_enemy(e)
	for w in sim.state.weapons:
		if w.id == "weapon.procession_gear":
			var gear_data = sim.resolved_weapon_rule(w)
			var parade = sim.weapon_evolution_id(w) == "evolution.maintenance_parade"
			var inner_range = float(gear_data.get("inner_range", gear_data.range))
			var outer_range = float(gear_data.get("extended_range", 176) if parade and int(sim.state.get("parade_until", 0)) > sim.state.tick else gear_data.range)
			var inner_angle = sim.state.tick * float(gear_data.get("inner_speed", 0.045))
			var p = sim.state.position + Vector2.from_angle(inner_angle) * inner_range
			draw_arc(sim.state.position, inner_range, 0, TAU, 48, Color(0.5, 0.75, 0.65, 0.12), 1)
			draw_gear(p, 15, GREEN, sim.state.tick * 0.08)
			if parade:
				var outer_angle = sim.state.tick * float(gear_data.outer_speed) + PI / 3.0
				var outer = sim.state.position + Vector2.from_angle(outer_angle) * outer_range
				draw_arc(sim.state.position, outer_range, 0, TAU, 64, Color(0.86, 0.73, 0.42, 0.17), 2)
				draw_gear(sim.state.position - Vector2.from_angle(inner_angle) * inner_range, 12, PAPER, -sim.state.tick * 0.07)
				draw_gear(outer, 13, GOLD, -sim.state.tick * 0.06)
				draw_gear(sim.state.position - Vector2.from_angle(outer_angle) * outer_range, 13, GOLD, sim.state.tick * 0.06)
			elif int(gear_data.get("orbit_contacts", 1)) > 1:
				draw_gear(sim.state.position - (p - sim.state.position), 15, GREEN, sim.state.tick * 0.08 + PI)
		if w.id == "weapon.foundry_censer":
			var ashen = sim.weapon_evolution_id(w) == "evolution.ashen_benediction"
			var censer_data = sim.resolved_weapon_rule(w)
			var ring_origin = sim.state.position + (Vector2.from_angle(sim.state.tick * 0.018) * 34 if ashen else Vector2.ZERO)
			var ring_range = 52.0 if ashen else float(censer_data.range)
			var p = ring_origin + Vector2.from_angle(sim.state.tick * 0.055) * 62
			draw_circle(ring_origin, ring_range, Color(0.25, 0.62, 0.55, 0.06))
			draw_arc(ring_origin, ring_range, 0, TAU, 56, Color("b58ebd") if ashen else Color(0.32, 0.72, 0.63, 0.22), 2)
			draw_line(sim.state.position, p, Color("6b5944"), 2)
			draw_circle(p, 8, Color("273b38"))
			draw_circle(p, 3, GOLD)
		if w.id == "weapon.welded_halo":
			var angle = sim.state.tick * 0.045
			draw_arc(sim.state.position, 31, angle, angle + TAU * 0.82, 36, Color("9ac99d"), 3)
			draw_circle(sim.state.position + Vector2.from_angle(angle) * 31, 4, PAPER)
			if sim.weapon_evolution_id(w) == "evolution.halo_of_repairs":
				draw_arc(sim.state.position, 40, -angle, -angle + TAU * 0.82, 36, Color("d6edbf"), 2)
				draw_circle(sim.state.position - Vector2.from_angle(angle) * 40, 4, PAPER)
		if w.id == "weapon.cable_contrition" and sim.weapon_evolution_id(w) == "evolution.contrition_lattice":
			var angle = sim.state.tick * 0.012
			var points = [sim.state.position + Vector2.from_angle(angle) * 58, sim.state.position + Vector2.from_angle(angle + TAU / 3.0) * 58, sim.state.position + Vector2.from_angle(angle + TAU * 2.0 / 3.0) * 58]
			for index in range(3): draw_line(points[index], points[(index + 1) % 3], Color(0.5, 0.72, 0.82, 0.28), 2, true)
	draw_saint(sim.state.position, sim.state.facing)
	draw_set_transform(camera_offset)
	for e in fx: draw_effect(e)

func draw_boss_hud():
	for e in sim.state.enemies:
		if e.major:
			panel(Rect2(293, 167, 490, 46), Color("152428"))
			var boss_names = {"boss.foreman_engine": "FOREMAN ENGINE", "boss.choir_regent": "CHOIR REGENT", "boss.factory_heart": "FACTORY HEART", "boss.archivist_prime": "ARCHIVIST PRIME", "boss.red_cardinal": "RED CARDINAL", "boss.null_auditor": "NULL AUDITOR", "elite.memory_crane": "MEMORY CRANE"}
			text_at(boss_names.get(e.type, str(e.type).trim_prefix("boss.").replace("_", " ").to_upper()), Vector2(309, 186), 12, GOLD)
			if e.type == sim.current_boss_id():
				var phase_name = ["SCHEDULE","WORKER CALL","FINAL ORDERS"][clampi(int(e.get("phase",0)),0,2)] if not sim.is_destination() else sim.boss_phase_name(e)
				text_at(phase_name, Vector2(582, 186), 11, RED)
			bar(Rect2(309, 196, 458, 6), e.hp / e.max_hp, RED)
			if e.get("inspected", false): text_at("INSPECTED / " + sim.state.inspection, Vector2(309, 218), 10, Color("8edce0"))

func draw_minimap():
	var r = Rect2(76, 610, 150, 105)
	panel(r, Color("102226"))
	var factor = r.size / sim.arena.bounds.size
	for obstacle in sim.arena.obstacles:
		draw_rect(Rect2(r.position + (obstacle.position - sim.arena.bounds.position) * factor, obstacle.size * factor), MUTED)
	if sim.is_destination():
		var objective = sim.objective_data()
		for i in range(sim.state.objective.size()):
			var node_data = objective.nodes[i]
			var p = Vector2(node_data.position[0], node_data.position[1])
			draw_circle(r.position + (p - sim.arena.bounds.position) * factor, 3, GREEN if sim.state.objective[i].complete else GOLD)
	else:
		for i in range(sim.state.machines.size()):
			var data = sim.config.optional_repairs.machines[i]
			var p = Vector2(data.position[0], data.position[1])
			draw_circle(r.position + (p - sim.arena.bounds.position) * factor, 3, GREEN if sim.state.machines[i].complete else GOLD)
	draw_circle(r.position + (sim.state.position - sim.arena.bounds.position) * factor, 3, PAPER)
	var visible = Rect2(WORLD_VIEW.position - camera_offset, WORLD_VIEW.size)
	draw_rect(Rect2(r.position + (visible.position - sim.arena.bounds.position) * factor, visible.size * factor), GREEN, false, 1)
	text_at(sim.arena.data.name.to_upper(), r.position + Vector2(0, -7), 10, MUTED)

func draw_destination_objective():
	var objective = sim.objective_data()
	if objective.is_empty(): return
	for i in range(sim.state.objective.size()):
		var node = sim.state.objective[i]
		var data = objective.nodes[i]
		var p = Vector2(data.position[0], data.position[1])
		var locked = sim.state.tick < int(sim.state.get("objective_lock_until", 0))
		var active_index = sim.active_destination_node_index()
		var waiting = objective.type in ["RECOVER_SEQUENCE", "VENT_ROTATION"] and i != active_index and not node.complete
		var color = GREEN if node.complete else (RED if locked else (MUTED if waiting else GOLD))
		draw_circle(p, 29, Color("1c3432"))
		draw_arc(p, float(objective.radius), 0, TAU, 48, Color(color, 0.38), 2)
		draw_arc(p, 38, -PI / 2, -PI / 2 + TAU * maxf(0.001, node.progress / float(objective.required_ticks)), 32, color, 4)
		draw_gear(p, 18, color, sim.state.tick * 0.018 if node.complete else 0)
		panel(Rect2(p + Vector2(-82, -74), Vector2(164, 22)), PANEL)
		text_at(data.name, p + Vector2(-72, -57), 11, color)
		if objective.type == "CALIBRATE_NODES" and not node.complete:
			var unsafe = sim.state.enemies.any(func(enemy): return enemy.hp > 0 and enemy.p.distance_to(p) < float(objective.safety_radius))
			if unsafe: text_at("CLEAR THE RING", p + Vector2(-49, 70), 10, RED)
		elif locked and not node.complete:
			text_at("PULSE LOCK · MOVE", p + Vector2(-58, 70), 10, RED)
		elif objective.type == "VENT_ROTATION" and not node.complete:
			text_at("ACTIVE VENT" if i == active_index else "STANDBY", p + Vector2(-43, 70), 10, GOLD if i == active_index else MUTED)
		elif objective.type == "RECOVER_SEQUENCE" and waiting:
			text_at("AWAIT PRIOR RECORD", p + Vector2(-58, 70), 10, MUTED)
		elif objective.type == "QUIET_REPAIR" and not node.complete and sim.state.position.distance_to(p) < float(objective.radius):
			text_at("RELICS QUIET · WORKING", p + Vector2(-68, 70), 10, RED)

func draw_travel_background():
	for y in range(160, 736, 54):
		draw_line(Vector2(60, y), Vector2(1040, y), Color("1f3335"), 2)
	for i in range(9):
		var x = 105 + i * 116
		draw_line(Vector2(x, 736), Vector2(505 + (x - 505) * 0.22, 158), Color("304344"), 2)
	var route = sim.current_route()
	var route_colors = {"route.brass_choir": GOLD, "route.rootworks": GREEN, "route.pale_archive": Color("cbb8ed"), "route.red_foundry": RED, "route.null_assembly": Color("8edce0")}
	var accent = route_colors.get(sim.state.route, GREEN)
	for i in range(6):
		var p = Vector2(145 + i * 165, 570 - (i % 2) * 70)
		draw_circle(p, 15 + i * 2, Color(accent, 0.16))
		draw_arc(p, 18 + i * 2, 0, TAU, 20, accent, 2)

func draw_route_choice():
	draw_pilgrimage_map(false)

func map_site_data(site_id: String) -> Dictionary:
	for site in sim.chapter.expedition_map.sites:
		if str(site.id) == site_id: return site
	return {}

func map_route_for_site(site_id: String) -> Dictionary:
	for route in sim.chapter.routes:
		if str(route.site_id) == site_id: return route
	return {}

func map_site_tier(site_id: String) -> int:
	return int(map_site_data(site_id).get("tier", 0))

func map_route_names(route_ids: Array) -> String:
	var names: Array[String] = []
	for route_id in route_ids:
		if sim.routes.has(str(route_id)): names.append(str(sim.routes[str(route_id)].name))
	return " / ".join(names)

func pilgrimage_site_preview(site_id: String, departure: bool) -> Dictionary:
	var site = map_site_data(site_id)
	var origin_id = str(sim.chapter.expedition_map.origin_site_id)
	if site_id == origin_id:
		var origin = sim.chapter.expedition_map.origin_preview
		return {
			"name": str(site.get("name", "Collapsed Workshop")), "experience": str(origin.experience),
			"threat": str(origin.threat_preview), "optional": str(origin.optional_preview),
			"boss": str(sim.bosses[str(origin.boss)].name), "waves": int(origin.wave_count),
			"wave_ticks": int(origin.wave_ticks), "cost": 0, "arrival_floor": 1.0,
			"road": "DEPARTURE  →  COLLAPSED WORKSHOP",
			"next": map_route_names(["route.brass_choir", "route.rootworks"]), "terminal": false,
		}
	var route = map_route_for_site(site_id)
	if route.is_empty(): return {"name": str(site.get("name", site_id)), "experience": "No pilgrimage record is available."}
	var road_names: Array[String] = []
	for node in route.get("road_nodes", []): road_names.append(str(node.name).to_upper())
	road_names.append(str(site.name).to_upper())
	return {
		"name": str(route.name), "experience": str(route.description),
		"threat": str(route.get("threat_preview", route.risk)), "optional": str(route.get("optional_preview", route.objective.description)),
		"boss": str(sim.bosses[str(route.boss)].name), "waves": int(route.wave_count),
		"wave_ticks": int(route.wave_ticks), "cost": int(route.cost), "arrival_floor": float(route.arrival_repair_floor),
		"road": "  →  ".join(road_names), "next": "ENDS THE CHAPTER" if route.terminal else map_route_names(route.next_routes),
		"terminal": bool(route.terminal), "route_id": str(route.id), "departure": departure,
	}

func pilgrimage_duration_text(preview: Dictionary) -> String:
	var seconds = int(preview.get("waves", 0)) * int(preview.get("wave_ticks", 0)) / maxi(1, int(sim.config.tick_rate))
	return "~%dM %02dS COMBAT" % [int(seconds / 60), seconds % 60]

func map_site_state(site_id: String, departure: bool) -> String:
	var origin_id = str(sim.chapter.expedition_map.origin_site_id)
	if departure: return "current" if site_id == origin_id else "future"
	if site_id == str(sim.state.site_id): return "current"
	if site_id in sim.state.get("completed_site_ids", []): return "cleared"
	for route in sim.available_routes():
		if str(route.site_id) == site_id: return "reachable_final" if bool(route.terminal) else "reachable"
	var current_tier = map_site_tier(str(sim.state.site_id))
	return "future" if map_site_tier(site_id) > current_tier + 1 else "not_taken"

func map_site_state_label(state_name: String) -> String:
	return {"current":"● CURRENT", "cleared":"✓ CLEARED", "reachable":"◆ REACHABLE", "reachable_final":"◆ FINAL / REACHABLE", "future":"○ FUTURE CONNECTION", "not_taken":"× NOT THIS RUN"}.get(state_name, state_name.to_upper())

func map_state_color(state_name: String) -> Color:
	if state_name == "current": return GOLD
	if state_name == "cleared": return GREEN
	if state_name in ["reachable", "reachable_final"]: return Color("9fd7cb")
	if state_name == "not_taken": return Color(MUTED, 0.34)
	return Color(MUTED, 0.58)

func draw_map_site_state(site: Dictionary, departure: bool):
	var p = map_site_position(site)
	var state_name = map_site_state(str(site.id), departure)
	var color = map_state_color(state_name)
	var outline = Rect2(p - Vector2(82, 23), Vector2(164, 46))
	if state_name == "current":
		draw_arc(p, 91, -0.36, 0.36, 16, color, 3, true)
	elif state_name == "cleared":
		draw_rect(outline.grow(3), color, false, 3)
	elif state_name in ["reachable", "reachable_final"]:
		var points = PackedVector2Array([Vector2(p.x, p.y - 30), Vector2(p.x + 88, p.y), Vector2(p.x, p.y + 30), Vector2(p.x - 88, p.y), Vector2(p.x, p.y - 30)])
		draw_polyline(points, color, 2, true)
	elif state_name == "not_taken":
		draw_line(outline.position, outline.end, color, 2)
		draw_line(Vector2(outline.end.x, outline.position.y), Vector2(outline.position.x, outline.end.y), color, 2)
	else:
		for dash in range(4):
			draw_line(Vector2(outline.position.x + dash * 42, outline.position.y), Vector2(outline.position.x + dash * 42 + 22, outline.position.y), color, 2)
	text_at(map_site_state_label(state_name), p + Vector2(-72, 40), 8, color)

func map_build_summary(departure: bool) -> String:
	if departure:
		var frame_name = chosen_frame
		for frame in frame_defs:
			if str(frame.id) == chosen_frame: frame_name = str(frame.name)
		var blessing_names = ["Workshop Gospel", "Bell Ward", "Mourner's Due", "Procession"]
		return "%s  ·  %s  ·  relics, Gifts, Scrap and Structure carry through all three levels" % [frame_name, blessing_names[chosen]]
	var relics: Array[String] = []
	for weapon in sim.state.get("weapons", []): relics.append(str(sim.config.weapons[weapon.id].short))
	return "%s  ·  %d Scrap  ·  %d/%d Structure  ·  build carries forward" % [", ".join(relics), int(sim.state.scrap), int(sim.state.hp), int(sim.saint_max_structure())]

func draw_pilgrimage_map(departure: bool):
	draw_rect(Rect2(0, 0, 1280, 800), Color("0d1c20"))
	text_at("THE FIRST PILGRIMAGE", Vector2(44, 55), 14, GOLD)
	text_at("Three levels. One carried build.", Vector2(40, 96), 31, PAPER, true)
	var level_label = "BEFORE DEPARTURE · LEVEL 1 / 3"
	if not departure:
		level_label = "FINAL DESTINATION" if map_site_tier(str(sim.state.site_id)) >= 1 else "CHOOSE LEVEL 2 / 3"
	text_at(level_label, Vector2(850, 56), 12, GREEN)
	panel(Rect2(34, 125, 780, 550), Color("13272b"))
	panel(Rect2(830, 125, 416, 550), Color("182e31"))
	var sites_by_id = {}
	for site in sim.chapter.expedition_map.sites: sites_by_id[str(site.id)] = site
	for edge in sim.chapter.expedition_map.edges:
		var from = map_site_position(sites_by_id[str(edge.from_site_id)])
		var to = map_site_position(sites_by_id[str(edge.to_site_id)])
		var emphasis = map_edge_emphasis(edge, departure)
		var edge_color = GREEN if emphasis == "accepted" else (GOLD if emphasis == "selected" else (Color("79b6aa") if emphasis == "reachable" else Color(MUTED, 0.25 if emphasis == "not_taken" else 0.44)))
		draw_line(from, to, edge_color, 4 if emphasis in ["accepted", "selected"] else 2)
		for step in range(1, 4): draw_circle(from.lerp(to, step / 4.0), 3, edge_color)
	for site in sim.chapter.expedition_map.sites: draw_map_site_state(site, departure)
	panel(Rect2(54, 620, 740, 40), Color("1a3033"))
	text_at("CARRIED BUILD", Vector2(70, 640), 9, GOLD)
	wrapped(map_build_summary(departure), Vector2(166, 641), 606, 10, PAPER)
	var selected_site_id = departure_selection if departure else map_inspection_site
	if selected_site_id == "": selected_site_id = str(sim.state.site_id)
	var preview = pilgrimage_site_preview(selected_site_id, departure)
	var state_name = map_site_state(selected_site_id, departure)
	var x = 852
	text_at(map_site_state_label(state_name), Vector2(x, 151), 9, map_state_color(state_name))
	text_at(str(preview.get("name", selected_site_id)), Vector2(x, 187), 25, PAPER, true)
	wrapped(str(preview.get("experience", "")), Vector2(x, 216), 368, 12, GREEN)
	text_at("THREAT / %s" % str(preview.get("boss", "UNKNOWN BOSS")).to_upper(), Vector2(x, 285), 9, RED)
	wrapped(str(preview.get("threat", "")), Vector2(x, 305), 368, 10, PAPER)
	text_at("OPTIONAL OPPORTUNITY", Vector2(x, 367), 9, GOLD)
	wrapped(str(preview.get("optional", "")), Vector2(x, 387), 368, 10, MUTED)
	text_at("%d WAVES  ·  %s" % [int(preview.get("waves", 0)), pilgrimage_duration_text(preview)], Vector2(x, 447), 10, PAPER)
	var current_scrap = int(sim.config.economy.starting_scrap) if departure else int(sim.state.scrap)
	var fare = int(preview.get("cost", 0))
	text_at("TRAVEL / %s  ·  YOU HAVE %d SCRAP" % ["NO FARE" if fare == 0 else "%d SCRAP" % fare, current_scrap], Vector2(x, 470), 10, GOLD)
	text_at("ARRIVAL / %s" % ("FULL STRUCTURE" if selected_site_id == str(sim.chapter.expedition_map.origin_site_id) else "AT LEAST %d%% STRUCTURE" % int(float(preview.get("arrival_floor", 0.0)) * 100.0)), Vector2(x, 493), 10, GREEN)
	text_at("ROAD", Vector2(x, 525), 9, GOLD)
	wrapped(str(preview.get("road", "")), Vector2(x, 545), 368, 9, PAPER)
	text_at("NEXT / " + str(preview.get("next", "" )).to_upper(), Vector2(x, 590), 9, GREEN if not bool(preview.get("terminal", false)) else GOLD)
	var reason = "Only the Workshop launches this expedition; inspect later sites now." if departure and selected_site_id != str(sim.chapter.expedition_map.origin_site_id) else "The Workshop begins the carried three-level expedition."
	if not departure:
		if map_selection == "": reason = "Not connected from the current route. Inspection does not commit travel."
		elif current_scrap < fare: reason = "Need %d more Scrap. Selection remains reversible." % (fare - current_scrap)
		else: reason = "Travel commits the fare once, then enters both authored road stops."
	wrapped(reason, Vector2(x, 625), 368, 10, RED if (map_selection == "" and not departure) or (not departure and current_scrap < fare) else MUTED)

func map_board_title() -> String:
	var current_site_id = str(sim.state.get("site_id", "site.collapsed_workshop"))
	for site in sim.chapter.get("expedition_map", {}).get("sites", []):
		if str(site.id) == current_site_id:
			return "PILGRIMAGE BOARD / " + str(site.name).to_upper()
	return "PILGRIMAGE BOARD / " + current_site_id.trim_prefix("site.").replace("_", " ").to_upper()

func map_edge_emphasis(edge: Dictionary, departure: bool = false) -> String:
	if departure: return "future"
	var route_id = str(edge.route_id)
	var edge_origin = str(edge.from_site_id)
	var current_origin = str(sim.state.get("site_id", "site.collapsed_workshop"))
	if sim.assignment_status(route_id) == "accepted":
		var accepted_origin = ""
		var history: Array = sim.state.get("route_history", [])
		var history_index = history.find(route_id)
		if history_index == 0: accepted_origin = str(sim.chapter.expedition_map.origin_site_id)
		elif history_index > 0 and sim.routes.has(str(history[history_index - 1])): accepted_origin = str(sim.routes[str(history[history_index - 1])].site_id)
		if accepted_origin == "": accepted_origin = str(sim.state.get("route_origin_site_id", ""))
		if accepted_origin == "": accepted_origin = current_origin
		if edge_origin == accepted_origin: return "accepted"
	if route_id == map_selection and edge_origin == current_origin: return "selected"
	if edge_origin == current_origin and sim.assignment_status(route_id) == "available": return "reachable"
	return "future" if map_site_tier(edge_origin) > map_site_tier(current_origin) else "not_taken"

func map_site_position(site: Dictionary) -> Vector2:
	return Vector2(100 + float(site.position[0]) * 690, 160 + float(site.position[1]) * 500)

func draw_travel():
	draw_rect(Rect2(60, 148, 980, 588), Color(0.03, 0.065, 0.07, 0.80))
	var route = sim.current_route()
	var node = sim.current_road_node()
	var nodes = sim.road_nodes_for(route)
	text_at("ACCEPTED / " + route.name.to_upper(), Vector2(92, 188), 11, GREEN)
	text_at("ROAD %d OF %d / %s" % [sim.state.travel_step + 1, nodes.size(), ("WORD FROM THE ROAD" if node.has("story_id") else str(node.kind).to_upper())], Vector2(92, 218), 10, GOLD)
	text_at(node.name, Vector2(88, 266), 34, PAPER, true)
	wrapped(node.news, Vector2(92, 300), 820, 16, GREEN)
	panel(Rect2(92, 353, 910, 62), Color("233236"))
	text_at("VISIBLE RISK", Vector2(108, 376), 10, RED)
	wrapped(node.risk, Vector2(108, 396), 870, 12, PAPER)
	for i in range(nodes.size() + 2):
		var p = Vector2(128 + i * (820.0 / (nodes.size() + 1)), 453)
		if i < nodes.size() + 1: draw_line(p, p + Vector2(820.0 / (nodes.size() + 1), 0), Color("49605c"), 3)
		var complete = i <= sim.state.travel_step
		draw_circle(p, 10, GREEN if complete else MUTED)
		text_at("SITE" if i == 0 or i == nodes.size() + 1 else "%02d" % i, p + Vector2(-13, 30), 9, MUTED)
	text_at("CARRIED / %d SCRAP · %d STRUCTURE     ROAD TOTAL / %+d SCRAP · %+d STRUCTURE" % [sim.state.scrap, sim.state.hp, int(sim.state.road_totals.scrap_delta), int(sim.state.road_totals.structure_delta)], Vector2(92, 514), 11, GOLD)

func draw_site_clear():
	var summary: Dictionary = sim.state.site_clear_summary
	draw_rect(Rect2(60, 148, 980, 588), Color(0.045, 0.06, 0.075, 0.97))
	text_at("SITE CLEAR · %d / 3" % sim.state.completed_site_ids.size(), Vector2(105, 193), 11, GOLD)
	text_at(str(summary.site_name), Vector2(100, 239), 36, PAPER, true)
	text_at(str(summary.boss_name).to_upper() + " / DEFEATED", Vector2(104, 270), 11, RED)
	panel(Rect2(96, 302, 360, 245), Color("172a2d"))
	text_at("WHAT THE SAINT CARRIES", Vector2(118, 333), 10, GOLD)
	text_at("STRUCTURE", Vector2(118, 370), 10, MUTED)
	bar(Rect2(118, 380, 310, 8), float(summary.structure) / maxf(1.0, float(summary.max_structure)), GREEN)
	text_at("%d / %d" % [int(summary.structure), int(summary.max_structure)], Vector2(118, 410), 13, PAPER)
	text_at("SCRAP / %d" % int(summary.scrap), Vector2(118, 443), 12, GOLD)
	text_at("OPTIONAL WORK / %d OF %d" % [int(summary.optional_completed), int(summary.optional_total)], Vector2(118, 470), 11, GREEN if int(summary.optional_completed) > 0 else MUTED)
	var reward = "+%d SCRAP / ROAD SALVAGE" % int(summary.route_salvage) if int(summary.route_salvage) > 0 else ("CHAPTER ROUTE SECURED" if bool(summary.terminal) else "TWO ROADS OPEN")
	text_at("REWARD / " + reward, Vector2(118, 501), 11, PAPER)
	panel(Rect2(480, 302, 520, 245), Color("1d2733"))
	text_at("MEMORY RECOVERED", Vector2(506, 333), 10, Color("cbb8ed"))
	text_at(str(summary.memory_title), Vector2(502, 368), 19, PAPER, true)
	wrapped(str(summary.memory_text), Vector2(506, 405), 462, 14, PAPER)
	wrapped(str(summary.conclusion), Vector2(506, 490), 462, 11, GREEN)
	var carried: Array[String] = []
	for weapon_id in summary.weapon_ids:
		carried.append(str(sim.config.weapons.get(weapon_id, {}).get("short", weapon_id)))
	text_at("BUILD CARRIES FORWARD", Vector2(100, 582), 9, GOLD)
	wrapped(", ".join(carried) + " · %d Evolutions · %d Gifts" % [summary.evolution_ids.size(), summary.gift_ids.size()], Vector2(274, 583), 718, 11, PAPER)

func draw_arrival():
	var summary: Dictionary = sim.state.arrival_summary
	draw_rect(Rect2(60, 148, 980, 588), Color(0.035, 0.065, 0.07, 0.96))
	text_at("DESTINATION REACHED · LEVEL %d / 3" % (sim.state.completed_site_ids.size() + 1), Vector2(105, 193), 11, GREEN)
	text_at(str(summary.site_name), Vector2(100, 239), 36, PAPER, true)
	wrapped(str(summary.experience), Vector2(104, 272), 880, 13, GREEN)
	panel(Rect2(96, 326, 360, 221), Color("172a2d"))
	text_at("ROAD ACCOUNT", Vector2(118, 357), 10, GOLD)
	text_at("ARRIVAL REST / +%d STRUCTURE" % int(summary.arrival_repair), Vector2(118, 391), 11, GREEN)
	text_at("STRUCTURE / %d OF %d" % [int(summary.structure), int(summary.max_structure)], Vector2(118, 422), 11, PAPER)
	text_at("SCRAP / %d" % int(summary.scrap), Vector2(118, 453), 11, GOLD)
	var road = summary.road_totals
	text_at("PILGRIMAGE ROAD TOTAL", Vector2(118, 486), 9, MUTED)
	text_at("%+d Scrap · %+d Structure" % [int(road.scrap_delta), int(road.structure_delta)], Vector2(118, 512), 11, PAPER)
	panel(Rect2(480, 326, 520, 221), Color("1d2733"))
	text_at("COMBAT BRIEFING", Vector2(506, 357), 10, RED)
	text_at(str(summary.boss_name).to_upper(), Vector2(502, 391), 19, PAPER, true)
	wrapped(str(summary.threat), Vector2(506, 421), 462, 11, PAPER)
	text_at("%d WAVES · %s" % [int(summary.waves), pilgrimage_duration_text(summary)], Vector2(506, 474), 10, GOLD)
	wrapped(str(summary.optional), Vector2(506, 502), 462, 10, MUTED)
	var carried: Array[String] = []
	for weapon_id in summary.weapon_ids:
		carried.append(str(sim.config.weapons.get(weapon_id, {}).get("short", weapon_id)))
	text_at("CARRIED BUILD", Vector2(100, 582), 9, GOLD)
	wrapped(", ".join(carried) + " · %d Evolutions · %d Gifts" % [summary.evolution_ids.size(), summary.gift_ids.size()], Vector2(230, 583), 760, 11, PAPER)

func draw_optional_machines():
	for i in range(sim.state.machines.size()):
		var machine = sim.state.machines[i]
		var data = sim.config.optional_repairs.machines[i]
		var p = Vector2(data.position[0], data.position[1])
		var color = GREEN if machine.complete else GOLD
		var working = not machine.complete and sim.state.active_machine == machine.id
		if not machine.complete:
			draw_arc(p, sim.config.optional_repairs.radius, 0, TAU, 40, Color("506657"), 1)
			draw_arc(p, sim.config.optional_repairs.radius, -PI / 2, -PI / 2 + TAU * maxf(0.001, machine.progress / sim.config.optional_repairs.required_ticks), 40, color, 3)
		actor_art.draw_repair(self, machine, p, sim.state.active_machine, sim.state.tick, reduced_fx, sim.config.optional_repairs.required_ticks)
		panel(Rect2(p + Vector2(-70, -57), Vector2(148, 17)), PANEL)
		text_at(data.name, p + Vector2(-64, -44), 11, color)
		text_at("RESTORED" if machine.complete else data.description, p + Vector2(-75, 76), 10, color)
		if machine.get("deferred", "") == "INTEGRITY_FULL": text_at("SAVE FOR DAMAGE", p + Vector2(-67, 94), 10, MUTED)
		if working:
			draw_line(sim.state.position, p, GREEN, 2)
			text_at("REPAIRING · %.1fs" % ((sim.config.optional_repairs.required_ticks - machine.progress) / sim.config.tick_rate), p + Vector2(-52, -68), 10, GREEN)

func draw_gear(p: Vector2, radius: float, color: Color, angle: float):
	for i in range(8):
		var d = Vector2.from_angle(angle + i * TAU / 8)
		draw_line(p + d * (radius - 4), p + d * (radius + 3), color, 5)
	draw_circle(p, radius - 3, color)
	draw_circle(p, radius * 0.45, INK)
	draw_circle(p, 3, GOLD)

func draw_saint(p: Vector2, direction: Vector2, size_factor = 1.0):
	var recoil = 0.0
	if screen == "game":
		for effect in fx:
			if effect.kind == "attack" and effect.shape in ["line", "shot", "rail"]:
				direction = (effect.to - effect.from).normalized()
				recoil = presentation_fade(effect) * (5 if effect.shape == "rail" else 2)
	draw_set_transform(p + camera_offset, 0, Vector2.ONE * size_factor)
	draw_ellipse_shadow(Vector2(0, 12), Vector2(25, 12))
	draw_rect(Rect2(-19, -8, 10, 31), Color("0e191e"))
	draw_rect(Rect2(9, -8, 10, 31), Color("0e191e"))
	for y in range(-5, 23, 6):
		draw_line(Vector2(-19, y), Vector2(-10, y), Color("697365"), 2)
		draw_line(Vector2(10, y), Vector2(19, y), Color("697365"), 2)
	draw_rect(Rect2(-14, -19, 28, 34), Color("c5b78f"))
	draw_rect(Rect2(-10, -16, 20, 12), Color("667c70"))
	draw_circle(Vector2(0, -9), 7, INK)
	draw_circle(Vector2(0, -9), 4, GREEN)
	draw_rect(Rect2(-8, 4, 16, 5), Color("74664d"))
	draw_line(Vector2(12, 0), direction * (29 - recoil), Color("8b9b86"), 7)
	draw_line(direction * (24 - recoil), direction * (39 - recoil), GOLD, 5)
	draw_line(Vector2(-13, 2), Vector2(-25, 9), Color("ac7455"), 4)
	draw_circle(Vector2(-25, 9), 4, GOLD)
	if screen == "game":
		for weapon in sim.state.weapons:
			if weapon.id == "weapon.nailer_small_mercies": draw_nailer_mount(weapon, direction)
			elif weapon.id == "weapon.bell_last_shift": draw_bell_mount(weapon)
			else: draw_weapon_mount(weapon)
	if screen == "game" and sim.has_gift("gift.spare_hand"):
		draw_line(Vector2(-10, -1), Vector2(-28, -9), Color("a99160"), 5)
		draw_line(Vector2(-28, -9), Vector2(-35, 2), PAPER, 3)
	if screen == "game" and sim.has_gift("gift.inspection_lens"):
		draw_arc(Vector2(0, -9), 10, -0.9, 0.9, 14, Color("8edce0"), 3)
		draw_line(Vector2(9, -11), Vector2(17, -18), Color("8edce0"), 2)
	if screen == "game" and sim.has_gift("gift.black_ledger"):
		draw_rect(Rect2(13, 4, 10, 14), Color("17171b"))
		draw_line(Vector2(16, 7), Vector2(21, 7), GOLD, 1)
	if screen == "game" and sim.has_gift("gift.loose_spring"):
		var spring_active = int(sim.state.get("loose_spring_until", 0)) > int(sim.state.tick)
		var spring_color = GREEN if spring_active else Color("b99158")
		var spring_points = PackedVector2Array([Vector2(-21, -2), Vector2(-13, 2), Vector2(-21, 7), Vector2(-13, 12), Vector2(-21, 18), Vector2(-14, 22)])
		draw_polyline(spring_points, spring_color, 3 if spring_active else 2, true)
		if spring_active:
			for lane in [-1, 1]: draw_line(Vector2(lane * 13, 26), Vector2(lane * 20, 38), Color(0.56, 0.86, 0.72, 0.7), 2)
	if screen == "game" and sim.has_gift("gift.honest_scale"):
		var scale_tip = 0.22 if sim.state.phase == "shop" else 0.0
		var scale_center = Vector2(-30, -10)
		var scale_axis = Vector2.from_angle(scale_tip)
		draw_line(scale_center + Vector2(0, -8), scale_center, Color("b99158"), 2)
		draw_line(scale_center - scale_axis * 9, scale_center + scale_axis * 9, GOLD, 2)
		for side in [-1, 1]:
			var pan_anchor = scale_center + scale_axis * 9 * side
			draw_line(pan_anchor, pan_anchor + Vector2(0, 6), Color("b99158"), 1)
			draw_arc(pan_anchor + Vector2(0, 7), 4, 0, PI, 8, GOLD, 1)
	if screen == "game" and sim.has_gift("gift.choir_filter"):
		var filter_active = sim.state.enemies.any(func(enemy): return int(enemy.get("support_lock_until", 0)) > int(sim.state.tick))
		var filter_color = Color("bdeff0") if filter_active else Color("b99158")
		draw_arc(Vector2(3, -9), 8, -PI / 2, PI / 2, 10, filter_color, 3)
		for hole_y in [-13, -9, -5]: draw_circle(Vector2(7, hole_y), 1.1, INK)
	if screen == "game" and sim.has_gift("gift.brass_fuse"):
		var fuse_lit = gift_fx_active("gift.brass_fuse")
		var fuse_color = Color("ffd06b") if fuse_lit else Color("8e6f45")
		var fuse_points = PackedVector2Array([Vector2(5, -18), Vector2(12, -25), Vector2(20, -22), Vector2(25, -28)])
		draw_polyline(fuse_points, fuse_color, 3 if fuse_lit else 2, true)
		draw_circle(Vector2(25, -28), 4 if fuse_lit else 2, Color("ffd06b") if fuse_lit else Color("574b3b"))
	for bolt in [Vector2(-10, -15), Vector2(10, -15), Vector2(-10, 10), Vector2(10, 10)]: draw_circle(bolt, 1.4, PAPER)

func weapon_ready_amount(weapon: Dictionary, lead_ticks: int) -> float:
	if sim.state.is_empty() or int(weapon.get("ready", 0)) <= int(sim.state.tick): return 0.0
	var remaining = int(weapon.ready) - int(sim.state.tick)
	if remaining > lead_ticks: return 0.0
	return 1.0 - float(remaining) / float(maxi(1, lead_ticks))

func draw_nailer_mount(weapon: Dictionary, fallback_direction: Vector2):
	var direction = fallback_direction.normalized()
	if direction == Vector2.ZERO: direction = Vector2.RIGHT
	var evolved = sim.weapon_evolution_id(weapon) == "evolution.mercy_rail"
	var readiness = weapon_ready_amount(weapon, 26 if evolved else 18)
	# The equipped Nailer is not a permanent extra limb. It condenses only in
	# the bounded pre-fire window; the committed object is drawn from its event.
	if readiness <= 0.0: return
	var origin = direction * 9 + direction.orthogonal() * 8
	draw_manifested_nailer_geometry(origin, direction, evolved, readiness * 0.24, 0.28 + readiness * 0.72, readiness)

func draw_bell_mount(weapon: Dictionary):
	var effect = latest_weapon_attack("weapon.bell_last_shift")
	if effect != null: return
	var evolved = sim.weapon_evolution_id(weapon) == "evolution.great_toll"
	var readiness = weapon_ready_amount(weapon, 16 if evolved else 10)
	if readiness <= 0.0: return
	var anchor = Vector2(0, -28 if evolved else -24)
	var width = 16.0 if evolved else (13.0 if int(weapon.rank) >= 2 else 11.0)
	draw_line(Vector2(0, -17), anchor + Vector2(0, -8 + readiness * 3), Color("796348"), 4, true)
	var bell_color = Color("d4a85b").lightened(0.18 * readiness)
	draw_colored_polygon(PackedVector2Array([anchor + Vector2(-width * 0.45, -7), anchor + Vector2(width * 0.45, -7), anchor + Vector2(width, 7), anchor + Vector2(-width, 7)]), bell_color)
	draw_line(anchor + Vector2(-width, 7), anchor + Vector2(width, 7), Color("7d633d"), 2, true)
	var clapper = anchor + Vector2(0, 10)
	draw_line(anchor, clapper, Color("5c4934"), 2, true)
	draw_circle(clapper, 3.5, GOLD)
	if evolved:
		draw_arc(anchor, 22 + readiness * 3, -PI * 0.82, -PI * 0.18, 18, Color(0.88, 0.72, 0.42, 0.5), 2)
		for cardinal in range(4):
			var marker = anchor + Vector2.from_angle(cardinal * PI / 2.0) * 20
			draw_line(marker - Vector2(0, 3), marker + Vector2(0, 3), Color(PAPER, 0.55), 2)

func draw_weapon_mount(weapon: Dictionary):
	var effect = latest_weapon_attack(str(weapon.id))
	var progress = presentation_progress(effect) if effect != null else 0.0
	var pulse = presentation_fade(effect) if effect != null else 0.0
	var readiness = weapon_ready_amount(weapon, 12)
	if str(weapon.id) in ["weapon.candle_nailer", "weapon.cable_contrition", "weapon.hymn_coil", "weapon.altar_mortar", "weapon.foundry_censer", "weapon.penance_winch"]:
		if effect != null or readiness <= 0.0: return
	var rank = int(weapon.get("rank", 1))
	var evolution = sim.weapon_evolution_id(weapon)
	match str(weapon.id):
		"weapon.procession_gear":
			var anchor = Vector2(-23, -2)
			draw_line(Vector2(-12, 1), anchor, Color("6e775f"), 4, true)
			draw_gear(anchor, 7 + (2 if rank >= 3 else 0), Color("91c9b0"), progress * TAU)
			if rank >= 2: draw_circle(anchor + Vector2(0, 11), 3, PAPER)
			if evolution == "evolution.maintenance_parade": draw_line(anchor + Vector2(-7, -8), anchor + Vector2(8, -12), GOLD, 3, true)
		"weapon.candle_nailer":
			var anchor = Vector2(-18, -18)
			draw_line(Vector2(-9, -9), anchor, Color("6d6269"), 4, true)
			draw_rect(Rect2(anchor - Vector2(8, 4), Vector2(16, 10)), Color("393039"))
			var flame_count = 3 if evolution == "evolution.candle_unreturned" else (2 if rank >= 2 else 1)
			for index in range(flame_count):
				var x = (index - (flame_count - 1) * 0.5) * 6.0
				var flame = anchor + Vector2(x, -7 - readiness * 3)
				draw_circle(flame, 2.5 + pulse, Color("cbb8ed"))
		"weapon.cable_contrition":
			var anchor = Vector2(-24, 11)
			draw_line(Vector2(-12, 7), anchor, Color("576a6d"), 4, true)
			draw_circle(anchor, 8, Color("496979"))
			draw_arc(anchor, 5, progress * TAU, progress * TAU + PI * 1.5, 14, Color("9bd7e5"), 2, true)
			if evolution == "evolution.contrition_lattice":
				for index in range(3): draw_circle(anchor + Vector2.from_angle(index * TAU / 3.0) * 11, 2.5, PAPER)
			elif rank >= 3: draw_line(anchor, anchor + Vector2(11, 4), GOLD, 3, true)
		"weapon.hymn_coil":
			var anchor = Vector2(21, -17)
			draw_line(Vector2(10, -8), anchor, Color("76684f"), 4, true)
			for offset in [-5, 0, 5]: draw_arc(anchor + Vector2(0, offset), 6, -PI * 0.65, PI * 0.65, 10, Color("8edce0"), 2 + (1 if rank >= 2 else 0))
			var fork_gap = 3.0 - 2.0 * maxf(readiness, pulse)
			for side in [-1, 1]: draw_line(anchor + Vector2(side * fork_gap, -9), anchor + Vector2(side * (fork_gap + 2), -17), PAPER if pulse > 0.3 else Color("8edce0"), 2, true)
			if evolution == "evolution.quiet_sermon": draw_arc(anchor, 13, -PI * 0.7, PI * 0.7, 18, Color("d7f2ef"), 3, true)
		"weapon.altar_mortar":
			var anchor = Vector2(23, -4)
			draw_line(Vector2(11, 1), anchor, Color("7d674f"), 5, true)
			draw_rect(Rect2(anchor - Vector2(7, 9), Vector2(15, 18)), Color("9b5f43"))
			draw_arc(anchor + Vector2(0, -8), 7 + readiness * 3, PI, TAU, 14, PAPER if pulse > 0.5 else Color("e89765"), 3, true)
			if rank >= 3: draw_line(anchor + Vector2(-6, 7), anchor + Vector2(8, 7), GOLD, 2, true)
			if evolution == "evolution.workshop_benediction": draw_rect(Rect2(anchor - Vector2(11, 12), Vector2(22, 3)), GREEN)
		"weapon.foundry_censer":
			var anchor = Vector2(-28, -10)
			draw_line(Vector2(-12, -7), anchor + Vector2(0, -8), Color("77634a"), 2, true)
			draw_line(anchor + Vector2(0, -8), anchor + Vector2(sin(progress * PI) * 4, 0), Color("77634a"), 2, true)
			draw_colored_polygon(PackedVector2Array([anchor + Vector2(-7, 0), anchor + Vector2(7, 0), anchor + Vector2(5, 9), anchor + Vector2(-5, 9)]), Color("344842") if evolution == "" else Color("4b384c"))
			for vent in [-4, 0, 4]: draw_circle(anchor + Vector2(vent, -2), 1.5 + pulse, Color("b58ebd") if evolution != "" else Color("74b9a6"))
		"weapon.penance_winch":
			var anchor = Vector2(24, 10)
			draw_line(Vector2(11, 7), anchor, Color("74664d"), 5, true)
			draw_circle(anchor, 8, Color("8a7048"))
			draw_circle(anchor, 3, INK)
			var extension = 7.0 * maxf(readiness, pulse)
			draw_line(anchor, anchor + Vector2(9 + extension, -5), Color("d6b16d"), 4, true)
			if rank >= 3: draw_colored_polygon(PackedVector2Array([anchor + Vector2(3, -8), anchor + Vector2(8, -5), anchor + Vector2(2, -2)]), PAPER)
			if evolution == "evolution.long_hand": draw_line(anchor + Vector2(8, -5), anchor + Vector2(15 + extension, 3), GOLD, 4, true)
		"weapon.welded_halo":
			var anchor = Vector2(0, -27)
			draw_line(Vector2(0, -16), anchor, Color("71806a"), 3, true)
			draw_arc(anchor, 12, progress * PI, progress * PI + TAU * 0.82, 24, Color("a9e0b1"), 3, true)
			draw_circle(anchor + Vector2.from_angle(progress * PI) * 12, 3 + pulse, PAPER)
			if evolution == "evolution.halo_of_repairs": draw_arc(anchor, 17, -progress * PI, -progress * PI + TAU * 0.82, 24, Color("d6edbf"), 2, true)

func gift_fx_active(gift_id: String) -> bool:
	return fx.any(func(effect): return gift_event_id(effect) == gift_id)

func nailer_manifest_state(effect: Dictionary) -> Dictionary:
	var origin: Vector2 = effect.get("from", Vector2.ZERO)
	var target: Vector2 = effect.get("to", origin + Vector2.RIGHT)
	var direction = (target - origin).normalized()
	if direction == Vector2.ZERO: direction = Vector2.RIGHT
	var progress = presentation_progress(effect)
	var evolved = str(effect.get("shape", "")) == "rail"
	var reveal = smoothstep(0.0, 0.10, progress) * (1.0 - smoothstep(0.84, 1.0, progress))
	var mechanism = smoothstep(0.07, 0.31, progress)
	var recoil = sin(clampf((progress - 0.18) / 0.42, 0.0, 1.0) * PI) * (7.0 if evolved else 4.0)
	return {
		"origin": origin,
		"direction": direction,
		"evolved": evolved,
		"progress": progress,
		"visibility": reveal,
		"mechanism": mechanism,
		"recoil": recoil,
		"guide_separation": (4.0 + mechanism * 6.0) if evolved else 0.0,
		"guide_length": (34.0 + mechanism * 27.0) if evolved else 30.0,
		"carriage": clampf((progress - 0.14) / (0.28 if evolved else 0.20), 0.0, 1.0),
	}

func draw_manifested_nailer_geometry(origin: Vector2, direction: Vector2, evolved: bool, progress: float, alpha: float, readiness = 0.0):
	if alpha <= 0.0: return
	var side = direction.orthogonal()
	var mechanism = smoothstep(0.07, 0.31, progress)
	var recoil = sin(clampf((progress - 0.18) / 0.42, 0.0, 1.0) * PI) * (7.0 if evolved else 4.0)
	var root = origin - direction * recoil
	var rear = root + direction * 7
	var body_front = root + direction * (34 if evolved else 31)
	var body_half = 8.0 if evolved else 7.0
	var casing = Color(0.34, 0.47, 0.41, alpha)
	var cream = Color(0.89, 0.84, 0.72, alpha)
	var bronze = Color(0.71, 0.55, 0.30, alpha)
	var dark = Color(0.14, 0.18, 0.17, alpha)
	draw_colored_polygon(PackedVector2Array([rear - side * body_half, body_front - side * body_half, body_front + side * body_half, rear + side * body_half]), casing)
	var patch_rear = rear.lerp(body_front, 0.22)
	var patch_front = rear.lerp(body_front, 0.57)
	draw_colored_polygon(PackedVector2Array([patch_rear - side * (body_half - 2), patch_front - side * (body_half - 2), patch_front + side * (body_half - 2), patch_rear + side * (body_half - 2)]), cream)
	var wheel = rear.lerp(body_front, 0.69)
	draw_circle(wheel, 5.0 if evolved else 4.0, dark)
	draw_arc(wheel, 3.0, progress * TAU * 2.0, progress * TAU * 2.0 + TAU * 0.78, 12, bronze, 2, true)
	var carriage_back = rear.lerp(body_front, 0.16 - readiness * 0.08)
	var carriage_front = carriage_back + direction * 5
	draw_line(carriage_back - side * body_half, carriage_front - side * body_half, bronze, 3, true)
	if evolved:
		var separation = 4.0 + mechanism * 6.0
		var guide_length = 34.0 + mechanism * 27.0
		var guide_end = rear + direction * guide_length
		for rail_side in [-1.0, 1.0]:
			var rail_start = rear + side * rail_side * separation
			var rail_finish = guide_end + side * rail_side * separation
			draw_line(rail_start, rail_finish, cream, 3, true)
			draw_line(rail_start + direction * 4, rail_finish, Color(bronze, alpha * 0.74), 1, true)
		for brace in [0.28, 0.62, 0.9]:
			var brace_center = rear.lerp(guide_end, brace)
			draw_line(brace_center - side * separation, brace_center + side * separation, Color(cream, alpha * 0.82), 2, true)
		var carriage_amount = clampf((progress - 0.14) / 0.28, 0.0, 1.0)
		var rail_carriage = rear.lerp(guide_end, carriage_amount)
		draw_colored_polygon(PackedVector2Array([rail_carriage - direction * 4 - side * 4, rail_carriage + direction * 4 - side * 4, rail_carriage + direction * 4 + side * 4, rail_carriage - direction * 4 + side * 4]), bronze)
		var muzzle = guide_end
		draw_line(muzzle - side * (separation + 3), muzzle - side * separation, cream, 3, true)
		draw_line(muzzle + side * separation, muzzle + side * (separation + 3), cream, 3, true)
	else:
		var jaw = body_front + direction * (5 + mechanism * 3)
		for jaw_side in [-1.0, 1.0]: draw_line(body_front + side * jaw_side * 4, jaw + side * jaw_side * 5, cream, 3, true)
		draw_line(jaw - side * 5, jaw + side * 5, bronze, 2, true)
	if not reduced_fx:
		draw_circle(rear, 10 + mechanism * 4, Color(0.95, 0.84, 0.55, alpha * 0.07))

func draw_nailer_attack(effect: Dictionary, color: Color, progress: float, fade: float):
	var origin: Vector2 = effect.from
	var target: Vector2 = effect.to
	var direction = (target - origin).normalized()
	if direction == Vector2.ZERO: direction = Vector2.RIGHT
	var side = direction.orthogonal()
	var is_rail = effect.shape == "rail"
	var manifestation = nailer_manifest_state(effect)
	draw_manifested_nailer_geometry(origin, direction, is_rail, progress, fade * float(manifestation.visibility))
	var guide_alpha = (1.0 - smoothstep(0.0, 0.32, progress)) * (0.34 if is_rail else 0.22)
	for segment in range(6):
		if segment % 2 == 0:
			var a = origin.lerp(target, segment / 6.0)
			var b = origin.lerp(target, (segment + 1) / 6.0)
			draw_line(a, b, Color(color, guide_alpha), 1, true)
	var travel = clampf((progress - 0.14) / (0.26 if is_rail else 0.20), 0.0, 1.0)
	if travel <= 0.0: return
	var head = origin.lerp(target, travel)
	var resolve_alpha = fade * smoothstep(0.14, 0.28, progress)
	if is_rail:
		draw_line(origin + side * 5, head + side * 5, Color(color, resolve_alpha * 0.5), 4, true)
		draw_line(origin - side * 5, head - side * 5, Color(color, resolve_alpha * 0.5), 4, true)
		draw_line(origin, head, Color(1.0, 0.98, 0.85, resolve_alpha), 3, true)
	else:
		draw_line(origin, head, Color(color, resolve_alpha), 3, true)
	if int(effect.get("rank", 1)) >= 2:
		for marker in [0.32, 0.62, 0.9]:
			if travel >= marker:
				var pin = origin.lerp(target, marker)
				draw_line(pin - side * 4, pin + side * 4, Color(PAPER, resolve_alpha * 0.75), 2, true)
	if travel >= 0.96:
		draw_circle(target, 5 + (1.0 - fade) * 6, Color(color, resolve_alpha * 0.22))
		draw_line(target - direction * 7, target + direction * 5, Color(PAPER, resolve_alpha), 2, true)
		if not reduced_fx:
			var particle_count = 8 if is_rail else 5
			for index in range(particle_count):
				var spread = -1.2 + index * (2.4 / maxf(1.0, particle_count - 1.0))
				var spark_direction = Vector2.from_angle(direction.angle() + PI + spread)
				var spark_length = (8 + index % 3 * 4) * (0.5 + fade * 0.5)
				draw_line(target + spark_direction * 3, target + spark_direction * spark_length, Color(GOLD, resolve_alpha), 2, true)

func manifested_relic_state(effect: Dictionary) -> Dictionary:
	var origin: Vector2 = effect.get("from", Vector2.ZERO)
	var target: Vector2 = effect.get("to", origin + Vector2.RIGHT)
	var direction = (target - origin).normalized()
	if direction == Vector2.ZERO: direction = Vector2.RIGHT
	var progress = presentation_progress(effect)
	return {"origin": origin, "direction": direction, "progress": progress, "shape": str(effect.get("shape", "")), "visibility": smoothstep(0.0, 0.1, progress) * (1.0 - smoothstep(0.86, 1.0, progress))}

func draw_manifested_bell(effect: Dictionary, progress: float, fade: float):
	var state = manifested_relic_state(effect)
	var origin: Vector2 = state.origin
	var direction: Vector2 = state.direction
	var alpha = fade * float(state.visibility)
	var radial = state.shape == "radial"
	# Keep the remembered tool beside the Saint while the authored attack still
	# resolves from the exact event origin. This prevents the body silhouette
	# from disappearing into the player sprite during dense overlaps.
	var bell_center = origin + Vector2(0, 40)
	var width = 19.0 if radial else 16.0
	var frame_top = bell_center + Vector2(0, -23)
	draw_line(frame_top + Vector2(-20, 0), frame_top + Vector2(20, 0), Color(0.20, 0.22, 0.20, alpha), 4, true)
	draw_line(frame_top, bell_center + Vector2(0, -10), Color(0.20, 0.22, 0.20, alpha), 4, true)
	var dome = PackedVector2Array([bell_center + Vector2(-width * 0.45, -10), bell_center + Vector2(width * 0.45, -10), bell_center + Vector2(width, 9), bell_center + Vector2(-width, 9)])
	draw_colored_polygon(dome, Color(0.72, 0.52, 0.27, alpha))
	draw_polyline(PackedVector2Array([dome[0], dome[1], dome[2], dome[3], dome[0]]), Color(0.91, 0.83, 0.64, alpha * 0.82), 2, true)
	draw_line(bell_center + Vector2(-width, 9), bell_center + Vector2(width, 9), Color(0.91, 0.83, 0.64, alpha), 3, true)
	draw_circle(bell_center + Vector2(0, 13), 3, Color(0.38, 0.31, 0.23, alpha))
	var strike = sin(clampf((progress - 0.06) / 0.34, 0.0, 1.0) * PI)
	var facing = 1.0 if direction.x >= 0.0 else -1.0
	var hammer_root = bell_center + Vector2(-facing * 28, -12)
	var hammer_tip = bell_center + Vector2(-facing * (width + 3.0 - strike * (width + 1.0)), -1)
	draw_line(hammer_root, hammer_tip, Color(0.50, 0.42, 0.30, alpha), 4, true)
	draw_circle(hammer_tip, 4, Color(0.88, 0.75, 0.48, alpha))

func draw_manifested_cable(effect: Dictionary, progress: float, fade: float):
	var state = manifested_relic_state(effect)
	var origin: Vector2 = state.origin
	var direction: Vector2 = state.direction
	var side = direction.orthogonal()
	var alpha = fade * float(state.visibility)
	var reel = origin - direction * 5
	draw_circle(reel, 11, Color(0.20, 0.31, 0.34, alpha))
	draw_arc(reel, 7, progress * TAU * 2.0, progress * TAU * 2.0 + TAU * 0.82, 18, Color(0.54, 0.76, 0.80, alpha), 3, true)
	draw_circle(reel, 3, Color(0.89, 0.84, 0.72, alpha))
	var reach = clampf((progress - 0.06) / 0.32, 0.0, 1.0)
	var clamp_tip = origin.lerp(effect.to, reach)
	draw_line(reel, clamp_tip, Color(0.45, 0.68, 0.72, alpha * 0.72), 2, true)
	draw_line(clamp_tip, clamp_tip - direction * 8 + side * 6, Color(0.89, 0.84, 0.72, alpha), 3, true)
	draw_line(clamp_tip, clamp_tip - direction * 8 - side * 6, Color(0.89, 0.84, 0.72, alpha), 3, true)

func draw_manifested_censer(effect: Dictionary, progress: float, fade: float):
	var state = manifested_relic_state(effect)
	var origin: Vector2 = state.origin
	var direction: Vector2 = state.direction
	var side = direction.orthogonal()
	var alpha = fade * float(state.visibility)
	var sway = sin(progress * PI) * 7.0
	var hanger = origin + direction * 3 + side * 58
	var body = hanger + Vector2(sway, 20)
	draw_line(hanger + Vector2(-11, -3), body + Vector2(-7, -9), Color(0.46, 0.38, 0.28, alpha), 2, true)
	draw_line(hanger + Vector2(11, -3), body + Vector2(7, -9), Color(0.46, 0.38, 0.28, alpha), 2, true)
	draw_colored_polygon(PackedVector2Array([body + Vector2(-12, -9), body + Vector2(12, -9), body + Vector2(8, 12), body + Vector2(-8, 12)]), Color(0.24, 0.34, 0.31, alpha))
	draw_rect(Rect2(body + Vector2(-10, -14), Vector2(20, 6)), Color(0.89, 0.84, 0.72, alpha))
	for vent_x in [-6, 0, 6]: draw_circle(body + Vector2(vent_x, 3), 2.1, Color(0.58, 0.80, 0.70, alpha))
	if not reduced_fx:
		for plume in range(3):
			var puff = body + Vector2(15 + plume * 8, 3 - plume * 5)
			draw_circle(puff, 5 + plume * 2, Color(0.48, 0.70, 0.64, alpha * (0.16 - plume * 0.03)))

func draw_manifested_candle(effect: Dictionary, progress: float, fade: float):
	var state = manifested_relic_state(effect)
	var origin: Vector2 = state.origin
	var direction: Vector2 = state.direction
	var side = direction.orthogonal()
	var alpha = fade * float(state.visibility)
	var evolved = state.shape == "funeral_shots"
	var body = origin - direction * 25 - side * 25
	var rear = body - direction * 11
	var front = body + direction * 13
	draw_line(front, origin, Color(0.46, 0.38, 0.34, alpha), 3, true)
	draw_colored_polygon(PackedVector2Array([rear - side * 8, front - side * 8, front + side * 8, rear + side * 8]), Color(0.22, 0.19, 0.22, alpha))
	draw_line(rear - side * 8, front - side * 8, Color(0.76, 0.69, 0.57, alpha), 2, true)
	var wick_count = 3 if evolved else 1
	for wick in range(wick_count):
		var offset = (wick - (wick_count - 1) * 0.5) * 7.0
		var socket = front + side * offset
		draw_line(socket - direction * 3, socket + direction * 7, Color(0.78, 0.68, 0.48, alpha), 3, true)
		var flame = socket + direction * (10 + sin(progress * TAU + wick) * 2)
		draw_colored_polygon(PackedVector2Array([flame + direction * 5, flame - direction * 3 - side * 3, flame - direction * 3 + side * 3]), Color(0.78, 0.67, 0.91, alpha))
		if not reduced_fx: draw_circle(flame, 6, Color(0.55, 0.39, 0.65, alpha * 0.16))

func draw_manifested_hymn(effect: Dictionary, progress: float, fade: float):
	var state = manifested_relic_state(effect)
	var origin: Vector2 = state.origin
	var direction: Vector2 = state.direction
	var side = direction.orthogonal()
	var alpha = fade * float(state.visibility)
	var evolved = state.shape == "sermon"
	var body = origin - direction * 22 + side * 27
	draw_line(body + direction * 9, origin, Color(0.42, 0.37, 0.29, alpha), 3, true)
	draw_circle(body, 12 if evolved else 10, Color(0.18, 0.29, 0.31, alpha))
	draw_arc(body, 7 if evolved else 6, progress * TAU * 2.0, progress * TAU * 2.0 + TAU * 0.8, 16, Color(0.56, 0.86, 0.88, alpha), 3, true)
	var tune = smoothstep(0.04, 0.24, progress)
	var gap = (9.0 if evolved else 7.0) - tune * 4.0
	var fork_root = body + direction * 6
	for fork_side in [-1.0, 1.0]:
		var fork_base = fork_root + side * fork_side * gap
		var fork_tip = origin + side * fork_side * (3.0 if evolved else 2.0)
		draw_line(fork_base, fork_tip, Color(0.73, 0.93, 0.94, alpha), 3 if evolved else 2, true)
		draw_line(fork_base - direction * 4, fork_base + side * fork_side * 4, Color(0.89, 0.84, 0.72, alpha), 2, true)

func draw_manifested_mortar(effect: Dictionary, progress: float, fade: float):
	var state = manifested_relic_state(effect)
	var origin: Vector2 = state.origin
	var direction: Vector2 = state.direction
	var side = direction.orthogonal()
	var alpha = fade * float(state.visibility)
	var evolved = state.shape in ["benediction", "consecrated"]
	var recoil = sin(clampf((progress - 0.08) / 0.34, 0.0, 1.0) * PI) * 5.0
	var base = origin - direction * (30 + recoil) + side * 24
	var mouth = origin - direction * recoil + side * 24
	draw_line(base - side * 10, base + side * 10, Color(0.36, 0.31, 0.25, alpha), 5, true)
	draw_line(base - side * 8, base - direction * 8 - side * 13, Color(0.45, 0.38, 0.28, alpha), 4, true)
	draw_line(base + side * 8, base - direction * 8 + side * 13, Color(0.45, 0.38, 0.28, alpha), 4, true)
	draw_line(base, mouth, Color(0.61, 0.37, 0.26, alpha), 13 if evolved else 11, true)
	draw_line(base + direction * 4, mouth, Color(0.91, 0.73, 0.46, alpha), 3, true)
	draw_arc(mouth, 8 if evolved else 7, direction.angle() - PI * 0.5, direction.angle() + PI * 0.5, 12, Color(0.89, 0.84, 0.72, alpha), 3, true)
	draw_line(mouth, origin, Color(0.89, 0.84, 0.72, alpha * 0.72), 2, true)
	if evolved: draw_rect(Rect2(base - Vector2(8, 8), Vector2(16, 16)), Color(0.35, 0.52, 0.43, alpha), false, 2)

func draw_manifested_winch(effect: Dictionary, progress: float, fade: float):
	var state = manifested_relic_state(effect)
	var origin: Vector2 = state.origin
	var direction: Vector2 = state.direction
	var side = direction.orthogonal()
	var alpha = fade * float(state.visibility)
	var evolved = state.shape == "long_hand"
	var drum = origin - direction * 20 - side * 27
	draw_line(drum + direction * 8, origin, Color(0.45, 0.38, 0.28, alpha), 4, true)
	draw_circle(drum, 13 if evolved else 11, Color(0.54, 0.44, 0.28, alpha))
	draw_arc(drum, 8 if evolved else 7, -progress * TAU * 2.0, -progress * TAU * 2.0 + TAU * 0.82, 18, Color(0.86, 0.70, 0.43, alpha), 3, true)
	draw_circle(drum, 3, Color(0.14, 0.18, 0.17, alpha))
	var pawl = drum + direction * 9 - side * 6
	draw_colored_polygon(PackedVector2Array([pawl, pawl - direction * 8 - side * 4, pawl - direction * 5 + side * 3]), Color(0.89, 0.84, 0.72, alpha))
	if evolved:
		draw_line(drum - side * 13, drum + side * 13, Color(0.89, 0.84, 0.72, alpha * 0.82), 3, true)

func draw_bell_attack(effect: Dictionary, color: Color, progress: float, fade: float):
	var origin: Vector2 = effect.from
	var radial = effect.shape == "radial"
	var direction = (effect.to - origin).normalized()
	if direction == Vector2.ZERO: direction = Vector2.RIGHT
	draw_manifested_bell(effect, progress, fade)
	var commit = clampf((progress - 0.16) / 0.52, 0.0, 1.0)
	var radius = float(effect.range) * ease(commit, -1.8)
	var alpha = fade * smoothstep(0.12, 0.28, progress)
	var preparation_radius = 22.0 - minf(progress / 0.16, 1.0) * 7.0
	if progress < 0.24:
		draw_arc(origin, preparation_radius, -PI * 0.8, -PI * 0.2, 18, Color(PAPER, 0.35 + progress), 3, true)
		draw_line(origin + Vector2(0, -28), origin + Vector2(0, -15 + progress * 18), Color(GOLD, 0.75), 4, true)
	if radial:
		draw_circle(origin, radius, Color(color, alpha * 0.055))
		draw_arc(origin, radius, 0, TAU, 64, Color(color, alpha), 6, true)
		if not reduced_fx:
			for cardinal in range(4):
				var marker = origin + Vector2.from_angle(cardinal * PI / 2.0) * radius * 0.72
				draw_arc(marker, 10 + 6 * commit, 0, TAU, 16, Color(PAPER, alpha * 0.8), 2, true)
	else:
		var half_width = float(effect.get("width", 0.8))
		var angle = direction.angle()
		draw_arc(origin, radius, angle - half_width, angle + half_width, 28, Color(color, alpha), 4, true)
		draw_line(origin, origin + Vector2.from_angle(angle - half_width) * radius, Color(color, alpha * 0.34), 1, true)
		draw_line(origin, origin + Vector2.from_angle(angle + half_width) * radius, Color(color, alpha * 0.34), 1, true)
		if int(effect.get("rank", 1)) >= 3:
			var second_radius = maxf(0.0, radius - 18.0)
			draw_arc(origin, second_radius, angle - half_width, angle + half_width, 28, Color(PAPER, alpha * 0.58), 2, true)
	if not reduced_fx and commit > 0.35:
		var count = 8 if radial else 5
		for index in range(count):
			var particle_angle = index * TAU / count if radial else direction.angle() - float(effect.get("width", 0.8)) + index * float(effect.get("width", 0.8)) * 2.0 / maxf(1.0, count - 1.0)
			var particle = origin + Vector2.from_angle(particle_angle) * radius
			draw_line(particle, particle + Vector2.from_angle(particle_angle) * (5 + index % 3 * 3), Color(GOLD, alpha * 0.85), 2, true)

func quadratic_point(start: Vector2, control: Vector2, finish: Vector2, amount: float) -> Vector2:
	var first = start.lerp(control, amount)
	var second = control.lerp(finish, amount)
	return first.lerp(second, amount)

func draw_procession_attack(effect: Dictionary, color: Color, progress: float, fade: float):
	var origin: Vector2 = effect.from
	var contacts: Array = [effect.to]
	if effect.shape == "parade": contacts = [effect.to, effect.to2] + effect.get("points", [])
	elif effect.get("targets", []).size() > 1: contacts = effect.targets
	var commit = clampf((progress - 0.10) / 0.44, 0.0, 1.0)
	var ring_alpha = fade * smoothstep(0.05, 0.24, progress)
	var inner_range = float(effect.get("inner_range", effect.range))
	draw_arc(origin, inner_range, -PI / 2, -PI / 2 + TAU * maxf(0.04, commit), 48, Color(color, ring_alpha * 0.35), 2, true)
	if effect.shape == "parade":
		draw_arc(origin, float(effect.range), PI / 2, PI / 2 - TAU * maxf(0.04, commit), 64, Color(GOLD if effect.get("extended", false) else color, ring_alpha * 0.42), 3, true)
	for index in range(contacts.size()):
		var contact: Vector2 = origin.lerp(contacts[index], ease(commit, -1.6))
		draw_gear(contact, 10 if effect.shape == "parade" else 8, GOLD if index >= 2 else color, progress * TAU * (-1 if index % 2 else 1))
		if progress > 0.38:
			draw_arc(contact, 9 + progress * 9, 0, TAU, 18, Color(PAPER, fade * 0.65), 2, true)
		if not reduced_fx and progress > 0.42:
			for filing in range(2):
				var d = Vector2.from_angle(index + filing * PI) * (7 + progress * 12)
				draw_line(contact + d * 0.5, contact + d, Color(GOLD, fade), 2, true)
	if effect.shape == "parade" and effect.get("extended", false):
		for flag_angle in [0.0, PI]:
			var pole = origin + Vector2.from_angle(flag_angle) * float(effect.range)
			draw_line(pole, pole + Vector2(0, -16), Color(PAPER, fade), 2, true)
			draw_colored_polygon(PackedVector2Array([pole + Vector2(0, -16), pole + Vector2(11, -12), pole + Vector2(0, -8)]), Color(GOLD, fade * 0.75))

func draw_candle_attack(effect: Dictionary, color: Color, progress: float, fade: float):
	draw_manifested_candle(effect, progress, fade)
	var targets: Array = effect.get("targets", [])
	if targets.is_empty(): targets = [effect.to]
	var travel = clampf((progress - 0.12) / (0.42 if effect.shape == "funeral_shots" else 0.30), 0.0, 1.0)
	for index in range(targets.size()):
		var target: Vector2 = targets[index]
		var direction = (target - effect.from).normalized()
		var side = direction.orthogonal()
		var control = effect.from.lerp(target, 0.5) + side * ((index - (targets.size() - 1) * 0.5) * 24.0 - 18.0)
		var points = PackedVector2Array()
		for step in range(9):
			var amount = minf(travel, step / 8.0)
			points.append(quadratic_point(effect.from, control, target, amount))
			if amount >= travel: break
		if points.size() > 1: draw_polyline(points, Color(color, fade * 0.65), 2 if effect.shape == "shot" else 3, true)
		var head = quadratic_point(effect.from, control, target, travel)
		draw_circle(head, 4 + (2 if effect.shape == "funeral_shots" else 0), Color(PAPER, fade))
		draw_circle(head - direction * 5, 3, Color(color, fade * 0.72))
		if not reduced_fx and travel > 0.1:
			for ember in range(3):
				var trail_amount = maxf(0.0, travel - 0.05 * (ember + 1))
				draw_circle(quadratic_point(effect.from, control, target, trail_amount), 2, Color("7f628e", fade * (0.75 - ember * 0.16)))
		if travel >= 0.98:
			draw_arc(target, 7 + progress * 10, -PI * 0.75, PI * 0.75, 16, Color(color, fade), 2, true)

func draw_cable_attack(effect: Dictionary, color: Color, progress: float, fade: float):
	var origin: Vector2 = effect.from
	var direction = (effect.to - origin).normalized()
	if direction == Vector2.ZERO: direction = Vector2.RIGHT
	draw_manifested_cable(effect, progress, fade)
	var commit = clampf((progress - 0.10) / 0.38, 0.0, 1.0)
	if effect.shape == "lattice":
		var points: Array = effect.get("points", [])
		if points.size() != 3: return
		for index in range(3):
			var anchor: Vector2 = points[index]
			var stamp = clampf(progress * 4.0 - index * 0.22, 0.0, 1.0)
			draw_arc(anchor, 8 + stamp * 5, 0, TAU * stamp, 18, Color(PAPER, fade * stamp), 2, true)
		var edge_progress = clampf((progress - 0.24) / 0.42, 0.0, 1.0)
		for index in range(3):
			var start: Vector2 = points[index]
			var finish: Vector2 = points[(index + 1) % 3]
			var local_progress = clampf(edge_progress * 3.0 - index, 0.0, 1.0)
			draw_line(start, start.lerp(finish, local_progress), Color(color, fade * 0.62), 7, true)
			draw_line(start, start.lerp(finish, local_progress), Color(PAPER, fade * 0.7), 2, true)
		return
	var half_width = float(effect.get("width", 0.8))
	var angle = direction.angle()
	var sweep_angle = lerpf(angle - half_width, angle + half_width, ease(commit, -1.5))
	var hook = origin + Vector2.from_angle(sweep_angle) * float(effect.range)
	draw_arc(origin, float(effect.range), angle - half_width, sweep_angle, 28, Color(color, fade * 0.7), 5, true)
	draw_line(origin, hook, Color(color, fade * 0.22), 2, true)
	draw_line(hook, hook - direction.rotated(half_width) * 10 + direction.orthogonal() * 7, Color(PAPER, fade), 3, true)
	if progress > 0.48:
		for tick in [0.32, 0.55, 0.78]:
			var p = origin.lerp(hook, tick)
			draw_line(p - direction.orthogonal() * 3, p + direction.orthogonal() * 3, Color(PAPER, fade * 0.72), 2, true)

func draw_hymn_attack(effect: Dictionary, color: Color, progress: float, fade: float):
	draw_manifested_hymn(effect, progress, fade)
	var origin: Vector2 = effect.from
	var target: Vector2 = effect.to
	var direction = (target - origin).normalized()
	if direction == Vector2.ZERO: direction = Vector2.RIGHT
	var side = direction.orthogonal()
	var commit = clampf((progress - 0.10) / 0.24, 0.0, 1.0)
	var width = 18.0 if effect.shape == "sermon" else maxf(4.0, float(effect.get("width", 6)))
	if progress < 0.22:
		for tine in [-1, 1]: draw_line(origin + side * tine * 10, origin + direction * 24 + side * tine * (3 + 7 * (1.0 - commit)), Color(color, 0.35 + commit * 0.45), 2, true)
	var pulse_count = 4 if effect.shape == "sermon" else 3
	for pulse in range(pulse_count):
		var offset = side * (pulse - (pulse_count - 1) * 0.5) * width / maxf(1.0, pulse_count - 1.0)
		var alpha = fade * (0.26 + 0.18 * ((pulse + int(progress * 12)) % 2))
		draw_line(origin + offset, origin.lerp(target, commit) + offset, Color(color, alpha), 3 if effect.shape == "sermon" else 2, true)
	if effect.shape == "sermon":
		draw_line(origin, origin.lerp(target, commit), Color(color, fade * 0.12), width, true)
		for marker in [0.28, 0.58, 0.86]:
			if commit >= marker:
				var p = origin.lerp(target, marker)
				draw_line(p - side * 8, p + side * 8, Color(PAPER, fade * 0.75), 2, true)

func draw_mortar_attack(effect: Dictionary, color: Color, progress: float, fade: float):
	draw_manifested_mortar(effect, progress, fade)
	var origin: Vector2 = effect.from
	var target: Vector2 = effect.to
	var travel = clampf((progress - 0.10) / 0.42, 0.0, 1.0)
	var direction = (target - origin).normalized()
	if direction == Vector2.ZERO: direction = Vector2.RIGHT
	var control = origin.lerp(target, 0.5) + direction.orthogonal() * -90.0
	var path = PackedVector2Array()
	for step in range(13): path.append(quadratic_point(origin, control, target, step / 12.0))
	draw_polyline(path, Color(color, fade * 0.22), 1, true)
	var shell = quadratic_point(origin, control, target, travel)
	draw_colored_polygon(PackedVector2Array([shell + Vector2(0, -5), shell + Vector2(5, 2), shell + Vector2(0, 5), shell + Vector2(-5, 2)]), Color(PAPER, fade))
	if travel < 0.98: return
	var radius = float(effect.get("range", 60)) * clampf((progress - 0.46) / 0.34, 0.0, 1.0)
	var repair = effect.shape == "consecrated"
	var seal_color = GREEN if repair else color
	draw_circle(target, radius, Color(seal_color, fade * 0.09))
	for side in range(4):
		var a = target + Vector2.from_angle(side * PI / 2.0 + PI / 4.0) * radius
		var b = target + Vector2.from_angle((side + 1) * PI / 2.0 + PI / 4.0) * radius
		draw_line(a, b, Color(seal_color, fade * 0.88), 4, true)
	if effect.shape == "benediction":
		var inner = radius * 0.58
		for side in range(4):
			var a = target + Vector2.from_angle(side * PI / 2.0) * inner
			var b = target + Vector2.from_angle((side + 1) * PI / 2.0) * inner
			draw_line(a, b, Color(PAPER, fade * 0.74), 2, true)
		for cardinal in range(4):
			var d = Vector2.from_angle(cardinal * PI / 2.0)
			draw_line(target + d * inner, target + d * radius, Color(GOLD, fade * 0.8), 3, true)
	if not reduced_fx:
		for index in range(8):
			var d = Vector2.from_angle(index * TAU / 8.0) * radius
			draw_line(target + d * 0.78, target + d, Color(GOLD, fade * 0.75), 2, true)

func draw_censer_attack(effect: Dictionary, color: Color, progress: float, fade: float):
	draw_manifested_censer(effect, progress, fade)
	var center: Vector2 = effect.to if effect.shape == "ashen_censer" else effect.from
	var radius = float(effect.range)
	var bloom = ease(clampf((progress - 0.08) / 0.46, 0.0, 1.0), -1.6)
	for layer in range(3 if not reduced_fx else 1):
		var layer_radius = radius * bloom * (0.72 + layer * 0.14)
		var layer_color = Color("b58ebd") if effect.shape == "ashen_censer" else color
		draw_circle(center + Vector2(layer * 5 - 5, -layer * 3), layer_radius, Color(layer_color, fade * (0.045 + layer * 0.018)))
		draw_arc(center, layer_radius, progress * (layer + 1), progress * (layer + 1) + PI * 1.45, 32, Color(layer_color, fade * 0.34), 2, true)
	if effect.shape == "ashen_censer": draw_line(effect.from, center, Color(color, fade * 0.24), 2, true)
	if not reduced_fx and bloom > 0.35:
		for index in range(7):
			var soot = center + Vector2.from_angle(index * TAU / 7.0 + progress) * radius * (0.25 + 0.55 * bloom)
			draw_circle(soot, 2 + index % 2, Color("2f292c", fade * 0.62))

func draw_winch_attack(effect: Dictionary, color: Color, progress: float, fade: float):
	draw_manifested_winch(effect, progress, fade)
	var origin: Vector2 = effect.from
	var target: Vector2 = effect.to
	var direction = (target - origin).normalized()
	if direction == Vector2.ZERO: direction = Vector2.RIGHT
	var side = direction.orthogonal()
	var extend = clampf((progress - 0.08) / 0.34, 0.0, 1.0)
	var retract = 1.0 - smoothstep(0.66, 1.0, progress)
	var reach = extend * retract
	if progress < 0.18:
		for segment in range(5):
			if segment % 2 == 0:
				var a = origin.lerp(target, segment / 5.0)
				var b = origin.lerp(target, (segment + 1) / 5.0)
				draw_line(a, b, Color(color, 0.28), 2, true)
	var head = origin.lerp(target, reach)
	var elbows = 5 if effect.shape == "long_hand" else 3
	for segment in range(elbows):
		var a = origin.lerp(head, segment / float(elbows)) + side * (6 if segment % 2 else -6)
		var b = origin.lerp(head, (segment + 1) / float(elbows)) + side * (6 if (segment + 1) % 2 else -6)
		draw_line(a, b, Color(color, fade * 0.78), 7 if effect.shape == "long_hand" else 5, true)
		draw_line(a, b, Color(PAPER, fade * 0.44), 2, true)
	draw_line(head, head - direction * 10 + side * 8, Color(PAPER, fade), 3, true)
	draw_line(head, head - direction * 10 - side * 8, Color(PAPER, fade), 3, true)
	if effect.shape == "long_hand":
		draw_line(origin + side * 13, head + side * 13, Color(color, fade * 0.16), 2, true)
		draw_line(origin - side * 13, head - side * 13, Color(color, fade * 0.16), 2, true)

func draw_halo_attack(effect: Dictionary, color: Color, progress: float, fade: float):
	var origin: Vector2 = effect.from
	var contacts: Array = [effect.to]
	if effect.shape == "repair_halo": contacts.append(effect.to2)
	var commit = clampf((progress - 0.10) / 0.34, 0.0, 1.0)
	draw_arc(origin, 31, -PI / 2, -PI / 2 + TAU * commit, 32, Color(color, fade * 0.55), 3, true)
	if effect.shape == "repair_halo": draw_arc(origin, 40, PI / 2, PI / 2 - TAU * commit, 36, Color(PAPER, fade * 0.42), 2, true)
	for index in range(contacts.size()):
		var contact: Vector2 = origin.lerp(contacts[index], ease(commit, -1.4))
		draw_circle(contact, 6 + progress * 5, Color(color, fade * 0.22))
		draw_arc(contact, 8 + progress * 7, 0, TAU, 18, Color(PAPER, fade * 0.78), 2, true)
		if progress > 0.42: draw_line(contact, origin, Color("c9f2c8", fade * (0.75 if effect.shape == "repair_halo" else 0.4)), 3 if effect.shape == "repair_halo" else 2, true)
	if effect.shape == "repair_halo" and progress > 0.52:
		draw_arc(origin, 18 + progress * 12, 0, TAU, 24, Color(GREEN, fade * 0.72), 3, true)

func draw_evolution_reconfiguration(effect: Dictionary, progress: float, fade: float):
	var position: Vector2 = effect.get("position", sim.state.position)
	var recipe = str(effect.get("recipe", ""))
	var radius = 24.0 + 36.0 * smoothstep(0.0, 0.72, progress)
	draw_arc(position, radius, -PI / 2, -PI / 2 + TAU * minf(1.0, progress * 1.7), 48, Color(GOLD, fade), 4, true)
	if recipe == "evolution.mercy_rail":
		for side in [-1, 1]: draw_line(position + Vector2(-18, side * 6), position + Vector2(38 + progress * 24, side * 6), Color(PAPER, fade * 0.9), 3, true)
	elif recipe == "evolution.great_toll":
		for cardinal in range(4):
			var marker = position + Vector2.from_angle(cardinal * PI / 2.0) * radius * 0.68
			draw_arc(marker, 7, 0, TAU, 14, Color(PAPER, fade * 0.85), 2, true)
	elif recipe == "evolution.maintenance_parade":
		for ring_radius in [radius * 0.55, radius]: draw_arc(position, ring_radius, 0, TAU * progress, 36, Color(GOLD, fade * 0.75), 2, true)
		for cardinal in range(4): draw_gear(position + Vector2.from_angle(cardinal * PI / 2.0 + progress) * radius * 0.75, 5, PAPER, progress * TAU)
	elif recipe == "evolution.candle_unreturned":
		for index in range(3):
			var flame = position + Vector2((index - 1) * 13, -10 - progress * 26)
			draw_circle(flame, 4, Color("cbb8ed", fade))
	elif recipe == "evolution.contrition_lattice":
		var points = [position + Vector2(0, -radius), position + Vector2(radius * 0.87, radius * 0.5), position + Vector2(-radius * 0.87, radius * 0.5)]
		for index in range(3): draw_line(points[index], points[(index + 1) % 3], Color("81b8d0", fade * 0.8), 3, true)
	elif recipe == "evolution.quiet_sermon":
		draw_line(position + Vector2(-radius, 0), position + Vector2(radius, 0), Color("bdeff0", fade * 0.85), 8, true)
		for offset in [-12, 12]: draw_line(position + Vector2(offset, -9), position + Vector2(offset, 9), Color(PAPER, fade), 2, true)
	elif recipe == "evolution.workshop_benediction":
		for side in range(4):
			var a = position + Vector2.from_angle(side * PI / 2.0 + PI / 4.0) * radius * 0.72
			var b = position + Vector2.from_angle((side + 1) * PI / 2.0 + PI / 4.0) * radius * 0.72
			draw_line(a, b, Color(GREEN, fade * 0.85), 4, true)
	elif recipe == "evolution.ashen_benediction":
		draw_circle(position + Vector2(progress * 26, 0), radius * 0.7, Color("5b3f61", fade * 0.22))
		draw_arc(position + Vector2(progress * 26, 0), radius * 0.7, 0, TAU, 32, Color("b58ebd", fade), 3, true)
	elif recipe == "evolution.long_hand":
		var elbow = position + Vector2(radius * 0.45, -radius * 0.25)
		draw_line(position - Vector2(radius * 0.5, 0), elbow, Color(GOLD, fade), 7, true)
		draw_line(elbow, position + Vector2(radius, radius * 0.18), Color(PAPER, fade * 0.85), 7, true)
	elif recipe == "evolution.halo_of_repairs":
		draw_arc(position, radius * 0.62, progress, progress + TAU * 0.82, 30, Color(GREEN, fade), 3, true)
		draw_arc(position, radius, -progress, -progress + TAU * 0.82, 40, Color(PAPER, fade * 0.8), 2, true)
	if not reduced_fx:
		for index in range(10):
			var spark_direction = Vector2.from_angle(index * TAU / 10.0 + progress)
			draw_circle(position + spark_direction * (12 + progress * 40), 2, Color(GOLD, fade * 0.8))

func draw_weapon_hit_aftermath(effect: Dictionary, progress: float, fade: float):
	var position: Vector2 = effect.position
	match str(effect.get("weapon", "")):
		"weapon.procession_gear":
			for tooth in range(4):
				var d = Vector2.from_angle(tooth * PI / 2.0 + progress)
				draw_line(position + d * 5, position + d * 10, Color("91c9b0", fade), 3, true)
		"weapon.candle_nailer":
			draw_line(position + Vector2(0, 5), position + Vector2(0, -4), Color("6f586f", fade), 2, true)
			draw_circle(position + Vector2(0, -7), 3 + progress * 2, Color("cbb8ed", fade))
		"weapon.cable_contrition":
			draw_arc(position, 10 + progress * 4, -PI * 0.75, PI * 0.75, 16, Color("81b8d0", fade), 2, true)
			for side in [-1, 1]: draw_line(position + Vector2(side * 8, -5), position + Vector2(side * 8, 5), Color(PAPER, fade * 0.7), 2, true)
		"weapon.hymn_coil":
			draw_line(position + Vector2(-8, -10), position + Vector2(8, -10), Color("8edce0", fade), 3, true)
			if progress > 0.45: draw_line(position + Vector2(-5, -14), position + Vector2(5, -6), Color(PAPER, fade * 0.7), 2, true)
		"weapon.altar_mortar":
			var size = 7 + progress * 5
			draw_rect(Rect2(position - Vector2(size, size), Vector2(size * 2, size * 2)), Color("e89765", fade), false, 2)
		"weapon.foundry_censer":
			draw_circle(position + Vector2(0, -progress * 12), 5 + progress * 3, Color("293431", fade * 0.55))
		"weapon.penance_winch":
			draw_line(position + Vector2(-7, -7), position + Vector2(7, 7), Color("d6b16d", fade), 3, true)
			draw_line(position + Vector2(7, -7), position + Vector2(-7, 7), Color(PAPER, fade * 0.65), 2, true)
		"weapon.welded_halo":
			draw_line(position + Vector2(-9, 0), position + Vector2(9, 0), Color("a9e0b1", fade), 3, true)
			for stitch in [-6, 0, 6]: draw_line(position + Vector2(stitch, -4), position + Vector2(stitch, 4), Color(PAPER, fade * 0.75), 2, true)

func draw_ellipse_shadow(p: Vector2, radii: Vector2):
	# Local circle shadow keeps the silhouette readable without physics ownership.
	draw_circle(p, radii.x, Color(0.02, 0.04, 0.05, 0.35))

func enemy_reaction_offset(enemy: Dictionary) -> Vector2:
	var offset = Vector2.ZERO
	for index in range(fx.size() - 1, -1, -1):
		var effect = fx[index]
		if effect.get("kind", "") != "hit" or not effect.get("position", null) is Vector2: continue
		if enemy.p.distance_to(effect.position) > enemy.radius + 18: continue
		var progress = presentation_progress(effect)
		var away = (enemy.p - sim.state.position).normalized()
		if away == Vector2.ZERO: away = Vector2.RIGHT
		offset += away * sin(progress * PI) * 7.0
		break
	if int(enemy.get("stun", 0)) > int(sim.state.tick): offset += Vector2(sin(sim.state.tick * 0.62) * 3.0, 1.5)
	if int(enemy.get("windup", 0)) > int(sim.state.tick):
		var brace = clampf(1.0 - float(enemy.windup - sim.state.tick) / 60.0, 0.0, 1.0)
		offset -= Vector2(enemy.get("charge", Vector2.ZERO)) * (3.0 + brace * 5.0)
	return offset

func draw_enemy(e):
	var p = e.p + enemy_reaction_offset(e)
	var color = Color("cb8565") if e.major else Color(sim.config.enemies[e.type].color)
	if e.flash > sim.state.tick: color = PAPER
	draw_circle(p + Vector2(0, 7), e.radius + 3, Color(0.02, 0.04, 0.05, 0.4))
	if e.major:
		if actor_art.assets.has(e.type): actor_art.draw_major(self,e,p,sim.state.tick,reduced_fx,sim.state.hazards)
		else:
			draw_gear(p, e.radius, color, sim.state.tick * 0.009)
			draw_rect(Rect2(p - Vector2(17, 12), Vector2(34, 24)), INK)
			for i in range(3): draw_circle(p + Vector2(-10 + i * 10, 0), 3, RED)
	else:
		if e.type == "enemy.choir_drone" and sim.enemy_support_ready(e):
			draw_circle(p, sim.config.enemy_rules.drone_field_radius, Color(0.6, 0.5, 0.8, 0.035))
			draw_arc(p, sim.config.enemy_rules.drone_field_radius, 0, TAU, 40, Color(0.6, 0.5, 0.8, 0.15), 1)
		actor_art.draw_enemy(self, e, p, sim.state.tick, reduced_fx)
		if e.type == "enemy.choir_drone":
			draw_arc(p, 29, sim.state.tick * 0.03, sim.state.tick * 0.03 + PI, 20, color, 1.5)
		if e.type in ["enemy.rivet_hound", "enemy.forklift_brute"] and e.windup > sim.state.tick:
			draw_line(p, p + e.charge * 135, RED, 3 if e.type == "enemy.forklift_brute" else 2, true)
			if e.type == "enemy.rivet_hound": draw_circle(p + e.charge * 135, 4, GOLD)
	if e.stun > sim.state.tick: draw_arc(p, e.radius + 6, 0, TAU, 24, GOLD, 2)
	if e.flash > sim.state.tick:
		draw_arc(p, e.radius + 9, -PI * 0.3, PI * 1.3, 20, Color(PAPER, 0.75), 3, true)
		for impact in range(3):
			var d = Vector2.from_angle(impact * TAU / 3.0 + sim.state.tick) * (e.radius + 6)
			draw_line(p + d * 0.65, p + d, Color(GOLD, 0.85), 2, true)
	if e.marked > sim.state.tick:
		draw_line(p + Vector2(-4, -e.radius - 17), p + Vector2(4, -e.radius - 9), GOLD, 2)
		draw_line(p + Vector2(4, -e.radius - 17), p + Vector2(-4, -e.radius - 9), GOLD, 2)
	if e.bound > sim.state.tick: draw_line(p, sim.state.position, Color("81b8d0"), 1.5)
	if e.get("slow", 0) > sim.state.tick: draw_arc(p, e.radius + 10, 0, TAU, 24, Color("74b9a6"), 2)
	if e.get("quieted", 0) > sim.state.tick:
		draw_arc(p, e.radius + 11, -PI * 0.75, PI * 0.75, 22, Color("8edce0"), 2)
		draw_line(p + Vector2(-7, -e.radius - 14), p + Vector2(7, -e.radius - 14), Color("8edce0"), 2)
	elif e.get("support_lock_until", 0) > sim.state.tick:
		draw_arc(p, e.radius + 11, -PI * 0.72, PI * 0.72, 22, Color("8edce0"), 2)
		draw_line(p + Vector2(-7, -e.radius - 15), p + Vector2(7, -e.radius - 9), Color("8edce0"), 2)
		draw_line(p + Vector2(7, -e.radius - 15), p + Vector2(-7, -e.radius - 9), Color("8edce0"), 2)
		text_at("FILTERED", p + Vector2(-24, -e.radius - 21), 8, Color("8edce0"))
	if e.get("inspected", false):
		draw_arc(p, e.radius + 14, 0, TAU, 28, Color("8edce0"), 2)
		text_at("PRIORITY", p + Vector2(-25, -e.radius - 19), 9, Color("8edce0"))
	if e.get("relay_strike_at", 0) > sim.state.tick and e.stun <= sim.state.tick:
		var charge = 1.0 - float(e.relay_strike_at - sim.state.tick) / (sim.config.relay.strike_warning_ticks * sim.warning_multiplier())
		draw_line(p, sim.relay_position(), Color(0.9, 0.4, 0.3, 0.6), 2)
		draw_arc(p, e.radius + 7, -PI / 2, -PI / 2 + TAU * maxf(0.01, charge), 24, RED, 3)
		text_at("!", p + Vector2(-3, -e.radius - 13), 14, RED)
	if e.hp < e.max_hp: bar(Rect2(p + Vector2(-15, -e.radius - 9), Vector2(30, 3)), e.hp / e.max_hp, color)

func draw_effect(e):
	var gift_id = gift_event_id(e)
	var progress = presentation_progress(e)
	var fade = presentation_fade(e)
	var color = Color(e.get("color", "e9dec2"))
	color.a = fade
	if gift_id != "":
		var position = e.get("position", sim.state.position)
		if not position is Vector2: position = sim.state.position
		match gift_id:
			"gift.loose_spring":
				for i in range(3):
					var offset = Vector2(-24 + i * 12, 18 - i * 5)
					draw_line(position + offset, position + offset + Vector2(-16, 8), Color(0.56, 0.86, 0.72, fade), 3, true)
				draw_arc(position, 28 + (1.0 - fade) * 14, -PI * 0.1, PI * 1.1, 24, Color(0.56, 0.86, 0.72, fade), 2)
			"gift.choir_filter":
				draw_arc(position, 30 + (1.0 - fade) * 8, -PI * 0.72, PI * 0.72, 24, Color(0.56, 0.86, 0.88, fade), 3)
				draw_line(position + Vector2(-9, -10), position + Vector2(9, 10), Color(0.74, 0.94, 0.95, fade), 3)
				draw_line(position + Vector2(9, -10), position + Vector2(-9, 10), Color(0.74, 0.94, 0.95, fade), 3)
			"gift.brass_fuse":
				draw_line(sim.state.position, position, Color(1.0, 0.69, 0.25, fade * 0.5), 2, true)
				for i in range(6):
					var spark = Vector2.from_angle(i * TAU / 6.0 + e.tick) * (8 + (1.0 - fade) * 12)
					draw_line(position + spark * 0.55, position + spark, Color(1.0, 0.75, 0.35, fade), 2)
		return
	match e.kind:
		"attack":
			match e.shape:
				"line", "rail":
					if str(e.get("weapon", "")) == "weapon.nailer_small_mercies": draw_nailer_attack(e, color, progress, fade)
					else:
						draw_line(e.from, e.to, color, 5 if e.shape == "rail" else 2, true)
						if e.shape == "rail": draw_line(e.from, e.to, Color(1, 0.98, 0.85, fade), 2, true)
				"shot":
					if str(e.get("weapon", "")) == "weapon.candle_nailer": draw_candle_attack(e, color, progress, fade)
					else:
						for line_target in e.get("targets", []): draw_line(e.from, line_target, color, 2, true)
				"beam":
					if str(e.get("weapon", "")) == "weapon.hymn_coil": draw_hymn_attack(e, color, progress, fade)
					else: draw_line(e.from, e.to, color, 5, true)
				"blast":
					if str(e.get("weapon", "")) == "weapon.altar_mortar": draw_mortar_attack(e, color, progress, fade)
					else:
						draw_line(e.from, e.to, Color(color, fade * 0.4), 1)
						draw_circle(e.to, e.range * (1.0 - fade * 0.35), Color(color, fade * 0.2))
						draw_arc(e.to, e.range * (1.0 - fade * 0.35), 0, TAU, 32, color, 3)
				"cone":
					if str(e.get("weapon", "")) == "weapon.bell_last_shift": draw_bell_attack(e, color, progress, fade)
					else:
						var angle = (e.to - e.from).angle()
						var half_width = float(e.get("width", 0.8))
						draw_arc(e.from, e.range * (1 - fade * 0.4), angle - half_width, angle + half_width, 24, color, 3, true)
				"tether":
					if str(e.get("weapon", "")) == "weapon.cable_contrition": draw_cable_attack(e, color, progress, fade)
					else:
						var angle = (e.to - e.from).angle()
						var half_width = float(e.get("width", 0.8))
						draw_arc(e.from, e.range * (1 - fade * 0.4), angle - half_width, angle + half_width, 24, color, 3, true)
				"orbit":
					if str(e.get("weapon", "")) == "weapon.procession_gear": draw_procession_attack(e, color, progress, fade)
					else:
						for contact in e.get("targets", [e.to]): draw_arc(contact, 23 * (2 - fade), 0, TAU, 20, color, 2)
				"censer":
					if str(e.get("weapon", "")) == "weapon.foundry_censer": draw_censer_attack(e, color, progress, fade)
					else:
						draw_circle(e.from, e.range, Color(color, fade * 0.06))
						draw_arc(e.from, e.range * (1.0 - fade * 0.08), 0, TAU, 44, color, 3)
				"winch":
					if str(e.get("weapon", "")) == "weapon.penance_winch": draw_winch_attack(e, color, progress, fade)
					else: draw_line(e.from, e.to, color, 5, true)
				"halo":
					if str(e.get("weapon", "")) == "weapon.welded_halo": draw_halo_attack(e, color, progress, fade)
					else:
						draw_arc(e.from, 31, 0, TAU, 28, Color(color, fade * 0.65), 2)
						draw_line(e.from, e.to, Color(0.75, 1.0, 0.78, fade), 2, true)
						draw_arc(e.to, 11, 0, TAU, 16, color, 2)
				"radial":
					if str(e.get("weapon", "")) == "weapon.bell_last_shift": draw_bell_attack(e, color, progress, fade)
					else:
						draw_circle(e.from, e.range * (1.0 - fade * 0.2), Color(color, fade * 0.055))
						draw_arc(e.from, e.range * (1.0 - fade * 0.2), 0, TAU, 64, color, 6, true)
						for i in range(4): draw_arc(e.from + Vector2.from_angle(i * PI / 2) * e.range * 0.55, 13, 0, TAU, 18, PAPER, 2)
				"ashen_censer":
					draw_censer_attack(e, color, progress, fade)
				"long_hand":
					draw_winch_attack(e, color, progress, fade)
				"repair_halo":
					draw_halo_attack(e, color, progress, fade)
				"funeral_shots":
					draw_candle_attack(e, color, progress, fade)
				"sermon":
					draw_hymn_attack(e, color, progress, fade)
				"benediction", "consecrated":
					draw_mortar_attack(e, color, progress, fade)
				"parade":
					draw_procession_attack(e, color, progress, fade)
				"lattice":
					draw_cable_attack(e, color, progress, fade)
		"charge": draw_line(e.from, e.to, Color(0.9, 0.8, 0.5, fade * 0.35), 1)
		"hit", "death":
			var particle_count = 2 if reduced_fx else (7 if str(e.get("weapon", "")) != "" else 4)
			for i in range(particle_count):
				var d = Vector2.from_angle(i * TAU / particle_count + e.tick)
				draw_line(e.position + d * 3, e.position + d * (7 + (1 - fade) * 13), color, 2)
			if e.kind == "hit": draw_weapon_hit_aftermath(e, progress, fade)
			if e.kind == "hit" and str(e.get("weapon", "")) == "weapon.nailer_small_mercies" and progress > 0.35:
				draw_line(e.position + Vector2(-5, 0), e.position + Vector2(5, 0), Color(PAPER, fade), 2, true)
				draw_line(e.position + Vector2(0, -5), e.position + Vector2(0, 5), Color(PAPER, fade), 2, true)
			if e.kind == "hit" and str(e.get("weapon", "")) == "weapon.bell_last_shift" and progress > 0.28:
				draw_arc(e.position, 8 + progress * 9, 0, TAU, 18, Color(GOLD, fade * 0.8), 2, true)
		"evolution": draw_evolution_reconfiguration(e, progress, fade)
		"repair":
			draw_arc(e.position, 37 + (1 - fade) * 10, 0, TAU, 24, Color(0.6, 0.9, 0.7, fade), 2)
			if e.get("source") != null: draw_line(e.source, e.position, Color(0.6, 0.9, 0.7, fade), 2, true)
		"blast": draw_circle(e.position, e.radius, Color(0.9, 0.5, 0.3, fade * 0.25))
		"relay_hurt":
			draw_arc(e.position, 38 + (1 - fade) * 12, 0, TAU, 24, RED, 3)
			text_at("-%d" % e.amount, e.position + Vector2(35, -25 - (1 - fade) * 12), 14, RED)
		"hurt": draw_arc(e.position, 28, 0, TAU, 24, Color(1, 0.4, 0.3, fade), 3)

func draw_loadout():
	panel(Rect2(1052, 158, 200, 578))
	if sim.state.service_active or sim.state.calibrated:
		var active = "CALIBRATED" if sim.state.calibrated else sim.config.shop_rules.services[sim.state.doctrine].name.to_upper()
		text_at(active, Vector2(1068, 714), 10, GOLD)
	text_at("YOUR RELICS", Vector2(1068, 187), 12, GOLD)
	for i in range(sim.state.weapons.size()):
		var w = sim.state.weapons[i]
		var data = sim.config.weapons[w.id]
		var y = 219 + i * 79
		text_at("%02d" % (i + 1), Vector2(1068, y), 12, MUTED)
		var evolution_id = sim.weapon_evolution_id(w)
		var evolved_name = sim.config.evolution_rules[evolution_id].short if evolution_id in sim.config.evolution_rules else data.short
		text_at(evolved_name, Vector2(1095, y), 14, Color(data.color))
		text_at("RANK " + ["I", "II", "III"][w.rank - 1] + (" · EVOLVED" if sim.weapon_evolved(w) else ""), Vector2(1095, y + 20), 11, MUTED)
		var rank_summary = sim.weapon_rank_summary(w)
		if rank_summary != "": text_at(rank_summary, Vector2(1095, y + 37), 9, GREEN if w.rank == 2 else GOLD)
	text_at("RESERVE", Vector2(1068, 539), 11, GOLD)
	if not sim.state.reserve.is_empty(): text_at(sim.config.weapons[sim.state.reserve[0].id].short, Vector2(1068, 558), 12)
	else: text_at("One open place", Vector2(1068, 558), 12, MUTED)
	var gifts_y = 638 if sim.state.phase == "shop" else 589
	text_at("GIFTS  %d / %d" % [sim.state.gifts.size(), sim.config.gift_slots], Vector2(1068, gifts_y), 11, GOLD)
	for i in range(sim.state.gifts.size()):
		var gift_id = str(sim.state.gifts[i])
		var line_y = gifts_y + 21 + i * (40 if sim.state.phase == "shop" else 29)
		text_at(sim.config.gifts[gift_id].short, Vector2(1068, line_y), 10, Color("8edce0"))
		if sim.state.phase != "shop": text_at(gift_activity_label(gift_id), Vector2(1068, line_y + 12), 8, gift_activity_color(gift_id))
	if sim.state.phase != "shop":
		text_at("DOCTRINE / " + ("FULFILLED" if sim.state.fulfilled else "TAKING SHAPE"), Vector2(1068, 674), 10, GOLD)
		if sim.state.inspection != "": wrapped("LENS / " + sim.state.inspection, Vector2(1068, 691), 170, 9, Color("8edce0"))
		else: text_at("%d machines laid to rest" % sim.state.kills, Vector2(1068, 695), 10, MUTED)

func gift_activity_label(gift_id: String) -> String:
	match gift_id:
		"gift.loose_spring":
			var remaining = maxi(0, int(sim.state.get("loose_spring_until", 0)) - int(sim.state.tick))
			return "BURST · %.1fs" % (float(remaining) / float(sim.config.tick_rate)) if remaining > 0 else "WINDS ON REPAIR"
		"gift.honest_scale": return "READING OFFERS" if sim.state.phase == "shop" else "WORKSHOP TOOL"
		"gift.choir_filter":
			var held = sim.state.enemies.any(func(enemy): return int(enemy.get("support_lock_until", 0)) > int(sim.state.tick))
			return "SUPPORT HELD" if held else "FILTER READY"
		"gift.brass_fuse":
			return "FUSE SPENT" if str(sim.state.get("brass_fuse_segment", "")) == sim.site_wave_key() else "FUSE READY"
	return "CARRIED"

func gift_activity_color(gift_id: String) -> Color:
	if gift_id == "gift.loose_spring" and int(sim.state.get("loose_spring_until", 0)) > int(sim.state.tick): return GREEN
	if gift_id == "gift.choir_filter" and sim.state.enemies.any(func(enemy): return int(enemy.get("support_lock_until", 0)) > int(sim.state.tick)): return Color("8edce0")
	if gift_id == "gift.brass_fuse" and str(sim.state.get("brass_fuse_segment", "")) != sim.site_wave_key(): return GOLD
	return MUTED

func wrapped(value: String, p: Vector2, width: float, size = 14, color = MUTED):
	var line = ""
	var row = 0
	for word in value.split(" "):
		var proposed = line + (" " if line != "" else "") + word
		if font.get_string_size(proposed, HORIZONTAL_ALIGNMENT_LEFT, -1, int(size * ui_scale)).x > width and line != "":
			text_at(line, p + Vector2(0, row * 20), size, color)
			line = word
			row += 1
		else: line = proposed
	if line != "": text_at(line, p + Vector2(0, row * 20), size, color)

func wrapped_limited(value: String, p: Vector2, width: float, size: int, color: Color, max_rows: int, line_height: int):
	var words = value.split(" ")
	var line = ""
	var row = 0
	for index in range(words.size()):
		var word = words[index]
		var proposed = line + (" " if line != "" else "") + word
		if font.get_string_size(proposed, HORIZONTAL_ALIGNMENT_LEFT, -1, int(size * ui_scale)).x <= width or line == "":
			line = proposed
			continue
		text_at(line, p + Vector2(0, row * line_height), size, color)
		row += 1
		if row >= max_rows:
			return
		line = word
		if row == max_rows - 1 and index < words.size() - 1:
			while font.get_string_size(line + "…", HORIZONTAL_ALIGNMENT_LEFT, -1, int(size * ui_scale)).x > width and line.length() > 1:
				line = line.substr(0, line.length() - 1)
			text_at(line + "…", p + Vector2(0, row * line_height), size, color)
			return
	if line != "" and row < max_rows: text_at(line, p + Vector2(0, row * line_height), size, color)

func honest_scale_preview_text(index: int) -> String:
	if not sim.has_gift("gift.honest_scale") or not sim.has_method("purchase_preview"): return ""
	var preview = sim.purchase_preview(index)
	if not preview is Dictionary or preview.is_empty(): return ""
	var result = str(preview.get("result", preview.get("result_code", "INVALID_OFFER")))
	if result != "OK": return "AFTER / " + result.replace("_", " ")
	var active = int(preview.get("active_count", preview.get("active", sim.state.weapons.size())))
	var reserve = int(preview.get("reserve_count", preview.get("reserve", sim.state.reserve.size())))
	var summary = "AFTER / %d ACTIVE · %d RESERVE" % [active, reserve]
	var combines = preview.get("combines", preview.get("combine_results", []))
	if combines is Array and not combines.is_empty():
		var combined = combines.back()
		var weapon_id = str(combined.get("weapon_id", combined.get("weapon", combined.get("id", "")))) if combined is Dictionary else ""
		var rank = int(combined.get("rank", 0)) if combined is Dictionary else 0
		var weapon_name = sim.config.weapons.get(weapon_id, {}).get("short", weapon_id)
		summary += " · COMBINE %s %s" % [weapon_name, ["", "I", "II", "III"][clampi(rank, 0, 3)]]
	return summary

func draw_shop():
	draw_rect(Rect2(60, 148, 980, 588), Color("14272b"))
	text_at("The relic workshop", Vector2(108, 189), 29, PAPER, true)
	var forecast = sim.forecast_data()
	text_at("Next: %s · %s" % [forecast.name, " / ".join(forecast.counters)], Vector2(483, 186), 14, GREEN)
	for i in range(6):
		var id = sim.state.offers[i]
		var x = 94 + (i % 3) * 302
		var y = 208 + int(i / 3) * 192
		panel(Rect2(x, y, 290, 176), Color("203538"))
		if id == "":
			text_at("Put to good use.", Vector2(x + 16, y + 42), 20, MUTED, true)
			continue
		var name_text = ""
		var description = ""
		var price = ""
		if id in sim.config.weapons:
			name_text = sim.config.weapons[id].short
			description = sim.config.weapons[id].role + " Weakness: " + sim.config.weapons[id].weakness
			price = "%d SCRAP · RANK I" % sim.catalogue[id].cost_scrap
		elif id in sim.config.catalysts:
			name_text = sim.config.catalysts[id].short
			description = sim.config.catalysts[id].description
			if sim.optional_mode() and id == "catalyst.saints_rivet": description = "Repair machines 25% faster. Rank III Nailer can evolve."
			price = "2 RELIC SHARDS"
		elif id in sim.config.gifts:
			name_text = sim.config.gifts[id].short
			description = sim.config.gifts[id].description
			price = "%d SCRAP · GIFT" % sim.catalogue[id].cost_scrap
		else:
			if id == "service.repair":
				name_text = "A little maintenance"
				description = "Restore 30 Saint integrity." if sim.optional_mode() else "Restore 30 integrity to you and the relay."
			elif id == "service.calibrate":
				name_text = "Tune the mechanisms"
				description = "Next wave: weapon cooldowns are 10% shorter. Once per visit."
			else:
				name_text = sim.config.shop_rules.services[sim.state.doctrine].name
				description = sim.config.shop_rules.services[sim.state.doctrine].description
				if sim.optional_mode() and sim.state.doctrine == 0: description = "Restore 45 Saint integrity."
				if sim.optional_mode() and sim.state.doctrine == 1: description = "Next wave: demolition warnings last 50% longer."
				if sim.state.doctrine == 3: description = "Next wave: orbiting relics travel 35% farther."
			price = "%d SCRAP / SERVICE" % (sim.config.shop_rules.services[sim.state.doctrine].cost if id == "service.doctrine" else sim.config.economy.repair_cost)
		text_at((sim.config.shop_rules.relic_roles[i] if sim.optional_mode() else sim.config.shop_rules.roles[i]) + (" / LOCKED" if sim.state.locked == id else ""), Vector2(x + 16, y + 16), 9, MUTED)
		text_at(price, Vector2(x + 16, y + 33), 10, GOLD)
		text_at(name_text, Vector2(x + 16, y + 60), 19, PAPER, true)
		wrapped_limited(description, Vector2(x + 16, y + 80), 252, 10, MUTED, 3, 14)
		var preview_text = honest_scale_preview_text(i)
		if preview_text == "":
			var projection = sim.purchase_preview(i)
			if projection.result != "OK": preview_text = str(projection.result).replace("_", " ")
			elif not projection.combines.is_empty(): preview_text = "COMBINES INTO A HIGHER RANK"
		if preview_text != "": text_at(preview_text, Vector2(x + 16, y + 125), 9, GREEN if sim.purchase_preview(i).get("result", "") == "OK" else RED)
	text_at("Gifts are unique support rules · seven designs · carry two.", Vector2(108, 685), 13, MUTED)
	text_at("Open the Evolution Ledger to inspect every recipe, ingredient and readiness state.", Vector2(108, 714), 11, GOLD)

func draw_evolution_ledger():
	draw_rect(Rect2(60, 148, 980, 588), Color("101f24"))
	text_at("Evolution Ledger", Vector2(88, 181), 28, PAPER, true)
	text_at("Rank III + one named catalyst. Every higher form remains optional.", Vector2(365, 179), 13, MUTED)
	for i in range(sim.config.evolutions.size()):
		var recipe_id = sim.config.evolutions[i]
		var recipe = sim.evolution_recipes[recipe_id]
		var x = 82 + (i % 2) * 470
		var y = 194 + int(i / 2) * 88
		panel(Rect2(x, y, 448, 78), Color("203538"))
		text_at(recipe.name.to_upper(), Vector2(x + 14, y + 18), 13, GOLD)
		text_at(sim.config.weapons[recipe.base_item_id].short + " III  +  " + sim.config.catalysts[recipe.required_catalyst_id].short, Vector2(x + 14, y + 37), 10, PAPER)
		var state_label = sim.evolution_recipe_state(recipe_id)
		text_at(state_label, Vector2(x + 14, y + 60), 10, GREEN if state_label == "READY" or state_label == "COMPLETED" else MUTED)
		text_at(str(recipe.result_geometry).replace("_", " "), Vector2(x + 118, y + 60), 10, MUTED)
	text_at("The Ledger names transformations; it never commits one without the EVOLVE command.", Vector2(88, 662), 12, MUTED)

func draw_results():
	draw_rect(Rect2(60, 148, 1192, 588), Color(0.04, 0.08, 0.09, 0.97))
	var won = sim.state.phase == "won"
	text_at("SHIFT COMPLETE" if won else "THE SHIFT FALLS SILENT", Vector2(220, 237), 14, GOLD)
	text_at("A road remembers you." if won and sim.state.chapter_complete else ("A small miracle." if won else "Even saints need repairs."), Vector2(216, 305), 46, PAPER, true)
	wrapped(sim.state.last_reason, Vector2(220, 350), 850, 18, GREEN if won else RED)
	var summary = sim.state.result_summary
	var outcome_line = ("%d stopped  ·  %d Scrap  ·  %d optional repairs" % [sim.state.kills, sim.state.scrap, summary.get("repairs", []).size()]) if sim.optional_mode() else ("%d stopped  ·  %d Scrap  ·  %d%% relay repaired" % [sim.state.kills, sim.state.scrap, sim.state.progress * 100 / sim.config.relay.required_ticks])
	if sim.state.chapter_complete: outcome_line += "  ·  " + sim.current_route().name
	text_at(outcome_line, Vector2(220, 402), 16)
	var top = summary.get("top_weapon", "")
	var top_name = sim.config.weapons[top].short if top in sim.config.weapons else "No relic recorded"
	text_at("MOST WORK  %s · %d damage" % [top_name, int(summary.get("top_weapon_damage", 0))], Vector2(220, 440), 14, GOLD)
	text_at("BLESSING  %s     EVOLUTION  %s" % ["FULFILLED" if summary.get("blessing_fulfilled", false) else "UNFULFILLED", str(summary.get("evolution", "")).replace("_", " ")], Vector2(220, 469), 13, MUTED)
	var result_gift_ids = summary.get("gift_ids", sim.state.gifts)
	var gift_line = "GIFTS  " + ("NONE" if result_gift_ids.is_empty() else ", ".join(result_gift_ids.map(func(id): return sim.config.gifts[id].short)))
	var gift_metrics = summary.get("gift_metrics", {})
	var gift_actions: Array[String] = []
	if int(gift_metrics.get("loose_spring_triggers", 0)) > 0: gift_actions.append("spring %d" % int(gift_metrics.loose_spring_triggers))
	if int(gift_metrics.get("choir_filter_applications", 0)) > 0: gift_actions.append("filter %d" % int(gift_metrics.choir_filter_applications))
	if int(gift_metrics.get("brass_fuse_triggers", 0)) > 0: gift_actions.append("fuse %d" % int(gift_metrics.brass_fuse_triggers))
	if not gift_actions.is_empty(): gift_line += " · " + " · ".join(gift_actions)
	text_at(gift_line, Vector2(220, 492), 12, Color("8edce0"))
	var road = summary.get("road_totals", {})
	if not summary.get("road_history", []).is_empty():
		text_at("ROAD  %d decisions · %+d Scrap · %+d Structure" % [summary.road_history.size(), int(road.get("scrap_delta", 0)), int(road.get("structure_delta", 0))], Vector2(220, 515), 12, GREEN)
	if not won:
		var loss_segment = str(summary.get("worst_damage_segment", "wave " + str(summary.get("worst_damage_wave", 0)))).replace("site.", "").replace(":wave_", " / wave ").replace("_", " ")
		text_at("PRIMARY CAUSE  " + summary.get("failure_cause", "UNCLASSIFIED") + " · largest loss " + loss_segment, Vector2(220, 534), 14, RED)
	wrapped(summary.get("replay_cue", "Try one clear change next shift."), Vector2(220, 545), 820, 17, PAPER)
	var memory_copy = sim.current_route().memory.text if won and sim.state.chapter_complete else "MEMORY 01 / A stranger gave this arm a sound joint and asked for nothing. The grace of that repair is still here. It is part of what woke you."
	wrapped(memory_copy, Vector2(220, 603), 820, 14, MUTED)
	if not recent_unlocks.is_empty():
		text_at("NEW OPTIONS  " + ", ".join(recent_unlocks.map(func(id): return str(id).get_slice(".", 1).replace("_", " ").to_upper())), Vector2(220, 638), 11, GOLD)

func capture_sequence():
	# Reproducible visual fixtures exercise real simulation commands; not a human playthrough.
	var names = ["WORKSHOP_BLESSING_SELECT", "RELAY_REPAIR_WAVE", "SHOP_MERCY_RAIL_PATH", "MERCY_RAIL_EVOLUTION", "FOREMAN_ENGINE_PHASE_TWO", "RESULTS_MEMORY_FRAGMENT", "RELAY_THREAT_WARNING"]
	if capture_step == 1:
		begin()
		sim.enter_shop()
		sim.state.scrap = 150 # explicit visual-fixture budget
		for id in ["weapon.bell_last_shift", "weapon.procession_gear"]:
			sim.state.offers[1] = id
			sim.command("buy", 1)
		sim.command("continue")
		for i in range(700):
			var desired = sim.relay_position() + Vector2.from_angle(i * 0.02) * 62
			sim.step((desired - sim.state.position).limit_length())
		for event in sim.events: present(event)
	if capture_step == 2:
		sim.enter_shop()
		sim.state.shards = 3
	if capture_step == 3:
		for i in range(3):
			sim.state.offers[0] = "weapon.nailer_small_mercies"
			sim.command("buy", 0)
		sim.state.offers[2] = "catalyst.saints_rivet"
		sim.command("buy", 2)
		sim.command("evolve")
		sim.command("continue")
		sim.state.enemies.clear()
		sim.spawn(sim.config.elite)
		sim.state.enemies[0].p = Vector2(600, 310)
		sim.state.relay_hp = 140
		for i in range(180):
			sim.step(Vector2.ZERO)
			if sim.events.any(func(e): return e.kind == "attack" and e.get("shape") == "rail"): break
		for event in sim.events: present(event)
	if capture_step == 4:
		fx.clear()
		sim.state.enemies.clear()
		sim.state.hazards.clear()
		sim.state.wave = 8
		sim.state.boss_spawned = false
		sim.state.hp = 100
		sim.state.relay_hp = 180
		sim.step(Vector2.ZERO)
		for enemy in sim.state.enemies:
			if enemy.major: enemy.hp = enemy.max_hp * 0.6
		for i in range(215):
			sim.step(Vector2.ZERO)
			if sim.state.hazards.size() >= 3: break
	if capture_step == 5:
		sim.state.phase = "won"
		sim.state.last_reason = "The relay sings again."
		sim.state.progress = sim.config.relay.required_ticks
	if capture_step == 6:
		fx.clear()
		sim.start(1, 147)
		sim.state.wave = 2
		sim.state.position = sim.relay_position() + Vector2(0, 82)
		sim.state.relay_hp = 48 # explicit warning/critical presentation fixture
		sim.spawn("enemy.rivet_hound")
		var enemy = sim.state.enemies[0]
		enemy.p = sim.relay_position() + Vector2(-30, 0)
		sim.update_relay_strike(enemy, 7)
		sim.state.tick = 30 # halfway through the authoritative warning
	build_ui()
	queue_redraw()
	await RenderingServer.frame_post_draw
	var path = capture_dir.path_join(names[capture_step] + ".png")
	get_viewport().get_texture().get_image().save_png(path)
	print("CAPTURE ", path)
	capture_step += 1
	if capture_step == names.size(): get_tree().quit()
