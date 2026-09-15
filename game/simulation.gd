extends RefCounted
## Authoritative fixed-tick simulation. No scene, input, sound or wall-clock access.
var arena = preload("res://game/arena.gd").new()
var config = {}
var catalogue = {}
var evolution_recipes = {}
var frames = {}
var bosses = {}
var chapter = {}
var routes = {}
var state = {}
var events: Array = []

func _init():
	config = JSON.parse_string(FileAccess.get_file_as_string("res://content/slices/first_shift.json"))
	chapter = JSON.parse_string(FileAccess.get_file_as_string("res://content/chapter/first_chapter.json"))
	for route in chapter.routes: routes[route.id] = route
	config.arena = arena.data.bounds
	config.relay.x = arena.data.relay[0]
	config.relay.y = arena.data.relay[1]
	config.relay.radius = arena.data.repair_radius
	var item_content = JSON.parse_string(FileAccess.get_file_as_string("res://content/items/first_slice.json"))
	for item in item_content.items:
		catalogue[item.id] = item
	for recipe in item_content.evolutions:
		evolution_recipes[recipe.id] = recipe
	for frame in JSON.parse_string(FileAccess.get_file_as_string("res://content/frames/first_chapter.json")).frames:
		frames[frame.id] = frame
	for boss in JSON.parse_string(FileAccess.get_file_as_string("res://content/bosses/first_slice.json")).bosses:
		bosses[boss.id] = boss

func start(doctrine: int = 0, seed_value: int = 147, mode: String = "relay", frame_id: String = "frame.pilgrim", run_id: String = ""):
	arena.load_file("res://content/arenas/collapsed_workshop.json")
	if not frames.has(frame_id): frame_id = "frame.pilgrim"
	var frame = frames[frame_id]
	state = {"mode": "optional" if mode == "optional" else "relay", "machines": [], "version": 3, "run_id": run_id if run_id != "" else "test-%d-%d-%s" % [seed_value, doctrine, frame_id], "frame_id": frame_id, "max_hp": float(frame.structure), "move_speed": float(frame.speed), "repair_grace_ticks": int(frame.repair_grace_ticks), "knockback_multiplier": float(frame.knockback_multiplier), "keeper_shove_segment": "", "repair_grace_until": 0, "arena_id": arena.data.id, "site_id": "site.collapsed_workshop", "route": "", "route_history": [], "route_origin_site_id": "", "travel_step": 0, "assignment_statuses": {}, "road_history": [], "road_flags": [], "road_totals": {"route_cost": 0, "service_cost": 0, "scrap_delta": 0, "structure_delta": 0.0}, "objective": [], "objective_complete": false, "objective_lock_until": 0, "weapon_lock_until": 0, "memory_id": "", "memory_ids": [], "chapter_complete": false, "pressure_until": 0, "pressure_multiplier": 1.0, "seed": seed_value, "rng": maxi(1, seed_value), "tick": 0, "phase": "combat", "paused": false,
		"wave": 1, "wave_tick": 0, "doctrine": doctrine, "position": arena.point(arena.data.start), "facing": Vector2.UP,
		"hp": float(frame.structure), "relay_hp": float(config.relay.structure * config.relay.starting_fraction), "progress": 0.0,
		"scrap": int(config.economy.starting_scrap), "shards": 0, "kills": 0, "next_id": 1,
		"weapons": [], "reserve": [], "catalysts": [], "gifts": [], "enemies": [], "pickups": [], "hazards": [],
		"offers": [], "locked": "", "rerolls": 0, "hurt_until": 0, "boss_spawned": false,
		"boss_dead": false, "evolved": false, "evolutions": [], "service_used": false, "repairs": 0.0, "damage": {}, "kills_by_weapon": {},
		"relay_last_hit": -999, "relay_damage_sources": {}, "relay_last_source": "", "backup_absorbed": 0.0, "calibrated": false, "service_active": false, "motes_left": 0, "last_reason": "", "forecast": false, "transactions": [], "fulfilled": false,
		"spawn_count": 0, "active_machine": "", "repair_blocked_until": 0, "signal_reserve": 0,
		"damage_taken": {}, "damage_by_wave": {}, "last_damage_source": "", "scrap_sources": {"starting": int(config.economy.starting_scrap)},
		"scrap_by_segment": {"site.collapsed_workshop:wave_1": int(config.economy.starting_scrap)}, "completed_site_ids": [], "defeated_boss_ids": [],
		"metrics": {"first_contact_tick": -1, "longest_threat_gap": 0, "threat_gap_started": 0, "had_threat": false, "repairs_started": 0, "repairs_interrupted": 0, "useful_repairs": 0, "wasted_repairs": 0, "dead_shop_visits": 0},
		"result_summary": {}, "component_tag": "", "inspection": "", "scrap_tax_progress": 0, "censer_defeats": 0, "ashen_defeats": 0}
	var starts = ["weapon.nailer_small_mercies", "weapon.bell_last_shift", "weapon.candle_nailer", "weapon.procession_gear"]
	state.doctrine = clampi(doctrine, 0, starts.size() - 1)
	state.weapons.append(make_weapon(starts[state.doctrine]))
	for machine in config.optional_repairs.machines:
		state.machines.append({"id": machine.id, "progress": 0.0, "complete": false, "deferred": ""})
	events.clear()
	call_deferred_spawn = false
	deferred_spawn_id = ""

func make_weapon(id: String, rank: int = 1):
	return {"id": id, "rank": rank, "ready": 0, "evolution": "", "rail": false, "toll": false}

func weapon_evolution_id(w: Dictionary) -> String:
	var id = str(w.get("evolution", ""))
	if id != "": return id
	if w.get("rail", false): return "evolution.mercy_rail"
	if w.get("toll", false): return "evolution.great_toll"
	return ""

func weapon_evolved(w: Dictionary) -> bool:
	return weapon_evolution_id(w) != ""

func evolution_rule(w: Dictionary) -> Dictionary:
	return config.evolution_rules.get(weapon_evolution_id(w), {})

func weapon_rank_rule(w: Dictionary) -> Dictionary:
	var rule: Dictionary = {}
	if weapon_evolved(w) or not config.weapons.has(w.id): return rule
	var rank_rules = config.weapons[w.id].get("rank_rules", {})
	for rank in range(2, mini(3, int(w.rank)) + 1):
		for field in rank_rules.get(str(rank), {}):
			if field not in ["id", "name", "description"]: rule[field] = rank_rules[str(rank)][field]
	return rule

func resolved_weapon_rule(w: Dictionary) -> Dictionary:
	var data: Dictionary = config.weapons[w.id].duplicate(true)
	var override = evolution_rule(w) if weapon_evolved(w) else weapon_rank_rule(w)
	for field in override: data[field] = override[field]
	return data

func weapon_rank_behavior_ids(w: Dictionary) -> Array:
	var result: Array = []
	if weapon_evolved(w) or not config.weapons.has(w.id): return result
	var rank_rules = config.weapons[w.id].get("rank_rules", {})
	for rank in range(2, mini(3, int(w.rank)) + 1):
		var rank_data = rank_rules.get(str(rank), {})
		if rank_data.get("id", "") != "": result.append(rank_data.id)
	return result

func weapon_rank_summary(w: Dictionary) -> String:
	if weapon_evolved(w) or int(w.rank) <= 1: return ""
	var rank_data = config.weapons[w.id].get("rank_rules", {}).get(str(mini(3, int(w.rank))), {})
	return str(rank_data.get("name", ""))

func evolution_recipe_state(recipe_id: String) -> String:
	if has_evolution(recipe_id): return "COMPLETED"
	if not evolution_recipes.has(recipe_id): return "UNKNOWN"
	var recipe = evolution_recipes[recipe_id]
	var rank = 0
	for w in state.get("weapons", []) + state.get("reserve", []):
		if w.id == recipe.base_item_id and not weapon_evolved(w): rank = maxi(rank, int(w.rank))
	if rank >= int(recipe.required_rank) and recipe.required_catalyst_id in state.get("catalysts", []): return "READY"
	if rank >= int(recipe.required_rank): return "NEEDS CATALYST"
	if rank > 0: return "RANK %s / III" % ["I", "II", "III"][rank - 1]
	return "BASE NOT OWNED"

func has_evolution(id: String) -> bool:
	return id in state.get("evolutions", [])

func has_gift(id: String) -> bool:
	return id in state.get("gifts", [])

func saint_max_structure() -> float:
	return float(state.get("max_hp", config.saint.structure))

func saint_speed() -> float:
	return float(state.get("move_speed", config.saint.speed))

func random_int(limit: int) -> int:
	state.rng = (int(state.rng) * 48271) % 2147483647
	return int(state.rng) % maxi(1, limit)

func emit(kind: String, payload: Dictionary = {}):
	payload["kind"] = kind
	payload["tick"] = state.tick
	payload["event_id"] = "%d:%d" % [state.tick, events.size()]
	events.append(payload)

func relay_position() -> Vector2:
	return arena.point(arena.data.relay)

func command(action: String, value = null) -> String:
	if state.is_empty():
		return "NO_RUN"
	if action == "pause":
		if state.phase != "combat": return "OUTSIDE_WINDOW"
		state.paused = not state.paused
		return "OK"
	if state.phase == "route":
		var route_result = choose_route(str(value)) if action == "choose_route" else "OUTSIDE_WINDOW"
		if route_result == "OK": state.last_reason = route_result
		return route_result
	if state.phase == "travel":
		var travel_result = choose_road_option(str(value)) if action == "choose_road_option" else (advance_travel() if action == "advance_travel" else "OUTSIDE_WINDOW")
		return travel_result
	if state.phase == "memory":
		if action != "accept_memory": return "OUTSIDE_WINDOW"
		if bool(current_route().get("terminal", true)):
			state.chapter_complete = true
			finish(true, current_route().memory.conclusion)
			emit("chapter_complete", {"memory_id": state.memory_id, "route": state.route, "route_history": state.route_history.duplicate()})
		else:
			state.phase = "route"
			refresh_assignments()
			state.last_reason = current_route().memory.conclusion
			emit("routes_opened", {"routes": available_routes().map(func(route): return route.id), "travel_salvage": int(current_route().get("route_salvage", 0))})
		return "OK"
	if state.phase != "shop":
		return "OUTSIDE_WINDOW"
	var result = "INVALID_COMMAND"
	match action:
		"continue":
			state.wave += 1
			state.wave_tick = 0
			state.spawn_count = 0
			state.phase = "combat"
			state.boss_spawned = false
			result = "OK"
		"buy": result = buy(int(value))
		"reroll":
			if state.rerolls >= config.economy.reroll_costs.size(): result = "NO_REFRESHES"
			elif state.scrap < config.economy.reroll_costs[state.rerolls]: result = "INSUFFICIENT_SCRAP"
			else:
				state.scrap -= int(config.economy.reroll_costs[state.rerolls])
				state.rerolls += 1
				roll_shop()
				result = "OK"
		"lock":
			if int(value) >= 0 and int(value) < state.offers.size():
				state.locked = "" if state.locked == state.offers[int(value)] else state.offers[int(value)]
				result = "OK"
		"sell", "dismantle":
			var index = int(value)
			if index >= 0 and index < state.weapons.size():
				if state.weapons.size() == 1: result = "LAST_WEAPON"
				else:
					var w = state.weapons[index]
					var refund_fraction = 0.4 if action == "dismantle" else config.economy.sell_fraction
					if action == "dismantle" and has_gift("gift.black_ledger"):
						refund_fraction = catalogue["gift.black_ledger"].tradeoff_value
						state.component_tag = component_tag_for(w.id)
					state.scrap += int(floor(catalogue[w.id].cost_scrap * pow(2, w.rank - 1) * refund_fraction))
					state.weapons.remove_at(index)
					if action == "dismantle" and state.component_tag != "": apply_component_lead()
					result = "OK"
		"sell_gift", "dismantle_gift":
			var index = int(value)
			if index >= 0 and index < state.gifts.size():
				var gift_id = state.gifts[index]
				state.scrap += int(floor(catalogue[gift_id].cost_scrap * (0.25 if action == "dismantle_gift" else config.economy.sell_fraction)))
				var ledger_stamp = action == "dismantle_gift" and gift_id != "gift.black_ledger" and has_gift("gift.black_ledger")
				if ledger_stamp: state.component_tag = component_tag_for(gift_id)
				state.gifts.remove_at(index)
				if ledger_stamp: apply_component_lead()
				result = "OK"
		"reserve":
			var index = int(value)
			if state.reserve.size() > 0: result = "RESERVE_FULL"
			elif state.weapons.size() <= 1: result = "LAST_WEAPON"
			elif index >= 0 and index < state.weapons.size():
				state.reserve.append(state.weapons.pop_at(index))
				result = "OK"
		"equip":
			if state.reserve.is_empty(): result = "RESERVE_EMPTY"
			elif state.weapons.size() >= config.economy.active_slots: result = "ACTIVE_SLOTS_FULL"
			else:
				state.weapons.append(state.reserve.pop_back())
				result = "OK"
		"combine": result = combine_owned()
		"evolve": result = evolve_weapon(str(value) if value != null else "")
	state.last_reason = result
	if result == "OK":
		state.transactions.append({"tick": state.tick, "site_id": state.site_id, "wave": state.wave, "action": action, "value": value})
		update_fulfilment()
	return result

