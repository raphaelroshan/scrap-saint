extends RefCounted
## Authoritative fixed-tick simulation. No scene, input, sound or wall-clock access.
var arena = preload("res://game/arena.gd").new()
var config = {}
var catalogue = {}
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
	for item in JSON.parse_string(FileAccess.get_file_as_string("res://content/items/first_slice.json")).items:
		catalogue[item.id] = item
	for frame in JSON.parse_string(FileAccess.get_file_as_string("res://content/frames/first_chapter.json")).frames:
		frames[frame.id] = frame
	for boss in JSON.parse_string(FileAccess.get_file_as_string("res://content/bosses/first_slice.json")).bosses:
		bosses[boss.id] = boss

func start(doctrine: int = 0, seed_value: int = 147, mode: String = "relay", frame_id: String = "frame.pilgrim", run_id: String = ""):
	arena.load_file("res://content/arenas/collapsed_workshop.json")
	if not frames.has(frame_id): frame_id = "frame.pilgrim"
	var frame = frames[frame_id]
	state = {"mode": "optional" if mode == "optional" else "relay", "machines": [], "version": 2, "run_id": run_id if run_id != "" else "test-%d-%d-%s" % [seed_value, doctrine, frame_id], "frame_id": frame_id, "max_hp": float(frame.structure), "move_speed": float(frame.speed), "repair_grace_ticks": int(frame.repair_grace_ticks), "knockback_multiplier": float(frame.knockback_multiplier), "keeper_shove_segment": "", "repair_grace_until": 0, "arena_id": arena.data.id, "site_id": "site.collapsed_workshop", "route": "", "travel_step": 0, "objective": [], "objective_complete": false, "objective_lock_until": 0, "memory_id": "", "chapter_complete": false, "pressure_until": 0, "pressure_multiplier": 1.0, "seed": seed_value, "rng": maxi(1, seed_value), "tick": 0, "phase": "combat", "paused": false,
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
		"result_summary": {}, "component_tag": "", "inspection": "", "scrap_tax_progress": 0, "censer_defeats": 0}
	var starts = ["weapon.nailer_small_mercies", "weapon.bell_last_shift", "weapon.candle_nailer", "weapon.procession_gear"]
	state.doctrine = clampi(doctrine, 0, starts.size() - 1)
	state.weapons.append(make_weapon(starts[state.doctrine]))
	for machine in config.optional_repairs.machines:
		state.machines.append({"id": machine.id, "progress": 0.0, "complete": false, "deferred": ""})
	events.clear()
	call_deferred_spawn = false
	deferred_spawn_id = ""

func make_weapon(id: String, rank: int = 1):
	return {"id": id, "rank": rank, "ready": 0, "rail": false, "toll": false}

func weapon_evolved(w: Dictionary) -> bool:
	return w.get("rail", false) or w.get("toll", false)

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
		var travel_result = advance_travel() if action == "advance_travel" else "OUTSIDE_WINDOW"
		state.last_reason = travel_result
		return travel_result
	if state.phase == "memory":
		if action != "accept_memory": return "OUTSIDE_WINDOW"
		state.chapter_complete = true
		finish(true, current_route().memory.conclusion)
		emit("chapter_complete", {"memory_id": state.memory_id, "route": state.route})
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

func choose_route(route_id: String) -> String:
	if not routes.has(route_id): return "INVALID_ROUTE"
	var route = routes[route_id]
	if state.scrap < int(route.cost): return "INSUFFICIENT_SCRAP"
	state.scrap -= int(route.cost)
	state.route = route_id
	state.travel_step = 0
	state.phase = "travel"
	state.enemies.clear()
	state.hazards.clear()
	state.pickups.clear()
	state.transactions.append({"tick": state.tick, "site_id": state.site_id, "wave": state.wave, "action": "choose_route", "value": route_id, "cost": int(route.cost)})
	emit("route_chosen", {"route": route_id})
	return "OK"

