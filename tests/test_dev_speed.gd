extends SceneTree
const Sim = preload("res://game/simulation.gd")
var failures = 0
var checks = 0

func check(ok: bool, message: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", message)

func _initialize():
	call_deferred("run_checks")

func run_checks():
	var game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	game.set_physics_process(false)
	await process_frame
	var from_cli = "--dev-speed=5" in OS.get_cmdline_user_args()
	check(game.simulation_speed == (5 if from_cli else 1), "launcher argument selects rate; ordinary launch defaults to one")
	game.sim.start(0, 147)
	var reference = Sim.new()
	reference.start(0, 147)
	game.simulation_speed = 5
	game.advance_simulation(Vector2.RIGHT)
	for i in range(5): reference.step(Vector2.RIGHT)
	check(game.sim.state_hash() == reference.state_hash(), "5x equals five unchanged ticks")
	game.sim.command("pause")
	var paused_hash = game.sim.state_hash()
	game.advance_simulation(Vector2.RIGHT)
	check(game.sim.state_hash() == paused_hash, "pause remains frozen")
	game.sim.command("pause")
	game.sim.state.wave_tick = int(game.sim.config.wave_ticks) - 1
	var tick = game.sim.state.tick
	game.advance_simulation(Vector2.ZERO)
	check(game.sim.state.phase == "shop" and game.sim.state.tick == tick + 1, "batch stops immediately at shop")
	var shop_hash = game.sim.state_hash()
	game.advance_simulation(Vector2.ONE)
	check(game.sim.state_hash() == shop_hash, "shop does not fast-forward")
	game.dev_mode = true
	var event = InputEventKey.new()
	event.keycode = KEY_F6
	event.pressed = true
	game._unhandled_key_input(event)
	check(game.simulation_speed == 1, "F6 switches to normal speed")
	game._unhandled_key_input(event)
	check(game.simulation_speed == 5, "F6 restores 5x")
	game.queue_free()
	await process_frame
	print("DEV SPEED: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
