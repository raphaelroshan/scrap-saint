extends RefCounted
## Authoritative fixed-tick simulation. No scene, input, sound or wall-clock access.
var arena = preload("res://game/arena.gd").new()
var config = {}
var catalogue = {}
var state = {}
var events: Array = []

func _init():
	config = JSON.parse_string(FileAccess.get_file_as_string("res://content/slices/first_shift.json"))
	config.arena = arena.data.bounds
	config.relay.x = arena.data.relay[0]
	config.relay.y = arena.data.relay[1]
	config.relay.radius = arena.data.repair_radius
	for item in JSON.parse_string(FileAccess.get_file_as_string("res://content/items/first_slice.json")).items:
		catalogue[item.id] = item

func start(doctrine: int = 0, seed_value: int = 147, mode: String = "relay"):
	state = {"mode": "optional" if mode == "optional" else "relay", "machines": [], "version": 1, "arena_id": arena.data.id, "seed": seed_value, "rng": maxi(1, seed_value), "tick": 0, "phase": "combat", "paused": false,
		"wave": 1, "wave_tick": 0, "doctrine": doctrine, "position": arena.point(arena.data.start), "facing": Vector2.UP,
		"hp": float(config.saint.structure), "relay_hp": float(config.relay.structure * config.relay.starting_fraction), "progress": 0.0,
		"scrap": int(config.economy.starting_scrap), "shards": 0, "kills": 0, "next_id": 1,
		"weapons": [], "reserve": [], "catalysts": [], "gifts": [], "enemies": [], "pickups": [], "hazards": [],
		"offers": [], "locked": "", "rerolls": 0, "hurt_until": 0, "boss_spawned": false,
		"boss_dead": false, "evolved": false, "service_used": false, "repairs": 0.0, "damage": {},
		"relay_last_hit": -999, "relay_damage_sources": {}, "relay_last_source": "", "backup_absorbed": 0.0, "calibrated": false, "service_active": false, "motes_left": 0, "last_reason": "", "forecast": false, "transactions": [], "fulfilled": false,
		"component_tag": "", "inspection": "", "scrap_tax_progress": 0, "censer_defeats": 0}
	var starts = ["weapon.nailer_small_mercies", "weapon.bell_last_shift", "weapon.candle_nailer"]
	state.weapons.append(make_weapon(starts[clampi(doctrine, 0, 2)]))
	for machine in config.optional_repairs.machines:
		state.machines.append({"id": machine.id, "progress": 0.0, "complete": false})
	events.clear()
	call_deferred_spawn = false

func make_weapon(id: String, rank: int = 1):
	return {"id": id, "rank": rank, "ready": 0, "rail": false, "toll": false}

func weapon_evolved(w: Dictionary) -> bool:
	return w.get("rail", false) or w.get("toll", false)

func has_gift(id: String) -> bool:
	return id in state.get("gifts", [])

func random_int(limit: int) -> int:
	state.rng = (int(state.rng) * 48271) % 2147483647
	return int(state.rng) % maxi(1, limit)

func emit(kind: String, payload: Dictionary = {}):
	payload["kind"] = kind
	payload["tick"] = state.tick
	payload["event_id"] = "%d:%d" % [state.tick, events.size()]
	events.append(payload)

func relay_position() -> Vector2:
	return Vector2(config.relay.x, config.relay.y)

func command(action: String, value = null) -> String:
	if state.is_empty():
		return "NO_RUN"
	if action == "pause":
		if state.phase != "combat": return "OUTSIDE_WINDOW"
		state.paused = not state.paused
		return "OK"
	if state.phase != "shop":
		return "OUTSIDE_WINDOW"
	var result = "INVALID_COMMAND"
	match action:
		"continue":
			state.wave += 1
			state.wave_tick = 0
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
					if action == "dismantle" and state.component_tag != "": roll_shop()
					result = "OK"
		"sell_gift", "dismantle_gift":
			var index = int(value)
			if index >= 0 and index < state.gifts.size():
				var gift_id = state.gifts[index]
				state.scrap += int(floor(catalogue[gift_id].cost_scrap * (0.25 if action == "dismantle_gift" else config.economy.sell_fraction)))
				state.gifts.remove_at(index)
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
		state.transactions.append({"tick": state.tick, "action": action, "value": value})
		update_fulfilment()
	return result

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
				state.catalysts.erase(recipe.catalyst)
				emit("evolution", {"position": state.position, "recipe": recipe.id, "name": recipe.name})
				return "OK"
	return "MISSING_INGREDIENT"