func advance_travel() -> String:
	var route = current_route()
	if route.is_empty(): return "INVALID_ROUTE"
	state.travel_step += 1
	if state.travel_step >= route.travel.size(): enter_destination(route)
	else: emit("travel_advanced", {"route": state.route, "step": state.travel_step})
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
	if objective.type == "CALIBRATE_NODES":
		return not state.enemies.any(func(enemy): return enemy.hp > 0 and enemy.p.distance_to(p) < float(objective.safety_radius))
	return true

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
	state.last_reason = "The Foreman is silent. Two roads answer the repaired workshop."
	state.enemies.clear()
	state.hazards.clear()
	state.pickups.clear()
	if "site.collapsed_workshop" not in state.completed_site_ids: state.completed_site_ids.append("site.collapsed_workshop")
	if str(config.boss) not in state.defeated_boss_ids: state.defeated_boss_ids.append(str(config.boss))
	emit("routes_opened", {"routes": routes.keys(), "travel_salvage": 8})

func open_memory():
	state.phase = "memory"
	state.memory_id = current_route().memory.id
	state.last_reason = current_route().memory.text
	state.enemies.clear()
	state.hazards.clear()
	state.pickups.clear()
	if state.site_id not in state.completed_site_ids: state.completed_site_ids.append(state.site_id)
	if current_boss_id() not in state.defeated_boss_ids: state.defeated_boss_ids.append(current_boss_id())
	emit("memory_recovered", {"memory_id": state.memory_id, "route": state.route})

func evolve_weapon(requested: String = "") -> String:
	var recipes = [
		{"id": "evolution.mercy_rail", "base": "weapon.nailer_small_mercies", "catalyst": "catalyst.saints_rivet", "flag": "rail", "name": "Mercy Rail"},
		{"id": "evolution.great_toll", "base": "weapon.bell_last_shift", "catalyst": "catalyst.cracked_bell_clapper", "flag": "toll", "name": "The Great Toll"}
	]
	for recipe in recipes:
		if requested != "" and requested != recipe.id: continue
		if recipe.catalyst not in state.catalysts: continue
		for w in state.weapons:
			if w.id == recipe.base and w.rank == 3 and not weapon_evolved(w):
				w[recipe.flag] = true
				state.evolved = true
				if recipe.id not in state.evolutions: state.evolutions.append(recipe.id)
				state.catalysts.erase(recipe.catalyst)
				emit("evolution", {"position": state.position, "recipe": recipe.id, "name": recipe.name})
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

