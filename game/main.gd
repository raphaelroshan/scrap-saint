extends Node2D
const Sim = preload("res://game/simulation.gd")
const Sound = preload("res://game/sound.gd")
const INK = Color("101e23")
const PANEL = Color("17292d")
const PAPER = Color("e9dec2")
const MUTED = Color("8da49d")
const GOLD = Color("dfb56b")
const GREEN = Color("8ecdb2")
const RED = Color("e48b73")
var sim = Sim.new()
var sound
var screen = "menu"
var chosen = 0
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
var capture_step = 0
var rendered_frames = 0
var last_phase = ""
var seed_value = 147
var ui_scale = 1.0
var save_path = "user://first_shift.save"
var dev_mode = false
var simulation_speed = 1

func _ready():
	title_font.font_names = PackedStringArray(["Georgia", "DejaVu Serif"])
	sound = Sound.new()
	add_child(sound)
	ui = Control.new()
	add_child(ui)
	for arg in OS.get_cmdline_user_args():
		if arg == "--dev-speed=5":
			dev_mode = true
			simulation_speed = 5
		if arg.begins_with("--capture-dir="):
			capture_dir = arg.trim_prefix("--capture-dir=")
			run_mode = "relay"
			debug_visible = true
			DirAccess.make_dir_recursive_absolute(capture_dir)
	build_ui()

func _physics_process(_delta):
	if screen == "game" and not sim.state.is_empty():
		var movement = Vector2(float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)), float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP)))
		if Input.get_connected_joypads().size() > 0:
			var pad = Input.get_connected_joypads()[0]
			var stick = Vector2(Input.get_joy_axis(pad, JOY_AXIS_LEFT_X), Input.get_joy_axis(pad, JOY_AXIS_LEFT_Y))
			if stick.length() > 0.2: movement = stick
		advance_simulation(movement)
		if sim.state.phase != last_phase:
			last_phase = sim.state.phase
			build_ui()
	fx = fx.filter(func(e): return Time.get_ticks_msec() < e.expires)
	queue_redraw()

func advance_simulation(movement: Vector2):
	# Preserve fixed-tick rules and every substep's events. Never fast-forward menus.
	for substep in range(simulation_speed):
		if sim.state.is_empty() or sim.state.phase != "combat" or sim.state.paused: break
		sim.step(movement)
		for event in sim.events: present(event)

func _process(_delta):
	if capture_dir != "":
		rendered_frames += 1
		if rendered_frames in [3, 15, 27, 39, 51, 63, 75]:
			capture_sequence()

func _unhandled_key_input(event):
	if not event.pressed or event.echo: return
	if event.keycode == KEY_F3: debug_visible = not debug_visible
	if event.keycode == KEY_F6 and dev_mode:
		simulation_speed = 1 if simulation_speed == 5 else 5
	if event.keycode == KEY_M:
		sound.muted = not sound.muted
		build_ui()
	if event.keycode == KEY_ESCAPE and screen == "game":
		sim.command("pause")
		build_ui()
	if event.keycode == KEY_F5 and screen == "game": save_run()
	if event.keycode == KEY_F9: load_run()

func _input(event):
	if event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_START and screen == "game":
		sim.command("pause")
		build_ui()

func begin():
	# Fixed seed makes the two objective modes directly comparable.
	sim.start(chosen, seed_value, run_mode)
	screen = "game"
	last_phase = "combat"
	fx.clear()
	build_ui()

func act(action: String, value = null):
	sim.events.clear()
	var result = sim.command(action, value)
	for event in sim.events: present(event)
	notification = result.replace("_", " ").capitalize() if result != "OK" else ""
	notice_until = Time.get_ticks_msec() + 2500
	if action == "evolve" and result == "OK":
		notification = ("THE GREAT TOLL — every direction answers" if str(value) == "evolution.great_toll" else "MERCY RAIL — a new shape of mercy")
		notice_until = Time.get_ticks_msec() + 4500
	build_ui()

func save_run():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_var(sim.snapshot())
		notification = "Shift saved. F9 to resume."
	else: notification = "Could not write save."
	notice_until = Time.get_ticks_msec() + 2500

func load_run():
	if not FileAccess.file_exists(save_path): return
	var file = FileAccess.open(save_path, FileAccess.READ)
	var saved = file.get_var(false)
	if saved is Dictionary and sim.restore(saved):
		screen = "game"
		fx.clear()
		build_ui()

	else:
		notification = "This save predates the workshop layout. Start a new shift."
		notice_until = Time.get_ticks_msec() + 6000