func component_tag_for(id: String) -> String:
	var ignored = ["shot", "beam", "ground", "risk", "shop"]
	for tag in catalogue[id].get("tags", []):
		if tag not in ignored: return tag
	return ""

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
			if state.hp >= config.saint.structure and (optional_mode() or state.relay_hp >= config.relay.structure): return "ALREADY_REPAIRED"
			state.hp = minf(config.saint.structure, state.hp + config.economy.repair_amount)
			repair_relay(config.economy.repair_amount)
		elif id == "service.calibrate":
			if state.calibrated: return "SERVICE_USED"
			state.calibrated = true
		else:
			if state.service_used: return "SERVICE_USED"
			if state.doctrine == 0 and state.hp >= config.saint.structure and (optional_mode() or state.relay_hp >= config.relay.structure): return "ALREADY_REPAIRED"
			state.service_used = true
			state.service_active = true
			match state.doctrine:
				0:
					state.hp = minf(config.saint.structure, state.hp + (config.doctrine_rules.workshop_service_relay if optional_mode() else config.doctrine_rules.workshop_service_hp))
					repair_relay(config.doctrine_rules.workshop_service_relay)
				1:
					state.forecast = true
				2:
					state.motes_left = int(config.shop_rules.mourner_motes)
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
	var tags = ["labour", "witness", "mourn"]
	var unique = {}
	for w in state.weapons:
		if tags[state.doctrine] in catalogue[w.id].tags: unique[w.id] = true
	state.fulfilled = unique.size() >= 2

func can_fit_weapon(id: String) -> bool:
	var all = (state.weapons + state.reserve).duplicate(true)
	all.append(make_weapon(id))
	for rank in [1, 2]:
		var matches = all.filter(func(w): return w.id == id and w.rank == rank and not w.rail)
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
	elif path in state.catalysts or state.evolved:
		path = "weapon.nailer_small_mercies" if not state.evolved and not rail_ready and can_fit_weapon("weapon.nailer_small_mercies") else "service.calibrate"
	state.offers = [shop_pick(upgrades, 0), shop_pick(fresh, 1), path, preferred if preferred in support else shop_pick(support, 3), "service.repair", "service.doctrine"]
	if state.component_tag != "":
		var leads = fresh.filter(func(id): return state.component_tag in catalogue[id].tags)
		if leads.is_empty(): leads = config.weapons.keys().filter(func(id): return can_fit_weapon(id) and state.component_tag in catalogue[id].tags)
		if not leads.is_empty(): state.offers[1] = shop_pick(leads, 11)
	if state.hp >= config.saint.structure and (optional_mode() or state.relay_hp >= config.relay.structure): state.offers[4] = "service.calibrate"
	if state.locked != "" and state.locked not in state.offers:
		state.offers[1 if state.locked in config.weapons else 3] = state.locked

func warning_multiplier() -> float:
	return config.shop_rules.bell_warning_multiplier if state.service_active and state.doctrine == 1 else 1.0

func enter_shop():
	state.phase = "shop"
	state.scrap += int(config.economy.wave_scrap)
	if state.wave in [2, 4, 6]: state.shards += 1
	for p in state.pickups:
		if p.kind == "scrap": collect_scrap(int(p.amount))
	state.pickups.clear()
	state.enemies.clear()
	state.hazards.clear()
	state.rerolls = 0
	state.service_used = false
	state.service_active = false
	state.calibrated = false
	state.motes_left = 0
	roll_shop()
	emit("wave_complete")