func combine_owned() -> String:
	var all = state.weapons + state.reserve
	for i in range(all.size()):
		for j in range(i + 1, all.size()):
			if all[i].id == all[j].id and all[i].rank == all[j].rank and all[i].rank < 3 and not weapon_evolved(all[i]) and not weapon_evolved(all[j]):
				var merged = make_weapon(all[i].id, all[i].rank + 1)
				all.remove_at(j)
				all.remove_at(i)
				all.push_front(merged)
				state.weapons = all.slice(0, int(config.economy.active_slots))
				state.reserve = all.slice(int(config.economy.active_slots))
				return "OK"
	return "NO_MATCHING_PAIR"

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
		var changed = true
		while changed:
			changed = false
			for i in range(all.size()):
				for j in range(i + 1, all.size()):
					if all[i].id == id and all[j].id == id and all[i].rank == all[j].rank and all[i].rank < 3 and not weapon_evolved(all[i]) and not weapon_evolved(all[j]):
						all[i].rank += 1
						all.remove_at(j)
						changed = true
						break
				if changed: break
		if all.size() > config.economy.active_slots + config.economy.reserve_slots: return "LOADOUT_FULL"
		state.scrap -= cost
		state.weapons = all.slice(0, int(config.economy.active_slots))
		state.reserve = all.slice(int(config.economy.active_slots))
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
	var signature = var_to_str(state.weapons + state.reserve + state.catalysts)
	var key = "%d/%d/%d/%d/%d/%s" % [state.seed, state.wave, state.doctrine, state.rerolls, slot, signature]
	var index = key.sha256_text().substr(0, 8).hex_to_int() % ids.size()
	return ids[index]

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
	var path = "catalyst.saints_rivet"
	var bell_ready = state.weapons.any(func(w): return w.id == "weapon.bell_last_shift" and w.rank == 3 and not weapon_evolved(w))
	var rail_ready = state.weapons.any(func(w): return w.id == "weapon.nailer_small_mercies" and w.rank == 3 and not weapon_evolved(w))
	if bell_ready and "catalyst.cracked_bell_clapper" not in state.catalysts:
		path = "catalyst.cracked_bell_clapper"
	elif path in state.catalysts or has_evolution("evolution.mercy_rail"):
		path = "weapon.nailer_small_mercies" if not has_evolution("evolution.mercy_rail") and not rail_ready and can_fit_weapon("weapon.nailer_small_mercies") else "service.calibrate"
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
	if has_evolution("evolution.mercy_rail"): completed.append("MERCY_RAIL")
	if has_evolution("evolution.great_toll"): completed.append("GREAT_TOLL")
	for weapon in state.weapons + state.reserve:
		if weapon.get("rail", false) and "MERCY_RAIL" not in completed: completed.append("MERCY_RAIL")
		if weapon.get("toll", false) and "GREAT_TOLL" not in completed: completed.append("GREAT_TOLL")
	if not completed.is_empty(): return "+".join(completed) + "_COMPLETED"
	var nailer_rank = 0
	var bell_rank = 0
	for weapon in state.weapons + state.reserve:
		if weapon.id == "weapon.nailer_small_mercies": nailer_rank = maxi(nailer_rank, int(weapon.rank))
		if weapon.id == "weapon.bell_last_shift": bell_rank = maxi(bell_rank, int(weapon.rank))
	if bell_rank == 3 and "catalyst.cracked_bell_clapper" in state.catalysts: return "GREAT_TOLL_READY"
	if nailer_rank == 3 and "catalyst.saints_rivet" in state.catalysts: return "MERCY_RAIL_READY"
	if bell_rank > 0 or "catalyst.cracked_bell_clapper" in state.catalysts: return "GREAT_TOLL_PURSUED"
	if nailer_rank > 0 or "catalyst.saints_rivet" in state.catalysts: return "MERCY_RAIL_PURSUED"
	return "MERCY_RAIL_IGNORED"

func build_result_summary(won: bool) -> Dictionary:
	var completed = []
	for i in range(state.machines.size()):
		if state.machines[i].complete:
			completed.append({"id": state.machines[i].id, "reward": config.optional_repairs.machines[i].description})
	var top_weapon = largest_entry(state.damage)
	var worst_wave = largest_entry(state.damage_by_wave)
	var cause = "" if won else classify_failure()
	var cue = "Try another doctrine and compare its workshop service."
	if not won:
		match cause:
			"THREAT_RESPONSE": cue = "Answer the forecast with control or priority range before the next pressure arrives."
			"POSITIONING": cue = "Keep one escape lane open and leave a marked blast before it resolves."
			"BUILD_GEOMETRY": cue = "Add a relic whose geometry answers the wave that stopped this build."
			"ECONOMY": cue = "Spend earlier on an affordable current-build improvement."
			"OBJECTIVE_NEGLECT": cue = "Break announced objective strikes before returning to repair work."
	elif state.chapter_complete: cue = "Take the other road with this build and compare the work, pressure and recovered memory."
	elif completed.is_empty(): cue = "Try one optional machine when its visible reward solves the next decision."
	elif not state.evolved: cue = "Compare this reliable build with a visible evolution route next shift."
	return {
		"run_id": state.run_id,
		"won": won,
		"site_id": state.site_id,
		"boss_id": current_boss_id(),
		"route_id": state.route,
		"optional_repairs": completed.size(),
		"memory_ids": [state.memory_id] if state.memory_id != "" else [],
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
		"worker": false, "phase": 0, "inspected": inspected})
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

