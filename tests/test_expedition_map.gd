extends SceneTree
const Sim = preload("res://game/simulation.gd")
var checks = 0
var failures = 0

func check(ok: bool, message: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("EXPEDITION MAP FAIL: ", message)

func reach_map(sim):
	sim.state.wave = sim.current_wave_count()
	sim.state.boss_dead = true
	sim.step(Vector2.ZERO)

func _initialize():
	var sim = Sim.new()
	sim.start(0, 147, "optional")
	reach_map(sim)
	check(sim.state.phase == "route", "Foreman completion opens the expedition map")
	check(sim.available_routes().map(func(route): return route.id) == ["route.brass_choir", "route.rootworks"], "Workshop exposes the two authored first-tier assignments")
	check(sim.assignment_status("route.brass_choir") == "available" and sim.assignment_status("route.rootworks") == "available", "unaccepted assignments are available")
	var edge_keys = sim.chapter.expedition_map.edges.map(func(edge): return "%s>%s:%s" % [edge.from_site_id, edge.to_site_id, edge.route_id])
	check("site.brass_choir_relay>site.red_foundry:route.red_foundry" in edge_keys and "site.rootworks_pump>site.red_foundry:route.red_foundry" in edge_keys, "shared Red Foundry endpoint has stable graph edges")
	check(sim.chapter.expedition_map.sites.any(func(site): return site.id == "site.pale_archive") and sim.chapter.expedition_map.sites.any(func(site): return site.id == "site.null_assembly"), "terminal site IDs are stable extension points")

	var before_route = sim.snapshot()
	check(sim.command("choose_route", "route.red_foundry") == "INVALID_ROUTE" and sim.snapshot() == before_route, "unimplemented terminal assignment cannot mutate the run")
	sim.state.scrap = 20
	check(sim.command("choose_route", "route.brass_choir") == "OK", "Brass assignment accepts through the public command")
	check(sim.state.phase == "travel" and sim.assignment_status("route.brass_choir") == "accepted", "accepted assignment changes color state and opens its first road node")
	check(sim.state.road_totals.route_cost == 8 and sim.state.scrap == 12, "route fare is included in authoritative road totals")
	check(sim.current_road_node().id == "road.brass.warning_wire", "first authored in-between area cannot be skipped")
	var before_bypass = sim.snapshot()
	check(sim.command("advance_travel") == "ROAD_CHOICE_REQUIRED" and sim.snapshot() == before_bypass, "legacy travel command cannot bypass a road area")
	check(sim.command("choose_road_option", "choice.unknown") == "INVALID_ROAD_OPTION" and sim.snapshot() == before_bypass, "unknown road choice is non-mutating")
	check(sim.command("choose_road_option", "choice.brass.cross") == "OK", "free risk choice resolves deterministically")
	check(sim.state.hp == sim.saint_max_structure() - 12 and sim.state.road_flags == ["road.brass.warning_endured"], "road damage and flag are authoritative")
	check(sim.current_road_node().id == "road.brass.ada_waycart", "resolving one area advances exactly one node")
	var saved = sim.snapshot()
	var restored = Sim.new()
	check(restored.restore(saved) and restored.state_hash() == sim.state_hash(), "mid-road save restores exactly")
	sim.events.clear()
	restored.events.clear()
	check(sim.command("choose_road_option", "choice.brass.repair") == "OK" and restored.command("choose_road_option", "choice.brass.repair") == "OK", "merchant repair resolves after restore")
	check(restored.state_hash() == sim.state_hash() and restored.events == sim.events, "restored road choice preserves exact state and event trace")
	check(sim.state.phase == "combat" and sim.state.site_id == "site.brass_choir_relay", "all intermediate nodes resolve before destination arrival")
	check(sim.state.hp == sim.saint_max_structure() and sim.state.scrap == 8, "paid service consequence carries into the destination")
	check(sim.state.road_history.map(func(entry): return entry.choice_id) == ["choice.brass.cross", "choice.brass.repair"], "ordered road history survives arrival")

	var insufficient = Sim.new()
	insufficient.start(0, 147, "optional")
	reach_map(insufficient)
	insufficient.state.scrap = 8
	insufficient.command("choose_route", "route.brass_choir")
	var no_scrap_state = insufficient.snapshot()
	check(insufficient.command("choose_road_option", "choice.brass.splice") == "INSUFFICIENT_SCRAP" and insufficient.snapshot() == no_scrap_state, "unaffordable road service cannot mutate state")
	check(insufficient.command("choose_road_option", "choice.brass.cross") == "OK", "every encounter retains an affordable continuation")
	check(insufficient.current_road_node().choices.any(func(choice): return int(choice.cost) == 0), "merchant stop retains a free continuation")

	var root = Sim.new()
	root.start(2, 104729, "optional")
	reach_map(root)
	root.state.scrap = 16
	root.command("choose_route", "route.rootworks")
	root.command("choose_road_option", "choice.rootworks.brace")
	root.command("choose_road_option", "choice.rootworks.sell_valve")
	check(root.state.site_id == "site.rootworks_pump" and root.state.scrap == 11, "Rootworks road cost, safety purchase, and merchant sale compose deterministically")
	check(root.state.road_totals.scrap_delta == -5 and root.state.road_flags == ["road.rootworks.culvert_braced", "road.rootworks.valve_sold"], "Rootworks consequences remain explicit")
	for node in root.state.objective: node.complete = true
	root.state.objective_complete = true
	root.state.wave = root.current_wave_count()
	root.state.boss_dead = true
	root.step(Vector2.ZERO)
	root.command("accept_memory")
	check(root.state.result_summary.road_history.size() == 2 and root.state.result_summary.road_totals.scrap_delta == -5, "Results carry the complete road record")

	var extension = Sim.new()
	extension.start(0, 147, "optional")
	reach_map(extension)
	extension.state.scrap = 40
	extension.command("choose_route", "route.rootworks")
	extension.command("choose_road_option", "choice.rootworks.ford")
	extension.command("choose_road_option", "choice.rootworks.pass")
	extension.state.phase = "route"
	var red_route = extension.routes["route.brass_choir"].duplicate(true)
	red_route.id = "route.red_foundry"
	red_route.site_id = "site.red_foundry"
	red_route.assignment_id = "assignment.red_foundry"
	red_route.cost = 5
	red_route.road_nodes = [{"id": "road.red.test", "kind": "passage", "name": "Foundry approach", "news": "The shared road is open.", "risk": "No reported hazard.", "choices": [{"id": "choice.red.continue", "label": "Continue", "description": "Follow the road.", "cost": 0, "structure_delta": 0, "scrap_delta": 0, "flag": "road.red.entered", "result": "The Foundry answers."}]}]
	extension.routes[red_route.id] = red_route
	extension.chapter.routes.append(red_route)
	extension.refresh_assignments()
	check(extension.available_routes().map(func(route): return route.id) == ["route.red_foundry"], "graph edges expose a shared terminal route from Rootworks without engine changes")
	check(extension.command("choose_route", "route.red_foundry") == "OK", "plugged-in terminal content uses the same authoritative assignment command")
	var extension_restored = Sim.new()
	extension_restored.routes[red_route.id] = red_route
	extension_restored.chapter.routes.append(red_route)
	check(extension_restored.restore(extension.snapshot()) and extension_restored.state_hash() == extension.state_hash(), "second-leg travel restores its origin arena and exact state")
	check(extension.command("choose_road_option", "choice.red.continue") == "OK", "plugged-in terminal road uses the shared road command")
	check(extension.state.site_id == "site.red_foundry" and extension.state.route_history == ["route.rootworks", "route.red_foundry"] and extension.state.road_history.size() == 3, "terminal route accumulates stable destination and road history IDs")

	var legacy_source = Sim.new()
	legacy_source.start(0, 147, "optional")
	reach_map(legacy_source)
	legacy_source.state.scrap = 20
	legacy_source.command("choose_route", "route.brass_choir")
	legacy_source.state.version = 2
	legacy_source.state.travel_step = 1
	for field in ["route_history", "route_origin_site_id", "assignment_statuses", "road_history", "road_flags", "road_totals"]: legacy_source.state.erase(field)
	var migrated = Sim.new()
	check(migrated.restore(legacy_source.snapshot()), "version-two travel save migrates")
	check(migrated.state.version == 3 and migrated.state.travel_step == 0 and migrated.current_road_node().id == "road.brass.warning_wire", "legacy travel restarts before the first unskippable area")
	check(migrated.assignment_status("route.brass_choir") == "accepted", "legacy selected route migrates to accepted assignment state")

	print("EXPEDITION MAP: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