func step(move: Vector2):
	events.clear()
	if state.is_empty() or state.phase != "combat" or state.paused: return
	state.tick += 1
	state.wave_tick += 1
	move = move.limit_length()
	if move.length() > 0.1: state.facing = move.normalized()
	var move_multiplier = catalogue["gift.spare_hand"].tradeoff_value if has_gift("gift.spare_hand") and working_optional_machine() else 1.0
	state.position = arena.move_body(state.position, move * config.saint.speed * move_multiplier / config.tick_rate, config.saint.radius)
	if optional_mode(): update_optional_repairs()
	elif state.position.distance_to(relay_position()) < config.relay.radius:
		var rate = (config.doctrine_rules.fulfilled_workshop_rate if state.fulfilled else config.doctrine_rules.workshop_rate) if state.doctrine == 0 else 1.0
		if "catalyst.saints_rivet" in state.catalysts: rate *= config.catalysts["catalyst.saints_rivet"].repair_multiplier
		state.progress = minf(config.relay.required_ticks, state.progress + rate)
		if state.tick % 60 == 0: repair_relay(config.relay.repair_per_tick * 60 * rate)
	var interval = maxi(config.combat.spawn_minimum, config.combat.spawn_interval - state.wave * 8)
	if state.wave_tick % interval == 0 and state.enemies.size() < config.combat.enemy_limit:
		var types = config.enemies.keys()
		spawn(types[random_int(mini(types.size(), 1 + state.wave))])
	if state.wave in [6, 8] and not state.boss_spawned:
		spawn(config.elite if state.wave == 6 else config.boss)
		state.boss_spawned = true
	update_enemies()
	update_weapons()
	update_pickups()
	update_hazards()
	if state.hp <= 0: finish(false, "The Saint's structure failed.")
	elif not optional_mode() and state.relay_hp <= 0: finish(false, "The relay was destroyed.")
	elif state.wave == 8 and state.boss_dead:
		finish(optional_mode() or state.progress >= config.relay.required_ticks, "The shift is yours. Every repair was your choice." if optional_mode() else ("The Foreman fell, but the relay was unfinished." if state.progress < config.relay.required_ticks else "The relay sings again."))
	elif state.wave_tick >= config.wave_ticks:
		if state.wave == 8: finish(false, "The demolition schedule reached its final order.")
		elif state.wave == 6 and has_major(): finish(false, "The Memory Crane outlasted the shift.")
		else: enter_shop()

func optional_mode() -> bool:
	return state.get("mode", "relay") == "optional"

func working_optional_machine() -> bool:
	if not optional_mode(): return false
	for i in range(state.machines.size()):
		if state.machines[i].complete: continue
		var p = Vector2(config.optional_repairs.machines[i].position[0], config.optional_repairs.machines[i].position[1])
		if state.position.distance_to(p) < config.optional_repairs.radius: return true
	return false

func update_optional_repairs():
	for i in range(state.machines.size()):
		var machine = state.machines[i]
		var data = config.optional_repairs.machines[i]
		var p = Vector2(data.position[0], data.position[1])
		if machine.complete or state.position.distance_to(p) >= config.optional_repairs.radius: continue
		var rate = (config.doctrine_rules.fulfilled_workshop_rate if state.fulfilled else config.doctrine_rules.workshop_rate) if state.doctrine == 0 else 1.0
		if "catalyst.saints_rivet" in state.catalysts: rate *= config.catalysts["catalyst.saints_rivet"].repair_multiplier
		if has_gift("gift.spare_hand"): rate *= catalogue["gift.spare_hand"].effect_value
		advance_optional_machine(i, rate, state.position)
		break

func advance_optional_machine(index: int, amount: float, source = null):
	var machine = state.machines[index]
	if machine.complete: return
	var data = config.optional_repairs.machines[index]
	var p = Vector2(data.position[0], data.position[1])
	machine.progress = minf(config.optional_repairs.required_ticks, machine.progress + amount)
	emit("repair", {"position": p, "source": source, "amount": amount})
	if machine.progress < config.optional_repairs.required_ticks: return
	machine.complete = true
	match data.reward:
		"scrap": state.scrap += int(data.amount)
		"heal": state.hp = minf(config.saint.structure, state.hp + data.amount)
		"stun":
			for enemy in state.enemies:
				enemy.stun = maxi(enemy.stun, state.tick + int(data.amount))
				enemy.relay_strike_at = 0
	emit("machine_restored", {"position": p, "machine_id": machine.id, "reward": data.description})