func append_boss_hazard(boss: Dictionary, phase_data: Dictionary, position: Vector2):
	var warning_ticks = int(float(phase_data.warning_ticks) * warning_multiplier())
	state.hazards.append({"p": position, "from": boss.p, "until": state.tick + warning_ticks, "warning_ticks": warning_ticks,
		"radius": float(phase_data.hazard_radius), "damage": float(phase_data.hazard_damage), "source": boss.type, "source_id": boss.id,
		"copy": false, "kind": str(phase_data.id), "phase": boss.phase})

func destination_hazard_points(pattern: String) -> Array:
	var points: Array = []
	if pattern in ["player", "player_and_objective_nodes", "objective_and_player"]:
		points.append(state.position)
	if pattern in ["objective", "objective_nodes", "player_and_objective_nodes", "objective_and_player"]:
		for node in objective_data().get("nodes", []):
			var point = Vector2(node.position[0], node.position[1])
			if not points.any(func(existing): return existing.distance_to(point) < 1.0): points.append(point)
	return points

func update_destination_boss(boss: Dictionary, boss_elapsed: int, phase_data: Dictionary):
	if phase_data.is_empty() or boss_elapsed <= 0 or boss_elapsed % int(phase_data.interval) != 0: return
	for point in destination_hazard_points(str(phase_data.hazard_pattern)):
		append_boss_hazard(boss, phase_data, point)
	if boss.type == "boss.choir_regent":
		state.pressure_until = state.tick + int(phase_data.pressure_duration)
		state.pressure_multiplier = float(phase_data.cooldown_multiplier)
	if boss.type == "boss.factory_heart":
		state.objective_lock_until = maxi(int(state.objective_lock_until), state.tick + int(phase_data.objective_lock_ticks))
		var summon_id = str(phase_data.get("summon_id", ""))
		if summon_id != "" and state.enemies.size() < int(config.combat.enemy_limit):
			call_deferred_spawn = true
			deferred_spawn_id = summon_id
	emit("boss_contract", {"position": boss.p, "boss_id": boss.type, "phase_id": phase_data.id, "phase_name": phase_data.name,
		"rule": phase_data.rule, "pressure_until": state.pressure_until, "objective_lock_until": state.objective_lock_until})

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
		if e.type == "enemy.rust_pilgrim":
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
		if e.type == "enemy.cinder_spitter" and state.tick >= e.attack:
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