func present(event):
	var e = event.duplicate(true)
	e.expires = Time.get_ticks_msec() + (480 if e.kind in ["repair", "death", "blast"] else 230)
	if fx.size() < (60 if reduced_fx else 160): fx.append(e)
	if e.kind == "machine_restored":
		notification = "RESTORED / " + e.reward
		notice_until = Time.get_ticks_msec() + 3000
	if e.kind == "attack": sound.play(e.shape)
	elif e.kind in ["hurt", "relay_hurt", "repair", "pickup"]: sound.play(e.kind)

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
	for child in ui.get_children():
		ui.remove_child(child)
		child.queue_free()
	if screen == "menu":
		if dev_mode: button("Optional repairs" if run_mode == "optional" else "Relay defence", Rect2(124, 278, 300, 34), func(): run_mode = "relay" if run_mode == "optional" else "optional"; build_ui())
		button("Seed %d / change seed" % seed_value, Rect2(440, 278, 320, 34), func(): seed_value = randi_range(1, 1000000); build_ui())
		for i in range(3):
			button("Choose " + ["Workshop", "Bell Ward", "Mourner"][i], Rect2(124 + i * 354, 522, 322, 42), func(): chosen = i; build_ui(), chosen == i)
		button("BEGIN THE FIRST SHIFT  →", Rect2(436, 613, 408, 52), begin, true).grab_focus()
		if FileAccess.file_exists(save_path): button("Resume saved shift", Rect2(436, 678, 408, 36), load_run)
	elif sim.state.phase == "shop":
		for i in range(6):
			var col = i % 3
			var row = int(i / 3)
			var x = 94 + col * 302
			var y = 208 + row * 192
			button("BUY / COMBINE" if i < 2 else "ACQUIRE", Rect2(x + 14, y + 129, 182, 32), func(): act("buy", i))
			button("◆" if sim.state.locked == sim.state.offers[i] and sim.state.offers[i] != "" else "Lock", Rect2(x + 205, y + 129, 66, 32), func(): act("lock", i))
		var costs = sim.config.economy.reroll_costs
		var refresh = "No refreshes left" if sim.state.rerolls >= costs.size() else ("Refresh · FREE" if costs[sim.state.rerolls] == 0 else "Refresh · %d Scrap" % costs[sim.state.rerolls])
		button(refresh, Rect2(108, 613, 220, 40), func(): act("reroll"))
		button("Mercy Rail", Rect2(344, 613, 120, 40), func(): act("evolve", "evolution.mercy_rail"))
		button("Great Toll", Rect2(470, 613, 128, 40), func(): act("evolve", "evolution.great_toll"))
		button("NEXT WAVE  →", Rect2(734, 613, 250, 40), func(): act("continue"), true).grab_focus()
		button("Combine pair", Rect2(1060, 573, 188, 32), func(): act("combine"))
		button("Equip reserve", Rect2(1060, 613, 188, 32), func(): act("equip"))
		for i in range(sim.state.weapons.size()):
			button("Sell", Rect2(1060, 243 + i * 79, 52, 26), func(): act("sell", i))
			button("Dism.", Rect2(1118, 243 + i * 79, 59, 26), func(): act("dismantle", i))
			button("Store", Rect2(1183, 243 + i * 79, 65, 26), func(): act("reserve", i))
	elif sim.state.phase in ["won", "lost"]:
		button("RETURN TO THE WORKSHOP", Rect2(410, 615, 460, 48), func(): screen = "menu"; build_ui(), true).grab_focus()
	elif sim.state.paused:
		button("Resume", Rect2(475, 355, 330, 46), func(): sim.command("pause"); build_ui(), true).grab_focus()
		button("Save shift", Rect2(475, 415, 330, 42), save_run)
		button("Back to title", Rect2(475, 475, 330, 42), func(): screen = "menu"; build_ui())
	button("Sound " + ("off" if sound.muted else "on"), Rect2(28, 757, 117, 28), func(): sound.muted = not sound.muted; build_ui())
	button("Effects " + ("low" if reduced_fx else "full"), Rect2(153, 757, 122, 28), func(): reduced_fx = not reduced_fx; build_ui())
	button("Text " + ("large" if ui_scale > 1 else "normal"), Rect2(283, 757, 127, 28), func(): ui_scale = 1.15 if ui_scale == 1 else 1.0; build_ui())

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
	if screen == "menu":
		camera_offset = Vector2.ZERO
		draw_menu()
	else:
		var half_view = WORLD_VIEW.size * 0.5
		var camera = sim.state.position.clamp(sim.arena.bounds.position + half_view, sim.arena.bounds.end - half_view)
		camera_offset = WORLD_VIEW.get_center() - camera
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
		if sim.state.phase == "shop": draw_shop()
		if sim.state.phase in ["won", "lost"]: draw_results()
		if sim.state.paused and sim.state.phase == "combat":
			draw_rect(Rect2(0, 0, 1280, 745), Color(0.025, 0.05, 0.06, 0.87))
			text_at("The machines can wait.", Vector2(432, 300), 34, PAPER, true)
	if notification != "" and Time.get_ticks_msec() < notice_until:
		panel(Rect2(430, 699, 600, 34))
		text_at(notification, Vector2(444, 721), 15, GOLD)
	if dev_mode:
		panel(Rect2(924, 94, 328, 33))
		text_at("DEV %d× SPEED · F6 toggles 1× / 5×" % simulation_speed, Vector2(938, 116), 13, GOLD)
	text_at("WASD / arrows · move     ESC · pause     F5 / F9 · save / load", Vector2(445, 777), 13, MUTED)
	if debug_visible:
		text_at("BUILD 0.1.0 | Godot %s | 1280×800 | seed %d | tick %d | %s" % [Engine.get_version_info().string, seed_value, sim.state.get("tick", 0), "FIXTURE CAPTURE" if capture_dir != "" else "LIVE"], Vector2(28, 745), 11, GOLD)

