extends SceneTree
const Sim = preload("res://game/simulation.gd")
var checks = 0
var failures = 0

func check(ok: bool, label: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", label)

func _initialize():
	var sim = Sim.new()
	sim.start(1)
	check(is_equal_approx(sim.state.relay_hp, 126), "relay starts at 70 percent")
	sim.spawn("enemy.rivet_hound")
	var enemy = sim.state.enemies[0]
	enemy.p = sim.relay_position() + Vector2(30, 0)
	sim.update_relay_strike(enemy, 7)
	check(enemy.relay_strike_at == 60 and is_equal_approx(sim.state.relay_hp, 126), "warning precedes damage")
	check(sim.events.any(func(e): return e.kind == "relay_warning" and e.source_id == enemy.id), "warning identifies attacker")
	check(sim.relay_threat_count() == 1, "pending attack is visible threat")
	sim.state.tick = 59
	sim.update_relay_strike(enemy, 7)
	check(is_equal_approx(sim.state.relay_hp, 126), "no early strike")
	var saved = sim.snapshot()
	var other = Sim.new()
	other.restore(saved)
	sim.state.tick = 60
	other.state.tick = 60
	sim.update_relay_strike(enemy, 7)
	other.update_relay_strike(other.state.enemies[0], 7)
	check(sim.state_hash() == other.state_hash(), "save resumes pending strike exactly")
	check(is_equal_approx(sim.state.relay_hp, 119) and sim.state.relay_last_source == enemy.type, "strike records actual damage and source")
	sim.update_relay_strike(enemy, 7)
	check(is_equal_approx(sim.state.relay_hp, 119) and enemy.relay_strike_at == 0, "cooldown prevents repeated strike")
	sim.state.tick = enemy.relay_ready
	sim.update_relay_strike(enemy, 7)
	check(enemy.relay_strike_at > sim.state.tick, "next strike requires another full warning")
	enemy.stun = sim.state.tick + 48
	sim.update_relay_strike(enemy, 7)
	check(enemy.relay_strike_at == 0 and sim.relay_threat_count() == 0, "stagger cancels strike")
	enemy.stun = 0
	sim.update_relay_strike(enemy, 7)
	enemy.p += Vector2(100, 0)
	sim.update_relay_strike(enemy, 7)
	check(enemy.relay_strike_at == 0, "leaving relay range cancels strike")
	sim.damage_relay(1000, "test.contact")
	check(sim.state.relay_hp == 18 and sim.state.backup_absorbed > 0, "wave-one backup prevents lethal damage")
	sim.damage_relay(1000, "test.demolition")
	check(sim.state.relay_hp == 18, "all damage sources respect backup")
	sim.state.wave = 2
	sim.damage_relay(1000, "test.contact")
	check(sim.state.relay_hp == 0, "backup ends after first workshop")
	sim.state.relay_hp = 179
	sim.repair_relay(20)
	check(sim.state.relay_hp == 180 and sim.state.repairs == 1, "repair clamps and records actual restoration")
	sim.start(1)
	sim.state.wave = 2
	sim.state.position = sim.relay_position() + Vector2(0, 70)
	sim.spawn("enemy.rivet_hound")
	enemy = sim.state.enemies[0]
	enemy.p = sim.relay_position() + Vector2(20, 0)
	sim.update_relay_strike(enemy, 7)
	sim.update_weapons()
	check(enemy.stun > 0 and enemy.relay_strike_at == 0, "actual Bell hit cancels strike")
	sim.start()
	sim.state.hazards.append({"p": sim.relay_position(), "from": Vector2.ZERO, "until": 0, "radius": 62, "copy": false, "source": "boss.foreman_engine"})
	sim.state.relay_hp = 19
	sim.update_hazards()
	check(sim.state.relay_hp == 18 and sim.state.relay_damage_sources.has("boss.foreman_engine"), "demolition uses common damage rule")
	var legacy = sim.snapshot()
	legacy.erase("relay_damage_sources")
	legacy.erase("backup_absorbed")
	check(other.restore(legacy) and other.state.backup_absorbed == 0, "authored-layout save gets compatible pressure defaults")
	print("RELAY: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)