func finish(won: bool, reason: String):
	state.phase = "won" if won else "lost"
	state.last_reason = reason
	emit("result")

func has_major() -> bool:
	for e in state.enemies:
		if e.major: return true
	return false

func spawn(id: String):
	var major = id == config.elite or id == config.boss
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
	var hp = float(config.boss_rules.boss_hp if id == config.boss else config.boss_rules.elite_hp) if major else data.hp * (1.0 + state.wave * config.enemy_rules.wave_hp_scale)
	var inspected = major and has_gift("gift.inspection_lens")
	state.enemies.append({"id": state.next_id, "type": id, "p": p, "hp": hp, "max_hp": hp, "radius": 35 if major else data.radius,
		"relay_strike_at": 0, "relay_ready": 0, "entry_id": entry.id, "major": major, "marked": 0, "stun": 0, "bound": 0, "slow": 0, "attack": 0, "charge": Vector2.ZERO, "windup": 0, "flash": 0, "stolen": 0, "inspected": inspected})
	if inspected:
		state.inspection = "DEMOLITION CIRCLES / WORKER CALLS" if id == config.boss else "COPIES YOUR EVOLVED GEOMETRY"
		emit("inspection", {"position": p, "target_id": state.next_id, "property": state.inspection})
	state.next_id += 1

func update_enemies():
	for e in state.enemies:
		if e.hp <= 0: continue
		if e.major:
			if state.tick % int(config.boss_rules.hazard_interval) == 0:
				var count = 3 if e.type == config.boss else 1
				if e.type == config.boss and e.hp / e.max_hp < 0.34: count = 4
				for i in range(count):
					var p = state.position if i == 0 else relay_position() + Vector2(random_int(420) - 210, random_int(300) - 150)
					state.hazards.append({"p": p, "from": e.p, "until": state.tick + int(config.boss_rules.hazard_warning_ticks * warning_multiplier()), "radius": config.boss_rules.hazard_radius, "source": e.type, "source_id": e.id, "copy": e.type == config.elite and state.evolved})
				emit("warning", {"position": e.p})
			if e.type == config.boss and e.hp / e.max_hp < 0.67 and state.tick % int(config.boss_rules.worker_interval) == 0: call_deferred_spawn = true
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
		var speed = float(config.enemy_rules.major_speed) if e.major else float(data.speed)
		if e.get("slow", 0) > state.tick: speed *= 0.62
		# Controllers threaten the relay through announced hazards and workers.
		# They do not park on it and apply unavoidable contact damage.
		if e.major and e.p.distance_to(target) < config.enemy_rules.drone_distance: speed = 0
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
				state.position = arena.move_body(state.position, (state.position - e.p).normalized() * data.push_distance, config.saint.radius)
			hurt_saint(data.damage)
		update_relay_strike(e, data.damage)
	if call_deferred_spawn:
		call_deferred_spawn = false
		spawn("enemy.rivet_hound")

var call_deferred_spawn = false

func hurt_saint(amount: float):
	if state.tick < state.hurt_until: return
	state.hp -= amount
	state.hurt_until = state.tick + int(config.saint.invulnerability_ticks)
	emit("hurt", {"position": state.position, "amount": amount})

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

func update_weapons():
	for w in state.weapons:
		var data = config.weapons[w.id]
		var rail = w.get("rail", false)
		var toll = w.get("toll", false)
		var shape = "rail" if rail else ("radial" if toll else data.shape)
		var radius = config.rail.range if rail else (config.great_toll.range if toll else data.range)
		var target = null
		var score = INF
		for e in state.enemies:
			if e.hp <= 0 or state.position.distance_to(e.p) > radius: continue
			var distance_score = state.position.distance_squared_to(e.p)
			var candidate = e.hp if shape == "shot" else distance_score
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
					state.hp = minf(config.saint.structure, state.hp + config.rail.repair_on_elite_hit)
					emit("repair", {"position": state.position, "source": e.p})
				else: repair_relay(config.rail.repair_on_elite_hit, e.p)
			emit("hit", {"position": e.p, "amount": dealt, "weapon": w.id, "color": data.color})
			if e.hp <= 0:
				state.kills += 1
				emit("death", {"position": e.p, "color": data.color})
				if e.type == config.boss: state.boss_dead = true
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
	if optional_mode():
		for i in range(state.machines.size()):
			if state.machines[i].complete: continue
			var machine_data = config.optional_repairs.machines[i]
			var p = Vector2(machine_data.position[0], machine_data.position[1])
			if state.position.distance_to(p) <= data.machine_range:
				advance_optional_machine(i, data.repair_progress, state.position)
				return
	if state.hp < config.saint.structure:
		var actual = minf(data.saint_repair, config.saint.structure - state.hp)
		state.hp += actual
		if actual > 0: emit("repair", {"position": state.position, "amount": actual, "source": state.position + Vector2(0, -28)})