func draw_menu():
	for x in range(0, 1280, 48): draw_line(Vector2(x, 0), Vector2(x, 745), Color("15252a"))
	for y in range(0, 745, 48): draw_line(Vector2(0, y), Vector2(1280, y), Color("15252a"))
	text_at("A PILGRIMAGE OF REPAIRS", Vector2(124, 89), 15, GOLD)
	text_at("Scrap Saint", Vector2(120, 171), 72, PAPER, true)
	text_at("Turn scrap into miracles.", Vector2(124, 218), 23, MUTED, true)
	text_at("Roam freely. Repair for rewards. Survive and defeat the Foreman." if run_mode == "optional" else "Protect and repair the relay. Survive and defeat the Foreman.", Vector2(124, 262), 17, PAPER)
	draw_saint(Vector2(1072, 177), Vector2(-1, 0), 2.8)
	var titles = ["The Workshop Gospel", "The Bell Ward", "The Mourner"]
	var lines = [["REPAIR · RELIABILITY", "Begin with the Nailer.", "Complete repairs faster.", "Two Labour weapons fulfil it."], ["CONTROL · ANTICIPATION", "Begin with the Last Shift Bell.", "Push danger out of your path.", "Two Witness weapons fulfil it."], ["REMNANTS · RECOVERY", "Begin with the Candle-Nailer.", "Defeats leave healing motes.", "Two Mourn weapons fulfil it."]]
	for i in range(3):
		var x = 108 + i * 354
		panel(Rect2(x, 324, 338, 254), Color("223733") if chosen == i else PANEL)
		text_at("0%d / BLESSING" % (i + 1), Vector2(x + 16, 355), 13, GOLD)
		text_at(titles[i], Vector2(x + 16, 395), 23, PAPER, true)
		for j in range(4): text_at(lines[i][j], Vector2(x + 16, 429 + j * 24), 14, MUTED if j > 0 else GREEN)
	text_at("Optional repairs. Your path through the shift.", Vector2(438, 603), 16, MUTED, true)

func draw_header():
	text_at("SCRAP SAINT", Vector2(28, 42), 25, PAPER, true)
	text_at("THE FIRST SHIFT / " + ["WORKSHOP GOSPEL", "BELL WARD", "THE MOURNER"][sim.state.doctrine], Vector2(28, 68), 12, GOLD)
	text_at("STRUCTURE", Vector2(352, 31), 11, MUTED)
	bar(Rect2(352, 43, 175, 8), sim.state.hp / sim.config.saint.structure, GREEN if sim.state.hp > 30 else RED)
	text_at("%d / %d" % [maxi(0, sim.state.hp), sim.config.saint.structure], Vector2(352, 72), 13)
	if sim.optional_mode():
		var count = sim.state.machines.filter(func(m): return m.complete).size()
		text_at("OPTIONAL REPAIRS", Vector2(568, 31), 11, MUTED)
		bar(Rect2(568, 43, 175, 8), count / 3.0, GREEN)
		text_at("%d / 3 machines restored" % count, Vector2(568, 72), 12)
	else:
		text_at("RELAY", Vector2(568, 31), 11, MUTED)
		bar(Rect2(568, 43, 175, 8), sim.state.relay_hp / sim.config.relay.structure, RED if sim.state.relay_hp < sim.config.relay.structure * sim.config.relay.critical_fraction else GOLD)
		text_at("%d%% integrity · %d%% work" % [sim.state.relay_hp * 100 / sim.config.relay.structure, sim.state.progress * 100 / sim.config.relay.required_ticks], Vector2(568, 72), 13)
	text_at("%02d  SCRAP" % sim.state.scrap, Vector2(800, 43), 19, GOLD)
	text_at("%d  RELIC SHARDS" % sim.state.shards, Vector2(800, 69), 12, MUTED)
	text_at("WAVE %02d / 08" % sim.state.wave, Vector2(1070, 43), 18)
	text_at("%02d:%02d" % [int(sim.state.tick / 3600), int(sim.state.tick / 60) % 60], Vector2(1070, 70), 14, MUTED)
	draw_line(Vector2(28, 89), Vector2(1252, 89), Color("3a4d48"))
	var instruction = "Stay in the work circle to repair. Weapons fire automatically."
	if sim.state.progress >= sim.config.relay.required_ticks: instruction = "RELAY ONLINE · Keep it standing. Finish the shift."
	if sim.state.wave == 8: instruction = "FOREMAN ENGINE · Watch the demolition circles. Protect the relay."
	if sim.state.phase == "shop": instruction = "A moment to rebuild. Choose what your machine becomes."
	if sim.optional_mode(): instruction = "Survive the shift. Defeat the Foreman. Repairs are optional rewards."
	if sim.state.wave == 8: instruction = "FOREMAN / Keep moving. Avoid the demolition zones."
	text_at(instruction, Vector2(60, 126), 16, GREEN)
	if sim.state.phase == "combat" and not sim.optional_mode():
		text_at("STARTUP BACKUP · Relay cannot break before the first workshop" if sim.state.wave == 1 else "BACKUP OFFLINE · Break enemy strike warnings to protect the relay", Vector2(60, 146), 11, GOLD if sim.state.wave == 1 else MUTED)