func update_weapons():
	for w in state.weapons:
		var data = config.weapons[w.id]
		var rail = w.get("rail", false)
		var toll = w.get("toll", false)
		var shape = "rail" if rail else ("radial" if toll else data.shape)
		var radius = config.rail.range if rail else (config.great_toll.range if toll else data.range)
		if state.service_active and state.doctrine == 3 and shape in ["orbit", "censer", "halo"]:
			radius *= config.shop_rules.procession_radius_multiplier
		var target = null
		var score = INF
		for e in state.enemies:
			if e.hp <= 0 or state.position.distance_to(e.p) > radius: continue
			var distance_score = state.position.distance_squared_to(e.p)
			var candidate = weapon_target_score(data, e)
			if shape == "winch":
				# A live relay strike always outranks distance; otherwise reach for the farthest threat.
				candidate = (-1000000000.0 if e.relay_strike_at > state.tick else 0.0) - distance_score
			if candidate < score:
				score = candidate
				target = e
		if target == null and shape != "halo": continue
		if rail and state.tick == w.ready - int(config.rail.charge_ticks): emit("charge", {"from": state.position, "to": target.p, "weapon": w.id})
		if state.tick < w.ready: continue
		var cooldown = config.rail.cooldown if rail else (config.great_toll.cooldown if toll else data.cooldown)
		for enemy in state.enemies:
			if enemy.type == "enemy.choir_drone" and enemy.hp > 0 and enemy.p.distance_to(state.position) < config.enemy_rules.drone_field_radius:
				cooldown *= config.enemy_rules.drone_cooldown_multiplier
				break
		if "catalyst.quiet_gear" in state.catalysts: cooldown *= config.catalysts["catalyst.quiet_gear"].cooldown_multiplier
		if state.calibrated: cooldown *= config.shop_rules.calibration_multiplier
		if is_destination() and state.pressure_until > state.tick: cooldown *= float(state.get("pressure_multiplier", current_route().pressure.cooldown_multiplier))
		w.ready = state.tick + int(cooldown)
		var origin = state.position
		var direction = (target.p - origin).normalized() if target != null else Vector2.from_angle(state.tick * 0.045)
		var end = origin + direction * radius
		var damage = (config.rail.damage if rail else (config.great_toll.damage if toll else data.damage)) * (1.0 + (w.rank - 1) * 0.6)
		if shape == "blast": end = target.p
		if shape == "winch": end = target.p
		if shape in ["orbit", "halo"]:
			end = origin + Vector2.from_angle(state.tick * 0.045) * data.range
		if shape == "radial": end = origin
		if shape == "halo": apply_halo_repair(data)
		var hits = 0
		for e in state.enemies:
			if e.hp <= 0: continue
			var delta = e.p - origin
			var hit = false
			match shape:
				"line", "rail", "beam":
					hit = delta.dot(direction) >= 0 and delta.dot(direction) <= radius and absf(delta.cross(direction)) < (config.rail.width if rail else data.width) + e.radius
				"cone", "tether": hit = delta.length() < radius + e.radius and absf(direction.angle_to(delta)) < data.width
				"blast": hit = e.p.distance_to(end) <= data.width + e.radius
				"shot": hit = e.id == target.id
				"orbit": hit = e.p.distance_to(end) < data.width + e.radius
				"censer", "radial": hit = delta.length() <= radius + e.radius
				"winch": hit = e.id == target.id
				"halo": hit = e.p.distance_to(end) < data.width + e.radius
			if not hit or (shape == "line" and hits >= 2): continue
			hits += 1
			var dealt = damage * (config.doctrine_rules.bell_mark_multiplier if e.marked > state.tick else 1.0)
			e.hp -= dealt
			e.flash = state.tick + 6
			state.damage[w.id] = state.damage.get(w.id, 0.0) + dealt
			var control = config.catalysts["catalyst.cracked_bell_clapper"].control_multiplier if "catalyst.cracked_bell_clapper" in state.catalysts else 1.0
			if shape == "cone":
				e.stun = state.tick + int(config.combat.control_ticks * control)
				e.relay_strike_at = 0
				e.p = arena.move_body(e.p, direction * config.combat.push_distance, e.radius)
				if state.doctrine == 1 and state.fulfilled: e.marked = state.tick + int(config.combat.bind_ticks)
			if shape == "tether":
				e.bound = state.tick + int(config.combat.bind_ticks * control)
				e.p = arena.move_body(e.p, -direction * 12, e.radius)
			if shape == "censer": e.slow = state.tick + int(data.slow_ticks)
			if shape == "winch":
				e.bound = state.tick + int(config.combat.bind_ticks * control)
				e.relay_strike_at = 0
				e.p = arena.move_body(e.p, (origin - e.p).normalized() * data.pull_distance, e.radius)
			if shape == "radial":
				e.stun = state.tick + int(config.great_toll.stun_ticks * control)
				e.marked = state.tick + int(config.great_toll.mark_ticks)
				e.relay_strike_at = 0
				e.p = arena.move_body(e.p, delta.normalized() * config.great_toll.push_distance, e.radius)
			if shape == "rail" and e.major:
				if optional_mode():
					state.hp = minf(saint_max_structure(), state.hp + config.rail.repair_on_elite_hit)
					emit("repair", {"position": state.position, "source": e.p})
				else: repair_relay(config.rail.repair_on_elite_hit, e.p)
			emit("hit", {"position": e.p, "amount": dealt, "weapon": w.id, "color": data.color})
			if e.hp <= 0:
				state.kills += 1
				state.kills_by_weapon[w.id] = int(state.kills_by_weapon.get(w.id, 0)) + 1
				emit("death", {"position": e.p, "color": data.color})
				if e.type == current_boss_id(): state.boss_dead = true
				if e.type == config.elite: state.shards += 2
				if state.kills % int(config.combat.scrap_drop_every) == 0 or e.stolen > 0:
					state.pickups.append({"p": e.p, "kind": "scrap", "amount": 1 + e.stolen})
				if shape == "censer":
					state.censer_defeats += 1
					if state.censer_defeats % int(data.scrap_every) == 0:
						state.pickups.append({"p": e.p + Vector2(-8, 0), "kind": "scrap", "amount": 1, "source": "censer"})
				var mourn_every = int(config.doctrine_rules.fulfilled_mourn_every if state.fulfilled else config.doctrine_rules.mourn_every)
				if state.motes_left > 0:
					state.motes_left -= 1
					state.pickups.append({"p": e.p, "kind": "mote", "amount": config.combat.mote_healing})
				if shape == "shot" or (state.doctrine == 2 and state.kills % mourn_every == 0) or ("catalyst.black_candle" in state.catalysts and state.kills % int(config.catalysts["catalyst.black_candle"].mote_every) == 0):
					state.pickups.append({"p": e.p + Vector2(8, 0), "kind": "mote", "amount": config.combat.mote_healing})
		if shape not in ["orbit", "halo"] or hits > 0 or shape == "halo":
			emit("attack", {"from": origin, "to": end, "shape": shape, "weapon": w.id, "color": data.color, "range": data.width if shape == "blast" else radius})
	state.enemies = state.enemies.filter(func(e): return e.hp > 0)

