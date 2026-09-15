extends SceneTree

const OUTPUT = "res://artifacts/gift-breadth"

func _initialize():
	call_deferred("capture")

func weapon(id: String, rank: int = 1, evolution: String = "") -> Dictionary:
	return {"id": id, "rank": rank, "rail": evolution == "evolution.mercy_rail", "toll": evolution == "evolution.great_toll", "evolution": evolution, "ready": 0}

func save_frame(game, filename: String):
	game.build_ui()
	game.queue_redraw()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUTPUT.path_join(filename))
	print("CAPTURE ", OUTPUT.path_join(filename))

func capture():
	DirAccess.make_dir_recursive_absolute(OUTPUT)
	var game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.set_physics_process(false)
	await process_frame
	game.screen = "game"
	game.debug_visible = true
	game.fixture_label = true
	game.seed_value = 147

	# The Scale reads an automatic Rank-II result in a production-valid shop where
	# the Filter appears only because Hymn Coil is carried.
	game.sim.start(0, 147, "optional")
	game.sim.enter_shop()
	game.sim.state.scrap = 80
	game.sim.state.weapons = [weapon("weapon.nailer_small_mercies"), weapon("weapon.bell_last_shift"), weapon("weapon.hymn_coil")]
	game.sim.state.reserve = []
	game.sim.state.gifts = ["gift.honest_scale"]
	game.sim.state.offers = ["weapon.nailer_small_mercies", "weapon.foundry_censer", "catalyst.saints_rivet", "gift.choir_filter", "service.repair", "service.doctrine"]
	game.capture_label = "FIXTURE / P16 / VALID OFFERS"
	await save_frame(game, "P16_HONEST_SCALE_SHOP.png")

	# A completed repair releases the Spring while the first Bell stagger burns
	# the Fuse. The configured target carries both authoritative combat statuses.
	game.sim.start(1, 147, "optional")
	game.sim.state.tick = 600
	game.sim.state.wave = 3
	game.sim.state.position = Vector2(550, 480)
	game.sim.state.weapons = [weapon("weapon.bell_last_shift", 3)]
	game.sim.state.gifts = ["gift.loose_spring", "gift.brass_fuse"]
	game.sim.state.loose_spring_until = 690
	game.sim.state.loose_spring_sources = ["machine.signal" ]
	game.sim.state.brass_fuse_segment = game.sim.site_wave_key()
	game.capture_label = "FIXTURE / P16 / SPRING + FUSE"
	game.sim.spawn("enemy.forklift_brute")
	game.sim.state.enemies[0].p = Vector2(700, 480)
	game.sim.state.enemies[0].stun = 648
	game.sim.state.enemies[0].marked = 780
	game.fx.clear()
	game.present({"kind": "loose_spring_released", "gift": "gift.loose_spring", "position": game.sim.state.position, "tick": game.sim.state.tick})
	game.present({"kind": "brass_fuse_lit", "gift": "gift.brass_fuse", "position": game.sim.state.enemies[0].p, "target_id": game.sim.state.enemies[0].id, "tick": game.sim.state.tick})
	await save_frame(game, "P16_SPRING_FUSE_COMBAT.png")

	# Quiet has ended, but the Filter's recovery lock remains visibly active on
	# both support families. Honest Scale stays physically carried without power.
	game.sim.start(2, 147, "optional")
	game.sim.state.tick = 900
	game.sim.state.wave = 5
	game.sim.state.position = Vector2(550, 480)
	game.sim.state.weapons = [weapon("weapon.hymn_coil", 3)]
	game.sim.state.gifts = ["gift.choir_filter", "gift.honest_scale"]
	for enemy_id in ["enemy.choir_drone", "enemy.rust_pilgrim"]:
		game.sim.spawn(enemy_id)
	game.sim.state.enemies[0].p = Vector2(690, 430)
	game.sim.state.enemies[1].p = Vector2(700, 545)
	for enemy in game.sim.state.enemies:
		enemy.quieted = 899
		enemy.support_lock_until = 1020
	game.fx.clear()
	game.capture_label = "FIXTURE / P16 / FILTER RECOVERY"
	game.present({"kind": "choir_filter_blocked", "gift": "gift.choir_filter", "position": game.sim.state.enemies[0].p, "target_id": game.sim.state.enemies[0].id, "tick": game.sim.state.tick})
	await save_frame(game, "P16_CHOIR_FILTER_RECOVERY.png")

	game.queue_free()
	await process_frame
	print("Gift breadth fixtures: configured executable states, seed 147, Godot 4.5.1 Compatibility renderer, 1280x800; not human playtests")
	quit()