func draw_workshop_layout():
	var arena = sim.arena
	for x in range(int(arena.bounds.position.x) + 8, int(arena.bounds.end.x), 40):
		for y in range(int(arena.bounds.position.y) + 8, int(arena.bounds.end.y), 40):
			draw_rect(Rect2(x, y, 32, 32), Color("263a3c"), false, 1)
	# Painted outer service circuit makes the two directions around machines visible.
	var loop = arena.bounds.grow(-65)
	draw_rect(loop, Color("40524b"), false, 2)
	for zone in arena.data.zones:
		var r = arena.rect(zone.rect)
		draw_rect(r, Color("293d3b"))
		text_at(zone.name, r.position + Vector2(5, 18), 10, MUTED)
		if zone.id == "zone.workshop":
			draw_line(r.position + Vector2(20, 45), r.end - Vector2(20, 30), Color("837353"), 4)
			text_at("REBUILD BETWEEN WAVES", r.position + Vector2(16, 65), 10, MUTED)
	for entry in arena.data.entries:
		var center = (arena.point(entry.from) + arena.point(entry.to)) * 0.5
		var inward = (sim.relay_position() - center).normalized()
		draw_line(arena.point(entry.from), arena.point(entry.to), Color("a88c59"), 5)
		for offset in [-16, 0, 16]:
			var tip = center + inward * (22 + offset)
			draw_line(tip - inward.rotated(0.6) * 9, tip, GOLD, 2)
			draw_line(tip - inward.rotated(-0.6) * 9, tip, GOLD, 2)
		var label = center + Vector2(-48, -18)
		if entry.id == "entry.west_conveyor": label = Vector2(165, 340)
		if entry.id == "entry.east_furnace": label = Vector2(808, 365)
		text_at(entry.name, label, 10, GOLD)
	for machine in arena.data.obstacles:
		var r = arena.rect(machine.rect)
		draw_rect(r.grow(5), Color("101f24"))
		draw_rect(r, Color("52625a"))
		draw_rect(r.grow(-7), Color("304443"))
		for y in range(int(r.position.y) + 14, int(r.end.y) - 8, 22):
			draw_line(Vector2(r.position.x + 12, y), Vector2(r.end.x - 12, y), Color("667061"), 5)
		for x in [r.position.x + 5, r.end.x - 5]:
			for y in [r.position.y + 5, r.end.y - 5]: draw_circle(Vector2(x, y), 2, GOLD)
		text_at(machine.name, r.position + Vector2(12, r.size.y / 2), 10, PAPER)
		for x in range(int(r.position.x), int(r.end.x), 12):
			draw_line(Vector2(x, r.end.y + 2), Vector2(x + 6, r.end.y + 8), Color("a08b55"), 3)