func apply_halo_repair(data: Dictionary):
	if state.tick < state.repair_blocked_until: return
	if apply_objective_repair_pulse(data.repair_progress, data.machine_range, state.position): return
	if state.hp < saint_max_structure():
		var actual = minf(data.saint_repair, saint_max_structure() - state.hp)
		state.hp += actual
		if actual > 0: emit("repair", {"position": state.position, "amount": actual, "source": state.position + Vector2(0, -28)})

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

func update_hazards():
	for h in state.hazards:
		if h.until != state.tick: continue
		var player_hit = state.position.distance_to(h.p) < h.radius
		var relay_hit = relay_position().distance_to(h.p) < h.radius
		if h.copy:
			if h.get("copy_shape", "rail") == "radial":
				player_hit = state.position.distance_to(h.from) < config.great_toll.range + config.saint.radius
				relay_hit = relay_position().distance_to(h.from) < config.great_toll.range + 28
				emit("attack", {"from": h.from, "to": h.from, "shape": "radial", "weapon": "elite.memory_crane", "color": "e48b73", "range": config.great_toll.range})
			else:
				var direction = (h.p - h.from).normalized()
				var player_delta = state.position - h.from
				var relay_delta = relay_position() - h.from
				player_hit = player_delta.dot(direction) >= 0 and player_delta.dot(direction) < config.rail.range and absf(player_delta.cross(direction)) < config.rail.width + config.saint.radius
				relay_hit = relay_delta.dot(direction) >= 0 and relay_delta.dot(direction) < config.rail.range and absf(relay_delta.cross(direction)) < config.rail.width + 28
				emit("attack", {"from": h.from, "to": h.from + direction * config.rail.range, "shape": "rail", "weapon": "elite.memory_crane", "color": "e48b73", "range": config.rail.range})
		if player_hit: hurt_saint(h.get("damage", config.boss_rules.hazard_damage), h.get("source", "demolition"))
		if relay_hit:
			damage_relay(config.boss_rules.hazard_damage * config.boss_rules.relay_damage_multiplier, h.get("source", "demolition"))
		if not h.copy: emit("blast", {"position": h.p, "radius": h.radius})
	state.hazards = state.hazards.filter(func(h): return h.until > state.tick)