func current_route() -> Dictionary:
	return routes.get(state.get("route", ""), {})

func is_destination() -> bool:
	return state.get("site_id", "site.collapsed_workshop") != "site.collapsed_workshop"

func current_wave_count() -> int:
	return int(current_route().get("wave_count", config.wave_count)) if is_destination() else int(config.wave_count)

func current_wave_ticks() -> int:
	return int(current_route().get("wave_ticks", config.wave_ticks)) if is_destination() else int(config.wave_ticks)

func current_boss_id() -> String:
	return str(current_route().get("boss", config.boss)) if is_destination() else str(config.boss)

func current_enemy_pool() -> Array:
	return current_route().get("enemy_pool", config.enemies.keys()) if is_destination() else config.enemies.keys()

func available_routes() -> Array:
	var result: Array = []
	var visible_ids: Array = []
	for edge in chapter.get("expedition_map", {}).get("edges", []):
		if str(edge.from_site_id) == str(state.site_id) and routes.has(str(edge.route_id)) and str(edge.route_id) not in visible_ids:
			visible_ids.append(str(edge.route_id))
	for route in chapter.routes:
		if route.id in visible_ids or (visible_ids.is_empty() and str(route.get("from_site_id", chapter.expedition_map.origin_site_id)) == str(state.site_id)):
			result.append(route)
	return result

func assignment_status(route_id: String) -> String:
	if state.get("route", "") == route_id and state.get("phase", "") in ["travel", "combat", "shop", "memory", "won", "lost"]:
		return "accepted"
	if state.get("assignment_statuses", {}).has(route_id):
		return str(state.assignment_statuses[route_id])
	for route in available_routes():
		if route.id == route_id: return "available"
	return "unavailable"

func refresh_assignments():
	for route_id in state.assignment_statuses:
		if state.assignment_statuses[route_id] != "accepted": state.assignment_statuses[route_id] = "unavailable"
	for route in available_routes(): state.assignment_statuses[route.id] = "available"

func road_nodes_for(route: Dictionary) -> Array:
	if route.has("road_nodes"): return route.road_nodes
	# Compatibility extension point: newly-authored sites may land with legacy travel
	# beats before they receive bespoke road choices. Each beat still requires a command.
	var nodes: Array = []
	for i in range(route.get("travel", []).size()):
		nodes.append({"id": "%s.passage.%d" % [route.id, i], "kind": "passage", "name": "Road passage", "news": route.travel[i], "risk": "No reported hazard.", "choices": [{"id": "%s.continue.%d" % [route.id, i], "label": "Continue", "description": "Follow the authored road.", "cost": 0, "structure_delta": 0, "scrap_delta": 0, "flag": "%s.passage.%d" % [route.id, i], "result": route.travel[i]}]})
	return nodes

func current_road_node() -> Dictionary:
	var route = current_route()
	if route.is_empty(): return {}
	var nodes = road_nodes_for(route)
	var index = int(state.get("travel_step", 0))
	return nodes[index] if index >= 0 and index < nodes.size() else {}

func choose_route(route_id: String) -> String:
	if not routes.has(route_id): return "INVALID_ROUTE"
	var route = routes[route_id]
	if state.site_id not in route.get("from_sites", ["site.collapsed_workshop"]): return "ROUTE_NOT_CONNECTED"
	if assignment_status(route_id) != "available": return "ROUTE_UNAVAILABLE"
	if state.scrap < int(route.cost): return "INSUFFICIENT_SCRAP"
	state.scrap -= int(route.cost)
	state.route = route_id
	state.route_history.append(route_id)
	state.route_origin_site_id = state.site_id
	state.travel_step = 0
	state.road_totals.route_cost += int(route.cost)
	state.road_totals.scrap_delta -= int(route.cost)
	state.assignment_statuses[route_id] = "accepted"
	state.phase = "travel"
	state.enemies.clear()
	state.hazards.clear()
	state.pickups.clear()
	state.transactions.append({"tick": state.tick, "site_id": state.site_id, "wave": state.wave, "action": "choose_route", "value": route_id, "cost": int(route.cost)})
	emit("route_chosen", {"route": route_id, "assignment_id": route.get("assignment_id", route_id), "road_nodes": road_nodes_for(route).size()})
	return "OK"

func advance_travel() -> String:
	return "ROAD_CHOICE_REQUIRED" if not current_road_node().is_empty() else "INVALID_ROUTE"

func choose_road_option(option_id: String) -> String:
	var route = current_route()
	var node = current_road_node()
	if route.is_empty() or node.is_empty(): return "INVALID_ROUTE"
	var choice: Dictionary = {}
	for candidate in node.choices:
		if str(candidate.id) == option_id:
			choice = candidate
			break
	if choice.is_empty(): return "INVALID_ROAD_OPTION"
	var cost = int(choice.get("cost", 0))
	if state.scrap < cost: return "INSUFFICIENT_SCRAP"
	var before_hp = float(state.hp)
	var scrap_delta = int(choice.get("scrap_delta", 0)) - cost
	state.scrap += scrap_delta
	state.hp = clampf(state.hp + float(choice.get("structure_delta", 0)), 1.0, saint_max_structure())
	var actual_structure_delta = float(state.hp) - before_hp
	var flag = str(choice.get("flag", ""))
	if flag != "" and flag not in state.road_flags: state.road_flags.append(flag)
	var record = {"route_id": state.route, "node_id": node.id, "choice_id": option_id, "kind": node.kind, "scrap_delta": scrap_delta, "structure_delta": actual_structure_delta, "flag": flag, "result": str(choice.get("result", ""))}
	state.road_history.append(record)
	state.road_totals.service_cost += cost
	state.road_totals.scrap_delta += scrap_delta
	state.road_totals.structure_delta += actual_structure_delta
	state.transactions.append({"tick": state.tick, "site_id": state.site_id, "wave": state.wave, "action": "choose_road_option", "value": option_id, "node_id": node.id, "scrap_delta": scrap_delta, "structure_delta": actual_structure_delta})
	emit("road_choice", record.duplicate(true))
	state.last_reason = str(choice.get("result", "The road remembers the choice."))
	state.travel_step += 1
	if state.travel_step >= road_nodes_for(route).size(): enter_destination(route)
	else: emit("travel_advanced", {"route": state.route, "step": state.travel_step, "node_id": current_road_node().id})
	return "OK"

func enter_destination(route: Dictionary):
	arena.load_file(route.arena_path)
	state.arena_id = arena.data.id
	state.site_id = route.site_id
	var arrival_floor = saint_max_structure() * float(route.get("arrival_repair_floor", 0.0))
	var arrival_repair = maxf(0.0, arrival_floor - state.hp)
	state.hp = maxf(state.hp, arrival_floor)
	state.position = arena.point(arena.data.start)
	state.facing = Vector2.UP
	state.wave = 1
	state.wave_tick = 0
	state.phase = "combat"
	state.boss_spawned = false
	state.boss_dead = false
	state.spawn_count = 0
	state.active_machine = ""
	state.repair_blocked_until = 0
	state.repair_grace_until = 0
	state.service_used = false
	state.service_active = false
	state.calibrated = false
	state.motes_left = 0
	state.forecast = false
	state.objective.clear()
	for node in route.objective.nodes:
		state.objective.append({"id": node.id, "progress": 0.0, "complete": false})
	state.objective_complete = false
	state.objective_lock_until = 0
	state.weapon_lock_until = 0
	state.memory_id = ""
	state.pressure_until = 0
	state.pressure_multiplier = 1.0
	emit("destination_arrived", {"route": state.route, "site_id": state.site_id, "arrival_repair": arrival_repair})

func objective_data() -> Dictionary:
	return current_route().get("objective", {})

func update_destination_objective():
	var objective = objective_data()
	if objective.is_empty() or state.objective_complete: return
	for i in range(state.objective.size()):
		if not destination_node_valid(i, state.position, float(objective.radius)): continue
		var rate = (config.doctrine_rules.fulfilled_workshop_rate if state.fulfilled else config.doctrine_rules.workshop_rate) if state.doctrine == 0 else 1.0
		if "catalyst.saints_rivet" in state.catalysts: rate *= config.catalysts["catalyst.saints_rivet"].repair_multiplier
		advance_destination_node(i, rate, state.position)
		break

func destination_node_valid(index: int, source: Vector2, radius: float) -> bool:
	var objective = objective_data()
	if objective.is_empty() or index < 0 or index >= state.objective.size() or state.objective[index].complete: return false
	if state.tick < int(state.get("objective_lock_until", 0)): return false
	var node_data = objective.nodes[index]
	var p = Vector2(node_data.position[0], node_data.position[1])
	if source.distance_to(p) >= radius: return false
	if objective.type == "RECOVER_SEQUENCE":
		for earlier in range(index):
			if not state.objective[earlier].complete: return false
	if objective.type == "VENT_ROTATION" and index != active_destination_node_index(): return false
	if objective.type == "CALIBRATE_NODES":
		return not state.enemies.any(func(enemy): return enemy.hp > 0 and enemy.p.distance_to(p) < float(objective.safety_radius))
	return true

func active_destination_node_index() -> int:
	if state.objective.is_empty(): return -1
	var objective = objective_data()
	if objective.get("type", "") != "VENT_ROTATION":
		for i in range(state.objective.size()):
			if not state.objective[i].complete: return i
		return -1
	var start = int(state.wave_tick / int(objective.get("active_interval", 240))) % state.objective.size()
	for offset in range(state.objective.size()):
		var index = (start + offset) % state.objective.size()
		if not state.objective[index].complete: return index
	return -1

func working_quiet_objective() -> bool:
	if not is_destination() or objective_data().get("type", "") != "QUIET_REPAIR": return false
	for i in range(state.objective.size()):
		if destination_node_valid(i, state.position, float(objective_data().radius)): return true
	return false

func advance_destination_node(index: int, amount: float, source: Vector2):
	var objective = objective_data()
	var node = state.objective[index]
	var node_data = objective.nodes[index]
	var p = Vector2(node_data.position[0], node_data.position[1])
	node.progress = minf(float(objective.required_ticks), node.progress + amount)
	emit("objective_repair_pulse", {"position": p, "source": source, "node_id": node.id, "amount": amount})
	if node.progress >= float(objective.required_ticks):
		node.complete = true
		emit("objective_node_complete", {"position": p, "node_id": node.id})
		emit("repair", {"position": p, "source": source})
	state.objective_complete = state.objective.all(func(node): return node.complete)
	if state.objective_complete: emit("objective_complete", {"objective_id": objective.id})

func complete_workshop():
	# The Foreman's road-worthy salvage guarantees that neither authored branch can dead-end.
	record_scrap("foreman_travel", 8)
	state.phase = "route"
	refresh_assignments()
	state.last_reason = "The Foreman is silent. Two roads answer the repaired workshop."
	state.enemies.clear()
	state.hazards.clear()
	state.pickups.clear()
	if "site.collapsed_workshop" not in state.completed_site_ids: state.completed_site_ids.append("site.collapsed_workshop")
	if str(config.boss) not in state.defeated_boss_ids: state.defeated_boss_ids.append(str(config.boss))
	emit("routes_opened", {"routes": available_routes().map(func(route): return route.id), "travel_salvage": 8})