func draw_world():
	var a = sim.config.arena
	panel(Rect2(a[0], a[1], a[2], a[3]), Color("1d3033"))
	draw_workshop_layout()
	var relay = sim.relay_position()
	if sim.optional_mode(): draw_optional_machines()
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
			var direction = (h.p - h.from).normalized()
			draw_line(h.from, h.from + direction * sim.config.rail.range, Color(0.9, 0.4, 0.3, 0.15 + f * 0.3), sim.config.rail.width * 2)
			draw_line(h.from, h.from + direction * sim.config.rail.range, RED, 2, true)
			text_at("COPIED RAIL", h.from + Vector2(-40, -48), 11, RED)
			continue
		draw_circle(h.p, h.radius, Color(0.85, 0.3, 0.18, 0.13 + f * 0.1))
		draw_arc(h.p, h.radius, 0, TAU, 40, RED, 2)
		draw_arc(h.p, h.radius * f, 0, TAU, 40, GOLD, 2)
		text_at("!", h.p + Vector2(-4, 6), 20, GOLD)
	for p in sim.state.pickups:
		if p.kind == "scrap": draw_colored_polygon(PackedVector2Array([p.p + Vector2(0, -6), p.p + Vector2(6, 0), p.p + Vector2(0, 6), p.p + Vector2(-6, 0)]), GOLD)
		else:
			draw_circle(p.p, 5, Color("cbb8ed"))
			draw_arc(p.p, 9, 0, TAU, 16, Color("84759e"), 1)
	for e in sim.state.enemies: draw_enemy(e)
	for w in sim.state.weapons:
		if w.id == "weapon.procession_gear":
			var p = sim.state.position + Vector2.from_angle(sim.state.tick * 0.045) * sim.config.weapons[w.id].range
			draw_arc(sim.state.position, 80, 0, TAU, 48, Color(0.5, 0.75, 0.65, 0.12), 1)
			draw_gear(p, 15, GREEN, sim.state.tick * 0.08)
		if w.id == "weapon.foundry_censer":
			var p = sim.state.position + Vector2.from_angle(sim.state.tick * 0.055) * 62
			draw_circle(sim.state.position, sim.config.weapons[w.id].range, Color(0.25, 0.62, 0.55, 0.06))
			draw_arc(sim.state.position, sim.config.weapons[w.id].range, 0, TAU, 56, Color(0.32, 0.72, 0.63, 0.22), 2)
			draw_line(sim.state.position, p, Color("6b5944"), 2)
			draw_circle(p, 8, Color("273b38"))
			draw_circle(p, 3, GOLD)
		if w.id == "weapon.welded_halo":
			var angle = sim.state.tick * 0.045
			draw_arc(sim.state.position, 31, angle, angle + TAU * 0.82, 36, Color("9ac99d"), 3)
			draw_circle(sim.state.position + Vector2.from_angle(angle) * 31, 4, PAPER)
	draw_saint(sim.state.position, sim.state.facing)
	for e in fx: draw_effect(e)

func draw_boss_hud():
	for e in sim.state.enemies:
		if e.major:
			panel(Rect2(293, 167, 490, 46), Color("152428"))
			text_at("FOREMAN ENGINE" if e.type == sim.config.boss else "MEMORY CRANE", Vector2(309, 186), 12, GOLD)
			if e.type == sim.config.boss: text_at("DEMOLITION" if e.hp / e.max_hp > 0.67 else ("WORKERS" if e.hp / e.max_hp > 0.34 else "FINAL ORDERS"), Vector2(617, 186), 11, RED)
			bar(Rect2(309, 196, 458, 6), e.hp / e.max_hp, RED)
			if e.get("inspected", false): text_at("INSPECTED / " + sim.state.inspection, Vector2(309, 218), 10, Color("8edce0"))

func draw_minimap():
	var r = Rect2(76, 610, 150, 105)
	panel(r, Color("102226"))
	var factor = r.size / sim.arena.bounds.size
	for obstacle in sim.arena.obstacles:
		draw_rect(Rect2(r.position + (obstacle.position - sim.arena.bounds.position) * factor, obstacle.size * factor), MUTED)
	for i in range(sim.state.machines.size()):
		var data = sim.config.optional_repairs.machines[i]
		var p = Vector2(data.position[0], data.position[1])
		draw_circle(r.position + (p - sim.arena.bounds.position) * factor, 3, GREEN if sim.state.machines[i].complete else GOLD)
	draw_circle(r.position + (sim.state.position - sim.arena.bounds.position) * factor, 3, PAPER)
	var visible = Rect2(WORLD_VIEW.position - camera_offset, WORLD_VIEW.size)
	draw_rect(Rect2(r.position + (visible.position - sim.arena.bounds.position) * factor, visible.size * factor), GREEN, false, 1)
	text_at("WORKSHOP / 40 x 28m", r.position + Vector2(0, -7), 10, MUTED)

