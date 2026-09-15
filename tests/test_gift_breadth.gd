extends SceneTree
const Sim = preload("res://game/simulation.gd")

var checks = 0
var failures = 0

func check(ok: bool, label: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("GIFT BREADTH FAIL: ", label)

func enemy(sim, id: String, position: Vector2, hp = -1.0):
	sim.spawn(id)
	var target = sim.state.enemies.back()
	target.p = position
	if hp >= 0:
		target.hp = hp
		target.max_hp = maxf(target.max_hp, hp)
	return target

func preview_case(label: String, weapons: Array, reserve: Array, offered_id: String, scrap: int):
	var sim = Sim.new()
	sim.start(0, 147, "optional")
	sim.enter_shop()
	sim.state.gifts = ["gift.honest_scale"]
	sim.state.weapons = weapons.duplicate(true)
	sim.state.reserve = reserve.duplicate(true)
	sim.state.scrap = scrap
	sim.state.offers[0] = offered_id
	var saved = sim.snapshot()
	var hash_before = sim.state_hash()
	var events_before = sim.events.duplicate(true)
	var preview = sim.purchase_preview(0)
	check(sim.state_hash() == hash_before and sim.events == events_before, label + " preview is a pure query")

	var actual = Sim.new()
	check(actual.restore(saved), label + " comparison state restores")
	var actual_result = actual.command("buy", 0)
	check(preview.get("result", "") == actual_result, label + " preview result matches buy")
	if actual_result == "OK":
		check(int(preview.get("active_count", -1)) == actual.state.weapons.size() and int(preview.get("reserve_count", -1)) == actual.state.reserve.size(), label + " preview capacity matches buy")
		check(int(preview.get("scrap_after", -1)) == actual.state.scrap, label + " preview currency matches buy")
		var actual_combines: Array = []
		for event in actual.events.filter(func(event): return event.kind == "rank_up"):
			actual_combines.append({"weapon": event.weapon, "rank": int(event.rank)})
		check(preview.get("combines", []) == actual_combines, label + " preview Combine lineage matches buy events")
	return preview

func _initialize():
	var catalogue = Sim.new()
	check(catalogue.catalogue["gift.loose_spring"].duration_ticks == 90, "Loose Spring owns an exact 90-tick duration")
	check(is_equal_approx(float(catalogue.catalogue["gift.choir_filter"].tradeoff_value), 0.85), "Choir Filter owns its 0.85 damage trade-off")
	check(catalogue.catalogue["gift.brass_fuse"].effect_value == 180 and is_equal_approx(float(catalogue.catalogue["gift.brass_fuse"].tradeoff_value), 1.15), "Brass Fuse owns its 180-tick minimum Mark and 1.15 Bell cadence")

	# Honest Scale previews the exact transaction projected by the public buy command.
	var no_combine = preview_case("no-combine purchase", [catalogue.make_weapon("weapon.nailer_small_mercies")], [], "weapon.bell_last_shift", 100)
	check(no_combine.get("combines", []).is_empty() and no_combine.get("destination", "ACTIVE") == "ACTIVE", "Honest Scale identifies an ordinary active-slot purchase")
	var one_combine = preview_case("single Combine purchase", [catalogue.make_weapon("weapon.nailer_small_mercies")], [], "weapon.nailer_small_mercies", 100)
	check(one_combine.get("combines", []) == [{"weapon": "weapon.nailer_small_mercies", "rank": 2}], "Honest Scale reports Rank II auto-Combine")
	var cascade = preview_case("cascade Combine purchase", [catalogue.make_weapon("weapon.nailer_small_mercies", 2), catalogue.make_weapon("weapon.nailer_small_mercies")], [], "weapon.nailer_small_mercies", 100)
	check(cascade.get("combines", []) == [{"weapon": "weapon.nailer_small_mercies", "rank": 2}, {"weapon": "weapon.nailer_small_mercies", "rank": 3}], "Honest Scale reports ordered Rank II-to-III cascade")
	var full_active = [catalogue.make_weapon("weapon.nailer_small_mercies"), catalogue.make_weapon("weapon.bell_last_shift"), catalogue.make_weapon("weapon.candle_nailer"), catalogue.make_weapon("weapon.procession_gear")]
	var reserve_purchase = preview_case("reserve purchase", full_active, [], "weapon.cable_contrition", 100)
	check(reserve_purchase.get("destination", "") == "RESERVE" and reserve_purchase.reserve_count == 1, "Honest Scale identifies a reserve-slot purchase")
	var full_rejection = preview_case("full-loadout rejection", full_active, [catalogue.make_weapon("weapon.hymn_coil")], "weapon.cable_contrition", 100)
	check(full_rejection.result == "LOADOUT_FULL", "Honest Scale predicts a full-loadout rejection")
	var poor_rejection = preview_case("insufficient-Scrap rejection", [catalogue.make_weapon("weapon.nailer_small_mercies")], [], "weapon.bell_last_shift", 0)
	check(poor_rejection.result == "INSUFFICIENT_SCRAP", "Honest Scale predicts an insufficient-Scrap rejection")
	var repair_rejection = preview_case("unneeded repair rejection", [catalogue.make_weapon("weapon.nailer_small_mercies")], [], "service.repair", 100)
	check(repair_rejection.result == "ALREADY_REPAIRED", "Honest Scale predicts an already-complete repair service")
	var used_service = Sim.new()
	used_service.start(1, 147, "optional")
	used_service.enter_shop()
	used_service.state.gifts = ["gift.honest_scale"]
	used_service.state.scrap = 100
	used_service.state.calibrated = true
	used_service.state.offers[0] = "service.calibrate"
	var used_preview = used_service.purchase_preview(0)
	check(used_preview.result == "SERVICE_USED" and used_service.buy(0) == used_preview.result, "Honest Scale matches a used service rejection")

	# Loose Spring is wound only by authoritative first completion of stable work IDs.
	var spring = Sim.new()
	spring.start(0, 147, "optional")
	spring.state.gifts = ["gift.loose_spring"]
	var machine_data = spring.config.optional_repairs.machines[0]
	var machine_position = Vector2(machine_data.position[0], machine_data.position[1])
	spring.state.position = machine_position
	spring.state.machines[0].progress = float(spring.config.optional_repairs.required_ticks) - 1.0
	spring.step(Vector2.ZERO)
	var spring_until = spring.state.tick + 90
	check(spring.state.machines[0].complete and spring.state.loose_spring_until == spring_until, "optional repair completion winds Loose Spring for exactly 90 ticks")
	check(spring.state.loose_spring_sources == ["site.collapsed_workshop:%s" % spring.state.machines[0].id], "Loose Spring records the completed machine's site-qualified stable ID once")
	check(spring.events.any(func(event): return event.kind == "loose_spring_released" and event.until == spring_until), "Loose Spring completion emits its authoritative activation trace")
	var first_until = spring.state.loose_spring_until
	spring.advance_optional_machine(0, 999, spring.state.position, true)
	check(spring.state.loose_spring_until == first_until and spring.state.loose_spring_sources.size() == 1, "completed work cannot rewind or retrigger Loose Spring")
	spring.state.position = Vector2(550, 530)
	var burst_start = spring.state.position
	spring.step(Vector2.RIGHT)
	var burst_distance = burst_start.distance_to(spring.state.position)
	check(is_equal_approx(burst_distance, float(spring.state.move_speed) * 1.35 / spring.config.tick_rate), "Loose Spring applies its data-owned movement burst")
	for i in range(88): spring.step(Vector2.ZERO)
	var expired_start = spring.state.position
	spring.step(Vector2.RIGHT)
	check(spring.state.tick == spring_until and is_equal_approx(expired_start.distance_to(spring.state.position), float(spring.state.move_speed) / spring.config.tick_rate), "Loose Spring expires on the exact authored tick")

	var destination_spring = Sim.new()
	destination_spring.start(0, 147, "optional")
	destination_spring.state.gifts = ["gift.loose_spring"]
	destination_spring.state.route = "route.brass_choir"
	destination_spring.enter_destination(destination_spring.routes["route.brass_choir"])
	var objective_data = destination_spring.objective_data()
	destination_spring.state.objective[0].progress = float(objective_data.required_ticks) - 1.0
	destination_spring.state.position = Vector2(objective_data.nodes[0].position[0], objective_data.nodes[0].position[1])
	destination_spring.step(Vector2.ZERO)
	check(destination_spring.state.objective[0].complete and "%s:%s" % [destination_spring.state.site_id, objective_data.nodes[0].id] in destination_spring.state.loose_spring_sources, "destination objective-node completion also winds Loose Spring by site-qualified stable node ID")

	# Choir Filter keeps support actions suppressed after Quiet while paying exact damage.
	var hymn_baseline = Sim.new()
	hymn_baseline.start(0, 147, "optional")
	hymn_baseline.state.position = Vector2(550, 530)
	hymn_baseline.state.weapons = [hymn_baseline.make_weapon("weapon.hymn_coil", 3)]
	var baseline_support = enemy(hymn_baseline, "enemy.rust_pilgrim", hymn_baseline.state.position + Vector2(150, 0), 500)
	hymn_baseline.update_weapons()
	var baseline_damage = baseline_support.max_hp - baseline_support.hp

	var filter = Sim.new()
	filter.start(0, 147, "optional")
	filter.state.gifts = ["gift.choir_filter"]
	filter.state.position = Vector2(550, 530)
	filter.state.weapons = [filter.make_weapon("weapon.hymn_coil", 3)]
	var filtered_support = enemy(filter, "enemy.rust_pilgrim", filter.state.position + Vector2(150, 0), 500)
	filter.update_weapons()
	var filtered_damage = filtered_support.max_hp - filtered_support.hp
	check(is_equal_approx(filtered_damage, baseline_damage * 0.85), "Choir Filter applies exactly 0.85 direct Hymn damage")
	check(filtered_support.support_lock_until == filtered_support.quieted + int(filter.catalogue["gift.choir_filter"].effect_value), "Choir Filter begins recovery after Quiet expires")
	check(filter.events.any(func(event): return event.kind == "choir_filter_blocked" and event.until == filtered_support.support_lock_until), "Choir Filter emits a traceable support lock")
	var patient = enemy(filter, "enemy.rivet_hound", filtered_support.p + Vector2(30, 0), 500)
	patient.hp = 100
	filter.state.tick = filtered_support.quieted
	filtered_support.attack = 0
	filter.update_enemies()
	check(patient.hp == 100, "support action remains blocked after Quiet itself ends")
	filter.state.tick = filtered_support.support_lock_until
	filter.update_enemies()
	check(patient.hp > 100, "support action resumes on the exact recovery tick")

	# Brass Fuse keys its one activation to site+wave and taxes Bell cadence.
	var fuse = Sim.new()
	fuse.start(0, 147, "optional")
	fuse.state.gifts = ["gift.brass_fuse"]
	fuse.state.position = Vector2(550, 530)
	fuse.state.weapons = [fuse.make_weapon("weapon.bell_last_shift")]
	var fuse_a = enemy(fuse, "enemy.rivet_hound", fuse.state.position + Vector2(70, 0), 500)
	var fuse_b = enemy(fuse, "enemy.rivet_hound", fuse.state.position + Vector2.from_angle(0.45) * 95, 500)
	fuse.update_weapons()
	var fuse_mark_until = fuse.state.tick + maxi(180, fuse.current_wave_ticks() - fuse.state.wave_tick)
	var first_marked = [fuse_a, fuse_b].filter(func(target): return target.marked == fuse_mark_until)
	check(first_marked.size() == 1 and fuse.state.brass_fuse_segment == fuse.site_wave_key(), "Brass Fuse marks exactly the deterministic first Bell stagger per site-wave")
	check(fuse.state.weapons[0].ready == fuse.state.tick + int(fuse.config.weapons["weapon.bell_last_shift"].cooldown * 1.15), "Brass Fuse applies exactly 1.15 Bell cooldown")
	check(fuse.events.any(func(event): return event.kind == "brass_fuse_lit" and event.until == fuse_mark_until), "Brass Fuse emits its authoritative wave-long Mark trace")
	fuse.state.enemies.clear()
	var same_segment = enemy(fuse, "enemy.rivet_hound", fuse.state.position + Vector2(70, 0), 500)
	fuse.state.weapons[0].ready = 0
	fuse.update_weapons()
	check(same_segment.marked == 0, "Brass Fuse cannot retrigger in the same site-wave")
	fuse.state.enemies.clear()
	fuse.state.wave += 1
	fuse.state.wave_tick = 0
	var next_wave = enemy(fuse, "enemy.rivet_hound", fuse.state.position + Vector2(70, 0), 500)
	fuse.state.weapons[0].ready = 0
	fuse.update_weapons()
	fuse_mark_until = fuse.state.tick + maxi(180, fuse.current_wave_ticks() - fuse.state.wave_tick)
	check(next_wave.marked == fuse_mark_until and fuse.state.brass_fuse_segment == fuse.site_wave_key(), "Brass Fuse rearms on the next wave")
	fuse.state.enemies.clear()
	fuse.state.site_id = "site.rootworks_pump"
	var next_site = enemy(fuse, "enemy.rivet_hound", fuse.state.position + Vector2(70, 0), 500)
	fuse.state.weapons[0].ready = 0
	fuse.update_weapons()
	fuse_mark_until = fuse.state.tick + maxi(180, fuse.current_wave_ticks() - fuse.state.wave_tick)
	check(next_site.marked == fuse_mark_until and fuse.state.brass_fuse_segment == fuse.site_wave_key(), "same wave number at a different site is a distinct Fuse segment")

	# New transient state survives current saves and receives deterministic version-3 defaults.
	var saved_gifts = Sim.new()
	saved_gifts.start(0, 147, "optional")
	saved_gifts.state.gifts = ["gift.loose_spring", "gift.brass_fuse"]
	saved_gifts.state.loose_spring_until = 912
	saved_gifts.state.loose_spring_sources = ["repair.salvage"]
	saved_gifts.state.brass_fuse_segment = "site.collapsed_workshop:wave_2"
	var saved_enemy = enemy(saved_gifts, "enemy.choir_drone", saved_gifts.state.position + Vector2(100, 0))
	saved_enemy.support_lock_until = 777
	var restored = Sim.new()
	check(restored.restore(saved_gifts.snapshot()) and restored.state_hash() == saved_gifts.state_hash(), "Gift timers, sources, segment and support lock restore exactly")

	var additive = saved_gifts.snapshot()
	additive.erase("loose_spring_until")
	additive.erase("loose_spring_sources")
	additive.erase("brass_fuse_segment")
	for saved_support in additive.enemies: saved_support.erase("support_lock_until")
	var migrated = Sim.new()
	check(migrated.restore(additive), "version-3 save without Gift transients remains compatible")
	check(migrated.state.loose_spring_until == 0 and migrated.state.loose_spring_sources.is_empty() and migrated.state.brass_fuse_segment == "", "additive Gift defaults are deterministic")
	check(migrated.state.enemies.all(func(target): return target.support_lock_until == 0), "legacy enemies receive a deterministic support-lock default")

	var eligibility = Sim.new()
	eligibility.start(0, 147, "optional")
	check(eligibility.gift_offer_eligible("gift.honest_scale") and eligibility.gift_offer_eligible("gift.loose_spring"), "broad and unfinished-repair Gifts are eligible in a fresh Workshop")
	check(not eligibility.gift_offer_eligible("gift.choir_filter") and not eligibility.gift_offer_eligible("gift.brass_fuse"), "weapon-dependent Gifts are withheld from incompatible builds")
	eligibility.state.weapons.append(eligibility.make_weapon("weapon.hymn_coil"))
	eligibility.state.weapons.append(eligibility.make_weapon("weapon.bell_last_shift"))
	check(eligibility.gift_offer_eligible("gift.choir_filter") and eligibility.gift_offer_eligible("gift.brass_fuse"), "weapon-dependent Gifts become eligible with a matching carried relic")
	var stale_offer = Sim.new()
	stale_offer.start(0, 147, "optional")
	stale_offer.enter_shop()
	stale_offer.state.offers[3] = "gift.choir_filter"
	stale_offer.state.locked = "gift.choir_filter"
	var stale_hash = stale_offer.state_hash()
	check(stale_offer.purchase_preview(3).result == "INACTIVE_GIFT" and stale_offer.buy(3) == "INACTIVE_GIFT" and stale_offer.state_hash() == stale_hash, "stale incompatible Gift offers reject without mutation")
	stale_offer.roll_shop()
	check(stale_offer.state.locked == "" and "gift.choir_filter" not in stale_offer.state.offers, "reroll clears an incompatible locked Gift")

	var removal = Sim.new()
	removal.start(0, 147, "optional")
	removal.enter_shop()
	removal.state.gifts = ["gift.loose_spring", "gift.inspection_lens"]
	removal.state.loose_spring_until = 90
	removal.state.inspection = "VISIBLE PROPERTY"
	check(removal.command("sell_gift", 0) == "OK" and removal.state.loose_spring_until == 0, "selling Loose Spring ends its carried movement effect")
	check(removal.command("sell_gift", 0) == "OK" and removal.state.inspection == "", "selling Inspection Lens clears its carried HUD property")

	saved_gifts.finish(true, "Gift evidence complete.")
	check(saved_gifts.state.result_summary.gift_ids == ["gift.loose_spring", "gift.brass_fuse"] and saved_gifts.state.result_summary.gift_metrics == saved_gifts.state.gift_metrics, "Results snapshot ordered Gift IDs and causal metrics")

	print("GIFT BREADTH: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