func open_memory():
	state.phase = "memory"
	state.memory_id = current_route().memory.id
	if state.memory_id not in state.memory_ids: state.memory_ids.append(state.memory_id)
	state.last_reason = current_route().memory.text
	state.enemies.clear()
	state.hazards.clear()
	state.pickups.clear()
	if state.site_id not in state.completed_site_ids: state.completed_site_ids.append(state.site_id)
	if current_boss_id() not in state.defeated_boss_ids: state.defeated_boss_ids.append(current_boss_id())
	if not bool(current_route().get("terminal", true)): record_scrap("route_salvage", int(current_route().get("route_salvage", 0)))
	emit("memory_recovered", {"memory_id": state.memory_id, "route": state.route})

func evolve_weapon(requested: String = "") -> String:
	for recipe_id in config.evolutions:
		if requested != "" and requested != recipe_id: continue
		var recipe = evolution_recipes[recipe_id]
		if recipe.required_catalyst_id not in state.catalysts: continue
		for w in state.weapons + state.reserve:
			if w.id == recipe.base_item_id and w.rank == int(recipe.required_rank) and not weapon_evolved(w):
				w.evolution = recipe.id
				w.rail = recipe.id == "evolution.mercy_rail"
				w.toll = recipe.id == "evolution.great_toll"
				state.evolved = true
				if recipe.id not in state.evolutions: state.evolutions.append(recipe.id)
				state.catalysts.erase(recipe.required_catalyst_id)
				emit("evolution", {"position": state.position, "recipe": recipe.id, "name": recipe.name, "geometry": recipe.result_geometry, "effects": recipe.result_effects.duplicate()})
				return "OK"
	return "MISSING_INGREDIENT"

func component_tag_for(id: String) -> String:
	var ignored = ["shot", "beam", "ground", "risk", "shop"]
	for tag in catalogue[id].get("tags", []):
		if tag not in ignored: return tag
	return ""

func apply_component_lead():
	if state.component_tag == "" or state.offers.size() < 2: return
	var owned = (state.weapons + state.reserve).map(func(w): return w.id)
	var visible = state.offers.duplicate()
	visible.remove_at(1)
	var leads = config.weapons.keys().filter(func(id): return id not in owned and id not in visible and can_fit_weapon(id) and state.component_tag in catalogue[id].tags)
	if leads.is_empty(): leads = config.weapons.keys().filter(func(id): return id not in visible and can_fit_weapon(id) and state.component_tag in catalogue[id].tags)
	if not leads.is_empty(): state.offers[1] = shop_pick(leads, 11)

func combine_first(all: Array, required_id: String = "") -> Dictionary:
	for i in range(all.size()):
		for j in range(i + 1, all.size()):
			if (required_id == "" or all[i].id == required_id) and all[i].id == all[j].id and all[i].rank == all[j].rank and all[i].rank < 3 and not weapon_evolved(all[i]) and not weapon_evolved(all[j]):
				var merged = make_weapon(all[i].id, all[i].rank + 1)
				all.remove_at(j)
				all.remove_at(i)
				all.push_front(merged)
				return merged
	return {}

func combine_owned() -> String:
	var all = state.weapons + state.reserve
	var merged = combine_first(all)
	if merged.is_empty(): return "NO_MATCHING_PAIR"
	state.weapons = all.slice(0, int(config.economy.active_slots))
	state.reserve = all.slice(int(config.economy.active_slots))
	emit("rank_up", {"weapon": merged.id, "rank": merged.rank, "behaviors": weapon_rank_behavior_ids(merged)})
	return "OK"

func buy(index: int) -> String:
	if index < 0 or index >= state.offers.size(): return "INVALID_OFFER"
	var id = state.offers[index]
	if id == "": return "SOLD"
	if id.begins_with("service."):
		if id not in ["service.repair", "service.doctrine", "service.calibrate"]: return "INVALID_OFFER"
		var cost = int(config.shop_rules.services[state.doctrine].cost) if id == "service.doctrine" else int(config.economy.repair_cost)
		if state.scrap < cost: return "INSUFFICIENT_SCRAP"
		if id == "service.repair":
			if state.hp >= saint_max_structure() and (optional_mode() or state.relay_hp >= config.relay.structure): return "ALREADY_REPAIRED"
			state.hp = minf(saint_max_structure(), state.hp + config.economy.repair_amount)
			repair_relay(config.economy.repair_amount)
		elif id == "service.calibrate":
			if state.calibrated: return "SERVICE_USED"
			state.calibrated = true
		else:
			if state.service_used: return "SERVICE_USED"
			if state.doctrine == 0 and state.hp >= saint_max_structure() and (optional_mode() or state.relay_hp >= config.relay.structure): return "ALREADY_REPAIRED"
			state.service_used = true
			state.service_active = true
			match state.doctrine:
				0:
					state.hp = minf(saint_max_structure(), state.hp + (config.doctrine_rules.workshop_service_relay if optional_mode() else config.doctrine_rules.workshop_service_hp))
					repair_relay(config.doctrine_rules.workshop_service_relay)
				1:
					state.forecast = true
				2:
					state.motes_left = int(config.shop_rules.mourner_motes)
				3:
					# Procession service widens orbiting mechanisms for one pressure beat.
					state.forecast = true
		state.scrap -= cost
	elif id in config.catalysts:
		if id in state.catalysts: return "ALREADY_OWNED"
		var cost = int(catalogue[id].cost_relic_shards)
		if state.shards < cost: return "INSUFFICIENT_SHARDS"
		state.shards -= cost
		state.catalysts.append(id)
	elif id in config.gifts:
		if id in state.gifts: return "ALREADY_OWNED"
		if state.gifts.size() >= int(config.gift_slots): return "GIFT_SLOTS_FULL"
		var cost = int(catalogue[id].cost_scrap)
		if state.scrap < cost: return "INSUFFICIENT_SCRAP"
		state.scrap -= cost
		state.gifts.append(id)
		emit("gift_acquired", {"gift": id, "position": state.position})
	else:
		var cost = int(catalogue[id].cost_scrap)
		if state.scrap < cost: return "INSUFFICIENT_SCRAP"
		var all = (state.weapons + state.reserve).duplicate(true)
		all.append(make_weapon(id))
		# A purchase explicitly includes any displayed duplicate combines.
		var rank_ups: Array = []
		while true:
			var merged = combine_first(all, id)
			if merged.is_empty(): break
			rank_ups.append(merged)
		if all.size() > config.economy.active_slots + config.economy.reserve_slots: return "LOADOUT_FULL"
		state.scrap -= cost
		state.weapons = all.slice(0, int(config.economy.active_slots))
		state.reserve = all.slice(int(config.economy.active_slots))
		for merged in rank_ups: emit("rank_up", {"weapon": merged.id, "rank": merged.rank, "behaviors": weapon_rank_behavior_ids(merged)})
		if state.component_tag != "" and state.component_tag in catalogue[id].tags: state.component_tag = ""
	state.offers[index] = ""
	if state.locked == id: state.locked = ""
	return "OK"

func update_fulfilment():
	var tags = ["labour", "witness", "mourn", "orbit"]
	var unique = {}
	for w in state.weapons:
		if tags[state.doctrine] in catalogue[w.id].tags: unique[w.id] = true
	state.fulfilled = unique.size() >= 2

func can_fit_weapon(id: String) -> bool:
	var all = (state.weapons + state.reserve).duplicate(true)
	all.append(make_weapon(id))
	for rank in [1, 2]:
		var matches = all.filter(func(w): return w.id == id and w.rank == rank and not weapon_evolved(w))
		while matches.size() >= 2:
			all.erase(matches.pop_back())
			all.erase(matches.pop_back())
			all.append(make_weapon(id, rank + 1))
	return all.size() <= config.economy.active_slots + config.economy.reserve_slots

func shop_pick(ids: Array, slot: int) -> String:
	if ids.is_empty(): return "service.calibrate"
	# Local context hash never consumes combat RNG or mutates simulation time.
	# Empty P14.1 fields are omitted so unchanged unevolved builds retain their established offers.
	var signature_items = []
	for weapon in state.weapons + state.reserve:
		var stable_weapon = weapon.duplicate()
		if stable_weapon.get("evolution", "") == "": stable_weapon.erase("evolution")
		signature_items.append(stable_weapon)
	var signature = var_to_str(signature_items + state.catalysts)
	var key = "%d/%d/%d/%d/%d/%s" % [state.seed, state.wave, state.doctrine, state.rerolls, slot, signature]
	var index = key.sha256_text().substr(0, 8).hex_to_int() % ids.size()
	return ids[index]

func evolution_path_offer() -> String:
	var best_recipe = {}
	var best_rank = -1
	for recipe_id in config.evolutions:
		if has_evolution(recipe_id): continue
		var recipe = evolution_recipes[recipe_id]
		var rank = 0
		for w in state.weapons + state.reserve:
			if w.id == recipe.base_item_id and not weapon_evolved(w): rank = maxi(rank, int(w.rank))
		if rank > best_rank:
			best_rank = rank
			best_recipe = recipe
	if best_recipe.is_empty(): return "service.calibrate"
	if best_recipe.required_catalyst_id not in state.catalysts: return best_recipe.required_catalyst_id
	if best_rank < int(best_recipe.required_rank) and can_fit_weapon(best_recipe.base_item_id): return best_recipe.base_item_id
	return "service.calibrate"

func roll_shop():
	var upgrades = []
	var fresh = []
	var owned = []
	for w in state.weapons + state.reserve:
		owned.append(w.id)
		if w.rank < 3 and not weapon_evolved(w) and can_fit_weapon(w.id) and catalogue[w.id].cost_scrap <= state.scrap and w.id not in upgrades: upgrades.append(w.id)
	for id in config.weapons:
		if id not in owned and can_fit_weapon(id):
			fresh.append(id)
			if config.shop_rules.doctrine_tags[state.doctrine] in catalogue[id].tags: fresh.append(id)
	var support = []
	var preferred = config.shop_rules.threat_support[mini(2, int((state.wave + 1) / 2))]
	for id in config.catalysts:
		if id != "catalyst.saints_rivet" and id not in state.catalysts: support.append(id)
	for id in config.gifts:
		if id not in state.gifts and state.gifts.size() < int(config.gift_slots): support.append(id)
	var path = evolution_path_offer()
	var affordable_fresh = fresh.filter(func(id): return catalogue[id].cost_scrap <= state.scrap)
	var current_offer = shop_pick(upgrades, 0) if not upgrades.is_empty() else shop_pick(affordable_fresh, 0)
	state.offers = [current_offer, shop_pick(fresh, 1), path, preferred if preferred in support else shop_pick(support, 3), "service.repair", "service.doctrine"]
	if state.hp >= saint_max_structure() and (optional_mode() or state.relay_hp >= config.relay.structure): state.offers[4] = "service.calibrate"
	# A six-role workshop must not present the same fallback card repeatedly.
	var seen = {}
	for i in range(4):
		var id = state.offers[i]
		if id != "" and id in seen:
			var replacements = (fresh + upgrades + support).filter(func(candidate): return candidate not in seen and candidate not in state.catalysts)
			state.offers[i] = shop_pick(replacements, 10 + i) if not replacements.is_empty() else ("service.calibrate" if "service.calibrate" not in seen else "")
		id = state.offers[i]
		if id != "": seen[id] = true
	apply_component_lead()
	if state.locked != "" and state.locked not in state.offers:
		state.offers[1 if state.locked in config.weapons else 3] = state.locked

func warning_multiplier() -> float:
	return config.shop_rules.bell_warning_multiplier if state.service_active and state.doctrine == 1 else 1.0

func wave_profile(wave_number: int = -1) -> Dictionary:
	if is_destination():
		var route = current_route()
		var authored_profiles: Array = route.get("wave_profiles", [])
		var destination_wave = state.wave if wave_number < 0 else wave_number
		if not authored_profiles.is_empty():
			return authored_profiles[clampi(destination_wave - 1, 0, authored_profiles.size() - 1)]
		var pool: Array = route.enemy_pool
		var primary_index = clampi(destination_wave - 1, 0, pool.size() - 1)
		var support = pool.duplicate()
		support.erase(pool[primary_index])
		return {"name": route.name + " / PRESSURE %d" % destination_wave, "pressure": route.pressure.description, "primary": pool[primary_index], "primary_weight": 2, "support": support, "spawn_interval": maxi(config.combat.spawn_minimum, int(route.spawn_interval) - destination_wave * 8), "counters": ["movement", "control", "priority"]}
	var index = clampi((state.wave if wave_number < 0 else wave_number) - 1, 0, config.wave_profiles.size() - 1)
	return config.wave_profiles[index]