func draw_optional_machines():
	for i in range(sim.state.machines.size()):
		var machine = sim.state.machines[i]
		var data = sim.config.optional_repairs.machines[i]
		var p = Vector2(data.position[0], data.position[1])
		var color = GREEN if machine.complete else GOLD
		var working = not machine.complete and sim.state.position.distance_to(p) < sim.config.optional_repairs.radius
		if not machine.complete:
			draw_arc(p, sim.config.optional_repairs.radius, 0, TAU, 40, Color("506657"), 1)
			draw_arc(p, sim.config.optional_repairs.radius, -PI / 2, -PI / 2 + TAU * maxf(0.001, machine.progress / sim.config.optional_repairs.required_ticks), 40, color, 3)
		panel(Rect2(p - Vector2(20, 20), Vector2(40, 40)), Color("314b43"))
		draw_gear(p, 12, color, sim.state.tick * 0.02 if machine.complete else 0)
		panel(Rect2(p + Vector2(-70, -57), Vector2(148, 17)), PANEL)
		text_at(data.name, p + Vector2(-64, -44), 11, color)
		text_at("RESTORED" if machine.complete else data.description, p + Vector2(-75, 76), 10, color)
		if working:
			draw_line(sim.state.position, p, GREEN, 2)
			text_at("REPAIRING", p + Vector2(-32, -30), 10, GREEN)

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
				recoil = clampf(float(effect.expires - Time.get_ticks_msec()) / 230, 0, 1) * (5 if effect.shape == "rail" else 2)
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
	if screen == "game" and sim.state.get("evolved", false):
		draw_line(direction * 21 + direction.orthogonal() * 5, direction * 45 + direction.orthogonal() * 5, PAPER, 3)
	if screen == "game" and sim.state.weapons.any(func(w): return w.get("toll", false)):
		draw_line(Vector2(0, -20), Vector2(0, -34), Color("9e8150"), 4)
		draw_colored_polygon(PackedVector2Array([Vector2(-11, -34), Vector2(11, -34), Vector2(15, -23), Vector2(-15, -23)]), Color("b58645"))
		draw_circle(Vector2(0, -21), 3, PAPER)
	draw_line(Vector2(-13, 2), Vector2(-25, 9), Color("ac7455"), 4)
	draw_circle(Vector2(-25, 9), 4, GOLD)
	if screen == "game" and sim.has_gift("gift.spare_hand"):
		draw_line(Vector2(-10, -1), Vector2(-28, -9), Color("a99160"), 5)
		draw_line(Vector2(-28, -9), Vector2(-35, 2), PAPER, 3)
	if screen == "game" and sim.has_gift("gift.inspection_lens"):
		draw_arc(Vector2(0, -9), 10, -0.9, 0.9, 14, Color("8edce0"), 3)
		draw_line(Vector2(9, -11), Vector2(17, -18), Color("8edce0"), 2)
	if screen == "game" and sim.has_gift("gift.black_ledger"):
		draw_rect(Rect2(13, 4, 10, 14), Color("17171b"))
		draw_line(Vector2(16, 7), Vector2(21, 7), GOLD, 1)
	for bolt in [Vector2(-10, -15), Vector2(10, -15), Vector2(-10, 10), Vector2(10, 10)]: draw_circle(bolt, 1.4, PAPER)
	draw_set_transform(camera_offset)

func draw_ellipse_shadow(p: Vector2, radii: Vector2):
	# Local circle shadow keeps the silhouette readable without physics ownership.
	draw_circle(p, radii.x, Color(0.02, 0.04, 0.05, 0.35))

