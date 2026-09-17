extends SceneTree

var checks = 0
var failures = 0

func check(ok: bool, label: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("PRESENTATION QUALITY FAIL: ", label)

func _initialize():
	call_deferred("run_checks")

func run_checks():
	var game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.sound.muted = true

	game.visual_clock_override = 1000
	game.begin_title_transition()
	check(game.screen == "title" and game.sim.state.is_empty(), "title commit does not start authoritative simulation")
	game.visual_clock_override = 1675
	check(is_equal_approx(game.title_transition_progress(), 0.5), "title reveal uses deterministic presentation-clock progress")
	game.visual_clock_override = 2350
	game._process(0.0)
	check(game.screen == "menu" and game.sim.state.is_empty(), "title handoff reaches setup without advancing simulation")

	game.screen = "game"
	game.sim.start(0, 147, "optional")
	game.settings.state.screen_shake = true
	game.visual_clock_override = 3000
	var before_impact = game.sim.state_hash()
	var impact = {"kind": "hit", "position": game.sim.state.position + Vector2(80, 0), "weapon": "weapon.nailer_small_mercies", "tick": 12, "color": "efb966"}
	game.present(impact)
	game.visual_clock_override = 3040
	check(game.current_camera_impulse().length() > 0.05, "ordinary impact creates a restrained presentation-only impulse")
	check(game.sim.state_hash() == before_impact, "impact presentation does not mutate simulation state")
	var enemy = {"p": impact.position, "radius": 14.0, "stun": 0, "windup": 0, "charge": Vector2.ZERO}
	check(game.enemy_reaction_offset(enemy).length() > 0.1, "enemy pose reacts to an existing hit event")
	game.reduced_fx = true
	game.trigger_camera_impulse(5.0, {"tick": 14})
	check(game.current_camera_impulse() == Vector2.ZERO, "reduced effects disables camera impulse")
	game.reduced_fx = false

	game.sim.enter_shop()
	game.sim.state.weapons = [game.sim.make_weapon("weapon.nailer_small_mercies", 3)]
	game.sim.state.catalysts = ["catalyst.saints_rivet"]
	game.visual_clock_override = 4000
	game.act("evolve", "evolution.mercy_rail")
	check(not game.evolution_showcase.is_empty() and game.sim.weapon_evolution_id(game.sim.state.weapons[0]) == "evolution.mercy_rail", "accepted Evolution opens its premium presentation")
	var evolved_hash = game.sim.state_hash()
	game.visual_clock_override = 4725
	check(is_equal_approx(game.evolution_showcase_progress(), 0.5), "Evolution showcase progress is deterministic")
	check(game.sim.state_hash() == evolved_hash, "Evolution overlay does not further mutate authoritative state")
	game.visual_clock_override = 5450
	game._process(0.0)
	check(game.evolution_showcase.is_empty(), "Evolution showcase expires and returns control")

	var required_cues = ["line", "cone", "shot", "tether", "orbit", "rail", "beam", "blast", "censer", "winch", "halo", "radial", "ashen_censer", "long_hand", "repair_halo", "funeral_shots", "sermon", "benediction", "consecrated", "parade", "lattice", "repair", "hurt", "relay_hurt", "pickup", "death", "quieted", "evolution", "boss_contract", "machine_restored", "title_commit"]
	check(required_cues.all(func(cue): return game.sound.sounds.has(cue)), "all combat, world, Evolution, and title cues are synthesized")
	check(required_cues.all(func(cue): return game.sound.sounds[cue].data.size() > 0), "every synthesized cue contains playable PCM data")
	check(game.sound.sounds.evolution.data.size() > game.sound.sounds.line.data.size(), "Evolution receives a longer premium audio signature")

	game.queue_free()
	await process_frame
	print("PRESENTATION QUALITY: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