func forecast_data(wave_number: int = -1) -> Dictionary:
	var profile = wave_profile(state.wave + 1 if wave_number < 0 else wave_number)
	return {
		"name": profile.name,
		"pressure": profile.pressure,
		"primary": config.enemies[profile.primary].short,
		"support": profile.support.map(func(id): return config.enemies[id].short),
		"counters": profile.counters.duplicate()
	}

func record_scrap(source: String, amount: int):
	state.scrap += amount
	state.scrap_sources[source] = int(state.scrap_sources.get(source, 0)) + amount
	var segment = site_wave_key()
	state.scrap_by_segment[segment] = int(state.scrap_by_segment.get(segment, 0)) + amount

func site_wave_key(wave_number: int = -1) -> String:
	return "%s:wave_%d" % [state.get("site_id", "site.collapsed_workshop"), state.wave if wave_number < 0 else wave_number]

func wave_from_segment(key: String) -> int:
	if ":wave_" in key: return int(key.get_slice(":wave_", 1))
	return int(key) if key.is_valid_int() else 0

func update_threat_metrics():
	var has_threat = state.enemies.any(func(e): return e.hp > 0)
	if has_threat:
		if state.metrics.first_contact_tick < 0: state.metrics.first_contact_tick = state.tick
		if not state.metrics.had_threat:
			state.metrics.longest_threat_gap = maxi(state.metrics.longest_threat_gap, state.tick - state.metrics.threat_gap_started)
		state.metrics.had_threat = true
	elif state.metrics.had_threat:
		state.metrics.had_threat = false
		state.metrics.threat_gap_started = state.tick

func enter_shop():
	state.phase = "shop"
	record_scrap("wave", int(config.economy.wave_scrap))
	if state.wave in [2, 4, 6]: state.shards += 1
	for p in state.pickups:
		if p.kind == "scrap": collect_scrap(int(p.amount), "uncollected_pickups")
	state.pickups.clear()
	state.enemies.clear()
	state.hazards.clear()
	state.rerolls = 0
	state.service_used = false
	state.service_active = false
	state.calibrated = false
	state.motes_left = 0
	roll_shop()
	var actionable = false
	for id in state.offers:
		if id in catalogue and catalogue[id].get("cost_scrap", 9999) <= state.scrap:
			actionable = true
			break
	if not actionable and state.scrap < config.economy.repair_cost: state.metrics.dead_shop_visits += 1
	emit("wave_complete")

func step(move: Vector2):
	events.clear()
	if state.is_empty() or state.phase != "combat" or state.paused: return
	state.tick += 1
	state.wave_tick += 1
	move = move.limit_length()
	if move.length() > 0.1: state.facing = move.normalized()
	var move_multiplier = catalogue["gift.spare_hand"].tradeoff_value if has_gift("gift.spare_hand") and working_optional_machine() else 1.0
	state.position = arena.move_body(state.position, move * saint_speed() * move_multiplier / config.tick_rate, config.saint.radius)
	if is_destination(): update_destination_objective()
	elif optional_mode(): update_optional_repairs()
	elif state.position.distance_to(relay_position()) < config.relay.radius:
		var rate = (config.doctrine_rules.fulfilled_workshop_rate if state.fulfilled else config.doctrine_rules.workshop_rate) if state.doctrine == 0 else 1.0
		if "catalyst.saints_rivet" in state.catalysts: rate *= config.catalysts["catalyst.saints_rivet"].repair_multiplier
		state.progress = minf(config.relay.required_ticks, state.progress + rate)
		if state.tick % 60 == 0: repair_relay(config.relay.repair_per_tick * 60 * rate)
	var profile = wave_profile()
	var interval = maxi(config.combat.spawn_minimum, int(profile.spawn_interval))
	if state.wave_tick % interval == 0 and state.enemies.size() < config.combat.enemy_limit:
		var support: Array = profile.support
		var cycle = int(profile.primary_weight) + support.size()
		var slot = state.spawn_count % maxi(1, cycle)
		var enemy_id = profile.primary if slot < int(profile.primary_weight) else support[(slot - int(profile.primary_weight)) % support.size()]
		spawn(enemy_id)
		state.spawn_count += 1
	var boss_wave = current_wave_count()
	if ((not is_destination() and state.wave == 6) or state.wave == boss_wave) and not state.boss_spawned:
		spawn(config.elite if not is_destination() and state.wave == 6 else current_boss_id())
		state.boss_spawned = true
	update_threat_metrics()
	update_enemies()
	update_weapons()
	update_pickups()
	update_hazards()
	update_threat_metrics()
	if state.hp <= 0: finish(false, "The Saint's structure failed.")
	elif not optional_mode() and state.relay_hp <= 0: finish(false, "The relay was destroyed.")
	elif state.wave == boss_wave and state.boss_dead and (not is_destination() or state.objective_complete):
		if is_destination(): open_memory()
		else: complete_workshop()
	elif state.wave_tick >= current_wave_ticks():
		if state.wave == boss_wave:
			if is_destination() and state.boss_dead and not state.objective_complete: finish(false, "The destination held, but its work remained unfinished.")
			else: finish(false, "The demolition schedule reached its final order.")
		elif state.wave == 6 and has_major(): finish(false, "The Memory Crane outlasted the shift.")
		else: enter_shop()

func optional_mode() -> bool:
	return state.get("mode", "relay") == "optional"

func workshop_machine_repairs_available() -> bool:
	# Destination scenes keep the Workshop machine array for save compatibility,
	# but only the Workshop owns these optional repair interactions.
	return optional_mode() and state.get("site_id", "site.collapsed_workshop") == "site.collapsed_workshop"

func working_optional_machine() -> bool:
	if not workshop_machine_repairs_available(): return false
	for i in range(state.machines.size()):
		if state.machines[i].complete: continue
		var p = Vector2(config.optional_repairs.machines[i].position[0], config.optional_repairs.machines[i].position[1])
		if state.position.distance_to(p) < config.optional_repairs.radius: return true
	return false

func update_optional_repairs():
	if not workshop_machine_repairs_available(): return
	var nearby = -1
	for i in range(state.machines.size()):
		var p = Vector2(config.optional_repairs.machines[i].position[0], config.optional_repairs.machines[i].position[1])
		if not state.machines[i].complete and state.position.distance_to(p) < config.optional_repairs.radius:
			nearby = i
			break
	if state.active_machine != "" and (nearby < 0 or state.machines[nearby].id != state.active_machine):
		var active_index = -1
		for i in range(state.machines.size()):
			if state.machines[i].id == state.active_machine: active_index = i; break
		if state.repair_grace_ticks > 0 and active_index >= 0:
			if state.repair_grace_until == 0:
				state.repair_grace_until = state.tick + state.repair_grace_ticks
				emit("frame_rule", {"frame_id": state.frame_id, "rule": "REPAIR_GRACE", "until": state.repair_grace_until})
			if state.tick <= state.repair_grace_until:
				nearby = active_index
			else:
				state.metrics.repairs_interrupted += 1
				emit("machine_repair_interrupted", {"machine_id": state.active_machine, "reason": "LEFT_WORK_RING"})
				state.active_machine = ""
				state.repair_grace_until = 0
		else:
			state.metrics.repairs_interrupted += 1
			emit("machine_repair_interrupted", {"machine_id": state.active_machine, "reason": "LEFT_WORK_RING"})
			state.active_machine = ""
	if nearby >= 0 and state.active_machine == state.machines[nearby].id and state.position.distance_to(Vector2(config.optional_repairs.machines[nearby].position[0], config.optional_repairs.machines[nearby].position[1])) < config.optional_repairs.radius:
		state.repair_grace_until = 0
	if nearby < 0 or state.tick < state.repair_blocked_until: return
	var candidate = state.machines[nearby]
	var candidate_data = config.optional_repairs.machines[nearby]
	if candidate_data.reward == "heal" and state.hp >= saint_max_structure():
		if candidate.deferred == "": emit("machine_repair_deferred", {"position": Vector2(candidate_data.position[0], candidate_data.position[1]), "machine_id": candidate.id, "reason": "INTEGRITY_FULL"})
		candidate.deferred = "INTEGRITY_FULL"
		return
	candidate.deferred = ""
	if state.active_machine != candidate.id:
		state.active_machine = candidate.id
		state.metrics.repairs_started += 1
		emit("machine_repair_started", {"position": Vector2(candidate_data.position[0], candidate_data.position[1]), "machine_id": candidate.id, "reward": candidate_data.description, "progress": candidate.progress})
	for i in range(state.machines.size()):
		var machine = state.machines[i]
		var data = config.optional_repairs.machines[i]
		var p = Vector2(data.position[0], data.position[1])
		if machine.complete or machine.id != state.active_machine: continue
		var rate = (config.doctrine_rules.fulfilled_workshop_rate if state.fulfilled else config.doctrine_rules.workshop_rate) if state.doctrine == 0 else 1.0
		if "catalyst.saints_rivet" in state.catalysts: rate *= config.catalysts["catalyst.saints_rivet"].repair_multiplier
		if has_gift("gift.spare_hand"): rate *= catalogue["gift.spare_hand"].effect_value
		advance_optional_machine(i, rate, state.position, true)
		break

func advance_optional_machine(index: int, amount: float, source = null, track_progress = false):
	var machine = state.machines[index]
	if machine.complete: return
	var data = config.optional_repairs.machines[index]
	var p = Vector2(data.position[0], data.position[1])
	var prior_bucket = int(machine.progress / 60.0)
	machine.progress = minf(config.optional_repairs.required_ticks, machine.progress + amount)
	if track_progress and int(machine.progress / 60.0) > prior_bucket: emit("machine_repair_progress", {"position": p, "machine_id": machine.id, "progress": machine.progress})
	if amount >= 2.0: emit("repair", {"position": p, "source": source, "amount": amount})
	if machine.progress < config.optional_repairs.required_ticks: return
	machine.complete = true
	if state.active_machine == machine.id: state.active_machine = ""
	state.metrics.useful_repairs += 1
	match data.reward:
		"scrap": record_scrap("optional_repair", int(data.amount))
		"heal": state.hp = minf(saint_max_structure(), state.hp + data.amount)
		"stun":
			var living = state.enemies.filter(func(enemy): return enemy.hp > 0)
			if living.is_empty(): state.signal_reserve = int(data.amount)
			else:
				for enemy in living:
					enemy.stun = maxi(enemy.stun, state.tick + int(data.amount))
					enemy.relay_strike_at = 0
	emit("machine_restored", {"position": p, "machine_id": machine.id, "reward": data.description})

func largest_entry(values: Dictionary) -> String:
	var winner = ""
	var amount = -1.0
	for key in values:
		if float(values[key]) > amount:
			winner = str(key)
			amount = float(values[key])
	return winner

func classify_failure() -> String:
	if state.phase == "won": return ""
	if state.last_reason == "The demolition schedule reached its final order.": return "BUILD_GEOMETRY"
	if state.last_reason == "The Memory Crane outlasted the shift.": return "THREAT_RESPONSE"
	if not optional_mode() and state.relay_hp <= 0: return "OBJECTIVE_NEGLECT"
	var source = state.last_damage_source
	if source in ["enemy.cinder_spitter", config.elite, current_boss_id()]: return "THREAT_RESPONSE"
	if state.scrap >= 20 and state.transactions.size() < 3: return "ECONOMY"
	if state.kills < state.wave * 30: return "BUILD_GEOMETRY"
	return "POSITIONING"

func evolution_status() -> String:
	var completed = []
	for weapon in state.weapons + state.reserve:
		var id = weapon_evolution_id(weapon)
		var label = id.trim_prefix("evolution.").to_upper()
		if id != "" and label not in completed: completed.append(label)
	if not completed.is_empty(): return "+".join(completed) + "_COMPLETED"
	for recipe_id in config.evolutions:
		if evolution_recipe_state(recipe_id) == "READY": return recipe_id.trim_prefix("evolution.").to_upper() + "_READY"
	for recipe_id in config.evolutions:
		if evolution_recipe_state(recipe_id) != "BASE NOT OWNED": return recipe_id.trim_prefix("evolution.").to_upper() + "_PURSUED"
	return "MERCY_RAIL_IGNORED"