func update_pickups():
	for p in state.pickups:
		if p.p.distance_to(state.position) < config.combat.pickup_radius:
			if p.kind == "scrap": collect_scrap(int(p.amount))
			else: state.hp = minf(config.saint.structure, state.hp + p.amount)
			emit("pickup", {"position": p.p, "amount": p.amount})
			p.amount = 0
	state.pickups = state.pickups.filter(func(p): return p.amount > 0)

func collect_scrap(amount: int):
	var net = amount
	if has_gift("gift.inspection_lens"):
		state.scrap_tax_progress += amount
		var spent = int(state.scrap_tax_progress / 5)
		state.scrap_tax_progress %= 5
		net -= spent
	state.scrap += maxi(0, net)

func update_hazards():
	for h in state.hazards:
		if h.until != state.tick: continue
		var player_hit = state.position.distance_to(h.p) < h.radius
		var relay_hit = relay_position().distance_to(h.p) < h.radius
		if h.copy:
			var direction = (h.p - h.from).normalized()
			var player_delta = state.position - h.from
			var relay_delta = relay_position() - h.from
			player_hit = player_delta.dot(direction) >= 0 and player_delta.dot(direction) < config.rail.range and absf(player_delta.cross(direction)) < config.rail.width + config.saint.radius
			relay_hit = relay_delta.dot(direction) >= 0 and relay_delta.dot(direction) < config.rail.range and absf(relay_delta.cross(direction)) < config.rail.width + 28
			emit("attack", {"from": h.from, "to": h.from + direction * config.rail.range, "shape": "rail", "weapon": "elite.memory_crane", "color": "e48b73", "range": config.rail.range})
		if player_hit: hurt_saint(h.get("damage", config.boss_rules.hazard_damage))
		if relay_hit:
			damage_relay(config.boss_rules.hazard_damage * config.boss_rules.relay_damage_multiplier, h.get("source", "demolition"))
		if not h.copy: emit("blast", {"position": h.p, "radius": h.radius})
	state.hazards = state.hazards.filter(func(h): return h.until > state.tick)

func snapshot() -> Dictionary:
	return state.duplicate(true)

func restore(saved: Dictionary) -> bool:
	if saved.get("version", 0) != 1 or not saved.has("weapons") or not saved.has("rng"): return false
	if saved.get("arena_id", "") != arena.data.id: return false
	state = saved.duplicate(true)
	if not state.has("mode"): state.mode = "relay"
	if not state.has("machines"): state.machines = []
	# Compatible defaults for existing authored-workshop saves.
	var defaults = {"relay_last_hit": -999, "relay_damage_sources": {}, "relay_last_source": "", "backup_absorbed": 0.0, "calibrated": false, "service_active": false, "motes_left": 0,
		"gifts": [], "component_tag": "", "inspection": "", "scrap_tax_progress": 0, "censer_defeats": 0}
	for field in defaults:
		if not state.has(field): state[field] = defaults[field]
	for w in state.weapons + state.reserve:
		if not w.has("toll"): w.toll = false
	for enemy in state.enemies:
		if not enemy.has("relay_strike_at"): enemy.relay_strike_at = 0
		if not enemy.has("relay_ready"): enemy.relay_ready = 0
		if not enemy.has("slow"): enemy.slow = 0
		if not enemy.has("inspected"): enemy.inspected = false
	events.clear()
	return true

func state_hash() -> String:
	return var_to_bytes(state).hex_encode().sha256_text()
