extends SceneTree

var checks = 0
var failures = 0

func check(ok: bool, label: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("WEAPON PRESENTATION FAIL: ", label)

func _initialize():
	call_deferred("run_checks")

func run_checks():
	var game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.sound.muted = true
	game.screen = "game"
	game.sim.start(0, 147, "optional")
	game.visual_clock_override = 1000
	var state_before = game.sim.state_hash()
	var nail = {"kind": "attack", "shape": "line", "weapon": "weapon.nailer_small_mercies", "from": Vector2(100, 100), "to": Vector2(300, 100), "range": 330, "width": 10, "rank": 3, "color": "efb966"}
	game.present(nail)
	check(game.sim.state_hash() == state_before, "presenting weapon animation never mutates simulation state")
	check(game.fx.size() == 1 and game.fx[0].duration_ms == 380 and game.fx[0].presented_at == 1000, "Nailer event receives authored presentation timing")
	game.visual_clock_override = 1190
	check(is_equal_approx(game.presentation_progress(game.fx[0]), 0.5), "presentation progress is deterministic under the fixture clock")
	check(game.presentation_fade(game.fx[0]) > 0.99, "Nailer resolve remains fully legible at mid-animation")
	check(game.latest_weapon_attack("weapon.nailer_small_mercies") == game.fx[0] and game.latest_weapon_attack("weapon.bell_last_shift") == null, "physical mounts read only their matching authoritative attack")

	game.visual_clock_override = 2000
	game.present({"kind": "attack", "shape": "rail", "weapon": "weapon.nailer_small_mercies", "from": Vector2.ZERO, "to": Vector2.RIGHT * 620, "range": 620, "width": 19, "rank": 3, "color": "efb966"})
	game.present({"kind": "attack", "shape": "cone", "weapon": "weapon.bell_last_shift", "from": Vector2.ZERO, "to": Vector2.RIGHT * 155, "range": 155, "width": 1.04, "rank": 3, "color": "efcf83"})
	game.present({"kind": "attack", "shape": "radial", "weapon": "weapon.bell_last_shift", "from": Vector2.ZERO, "to": Vector2.ZERO, "range": 215, "width": 0, "rank": 3, "color": "efcf83"})
	check(game.fx[-3].duration_ms == 560, "Mercy Rail has a longer physical resolve than the base Nailer")
	check(game.fx[-2].duration_ms == 460, "Bell cone retains its authored strike and wobble window")
	check(game.fx[-1].duration_ms == 620, "Great Toll has room for the full radial procession")
	check(game.latest_weapon_attack("weapon.bell_last_shift").shape == "radial", "latest Bell event drives the current Bell mount pose")

	game.present({"kind": "evolution", "recipe": "evolution.mercy_rail", "position": Vector2(550, 530)})
	check(game.fx[-1].duration_ms == 760, "Evolution reconfiguration receives its premium presentation window")
	game.visual_clock_override = 2760
	game._physics_process(0.0)
	check(game.fx.is_empty(), "expired presentation effects are removed against the same visual clock")

	game.queue_free()
	await process_frame
	print("WEAPON PRESENTATION: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