func build_result_summary(won: bool) -> Dictionary:
	var completed = []
	for i in range(state.machines.size()):
		if state.machines[i].complete:
			completed.append({"id": state.machines[i].id, "reward": config.optional_repairs.machines[i].description})
	var top_weapon = largest_entry(state.damage)
	var worst_wave = largest_entry(state.damage_by_wave)
	var cause = "" if won else classify_failure()
	var result_memories: Array = state.memory_ids.duplicate()
	if result_memories.is_empty() and state.memory_id != "": result_memories.append(state.memory_id)
	var cue = "Try another doctrine and compare its workshop service."
	if not won:
		match cause:
			"THREAT_RESPONSE": cue = "Answer the forecast with control or priority range before the next pressure arrives."
			"POSITIONING": cue = "Keep one escape lane open and leave a marked blast before it resolves."
			"BUILD_GEOMETRY": cue = "Add a relic whose geometry answers the wave that stopped this build."
			"ECONOMY": cue = "Spend earlier on an affordable current-build improvement."
			"OBJECTIVE_NEGLECT": cue = "Break announced objective strikes before returning to repair work."
	elif state.chapter_complete: cue = "Repeat the pilgrimage through a different chain of sites and compare what this build preserves."
	elif completed.is_empty(): cue = "Try one optional machine when its visible reward solves the next decision."
	elif not state.evolved: cue = "Compare this reliable build with a visible evolution route next shift."
	return {
		"run_id": state.run_id,
		"won": won,
		"site_id": state.site_id,
		"boss_id": current_boss_id(),
		"route_id": state.route_history[0] if not state.route_history.is_empty() else state.route,
		"terminal_route_id": state.route,
		"route_ids": state.route_history.duplicate(),
		"optional_repairs": completed.size(),
		"memory_ids": result_memories,
		"evolution_ids": state.evolutions.duplicate(),
		"failure_cause": cause,
		"repairs": completed,
		"top_weapon": top_weapon,
		"top_weapon_damage": state.damage.get(top_weapon, 0.0),
		"worst_damage_wave": wave_from_segment(worst_wave),
		"worst_damage_segment": worst_wave,
		"worst_wave_damage": state.damage_by_wave.get(worst_wave, 0.0),
		"scrap_sources": state.scrap_sources.duplicate(true),
		"scrap_by_segment": state.scrap_by_segment.duplicate(true),
		"completed_site_ids": state.completed_site_ids.duplicate(),
		"defeated_boss_ids": state.defeated_boss_ids.duplicate(),
		"assignment_id": current_route().get("assignment_id", state.route),
		"assignment_ids": state.get("route_history", []).map(func(route_id): return routes.get(route_id, {}).get("assignment_id", route_id)),
		"route_history": state.get("route_history", []).duplicate(),
		"road_history": state.get("road_history", []).duplicate(true),
		"road_flags": state.get("road_flags", []).duplicate(),
		"road_totals": state.get("road_totals", {}).duplicate(true),
		"blessing_fulfilled": state.fulfilled,
		"evolution": evolution_status(),
		"replay_cue": cue
	}

func finish(won: bool, reason: String):
	state.phase = "won" if won else "lost"
	state.last_reason = reason
	state.result_summary = build_result_summary(won)
	emit("result")

func has_major() -> bool:
	for e in state.enemies:
		if e.major: return true
	return false

func spawn(id: String):
	var major = id == config.elite or id == current_boss_id()
	var types = config.enemies.keys()
	var data = config.enemies[types[0] if major else id]
	var entry = arena.data.entries[random_int(arena.data.entries.size())]
	var p = arena.point(entry.from).lerp(arena.point(entry.to), random_int(1001) / 1000.0)
	if optional_mode():
		for attempt in range(12):
			var angle = random_int(3600) * TAU / 3600.0
			var candidate = state.position + Vector2.from_angle(angle) * config.combat.roaming_spawn_radius
			if arena.walkable(candidate, 35 if major else data.radius):
				p = candidate
				break
	var boss_hp = float(current_route().get("boss_hp", config.boss_rules.boss_hp)) if is_destination() else float(config.boss_rules.boss_hp)
	var hp = (boss_hp if id == current_boss_id() else float(config.boss_rules.elite_hp)) if major else data.hp * (1.0 + state.wave * config.enemy_rules.wave_hp_scale)
	var inspected = major and has_gift("gift.inspection_lens")
	var initial_stun = state.tick + state.signal_reserve if state.signal_reserve > 0 else 0
	state.enemies.append({"id": state.next_id, "type": id, "p": p, "hp": hp, "max_hp": hp, "radius": 35 if major else data.radius, "spawn_tick": state.tick,
		"relay_strike_at": 0, "relay_ready": 0, "entry_id": entry.id, "major": major, "marked": 0, "stun": initial_stun, "bound": 0, "slow": 0, "attack": 0, "charge": Vector2.ZERO, "windup": 0, "flash": 0, "stolen": 0,
		"worker": false, "phase": 0, "inspected": inspected, "quieted": 0})
	if state.signal_reserve > 0:
		emit("signal_reserve_released", {"position": p, "duration": state.signal_reserve})
		state.signal_reserve = 0
	if inspected:
		state.inspection = config.gift_rules.inspection_properties.get(id, "PRIORITY PROPERTY REVEALED")
		emit("inspection", {"position": p, "target_id": state.next_id, "property": state.inspection})
	state.next_id += 1

func boss_phase(enemy: Dictionary) -> int:
	var ratio = enemy.hp / enemy.max_hp
	var thresholds = bosses.get(enemy.type, {}).get("phase_thresholds", [0.67, 0.34])
	return 0 if ratio > float(thresholds[0]) else (1 if ratio > float(thresholds[1]) else 2)

func boss_phase_data(enemy: Dictionary, phase: int = -1) -> Dictionary:
	var contract = bosses.get(enemy.type, {})
	var phases = contract.get("phases", [])
	var index = boss_phase(enemy) if phase < 0 else phase
	return phases[index] if index >= 0 and index < phases.size() else {}

func boss_phase_name(enemy: Dictionary) -> String:
	var data = boss_phase_data(enemy)
	return str(data.get("name", data.get("id", "PRESSURE"))).to_upper()

func equipped_archivist_copy() -> Dictionary:
	# Active slot order is visible to the player and is therefore the deterministic
	# tie-breaker when several equipped relics have evolved. Reserve weapons and the
	# historical evolution ledger are intentionally not candidates.
	for weapon in state.get("weapons", []):
		var evolution_id = weapon_evolution_id(weapon)
		if evolution_id == "" or not config.evolution_rules.has(evolution_id): continue
		var rule = config.evolution_rules[evolution_id]
		var copy = rule.get("archivist_copy", {}).duplicate(true)
		if copy.is_empty(): continue
		copy.evolution_id = evolution_id
		copy.weapon_id = weapon.id
		copy.range = float(copy.get("range", rule.get("range", 0)))
		copy.width = float(copy.get("width", rule.get("width", 0)))
		return copy
	return {}

func append_boss_hazard(boss: Dictionary, phase_data: Dictionary, position: Vector2):
	var warning_ticks = int(float(phase_data.warning_ticks) * warning_multiplier())
	var copy = equipped_archivist_copy() if phase_data.get("copy_evolution", false) else {}
	var copy_shape = str(copy.get("shape", ""))
	var copy_points: Array = []
	if copy_shape == "funeral_shots":
		var direction = (position - boss.p).normalized()
		if direction == Vector2.ZERO: direction = Vector2.RIGHT
		var spread = maxf(20.0, float(copy.get("width", 8)) * 3.0)
		for index in range(int(copy.get("target_count", 3))):
			copy_points.append(position + direction.orthogonal() * (index - (int(copy.get("target_count", 3)) - 1) * 0.5) * spread)
	state.hazards.append({"p": position, "from": boss.p, "until": state.tick + warning_ticks, "warning_ticks": warning_ticks,
		"radius": float(phase_data.hazard_radius), "damage": float(phase_data.hazard_damage), "source": boss.type, "source_id": boss.id,
		"copy": not copy.is_empty(), "copy_evolution": str(copy.get("evolution_id", "")), "copy_weapon": str(copy.get("weapon_id", "")),
		"copy_shape": copy_shape, "copy_behavior": str(copy.get("behavior", "")), "copy_range": float(copy.get("range", 0)),
		"copy_width": float(copy.get("width", 0)), "copy_effect_ticks": int(copy.get("effect_ticks", 0)),
		"copy_effect_value": float(copy.get("effect_value", 0)), "copy_points": copy_points, "kind": str(phase_data.id), "phase": boss.phase})

func destination_hazard_points(pattern: String, phase_data: Dictionary, boss_elapsed: int) -> Array:
	var points: Array = []
	if pattern in ["player", "player_and_objective_nodes", "objective_and_player", "player_and_active_objective", "player_and_arena_anchors"]:
		points.append(state.position)
	if pattern in ["objective", "objective_nodes", "player_and_objective_nodes", "objective_and_player"]:
		for node in objective_data().get("nodes", []):
			var point = Vector2(node.position[0], node.position[1])
			if not points.any(func(existing): return existing.distance_to(point) < 1.0): points.append(point)
	if pattern in ["active_objective", "player_and_active_objective"]:
		var active_index = active_destination_node_index()
		if active_index >= 0:
			var node = objective_data().nodes[active_index]
			var point = Vector2(node.position[0], node.position[1])
			if not points.any(func(existing): return existing.distance_to(point) < 1.0): points.append(point)
	if pattern in ["arena_anchors", "player_and_arena_anchors", "active_arena_anchor"]:
		var anchors = arena.data.get("boss_anchors", [])
		var active_anchor = maxi(0, int(boss_elapsed / int(phase_data.interval)) - 1) % maxi(1, anchors.size())
		for i in range(anchors.size()):
			if pattern == "active_arena_anchor" and i != active_anchor: continue
			var point = Vector2(anchors[i][0], anchors[i][1])
			if not points.any(func(existing): return existing.distance_to(point) < 1.0): points.append(point)
	return points

func update_destination_boss(boss: Dictionary, boss_elapsed: int, phase_data: Dictionary):
	if phase_data.is_empty() or boss_elapsed <= 0 or boss_elapsed % int(phase_data.interval) != 0: return
	for point in destination_hazard_points(str(phase_data.hazard_pattern), phase_data, boss_elapsed):
		append_boss_hazard(boss, phase_data, point)
	if int(phase_data.get("pressure_duration", 0)) > 0:
		state.pressure_until = state.tick + int(phase_data.pressure_duration)
		state.pressure_multiplier = float(phase_data.cooldown_multiplier)
	if int(phase_data.get("objective_lock_ticks", 0)) > 0:
		state.objective_lock_until = maxi(int(state.objective_lock_until), state.tick + int(phase_data.objective_lock_ticks))
	if int(phase_data.get("weapon_lock_ticks", 0)) > 0:
		state.weapon_lock_until = maxi(int(state.weapon_lock_until), state.tick + int(phase_data.weapon_lock_ticks))
	var summon_id = str(phase_data.get("summon_id", ""))
	if summon_id != "" and state.enemies.size() < int(config.combat.enemy_limit):
		call_deferred_spawn = true
		deferred_spawn_id = summon_id
	emit("boss_contract", {"position": boss.p, "boss_id": boss.type, "phase_id": phase_data.id, "phase_name": phase_data.name,
		"rule": phase_data.rule, "pressure_until": state.pressure_until, "objective_lock_until": state.objective_lock_until, "weapon_lock_until": state.weapon_lock_until})