func draw_enemy(e):
	var p = e.p
	var color = Color("cb8565") if e.major else Color(sim.config.enemies[e.type].color)
	if e.flash > sim.state.tick: color = PAPER
	draw_circle(p + Vector2(0, 7), e.radius + 3, Color(0.02, 0.04, 0.05, 0.4))
	if e.major:
		draw_gear(p, e.radius, color, sim.state.tick * 0.009)
		draw_rect(Rect2(p - Vector2(17, 12), Vector2(34, 24)), INK)
		for i in range(3): draw_circle(p + Vector2(-10 + i * 10, 0), 3, RED)
	elif e.type == "enemy.choir_drone":
		draw_circle(p, sim.config.enemy_rules.drone_field_radius, Color(0.6, 0.5, 0.8, 0.035))
		draw_arc(p, sim.config.enemy_rules.drone_field_radius, 0, TAU, 40, Color(0.6, 0.5, 0.8, 0.15), 1)
		draw_colored_polygon(PackedVector2Array([p + Vector2(0, -22), p + Vector2(19, 8), p + Vector2(0, 18), p + Vector2(-19, 8)]), color)
		draw_circle(p, 9, INK)
		draw_arc(p, 29, sim.state.tick * 0.03, sim.state.tick * 0.03 + PI, 20, color, 1.5)
	elif e.type == "enemy.rust_pilgrim":
		draw_rect(Rect2(p - Vector2(15, 20), Vector2(30, 38)), color)
		draw_line(p + Vector2(-9, -2), p + Vector2(9, -2), GREEN, 5)
		draw_line(p + Vector2(0, -11), p + Vector2(0, 7), GREEN, 5)
		draw_circle(p + Vector2(17, 6), 6, GOLD)
	elif e.type == "enemy.forklift_brute":
		draw_rect(Rect2(p - Vector2(23, 20), Vector2(46, 40)), color)
		for x in [-15, 15]: draw_line(p + Vector2(x, 10), p + Vector2(x, 38), GOLD, 6)
		draw_rect(Rect2(p - Vector2(14, 13), Vector2(28, 15)), INK)
		if e.windup > sim.state.tick: draw_line(p, p + e.charge * 135, RED, 3)
	elif e.type == "enemy.cinder_spitter":
		draw_circle(p, 16, color)
		var direction = (sim.state.position - p).normalized()
		draw_line(p, p + direction * 26, color, 10)
		draw_circle(p, 8, INK)
		draw_circle(p, 4, GOLD)
	elif e.type == "enemy.scrap_mite":
		for i in [-1, 1]:
			draw_line(p + Vector2(i * 6, -3), p + Vector2(i * 16, -9), color, 2)
			draw_line(p + Vector2(i * 6, 3), p + Vector2(i * 16, 9), color, 2)
		draw_circle(p, 9, color)
		draw_circle(p + Vector2(0, -3), 3, INK)
	else:
		draw_colored_polygon(PackedVector2Array([p + Vector2(-13, 10), p + Vector2(-10, -12), p + Vector2(8, -16), p + Vector2(16, 4), p + Vector2(7, 13)]), color)
		draw_line(p + Vector2(-7, -3), p + Vector2(7, -3), INK, 4)
		if e.windup > sim.state.tick:
			draw_line(p, p + e.charge * 135, RED, 2, true)
			draw_circle(p + e.charge * 135, 4, GOLD)
	if e.stun > sim.state.tick: draw_arc(p, e.radius + 6, 0, TAU, 24, GOLD, 2)
	if e.marked > sim.state.tick:
		draw_line(p + Vector2(-4, -e.radius - 17), p + Vector2(4, -e.radius - 9), GOLD, 2)
		draw_line(p + Vector2(4, -e.radius - 17), p + Vector2(-4, -e.radius - 9), GOLD, 2)
	if e.bound > sim.state.tick: draw_line(p, sim.state.position, Color("81b8d0"), 1.5)
	if e.get("slow", 0) > sim.state.tick: draw_arc(p, e.radius + 10, 0, TAU, 24, Color("74b9a6"), 2)
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
	var fade = clampf(float(e.expires - Time.get_ticks_msec()) / 230, 0, 1)
	var color = Color(e.get("color", "e9dec2"))
	color.a = fade
	match e.kind:
		"attack":
			match e.shape:
				"line", "shot", "rail", "beam":
					draw_line(e.from, e.to, color, 5 if e.shape in ["rail", "beam"] else 2, true)
					if e.shape == "rail": draw_line(e.from, e.to, Color(1, 0.98, 0.85, fade), 2, true)
				"blast":
					draw_line(e.from, e.to, Color(color, fade * 0.4), 1)
					draw_circle(e.to, e.range * (1.0 - fade * 0.35), Color(color, fade * 0.2))
					draw_arc(e.to, e.range * (1.0 - fade * 0.35), 0, TAU, 32, color, 3)
				"cone", "tether":
					var angle = (e.to - e.from).angle()
					draw_arc(e.from, e.range * (1 - fade * 0.4), angle - 0.8, angle + 0.8, 24, color, 3, true)
				"orbit": draw_arc(e.to, 23 * (2 - fade), 0, TAU, 20, color, 2)
				"censer":
					draw_circle(e.from, e.range, Color(color, fade * 0.06))
					draw_arc(e.from, e.range * (1.0 - fade * 0.08), 0, TAU, 44, color, 3)
				"winch":
					var delta = e.to - e.from
					for segment in range(3):
						var a = e.from + delta * segment / 3.0
						var b = e.from + delta * (segment + 0.82) / 3.0
						draw_line(a, b, color, 5, true)
					draw_line(e.to + Vector2(-7, -6), e.to, PAPER, 3)
					draw_line(e.to + Vector2(-7, 6), e.to, PAPER, 3)
				"halo":
					draw_arc(e.from, 31, 0, TAU, 28, Color(color, fade * 0.65), 2)
					draw_line(e.from, e.to, Color(0.75, 1.0, 0.78, fade), 2, true)
					draw_arc(e.to, 11, 0, TAU, 16, color, 2)
				"radial":
					draw_circle(e.from, e.range * (1.0 - fade * 0.2), Color(color, fade * 0.055))
					draw_arc(e.from, e.range * (1.0 - fade * 0.2), 0, TAU, 64, color, 6, true)
					for i in range(4): draw_arc(e.from + Vector2.from_angle(i * PI / 2) * e.range * 0.55, 13, 0, TAU, 18, PAPER, 2)
		"charge": draw_line(e.from, e.to, Color(0.9, 0.8, 0.5, fade * 0.35), 1)
		"hit", "death":
			for i in range(4):
				var d = Vector2.from_angle(i * TAU / 4 + e.tick)
				draw_line(e.position + d * 3, e.position + d * (7 + (1 - fade) * 13), color, 2)
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
		var evolved_name = "Mercy Rail" if w.get("rail", false) else ("The Great Toll" if w.get("toll", false) else data.short)
		text_at(evolved_name, Vector2(1095, y), 14, Color(data.color))
		text_at("RANK " + ["I", "II", "III"][w.rank - 1] + (" · EVOLVED" if sim.weapon_evolved(w) else ""), Vector2(1095, y + 20), 11, MUTED)
	text_at("RESERVE", Vector2(1068, 539), 11, GOLD)
	if not sim.state.reserve.is_empty(): text_at(sim.config.weapons[sim.state.reserve[0].id].short, Vector2(1068, 558), 12)
	else: text_at("One open place", Vector2(1068, 558), 12, MUTED)
	var gifts_y = 665 if sim.state.phase == "shop" else 589
	text_at("GIFTS  %d / %d" % [sim.state.gifts.size(), sim.config.gift_slots], Vector2(1068, gifts_y), 11, GOLD)
	for i in range(sim.state.gifts.size()): text_at(sim.config.gifts[sim.state.gifts[i]].short, Vector2(1068, gifts_y + 19 + i * 18), 11, Color("8edce0"))
	if sim.state.phase != "shop":
		text_at("DOCTRINE / " + ("FULFILLED" if sim.state.fulfilled else "TAKING SHAPE"), Vector2(1068, 664), 10, GOLD)
		if sim.state.inspection != "": wrapped("LENS / " + sim.state.inspection, Vector2(1068, 683), 170, 9, Color("8edce0"))
		else: text_at("%d machines laid to rest" % sim.state.kills, Vector2(1068, 686), 10, MUTED)

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

