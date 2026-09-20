extends SceneTree
const Sim = preload("res://game/simulation.gd")
var checks = 0
var failures = 0

func check(ok: bool, message: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("SAVE FLOW FAIL: ", message)

func restored_copy(source, label: String):
	var copy = Sim.new()
	check(copy.restore(source.snapshot()), label + " restores")
	check(copy.state_hash() == source.state_hash(), label + " restores the exact state hash")
	check(copy.arena.data.id == source.arena.data.id, label + " restores the authoritative arena")
	return copy

func compare_step(source, restored, movement: Vector2, label: String):
	source.events.clear()
	restored.events.clear()
	source.step(movement)
	restored.step(movement)
	check(restored.state_hash() == source.state_hash(), label + " continues deterministically")
	check(restored.events == source.events, label + " emits the same next events")

func compare_command(source, restored, action: String, value, label: String):
	source.events.clear()
	restored.events.clear()
	var expected = source.command(action, value)
	var actual = restored.command(action, value)
	check(actual == expected, label + " returns the same command result")
	check(restored.state_hash() == source.state_hash(), label + " command preserves deterministic state")
	check(restored.events == source.events, label + " command emits the same events")

func reach_route(sim):
	sim.state.wave = sim.current_wave_count()
	sim.state.boss_dead = true
	sim.step(Vector2.ZERO)
	if sim.state.phase == "site_clear": sim.command("continue_site_clear")

func finish_travel(sim):
	while sim.state.phase == "travel":
		var free_choice = sim.current_road_node().choices.filter(func(choice): return int(choice.cost) == 0)[0]
		sim.command("choose_road_option", free_choice.id)

func _initialize():
	var combat = Sim.new()
	combat.start(3, 147, "optional", "frame.surveyor", "save-combat")
	for i in range(12): combat.step(Vector2.RIGHT)
	var combat_copy = restored_copy(combat, "combat")
	compare_step(combat, combat_copy, Vector2.DOWN, "combat")

	var shop = Sim.new()
	shop.start(1, 104729, "optional", "frame.keeper", "save-shop")
	shop.enter_shop()
	shop.state.gifts = ["gift.inspection_lens"]
	shop.state.evolutions = ["evolution.great_toll"]
	shop.state.evolved = true
	shop.state.weapons[0].toll = true
	shop.state.weapons[0].evolution = "evolution.great_toll"
	var shop_copy = restored_copy(shop, "shop")
	compare_command(shop, shop_copy, "reroll", null, "shop")

	var route = Sim.new()
	route.start(0, 104730, "optional", "frame.pilgrim", "save-route")
	reach_route(route)
	var route_copy = restored_copy(route, "route")
	compare_command(route, route_copy, "choose_route", "route.rootworks", "route")

	var travel = Sim.new()
	travel.start(0, 104730, "optional", "frame.pilgrim", "save-travel")
	reach_route(travel)
	travel.command("choose_route", "route.brass_choir")
	travel.command("choose_road_option", "choice.brass.splice")
	var travel_copy = restored_copy(travel, "travel")
	compare_command(travel, travel_copy, "choose_road_option", "choice.brass.news", "travel")

	var destination = Sim.new()
	destination.start(2, 104729, "optional", "frame.keeper", "save-destination")
	reach_route(destination)
	destination.command("choose_route", "route.rootworks")
	finish_travel(destination)
	for i in range(15): destination.step(Vector2.LEFT)
	var destination_copy = restored_copy(destination, "destination combat")
	compare_step(destination, destination_copy, Vector2.UP, "destination combat")

	var memory = Sim.new()
	memory.start(0, 147, "optional", "frame.pilgrim", "save-memory")
	reach_route(memory)
	memory.command("choose_route", "route.brass_choir")
	finish_travel(memory)
	for node in memory.state.objective: node.complete = true
	memory.state.objective_complete = true
	memory.state.wave = memory.current_wave_count()
	memory.state.boss_dead = true
	memory.step(Vector2.ZERO)
	check(memory.state.phase == "site_clear", "memory fixture reaches the unified site-clear phase")
	var memory_copy = restored_copy(memory, "memory")
	compare_command(memory, memory_copy, "continue_site_clear", null, "site clear")

	# Version-two saves could already contain the chapter's two-leg route history.
	# Migrating the road-choice schema must not collapse that history to its last leg.
	var legacy_chain = Sim.new()
	legacy_chain.start(0, 147, "optional", "frame.pilgrim", "save-v2-chain")
	reach_route(legacy_chain)
	legacy_chain.command("choose_route", "route.brass_choir")
	finish_travel(legacy_chain)
	for node in legacy_chain.state.objective: node.complete = true
	legacy_chain.state.objective_complete = true
	legacy_chain.state.wave = legacy_chain.current_wave_count()
	legacy_chain.state.boss_dead = true
	legacy_chain.step(Vector2.ZERO)
	legacy_chain.command("continue_site_clear")
	legacy_chain.command("choose_route", "route.pale_archive")
	legacy_chain.state.version = 2
	var migrated_chain = Sim.new()
	check(migrated_chain.restore(legacy_chain.snapshot()), "version-two second-leg save restores")
	check(migrated_chain.state.route_history == ["route.brass_choir", "route.pale_archive"], "version-two migration preserves both authored route IDs")
	check(migrated_chain.state.travel_step == 0 and migrated_chain.assignment_status("route.pale_archive") == "accepted", "version-two second-leg travel restarts at its first road node without losing assignment state")

	# Version-one saves existed in both core-only and assembly forms. Missing fields must
	# receive stable defaults while known Gifts and evolved weapon flags remain intact.
	var legacy_source = Sim.new()
	legacy_source.start(1, 147, "optional")
	legacy_source.spawn("enemy.rivet_hound")
	legacy_source.state.version = 1
	legacy_source.state.gifts = ["gift.spare_hand"]
	legacy_source.state.weapons[0].toll = true
	legacy_source.state.weapons[0].erase("evolution")
	for field in ["run_id", "frame_id", "max_hp", "move_speed", "repair_grace_ticks", "repair_grace_until", "knockback_multiplier", "keeper_shove_segment", "evolutions", "site_id", "route", "route_history", "route_origin_site_id", "travel_step", "assignment_statuses", "road_history", "road_flags", "road_totals", "objective", "objective_complete", "objective_lock_until", "weapon_lock_until", "memory_id", "memory_ids", "site_clear_summary", "chapter_complete", "pressure_until", "completed_site_ids", "defeated_boss_ids", "scrap_by_segment", "result_summary"]:
		legacy_source.state.erase(field)
	for machine in legacy_source.state.machines: machine.erase("deferred")
	for enemy in legacy_source.state.enemies:
		for field in ["worker", "phase", "spawn_tick", "slow", "quieted", "inspected"]: enemy.erase(field)
	var legacy = Sim.new()
	check(legacy.restore(legacy_source.snapshot()), "version-one integrated legacy save restores")
	check(legacy.state.version == 4 and legacy.state.frame_id == "frame.pilgrim", "legacy save receives current version and frame defaults")
	check(legacy.state.route_history.is_empty() and legacy.state.memory_ids.is_empty() and legacy.state.weapon_lock_until == 0, "legacy saves receive deterministic chapter-chain defaults")
	check(legacy.state.road_history.is_empty() and legacy.state.assignment_statuses.is_empty() and legacy.state.road_totals.route_cost == 0, "legacy saves receive deterministic expedition-map defaults")
	check(legacy.state.gifts == ["gift.spare_hand"] and legacy.has_evolution("evolution.great_toll"), "legacy assembly state preserves Gifts and reconstructs evolution IDs")
	check(legacy.state.machines.all(func(machine): return machine.has("deferred")), "legacy machines receive interruption defaults")
	check(legacy.state.enemies.all(func(enemy): return enemy.has("worker") and enemy.has("phase") and enemy.has("spawn_tick") and enemy.has("slow") and enemy.has("quieted") and enemy.has("inspected")), "legacy enemies receive integrated runtime defaults")
	var legacy_again = Sim.new()
	check(legacy_again.restore(legacy_source.snapshot()) and legacy_again.state_hash() == legacy.state_hash(), "legacy migration is deterministic across repeated restores")

	print("SAVE FLOW: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