func update_enemies():
	for e in state.enemies:
		if e.hp <= 0: continue
		if e.major:
			var boss = e.type == current_boss_id()
			var phase = boss_phase(e) if boss else 0
			var boss_elapsed = state.tick - int(e.get("spawn_tick", state.tick))
			if e.phase != phase:
				e.phase = phase
				var phase_name = ["DEMOLITION", "WORKERS", "FINAL_ORDERS"][phase] if not is_destination() else boss_phase_name(e)
				emit("boss_phase", {"position": e.p, "phase": phase, "name": phase_name})
			if boss and is_destination():
				update_destination_boss(e, boss_elapsed, boss_phase_data(e, phase))
			elif boss_elapsed > 0 and boss_elapsed % int(config.boss_rules.hazard_interval) == 0:
				var offsets = config.boss_rules.phase_hazard_offsets[phase] if boss else [[0, 0]]
				for i in range(offsets.size()):
					var offset = Vector2(offsets[i][0], offsets[i][1]).rotated((boss_elapsed / int(config.boss_rules.hazard_interval) + phase) * PI / 2.0)
					var p = arena.move_body(state.position, offset, config.boss_rules.hazard_radius)
					var copies_mercy = e.type == config.elite and has_evolution("evolution.mercy_rail")
					var hazard = {"p": p, "from": e.p, "until": state.tick + int(config.boss_rules.hazard_warning_ticks * warning_multiplier()), "radius": config.boss_rules.hazard_radius, "source": e.type, "source_id": e.id, "copy": copies_mercy}
					if copies_mercy:
						hazard.copy_evolution = "evolution.mercy_rail"
						hazard.copy_shape = "rail"
					state.hazards.append(hazard)
				emit("warning", {"position": e.p, "phase": phase, "safe_lane": (phase + int(boss_elapsed / config.boss_rules.hazard_interval)) % 4})
			if boss and not is_destination() and e.hp / e.max_hp < 0.67 and boss_elapsed > 0 and boss_elapsed % int(config.boss_rules.worker_interval) == 0: call_deferred_spawn = true
		if e.stun > state.tick:
			e.relay_strike_at = 0
			continue
		var data = config.enemies["enemy.rivet_hound" if e.major else e.type]
		var target = state.position
		if not optional_mode() and (e.id % 3 == 0 or e.major): target = relay_position()
		if e.type == "enemy.scrap_mite":
			for p in state.pickups:
				if p.kind == "scrap":
					target = p.p
					if e.p.distance_to(p.p) < 18:
						e.stolen += p.amount
						p.amount = 0
					break
		if e.type == "enemy.rust_pilgrim" and e.quieted <= state.tick:
			var ally = null
			var missing = 0.0
			for other in state.enemies:
				if other.id != e.id and other.hp > 0 and other.hp < other.max_hp and e.p.distance_to(other.p) <= data.heal_radius and other.max_hp - other.hp > missing:
					ally = other
					missing = other.max_hp - other.hp
			if ally != null:
				target = ally.p
				if state.tick >= e.attack:
					ally.hp = minf(ally.max_hp, ally.hp + data.heal_amount)
					e.attack = state.tick + int(data.heal_interval)
					emit("repair", {"position": ally.p, "source": e.p})
		if e.type == "enemy.cinder_spitter" and e.quieted <= state.tick and state.tick >= e.attack:
			e.attack = state.tick + int(data.attack_interval)
			state.hazards.append({"p": state.position, "from": e.p, "until": state.tick + int(data.warning_ticks * warning_multiplier()), "warning_ticks": data.warning_ticks * warning_multiplier(), "radius": data.blast_radius, "damage": data.damage, "copy": false, "source": e.type, "source_id": e.id})
		var direction = arena.direction_to(e.p, target, e.radius)
		var destination_phase = boss_phase_data(e, e.phase) if e.type == current_boss_id() and is_destination() else {}
		var speed = float(destination_phase.get("speed", config.boss_rules.phase_speed[e.phase])) if e.type == current_boss_id() else (float(config.enemy_rules.major_speed) if e.major else float(data.speed))
		if e.get("slow", 0) > state.tick: speed *= 0.62
		# Controllers threaten the relay through announced hazards and workers.
		# They do not park on it and apply unavoidable contact damage.
		var major_stop = float(destination_phase.get("stop_distance", config.boss_rules.phase_stop_distance[e.phase])) if e.type == current_boss_id() else float(config.enemy_rules.drone_distance)
		if e.major and e.p.distance_to(target) < major_stop: speed = 0
		if e.bound > state.tick: speed *= 0.3
		if e.type in ["enemy.rivet_hound", "enemy.forklift_brute"] and e.p.distance_to(target) < config.enemy_rules.hound_range:
			if e.windup == 0 and state.tick >= e.attack:
				e.windup = state.tick + int(data.get("charge_warning", config.combat.hound_charge_ticks))
				e.charge = direction
				e.attack = state.tick + int(config.enemy_rules.hound_cycle)
			if e.windup > state.tick: speed = 0
			elif e.windup > 0 and state.tick < e.windup + config.enemy_rules.hound_dash_ticks:
				direction = e.charge
				speed = data.get("charge_speed", config.combat.hound_charge_speed)
			else: e.windup = 0
		if e.type == "enemy.choir_drone" and e.p.distance_to(state.position) < config.enemy_rules.drone_distance: speed = -config.enemy_rules.drone_retreat_speed
		if e.type == "enemy.cinder_spitter" and e.p.distance_to(target) < data.stand_off: speed = 0
		e.p = arena.move_body(e.p, direction * speed / config.tick_rate, e.radius)
		if e.p.distance_to(state.position) < e.radius + config.saint.radius:
			if e.type == "enemy.forklift_brute" and state.tick >= state.hurt_until:
				var push = float(data.push_distance)
				var segment = site_wave_key()
				if state.frame_id == "frame.keeper" and state.keeper_shove_segment != segment:
					push *= state.knockback_multiplier
					state.keeper_shove_segment = segment
					emit("frame_rule", {"frame_id": state.frame_id, "rule": "BRACED", "position": state.position})
				state.position = arena.move_body(state.position, (state.position - e.p).normalized() * push, config.saint.radius)
			hurt_saint(data.damage, e.type)
		update_relay_strike(e, data.damage)
	if call_deferred_spawn:
		call_deferred_spawn = false
		var spawn_id = deferred_spawn_id if deferred_spawn_id != "" else ("enemy.rust_pilgrim" if state.get("route", "") == "route.rootworks" else "enemy.rivet_hound")
		deferred_spawn_id = ""
		spawn(spawn_id)
		state.enemies.back().worker = true
		emit("worker_called", {"position": state.enemies.back().p, "source": current_boss_id()})

var call_deferred_spawn = false
var deferred_spawn_id = ""

func hurt_saint(amount: float, source: String = "contact"):
	if state.tick < state.hurt_until: return
	var actual = minf(amount, maxf(0, state.hp))
	state.hp -= actual
	state.hurt_until = state.tick + int(config.saint.invulnerability_ticks)
	state.damage_taken[source] = state.damage_taken.get(source, 0.0) + actual
	var segment = site_wave_key()
	state.damage_by_wave[segment] = state.damage_by_wave.get(segment, 0.0) + actual
	state.last_damage_source = source
	if state.active_machine != "":
		state.metrics.repairs_interrupted += 1
		emit("machine_repair_interrupted", {"position": state.position, "machine_id": state.active_machine, "reason": "DIRECT_HIT"})
		state.active_machine = ""
		state.repair_blocked_until = state.tick + int(config.combat.repair_hit_pause_ticks)
	emit("hurt", {"position": state.position, "amount": actual, "source": source})

func update_relay_strike(enemy: Dictionary, amount: float):
	if optional_mode() or enemy.major or enemy.hp <= 0 or enemy.stun > state.tick or enemy.p.distance_to(relay_position()) >= enemy.radius + 28:
		enemy.relay_strike_at = 0
		return
	if enemy.relay_strike_at == 0:
		if state.tick < enemy.relay_ready: return
		enemy.relay_strike_at = state.tick + int(config.relay.strike_warning_ticks * warning_multiplier())
		emit("relay_warning", {"position": enemy.p, "source_id": enemy.id, "until": enemy.relay_strike_at})
	elif state.tick >= enemy.relay_strike_at:
		damage_relay(amount, enemy.type, enemy.id)
		enemy.relay_strike_at = 0
		enemy.relay_ready = state.tick + int(config.relay.strike_recovery_ticks)

func damage_relay(amount: float, source: String, source_id: int = 0):
	if optional_mode(): return
	var floor_hp = float(config.relay.backup_floor) if state.wave == 1 else 0.0
	var actual = minf(maxf(0, amount), maxf(0, state.relay_hp - floor_hp))
	state.relay_hp -= actual
	if state.wave == 1: state.backup_absorbed += maxf(0, amount - actual)
	if actual > 0:
		state.relay_last_hit = state.tick
		state.relay_last_source = source
		state.relay_damage_sources[source] = state.relay_damage_sources.get(source, 0.0) + actual
		emit("relay_hurt", {"position": relay_position(), "amount": actual, "source": source, "source_id": source_id})

func relay_threat_count() -> int:
	var count = 0
	for enemy in state.enemies:
		if enemy.hp > 0 and enemy.get("relay_strike_at", 0) > 0 and enemy.stun <= state.tick: count += 1
	return count

func repair_relay(amount: float, source_position = null):
	if optional_mode(): return
	var actual = minf(amount, config.relay.structure - state.relay_hp)
	state.relay_hp += actual
	state.repairs += actual
	if actual > 0: emit("repair", {"position": relay_position(), "amount": actual, "source": source_position})

func weapon_target_score(data: Dictionary, enemy: Dictionary) -> float:
	var rule = data.get("target_rule", "nearest")
	if rule == "weakest": return enemy.hp
	if rule == "priority":
		var priority = 0
		if enemy.major: priority = 4
		elif enemy.type in data.get("counter_families", []): priority = 3
		return -priority * 1000000.0 + state.position.distance_squared_to(enemy.p)
	if rule == "cluster":
		var nearby = 0
		for other in state.enemies:
			if other.hp > 0 and other.p.distance_to(enemy.p) <= data.width + other.radius: nearby += 1
		return -nearby * 1000000.0 + state.position.distance_squared_to(enemy.p)
	if rule == "line_density":
		var direction = (enemy.p - state.position).normalized()
		var aligned = 0
		for other in state.enemies:
			var delta = other.p - state.position
			if other.hp > 0 and delta.dot(direction) >= 0 and delta.dot(direction) <= data.range and absf(delta.cross(direction)) < data.width + other.radius: aligned += 1
		return -aligned * 1000000.0 + state.position.distance_squared_to(enemy.p)
	return state.position.distance_squared_to(enemy.p)

func enemy_special_active(enemy: Dictionary) -> bool:
	return enemy.major or enemy.type in ["enemy.choir_drone", "enemy.rust_pilgrim", "enemy.cinder_spitter"] or enemy.get("windup", 0) > state.tick or enemy.get("relay_strike_at", 0) > state.tick

func nearest_repair_target(source: Vector2, radius: float):
	var best = null
	var best_distance = INF
	if is_destination():
		var objective = objective_data()
		for i in range(state.objective.size()):
			if state.objective[i].complete: continue
			var node = objective.nodes[i]
			var p = Vector2(node.position[0], node.position[1])
			var distance = source.distance_to(p)
			if distance <= radius and distance < best_distance and destination_node_valid(i, source, radius):
				best = p
				best_distance = distance
	elif workshop_machine_repairs_available():
		for i in range(state.machines.size()):
			if state.machines[i].complete: continue
			var machine = config.optional_repairs.machines[i]
			if machine.reward == "heal" and state.hp >= saint_max_structure(): continue
			var p = Vector2(machine.position[0], machine.position[1])
			var distance = source.distance_to(p)
			if distance <= radius and distance < best_distance:
				best = p
				best_distance = distance
	return best

