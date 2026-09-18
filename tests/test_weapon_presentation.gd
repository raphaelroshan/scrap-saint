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
	var base_manifest = game.nailer_manifest_state(game.fx[0])
	check(base_manifest.origin == Vector2(100, 100) and base_manifest.direction == Vector2.RIGHT, "manifested Nailer uses the authoritative event origin and direction")
	check(not base_manifest.evolved and is_zero_approx(base_manifest.guide_separation), "base Nailer remains a compact driver without Mercy guides")
	check(base_manifest.visibility > 0.9 and base_manifest.carriage > 0.9, "base Nailer exposes a bounded readable commit state")

	game.visual_clock_override = 2000
	game.present({"kind": "attack", "shape": "rail", "weapon": "weapon.nailer_small_mercies", "from": Vector2.ZERO, "to": Vector2.RIGHT * 620, "range": 620, "width": 19, "rank": 3, "color": "efb966"})
	game.visual_clock_override = 2170
	var rail_manifest = game.nailer_manifest_state(game.fx[-1])
	check(rail_manifest.evolved and rail_manifest.guide_separation > 7.0 and rail_manifest.guide_length > 48.0, "Mercy Rail unfolds a longer separated guide silhouette")
	var rail_origin = rail_manifest.origin
	game.sim.state.position = Vector2(90, 70)
	game.sim.state.facing = Vector2.LEFT
	check(game.nailer_manifest_state(game.fx[-1]).origin == rail_origin, "movement and facing changes do not detach a committed manifestation from its event origin")
	game.visual_clock_override = 2000
	game.present({"kind": "attack", "shape": "cone", "weapon": "weapon.bell_last_shift", "from": Vector2.ZERO, "to": Vector2.RIGHT * 155, "range": 155, "width": 1.04, "rank": 3, "color": "efcf83"})
	game.present({"kind": "attack", "shape": "radial", "weapon": "weapon.bell_last_shift", "from": Vector2.ZERO, "to": Vector2.ZERO, "range": 215, "width": 0, "rank": 3, "color": "efcf83"})
	check(game.fx[-3].duration_ms == 560, "Mercy Rail has a longer physical resolve than the base Nailer")
	check(game.fx[-2].duration_ms == 460, "Bell cone retains its authored strike and wobble window")
	check(game.fx[-1].duration_ms == 620, "Great Toll has room for the full radial procession")
	check(game.latest_weapon_attack("weapon.bell_last_shift").shape == "radial", "latest Bell event drives the current Bell mount pose")
	check(game.manifested_relic_state(game.latest_weapon_attack("weapon.bell_last_shift")).origin == Vector2.ZERO, "Bell manifestation preserves its authoritative origin")

	game.present({"kind": "evolution", "recipe": "evolution.mercy_rail", "position": Vector2(550, 530)})
	check(game.fx[-1].duration_ms == 760, "Evolution reconfiguration receives its premium presentation window")
	game.visual_clock_override = 2760
	game._physics_process(0.0)
	check(game.fx.is_empty(), "expired presentation effects are removed against the same visual clock")

	game.visual_clock_override = 3000
	var catalogue_hash = game.sim.state_hash()
	var family_cases = [
		["weapon.procession_gear", "orbit", 420],
		["weapon.procession_gear", "parade", 680],
		["weapon.candle_nailer", "shot", 420],
		["weapon.candle_nailer", "funeral_shots", 620],
		["weapon.cable_contrition", "tether", 500],
		["weapon.cable_contrition", "lattice", 680],
		["weapon.hymn_coil", "beam", 320],
		["weapon.hymn_coil", "sermon", 560],
		["weapon.altar_mortar", "blast", 620],
		["weapon.altar_mortar", "benediction", 700],
		["weapon.foundry_censer", "censer", 520],
		["weapon.foundry_censer", "ashen_censer", 680],
		["weapon.penance_winch", "winch", 580],
		["weapon.penance_winch", "long_hand", 720],
		["weapon.welded_halo", "halo", 480],
		["weapon.welded_halo", "repair_halo", 680],
	]
	for family_case in family_cases:
		game.present({"kind": "attack", "shape": family_case[1], "weapon": family_case[0], "from": Vector2.ZERO, "to": Vector2.RIGHT * 100, "to2": Vector2.LEFT * 100, "targets": [Vector2.RIGHT * 100], "points": [Vector2(100, 0), Vector2(-50, 80), Vector2(-50, -80)], "range": 100, "inner_range": 60, "width": 12, "rank": 3, "color": "efb966"})
		check(game.fx[-1].duration_ms == family_case[2], "%s uses its authored four-beat duration" % family_case[1])
	check(game.sim.state_hash() == catalogue_hash, "presenting all remaining base and Evolution families preserves simulation state")
	for weapon_id in ["weapon.procession_gear", "weapon.candle_nailer", "weapon.cable_contrition", "weapon.hymn_coil", "weapon.altar_mortar", "weapon.foundry_censer", "weapon.penance_winch", "weapon.welded_halo"]:
		check(game.latest_weapon_attack(weapon_id) != null and str(game.latest_weapon_attack(weapon_id).weapon) == weapon_id, "%s mount reads only its own latest attack" % weapon_id)
	for weapon_id in ["weapon.cable_contrition", "weapon.foundry_censer"]:
		var manifested = game.manifested_relic_state(game.latest_weapon_attack(weapon_id))
		check(manifested.origin == Vector2.ZERO and manifested.shape != "", "%s manifestation preserves its authoritative origin and shape" % weapon_id)

	game.queue_free()
	await process_frame
	print("WEAPON PRESENTATION: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
