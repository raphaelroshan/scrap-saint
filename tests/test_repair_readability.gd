extends SceneTree
var checks = 0
var failures = 0

func check(ok: bool, label: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("REPAIR READABILITY FAIL: ", label)

func _initialize(): call_deferred("run")

func run():
	var game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.set_physics_process(false)
	game.sim.start(0, 147, "optional")
	for scale in [1.0, 1.15]:
		game.ui_scale = scale
		for index in range(3):
			var data = game.sim.config.optional_repairs.machines[index]
			var machine_position = Vector2(data.position[0], data.position[1])
			for offset in [Vector2.ZERO, Vector2(40, 0), Vector2(-40, 0)]:
				game.sim.state.position = machine_position + offset
				var half_view = game.WORLD_VIEW.size * 0.5
				var camera = game.sim.state.position.clamp(game.sim.arena.bounds.position + half_view, game.sim.arena.bounds.end - half_view)
				game.camera_offset = game.WORLD_VIEW.get_center() - camera
				var visible = Rect2(game.WORLD_VIEW.position - game.camera_offset, game.WORLD_VIEW.size)
				for state in range(4):
					var machine = game.sim.state.machines[index]
					machine.complete = state == 3
					machine.progress = 90 if state == 1 else 0
					machine.deferred = "INTEGRITY_FULL" if state == 2 else ""
					game.sim.state.active_machine = machine.id if state == 1 else ""
					var before = game.sim.state_hash()
					var layout = game.optional_machine_layout(index)
					check(visible.encloses(layout.rect), "card inside viewport %d/%d/%s" % [index, state, scale])
					check(layout.rect.position.y > machine_position.y + 45 or layout.rect.end.y < machine_position.y - 45, "machine stays clear %d/%d/%s" % [index, state, scale])
					check(" ".join(layout.description_lines) == data.description, "full reward retained %d/%d/%s" % [index, state, scale])
					for line in layout.description_lines:
						check(game.font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, int(10 * scale)).x <= layout.rect.size.x - 20, "measured reward fits %d/%d/%s" % [index, state, scale])
					check(game.font.get_string_size(data.name, HORIZONTAL_ALIGNMENT_LEFT, -1, int(11 * scale)).x <= layout.rect.size.x - 20, "name fits %d/%d/%s" % [index, state, scale])
					check(game.font.get_string_size(layout.status, HORIZONTAL_ALIGNMENT_LEFT, -1, int(10 * scale)).x <= layout.rect.size.x - 20, "status fits %d/%d/%s" % [index, state, scale])
					check(before == game.sim.state_hash(), "layout is read only %d/%d/%s" % [index, state, scale])
	game.sim.start(0, 147, "optional")
	game.sim.state.position = Vector2(550, 70)
	game.sim.update_optional_repairs()
	check(game.optional_machine_layout(1).status.contains("SAVE FOR DAMAGE"), "full integrity defers healing")
	game.sim.state.position = Vector2(800, 400)
	game.sim.update_optional_repairs()
	check(game.optional_machine_layout(1).status.contains("SAVE FOR DAMAGE"), "leaving preserves authoritative deferred state")
	game.sim.state.hp = 50
	game.sim.state.position = Vector2(550, 70)
	game.sim.update_optional_repairs()
	check(not game.optional_machine_layout(1).status.contains("SAVE FOR DAMAGE"), "damage clears deferred wording")
	game.sim.start(0, 147, "optional")
	var salvage = game.sim.config.optional_repairs.machines[0]
	var salvage_position = Vector2(salvage.position[0], salvage.position[1])
	game.sim.state.position = salvage_position + Vector2(40, 0)
	for tick in range(90): game.sim.update_optional_repairs()
	var held_progress = game.sim.state.machines[0].progress
	game.sim.state.position = salvage_position + Vector2(180, 0)
	game.sim.update_optional_repairs()
	check(game.sim.state.machines[0].progress == held_progress and game.sim.state.active_machine == "", "departure keeps partial progress without active claim")
	check(game.optional_machine_layout(0).status.contains("PAUSED"), "departure describes held progress")
	game.sim.state.position = salvage_position + Vector2(40, 0)
	game.sim.update_optional_repairs()
	check(game.sim.state.machines[0].progress > held_progress and game.sim.state.active_machine == game.sim.state.machines[0].id, "re-entry resumes authoritative repair")
	for tick in range(90): game.sim.update_optional_repairs()
	check(game.sim.state.machines[0].complete and game.optional_machine_layout(0).status.contains("RESTORED"), "re-entry reaches restored state")
	game.sim.start(0, 147, "optional")
	game.sim.state.position = Vector2(1110, 560)
	var half_view = game.WORLD_VIEW.size * 0.5
	var camera = game.sim.state.position.clamp(game.sim.arena.bounds.position + half_view, game.sim.arena.bounds.end - half_view)
	game.camera_offset = game.WORLD_VIEW.get_center() - camera
	for index in range(4):
		game.sim.state.hazards.append({"p": Vector2(780 + index * 95, 520 + (index % 2) * 70), "radius": 62})
	var bell_card: Rect2 = game.optional_machine_layout(2).rect
	for hazard in game.sim.state.hazards:
		var danger = Rect2(hazard.p - Vector2.ONE * 62, Vector2.ONE * 124)
		check(not bell_card.intersects(danger), "Foreman warning stays clear of Bell card")
	game.queue_free()
	await process_frame
	print("REPAIR READABILITY: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