func update_weapons():
	if state.tick < int(state.get("weapon_lock_until", 0)) or working_quiet_objective(): return
	for w in state.weapons:
		var data = resolved_weapon_rule(w)
		var rank_behaviors = weapon_rank_behavior_ids(w)
		var evolution_id = weapon_evolution_id(w)
		var shape = str(data.shape)
		var radius = float(data.range)
		if state.service_active and state.doctrine == 3 and shape in ["orbit", "censer", "halo", "ashen_censer", "repair_halo"]:
			radius *= config.shop_rules.procession_radius_multiplier
		var target = null
		var score = INF
		for e in state.enemies:
			if e.hp <= 0 or state.position.distance_to(e.p) > radius: continue
			var distance_score = state.position.distance_squared_to(e.p)
			var candidate = weapon_target_score(data, e)
			if shape in ["winch", "long_hand"]:
				# A live relay strike always outranks distance; otherwise reach for the farthest threat.
				candidate = (-1000000000.0 if e.relay_strike_at > state.tick else 0.0) - distance_score
			if shape == "sermon" and enemy_special_active(e): candidate -= 2000000000.0
			if candidate < score:
				score = candidate
				target = e
		var repair_target = nearest_repair_target(state.position, float(data.get("machine_range", 900 if shape == "ashen_censer" else radius))) if shape in ["ashen_censer", "benediction"] else null
		if target == null and shape not in ["halo", "repair_halo", "benediction"]: continue
		if shape == "benediction" and target == null and repair_target == null: continue
		if shape == "rail" and state.tick == w.ready - int(config.rail.charge_ticks): emit("charge", {"from": state.position, "to": target.p, "weapon": w.id, "rank_behaviors": rank_behaviors})
		if state.tick < w.ready: continue
		var cooldown = float(data.cooldown)
		for enemy in state.enemies:
			if enemy.type == "enemy.choir_drone" and enemy.hp > 0 and enemy.quieted <= state.tick and enemy.p.distance_to(state.position) < config.enemy_rules.drone_field_radius:
				cooldown *= config.enemy_rules.drone_cooldown_multiplier
				break
		if "catalyst.quiet_gear" in state.catalysts: cooldown *= config.catalysts["catalyst.quiet_gear"].cooldown_multiplier
		if state.calibrated: cooldown *= config.shop_rules.calibration_multiplier
		if is_destination() and state.pressure_until > state.tick: cooldown *= float(state.get("pressure_multiplier", current_route().pressure.cooldown_multiplier))
		w.ready = state.tick + int(cooldown)
		var origin = state.position
		var direction = (target.p - origin).normalized() if target != null else Vector2.from_angle(state.tick * 0.045)
		var end = origin + direction * radius
		var end2 = end
		var damage = float(data.damage) * float(config.rank_damage_multipliers[clampi(int(w.rank), 1, 3) - 1])
		if shape in ["blast", "benediction"] and target != null: end = target.p
		if shape in ["winch", "long_hand"]: end = target.p
		if shape in ["orbit", "halo", "repair_halo"]:
			end = origin + Vector2.from_angle(state.tick * 0.045) * radius
			end2 = origin - Vector2.from_angle(state.tick * 0.045) * radius
			if shape == "repair_halo": end = origin + Vector2.from_angle(state.tick * 0.045) * radius
		if shape == "radial": end = origin
		if shape == "ashen_censer":
			var zone_direction = (repair_target - origin).normalized() if repair_target != null else direction
			end = origin + zone_direction * float(data.zone_offset)
		if shape in ["halo", "repair_halo"]: apply_halo_repair(data, w.id, int(w.rank), rank_behaviors)
		if shape == "benediction" and target == null:
			end = repair_target
			apply_benediction_repair(data, end)
			emit("attack", {"from": origin, "to": end, "shape": "consecrated", "weapon": w.id, "rank": w.rank, "rank_behaviors": rank_behaviors, "evolution": evolution_id, "color": data.color, "range": data.width, "width": data.width})
			continue
		var funeral_ids = []
		var funeral_points = []
		if shape == "funeral_shots":
			for selection in range(int(data.target_count)):
				var next_target = null
				var next_score = INF
				for enemy in state.enemies:
					if enemy.hp <= 0 or enemy.id in funeral_ids or origin.distance_to(enemy.p) > radius: continue
					var candidate_score = weapon_target_score(data, enemy)
					if candidate_score < next_score:
						next_score = candidate_score
						next_target = enemy
				if next_target != null:
					funeral_ids.append(next_target.id)
					funeral_points.append(next_target.p)
		var shot_ids = []
		var shot_points = []
		if shape == "shot":
			for selection in range(int(data.get("target_count", 1))):
				var next_target = null
				var next_score = INF
				for enemy in state.enemies:
					if enemy.hp <= 0 or enemy.id in shot_ids or origin.distance_to(enemy.p) > radius: continue
					var candidate_score = weapon_target_score(data, enemy)
					if candidate_score < next_score:
						next_score = candidate_score
						next_target = enemy
				if next_target != null:
					shot_ids.append(next_target.id)
					shot_points.append(next_target.p)
		var orbit_points = [end]
		if shape == "orbit" and int(data.get("orbit_contacts", 1)) > 1: orbit_points.append(origin - (end - origin))
		var hits = 0
		for e in state.enemies:
			if e.hp <= 0: continue
			var delta = e.p - origin
			var hit = false
			match shape:
				"line", "rail", "beam", "sermon", "long_hand":
					hit = delta.dot(direction) >= 0 and delta.dot(direction) <= radius and absf(delta.cross(direction)) < float(data.width) + e.radius
				"cone", "tether": hit = delta.length() < radius + e.radius and absf(direction.angle_to(delta)) < data.width
				"blast", "benediction": hit = e.p.distance_to(end) <= float(data.width) + e.radius
				"shot": hit = e.id in shot_ids
				"orbit": hit = orbit_points.any(func(contact): return e.p.distance_to(contact) < data.width + e.radius)
				"censer", "radial": hit = delta.length() <= radius + e.radius
				"ashen_censer": hit = e.p.distance_to(end) <= radius + e.radius
				"winch": hit = e.id == target.id
				"halo": hit = e.p.distance_to(end) < data.width + e.radius
				"repair_halo": hit = minf(e.p.distance_to(end), e.p.distance_to(end2)) < float(data.width) + e.radius
				"funeral_shots": hit = e.id in funeral_ids
			if not hit or (shape == "line" and hits >= int(data.get("pierce_targets", 2))): continue
			hits += 1
			var dealt = damage * (config.doctrine_rules.bell_mark_multiplier if e.marked > state.tick else 1.0)
			e.hp -= dealt
			e.flash = state.tick + 6
			state.damage[w.id] = state.damage.get(w.id, 0.0) + dealt
			var control = config.catalysts["catalyst.cracked_bell_clapper"].control_multiplier if "catalyst.cracked_bell_clapper" in state.catalysts else 1.0
			if shape == "cone":
				e.stun = state.tick + int(data.get("control_ticks", config.combat.control_ticks) * control)
				e.relay_strike_at = 0
				e.p = arena.move_body(e.p, direction * float(data.get("push_distance", config.combat.push_distance)), e.radius)
				if state.doctrine == 1 and state.fulfilled: e.marked = state.tick + int(config.combat.bind_ticks)
			if shape == "tether":
				e.bound = state.tick + int(data.get("bind_ticks", config.combat.bind_ticks) * control)
				e.p = arena.move_body(e.p, -direction * float(data.get("pull_distance", 12)), e.radius)
				if data.get("cancel_strikes", false): e.relay_strike_at = 0
			if shape == "censer": e.slow = state.tick + int(data.slow_ticks)
			if shape == "ashen_censer": e.slow = state.tick + int(data.slow_ticks)
			if shape == "winch":
				e.bound = state.tick + int(data.get("bind_ticks", config.combat.bind_ticks) * control)
				e.relay_strike_at = 0
				e.p = arena.move_body(e.p, (origin - e.p).normalized() * data.pull_distance, e.radius)
			if shape == "long_hand":
				e.bound = state.tick + int(data.bind_ticks * control)
				e.relay_strike_at = 0
				e.p = arena.move_body(e.p, (origin - e.p).normalized() * data.pull_distance, e.radius)
			if shape == "sermon":
				e.quieted = state.tick + int(data.quiet_ticks)
				e.relay_strike_at = 0
				emit("quieted", {"position": e.p, "target_id": e.id, "until": e.quieted})
			if shape == "beam" and int(data.get("quiet_ticks", 0)) > 0:
				e.quieted = state.tick + int(data.quiet_ticks)
				e.relay_strike_at = 0
				emit("quieted", {"position": e.p, "target_id": e.id, "until": e.quieted, "source": w.id, "rank_behaviors": rank_behaviors})
			if int(data.get("mark_counter_ticks", 0)) > 0 and (e.major or e.type in data.counter_families):
				e.marked = state.tick + int(data.mark_counter_ticks)
			if shape == "radial":
				e.stun = state.tick + int(config.great_toll.stun_ticks * control)
				e.marked = state.tick + int(config.great_toll.mark_ticks)
				e.relay_strike_at = 0
				e.p = arena.move_body(e.p, delta.normalized() * config.great_toll.push_distance, e.radius)
			if shape == "rail" and e.major:
				if optional_mode():
					state.hp = minf(saint_max_structure(), state.hp + config.rail.repair_on_elite_hit)
					emit("repair", {"position": state.position, "source": e.p, "weapon": w.id, "rank_behaviors": rank_behaviors})
				else: repair_relay(config.rail.repair_on_elite_hit, e.p)
			emit("hit", {"position": e.p, "amount": dealt, "weapon": w.id, "rank_behaviors": rank_behaviors, "color": data.color})
			if e.hp <= 0:
				state.kills += 1
				state.kills_by_weapon[w.id] = int(state.kills_by_weapon.get(w.id, 0)) + 1
				emit("death", {"position": e.p, "weapon": w.id, "rank_behaviors": rank_behaviors, "color": data.color})
				if e.type == current_boss_id(): state.boss_dead = true
				if e.type == config.elite: state.shards += 2
				if state.kills % int(config.combat.scrap_drop_every) == 0 or e.stolen > 0:
					state.pickups.append({"p": e.p, "kind": "scrap", "amount": 1 + e.stolen})
				if shape == "censer":
					state.censer_defeats += 1
					if state.censer_defeats % int(data.scrap_every) == 0:
						state.pickups.append({"p": e.p + Vector2(-8, 0), "kind": "scrap", "amount": 1, "source": "censer"})
				if shape == "ashen_censer":
					state.ashen_defeats += 1
					if state.ashen_defeats % int(data.mote_every) == 0:
						state.pickups.append({"p": e.p, "kind": "mote", "amount": config.combat.mote_healing, "seeking": true, "seek_speed": data.mote_seek_speed, "source": evolution_id})
				if shape == "funeral_shots":
					var mote_count = 1 + (int(data.marked_support_bonus) if e.marked > state.tick and enemy_special_active(e) else 0)
					for mote_index in range(mote_count):
						state.pickups.append({"p": e.p + Vector2(mote_index * 8, 0), "kind": "mote", "amount": data.mote_healing, "seeking": true, "seek_speed": data.mote_seek_speed, "source": evolution_id})
				var mourn_every = int(config.doctrine_rules.fulfilled_mourn_every if state.fulfilled else config.doctrine_rules.mourn_every)
				if state.motes_left > 0:
					state.motes_left -= 1
					state.pickups.append({"p": e.p, "kind": "mote", "amount": config.combat.mote_healing})
				if shape == "shot" or (state.doctrine == 2 and state.kills % mourn_every == 0) or ("catalyst.black_candle" in state.catalysts and state.kills % int(config.catalysts["catalyst.black_candle"].mote_every) == 0):
					var mote = {"p": e.p + Vector2(8, 0), "kind": "mote", "amount": config.combat.mote_healing}
					if shape == "shot" and data.get("seeking_motes", false):
						mote.seeking = true
						mote.seek_speed = float(data.mote_seek_speed)
						mote.source = "rank.candle.returning_motes"
					state.pickups.append(mote)
		if shape not in ["orbit", "halo", "repair_halo"] or hits > 0 or shape in ["halo", "repair_halo"]:
			var attack_targets = funeral_points if shape == "funeral_shots" else (shot_points if shape == "shot" else orbit_points if shape == "orbit" else [])
			emit("attack", {"from": origin, "to": end, "to2": end2, "targets": attack_targets, "shape": shape, "weapon": w.id, "rank": w.rank, "rank_behaviors": rank_behaviors, "evolution": evolution_id, "color": data.color, "range": data.width if shape in ["blast", "benediction"] else radius, "width": data.width})
	state.enemies = state.enemies.filter(func(e): return e.hp > 0)

func apply_halo_repair(data: Dictionary, weapon_id: String = "", rank: int = 1, rank_behaviors: Array = []):
	if state.tick < state.repair_blocked_until: return
	if apply_objective_repair_pulse(data.repair_progress, data.machine_range, state.position):
		if data.has("circuit_heal") and state.hp < saint_max_structure():
			var circuit_heal = minf(data.circuit_heal, saint_max_structure() - state.hp)
			state.hp += circuit_heal
			if circuit_heal > 0: emit("repair", {"position": state.position, "amount": circuit_heal, "source": state.position + Vector2(0, -34), "circuit": true, "weapon": weapon_id, "rank": rank, "rank_behaviors": rank_behaviors})
		return
	if state.hp < saint_max_structure():
		var actual = minf(data.get("saint_repair", 0.5), saint_max_structure() - state.hp)
		state.hp += actual
		if actual > 0: emit("repair", {"position": state.position, "amount": actual, "source": state.position + Vector2(0, -28), "weapon": weapon_id, "rank": rank, "rank_behaviors": rank_behaviors})