func draw_shop():
	draw_rect(Rect2(60, 148, 980, 588), Color("14272b"))
	text_at("The relic workshop", Vector2(108, 189), 29, PAPER, true)
	text_at("Next: " + ["Rivet Hounds · intercept / displace", "Scrap Mites · collect / clear", "Choir Drones · approach / focus"][mini(2, int((sim.state.wave + 1) / 2))], Vector2(483, 186), 14, GREEN)
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
			description = sim.config.weapons[id].description
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
			price = "%d SCRAP / SERVICE" % (sim.config.shop_rules.services[sim.state.doctrine].cost if id == "service.doctrine" else sim.config.economy.repair_cost)
		text_at(sim.config.shop_rules.roles[i] + (" / LOCKED" if sim.state.locked == id else ""), Vector2(x + 16, y + 16), 9, MUTED)
		text_at(price, Vector2(x + 16, y + 33), 10, GOLD)
		text_at(name_text, Vector2(x + 16, y + 60), 19, PAPER, true)
		wrapped(description, Vector2(x + 16, y + 82), 252, 12)
	text_at("Combine raises rank. Evolution consumes one catalyst. Gifts occupy two separate slots.", Vector2(108, 685), 13, MUTED)
	var rank = 0
	var bell_rank = 0
	for w in sim.state.weapons:
		if w.id == "weapon.nailer_small_mercies" and not sim.weapon_evolved(w): rank = maxi(rank, w.rank)
		if w.id == "weapon.bell_last_shift" and not sim.weapon_evolved(w): bell_rank = maxi(bell_rank, w.rank)
	text_at("MERCY RAIL  Nailer %s + Rivet %s    /    GREAT TOLL  Bell %s + Clapper %s" % ["—" if rank == 0 else ["I", "II", "III"][rank - 1], "✓" if "catalyst.saints_rivet" in sim.state.catalysts else "—", "—" if bell_rank == 0 else ["I", "II", "III"][bell_rank - 1], "✓" if "catalyst.cracked_bell_clapper" in sim.state.catalysts else "—"], Vector2(108, 714), 11, GOLD)

func draw_results():
	draw_rect(Rect2(60, 148, 1192, 588), Color(0.04, 0.08, 0.09, 0.97))
	var won = sim.state.phase == "won"
	text_at("SHIFT COMPLETE" if won else "THE SHIFT FALLS SILENT", Vector2(220, 237), 14, GOLD)
	text_at("A small miracle." if won else "Even saints need repairs.", Vector2(216, 305), 46, PAPER, true)
	text_at(sim.state.last_reason, Vector2(220, 350), 20, GREEN if won else RED)
	text_at(("%d enemies stopped     %d Scrap remaining     %d optional repairs" % [sim.state.kills, sim.state.scrap, sim.state.machines.filter(func(m): return m.complete).size()]) if sim.optional_mode() else ("%d machines stopped     %d Scrap remaining     %d%% relay repaired" % [sim.state.kills, sim.state.scrap, sim.state.progress * 100 / sim.config.relay.required_ticks]), Vector2(220, 409), 17)
	text_at("Your machine: " + ", ".join(sim.state.weapons.map(func(w): return "Mercy Rail" if w.get("rail", false) else ("The Great Toll" if w.get("toll", false) else sim.config.weapons[w.id].short))), Vector2(220, 452), 16, MUTED)
	text_at("Gifts: " + ("none" if sim.state.gifts.is_empty() else ", ".join(sim.state.gifts.map(func(id): return sim.config.gifts[id].short))), Vector2(220, 478), 14, Color("8edce0"))
	wrapped("MEMORY 01 / Your arm remembers a waterworks. Your bell remembers a factory. Neither remembers being asked to become a weapon." if won else ("The workshop keeps your place. Try another build, make room to dodge, or repair a machine for a useful reward." if sim.optional_mode() else "The workshop keeps your place. Try a different relic, leave the work circle to intercept threats, or return sooner to mend the relay."), Vector2(220, 510), 820, 18, PAPER)

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