func snapshot() -> Dictionary:
	return state.duplicate(true)

func restore(saved: Dictionary) -> bool:
	if saved.get("version", 0) not in [1, 2] or not saved.has("weapons") or not saved.has("rng"): return false
	var saved_route = str(saved.get("route", ""))
	if saved.get("site_id", "site.collapsed_workshop") != "site.collapsed_workshop" and saved_route != "" and routes.has(saved_route): arena.load_file(routes[saved_route].arena_path)
	else: arena.load_file("res://content/arenas/collapsed_workshop.json")
	if saved.get("arena_id", "") != arena.data.id: return false
	state = saved.duplicate(true)
	state.version = 2
	if not state.has("mode"): state.mode = "relay"
	if not state.has("machines"): state.machines = []
	var legacy_pressure_multiplier = float(routes.get(saved_route, {}).get("pressure", {}).get("cooldown_multiplier", 1.0))
	# Compatible defaults for existing authored-workshop saves.
	var defaults = {"run_id": "legacy-%d-%d" % [saved.get("seed", 0), saved.get("tick", 0)], "frame_id": "frame.pilgrim", "max_hp": float(config.saint.structure), "move_speed": float(config.saint.speed), "repair_grace_ticks": 0, "repair_grace_until": 0, "knockback_multiplier": 1.0, "keeper_shove_segment": "", "relay_last_hit": -999, "relay_damage_sources": {}, "relay_last_source": "", "backup_absorbed": 0.0, "calibrated": false, "service_active": false, "motes_left": 0,
		"spawn_count": 0, "active_machine": "", "repair_blocked_until": 0, "signal_reserve": 0, "kills_by_weapon": {}, "damage_taken": {}, "damage_by_wave": {}, "last_damage_source": "",
		"scrap_sources": {"starting": int(config.economy.starting_scrap)}, "metrics": {"first_contact_tick": -1, "longest_threat_gap": 0, "threat_gap_started": state.get("tick", 0), "had_threat": false, "repairs_started": 0, "repairs_interrupted": 0, "useful_repairs": 0, "wasted_repairs": 0, "dead_shop_visits": 0}, "result_summary": {},
		"scrap_by_segment": {}, "completed_site_ids": [], "defeated_boss_ids": [],
		"site_id": "site.collapsed_workshop", "route": "", "travel_step": 0, "objective": [], "objective_complete": false, "objective_lock_until": 0, "memory_id": "", "chapter_complete": false, "pressure_until": 0, "pressure_multiplier": legacy_pressure_multiplier,
		"evolutions": [], "gifts": [], "component_tag": "", "inspection": "", "scrap_tax_progress": 0, "censer_defeats": 0}
	for field in defaults:
		if not state.has(field): state[field] = defaults[field]
	for machine in state.machines:
		if not machine.has("deferred"): machine.deferred = ""
	for w in state.weapons + state.reserve:
		if not w.has("toll"): w.toll = false
		if w.get("rail", false) and "evolution.mercy_rail" not in state.evolutions: state.evolutions.append("evolution.mercy_rail")
		if w.get("toll", false) and "evolution.great_toll" not in state.evolutions: state.evolutions.append("evolution.great_toll")
	state.evolved = not state.evolutions.is_empty()
	for enemy in state.enemies:
		if not enemy.has("relay_strike_at"): enemy.relay_strike_at = 0
		if not enemy.has("relay_ready"): enemy.relay_ready = 0
		if not enemy.has("worker"): enemy.worker = false
		if not enemy.has("phase"): enemy.phase = 0
		if not enemy.has("spawn_tick"): enemy.spawn_tick = state.tick
		if not enemy.has("slow"): enemy.slow = 0
		if not enemy.has("inspected"): enemy.inspected = false
	events.clear()
	call_deferred_spawn = false
	deferred_spawn_id = ""
	return true

func state_hash() -> String:
	return var_to_bytes(state).hex_encode().sha256_text()