func apply_benediction_repair(data: Dictionary, target_position: Vector2):
	if state.tick < state.repair_blocked_until: return
	if apply_objective_repair_pulse(data.repair_progress, data.machine_range, state.position): return
	if state.hp < saint_max_structure():
		var actual = minf(data.saint_repair, saint_max_structure() - state.hp)
		state.hp += actual
		if actual > 0: emit("repair", {"position": state.position, "amount": actual, "source": target_position, "consecrated": true})

func apply_objective_repair_pulse(amount: float, radius: float, source: Vector2) -> bool:
	if is_destination():
		for i in range(state.objective.size()):
			if destination_node_valid(i, source, radius):
				advance_destination_node(i, amount, source)
				return true
		return false
	if workshop_machine_repairs_available():
		for i in range(state.machines.size()):
			if state.machines[i].complete: continue
			var machine_data = config.optional_repairs.machines[i]
			var p = Vector2(machine_data.position[0], machine_data.position[1])
			if machine_data.reward == "heal" and state.hp >= saint_max_structure(): continue
			if source.distance_to(p) <= radius:
				advance_optional_machine(i, amount, source)
				return true
	return false

func update_pickups():
	for p in state.pickups:
		if p.get("seeking", false) and p.p.distance_to(state.position) > 1:
			p.p += (state.position - p.p).normalized() * minf(float(p.get("seek_speed", 3.5)), p.p.distance_to(state.position))
		if p.p.distance_to(state.position) < config.combat.pickup_radius:
			if p.kind == "scrap": collect_scrap(int(p.amount), "pickups")
			else: state.hp = minf(saint_max_structure(), state.hp + p.amount)
			emit("pickup", {"position": p.p, "amount": p.amount})
			p.amount = 0
	state.pickups = state.pickups.filter(func(p): return p.amount > 0)

func collect_scrap(amount: int, source: String = "pickups"):
	var net = amount
	if has_gift("gift.inspection_lens"):
		state.scrap_tax_progress += amount
		var interval = int(config.gift_rules.ordinary_scrap_tax_interval)
		var spent = int(state.scrap_tax_progress / interval)
		state.scrap_tax_progress %= interval
		net -= spent
	record_scrap(source, maxi(0, net))

func copied_hazard_hits_point(hazard: Dictionary, point: Vector2, body_radius: float) -> bool:
	var shape = str(hazard.get("copy_shape", ""))
	var copy_rule = config.evolution_rules.get(str(hazard.get("copy_evolution", "")), {})
	var copy_range = float(hazard.get("copy_range", copy_rule.get("range", hazard.get("radius", 0))))
	var copy_width = float(hazard.get("copy_width", copy_rule.get("width", hazard.get("radius", 0))))
	var direction = (hazard.p - hazard.from).normalized()
	if direction == Vector2.ZERO: direction = Vector2.RIGHT
	match shape:
		"radial":
			return point.distance_to(hazard.from) < copy_range + body_radius
		"rail", "sermon", "long_hand":
			var delta = point - hazard.from
			return delta.dot(direction) >= 0 and delta.dot(direction) < copy_range and absf(delta.cross(direction)) < copy_width + body_radius
		"ashen_censer":
			return point.distance_to(hazard.p) < copy_range + body_radius
		"benediction":
			return point.distance_to(hazard.p) < copy_width + body_radius
		"repair_halo":
			var contact = hazard.from + direction * copy_range
			var opposite = hazard.from - direction * copy_range
			return minf(point.distance_to(contact), point.distance_to(opposite)) < copy_width + body_radius
		"funeral_shots":
			return hazard.get("copy_points", []).any(func(target): return point.distance_to(target) < copy_width + body_radius)
	return point.distance_to(hazard.p) < hazard.radius + body_radius

func emit_copied_hazard_attack(hazard: Dictionary):
	var shape = str(hazard.get("copy_shape", ""))
	var copy_rule = config.evolution_rules.get(str(hazard.get("copy_evolution", "")), {})
	var copy_range = float(hazard.get("copy_range", copy_rule.get("range", hazard.get("radius", 0))))
	var copy_width = float(hazard.get("copy_width", copy_rule.get("width", hazard.get("radius", 0))))
	var direction = (hazard.p - hazard.from).normalized()
	if direction == Vector2.ZERO: direction = Vector2.RIGHT
	var payload = {"from": hazard.from, "to": hazard.p, "shape": shape, "weapon": hazard.get("source", "boss.archivist_prime"),
		"evolution": hazard.get("copy_evolution", ""), "color": "e48b73", "range": copy_range, "width": copy_width}
	if shape == "radial": payload.to = hazard.from
	elif shape in ["rail", "sermon", "long_hand"]: payload.to = hazard.from + direction * copy_range
	elif shape == "repair_halo":
		payload.to = hazard.from + direction * copy_range
		payload.to2 = hazard.from - direction * copy_range
	elif shape == "funeral_shots": payload.targets = hazard.get("copy_points", [])
	emit("attack", payload)

func apply_copied_hazard_behavior(hazard: Dictionary):
	match str(hazard.get("copy_behavior", "")):
		"displace":
			var away = (state.position - hazard.from).normalized()
			if away == Vector2.ZERO: away = Vector2.RIGHT
			state.position = arena.move_body(state.position, away * float(hazard.copy_effect_value), config.saint.radius)
		"slow_cycles":
			state.pressure_until = maxi(int(state.pressure_until), state.tick + int(hazard.copy_effect_ticks))
			state.pressure_multiplier = maxf(float(state.pressure_multiplier), float(hazard.copy_effect_value))
		"pull":
			var toward = (hazard.from - state.position).normalized()
			if toward != Vector2.ZERO: state.position = arena.move_body(state.position, toward * float(hazard.copy_effect_value), config.saint.radius)
		"repair_on_contact":
			for enemy in state.enemies:
				if enemy.id != hazard.source_id: continue
				var restored = minf(float(hazard.copy_effect_value), enemy.max_hp - enemy.hp)
				enemy.hp += restored
				if restored > 0: emit("repair", {"position": enemy.p, "amount": restored, "source": state.position})
				break
		"quiet_weapons":
			state.weapon_lock_until = maxi(int(state.weapon_lock_until), state.tick + int(hazard.copy_effect_ticks))

func update_hazards():
	for h in state.hazards:
		if h.until != state.tick: continue
		var player_hit = state.position.distance_to(h.p) < h.radius
		var relay_hit = relay_position().distance_to(h.p) < h.radius
		if h.copy:
			player_hit = copied_hazard_hits_point(h, state.position, float(config.saint.radius))
			relay_hit = copied_hazard_hits_point(h, relay_position(), 28.0)
			emit_copied_hazard_attack(h)
		if player_hit: hurt_saint(h.get("damage", config.boss_rules.hazard_damage), h.get("source", "demolition"))
		if player_hit and h.copy: apply_copied_hazard_behavior(h)
		if relay_hit:
			damage_relay(config.boss_rules.hazard_damage * config.boss_rules.relay_damage_multiplier, h.get("source", "demolition"))
		if not h.copy: emit("blast", {"position": h.p, "radius": h.radius})
	state.hazards = state.hazards.filter(func(h): return h.until > state.tick)

func snapshot() -> Dictionary:
	return state.duplicate(true)

func restore(saved: Dictionary) -> bool:
	if saved.get("version", 0) not in [1, 2, 3] or not saved.has("weapons") or not saved.has("rng"): return false
	var saved_version = int(saved.get("version", 0))
	var saved_route = str(saved.get("route", ""))
	var saved_site = str(saved.get("site_id", "site.collapsed_workshop"))
	var site_route: Dictionary = {}
	for route in chapter.routes:
		if str(route.site_id) == saved_site:
			site_route = route
			break
	if not site_route.is_empty(): arena.load_file(site_route.arena_path)
	else: arena.load_file("res://content/arenas/collapsed_workshop.json")
	if saved.get("arena_id", "") != arena.data.id: return false
	state = saved.duplicate(true)
	state.version = 3
	if not state.has("mode"): state.mode = "relay"
	if not state.has("machines"): state.machines = []
	var legacy_pressure_multiplier = float(routes.get(saved_route, {}).get("pressure", {}).get("cooldown_multiplier", 1.0))
	# Compatible defaults for existing authored-workshop saves.
	var defaults = {"run_id": "legacy-%d-%d" % [saved.get("seed", 0), saved.get("tick", 0)], "frame_id": "frame.pilgrim", "max_hp": float(config.saint.structure), "move_speed": float(config.saint.speed), "repair_grace_ticks": 0, "repair_grace_until": 0, "knockback_multiplier": 1.0, "keeper_shove_segment": "", "relay_last_hit": -999, "relay_damage_sources": {}, "relay_last_source": "", "backup_absorbed": 0.0, "calibrated": false, "service_active": false, "motes_left": 0,
		"spawn_count": 0, "active_machine": "", "repair_blocked_until": 0, "signal_reserve": 0, "kills_by_weapon": {}, "damage_taken": {}, "damage_by_wave": {}, "last_damage_source": "",
		"scrap_sources": {"starting": int(config.economy.starting_scrap)}, "metrics": {"first_contact_tick": -1, "longest_threat_gap": 0, "threat_gap_started": state.get("tick", 0), "had_threat": false, "repairs_started": 0, "repairs_interrupted": 0, "useful_repairs": 0, "wasted_repairs": 0, "dead_shop_visits": 0}, "result_summary": {},
		"scrap_by_segment": {}, "completed_site_ids": [], "defeated_boss_ids": [],
		"site_id": "site.collapsed_workshop", "route": "", "route_history": [], "route_origin_site_id": "", "travel_step": 0, "assignment_statuses": {}, "road_history": [], "road_flags": [], "road_totals": {"route_cost": 0, "service_cost": 0, "scrap_delta": 0, "structure_delta": 0.0}, "objective": [], "objective_complete": false, "objective_lock_until": 0, "weapon_lock_until": 0, "memory_id": "", "memory_ids": [], "chapter_complete": false, "pressure_until": 0, "pressure_multiplier": legacy_pressure_multiplier,
		"evolutions": [], "gifts": [], "component_tag": "", "inspection": "", "scrap_tax_progress": 0, "censer_defeats": 0, "ashen_defeats": 0}
	for field in defaults:
		if not state.has(field): state[field] = defaults[field]
	if state.route_history.is_empty() and state.route != "": state.route_history.append(state.route)
	if state.memory_ids.is_empty() and state.memory_id != "": state.memory_ids.append(state.memory_id)
	if saved_version < 3:
		# Legacy travel beats had no choices. Resume at the first authored road node
		# rather than silently skipping a newly meaningful in-between area.
		if state.phase == "travel": state.travel_step = 0
		if state.route != "":
			state.assignment_statuses[state.route] = "accepted"
		elif state.phase == "route": refresh_assignments()
	for machine in state.machines:
		if not machine.has("deferred"): machine.deferred = ""
	for w in state.weapons + state.reserve:
		if not w.has("toll"): w.toll = false
		if not w.has("rail"): w.rail = false
		if not w.has("evolution"): w.evolution = ""
		if w.evolution == "" and w.rail: w.evolution = "evolution.mercy_rail"
		if w.evolution == "" and w.toll: w.evolution = "evolution.great_toll"
		if w.evolution != "" and w.evolution not in state.evolutions: state.evolutions.append(w.evolution)
	state.evolved = not state.evolutions.is_empty()
	for enemy in state.enemies:
		if not enemy.has("relay_strike_at"): enemy.relay_strike_at = 0
		if not enemy.has("relay_ready"): enemy.relay_ready = 0
		if not enemy.has("worker"): enemy.worker = false
		if not enemy.has("phase"): enemy.phase = 0
		if not enemy.has("spawn_tick"): enemy.spawn_tick = state.tick
		if not enemy.has("slow"): enemy.slow = 0
		if not enemy.has("quieted"): enemy.quieted = 0
		if not enemy.has("inspected"): enemy.inspected = false
	events.clear()
	call_deferred_spawn = false
	deferred_spawn_id = ""
	return true

func state_hash() -> String:
	return var_to_bytes(state).hex_encode().sha256_text()
