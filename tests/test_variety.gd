extends SceneTree
const Sim = preload("res://game/simulation.gd")
var checks = 0
var failures = 0
func check(ok: bool, label: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", label)
func enemy(s, kind, p):
	s.spawn(kind)
	var e = s.state.enemies.back()
	e.p = p
	return e
func _initialize():
	var s = Sim.new()
	for weapon in ["weapon.hymn_coil", "weapon.altar_mortar"]:
		s.start(0,147,"optional")
		s.state.position = Vector2(550,530)
		s.state.weapons = [{"id": weapon, "rank": 1, "rail": false, "ready": 0}]
		var a = enemy(s,"enemy.rivet_hound",Vector2(650,530))
		var b = enemy(s,"enemy.rivet_hound",Vector2(710,530))
		var c = enemy(s,"enemy.rivet_hound",Vector2(710,700))
		var hp = a.hp
		s.update_weapons()
		check(a.hp < hp and b.hp < hp and c.hp == hp,weapon + " hits aligned cluster but excludes distant flank")
		var after = a.hp
		s.update_weapons()
		check(a.hp == after,weapon + " respects cooldown")
	s.start(0,147,"optional")
	s.state.weapons = [s.make_weapon("weapon.nailer_small_mercies")]
	var close_mite = enemy(s,"enemy.scrap_mite",s.state.position + Vector2(70,70))
	var priority_spitter = enemy(s,"enemy.cinder_spitter",s.state.position + Vector2(250,0))
	var close_hp = close_mite.hp
	var priority_hp = priority_spitter.hp
	s.update_weapons()
	check(priority_spitter.hp < priority_hp and close_mite.hp == close_hp,"Nailer prioritizes an intended support threat over a closer swarm target")
	s.start(2,147,"optional")
	s.state.weapons = [s.make_weapon("weapon.candle_nailer")]
	var healthy = enemy(s,"enemy.choir_drone",s.state.position + Vector2(120,0))
	var wounded = enemy(s,"enemy.rivet_hound",s.state.position + Vector2(150,70))
	wounded.hp = 10
	var healthy_hp = healthy.hp
	s.update_weapons()
	check(wounded.hp < 10 and healthy.hp == healthy_hp,"Candle-Nailer executes the weakest reachable target")
	s.start(0,147,"optional")
	s.state.weapons = [s.make_weapon("weapon.altar_mortar")]
	var lone = enemy(s,"enemy.rivet_hound",s.state.position + Vector2(85,0))
	var cluster_a = enemy(s,"enemy.forklift_brute",s.state.position + Vector2(240,0))
	var cluster_b = enemy(s,"enemy.rivet_hound",s.state.position + Vector2(265,20))
	var lone_hp = lone.hp
	s.update_weapons()
	check(lone.hp == lone_hp and cluster_a.hp < cluster_a.max_hp and cluster_b.hp < cluster_b.max_hp,"Altar Mortar chooses a distant cluster over an isolated nearest target")
	s.start(0,147,"optional")
	s.state.weapons = [s.make_weapon("weapon.procession_gear")]
	var orbit_target = enemy(s,"enemy.forklift_brute",s.state.position + Vector2(80,0))
	var distant_target = enemy(s,"enemy.rivet_hound",s.state.position + Vector2(180,0))
	var distant_hp = distant_target.hp
	s.update_weapons()
	check(orbit_target.hp < orbit_target.max_hp and distant_target.hp == distant_hp,"Procession Gear protects close orbit but cannot answer range")
	s.start(0,147,"optional")
	s.state.weapons = [s.make_weapon("weapon.cable_contrition")]
	var bound_a = enemy(s,"enemy.forklift_brute",s.state.position + Vector2(130,0))
	var bound_b = enemy(s,"enemy.rivet_hound",s.state.position + Vector2(145,35))
	s.update_weapons()
	check(bound_a.bound > s.state.tick and bound_b.bound > s.state.tick,"Contrition Cable binds a broad approach")
	check(bound_a.max_hp - bound_a.hp < 20,"Contrition Cable preserves low burst as its weakness")
	s.start(0,147,"optional")
	var healer = enemy(s,"enemy.rust_pilgrim",Vector2(550,600))
	var ally = enemy(s,"enemy.forklift_brute",Vector2(590,600))
	ally.hp = ally.max_hp - 5
	s.update_enemies()
	check(ally.hp == ally.max_hp,"repair clamps to maximum health")
	ally.hp -= 20
	s.update_enemies()
	check(ally.hp == ally.max_hp - 20,"repair cannot repeat during cooldown")
	s.start(0,147,"optional")
	enemy(s,"enemy.cinder_spitter",Vector2(750,530))
	s.update_enemies()
	check(s.state.hazards.size() == 1,"spitter creates warning")
	var h = s.state.hazards[0].duplicate()
	var hp = s.state.hp
	s.state.tick = h.until - 1
	s.update_hazards()
	check(s.state.hp == hp,"warning does no early damage")
	s.state.tick = h.until
	s.update_hazards()
	check(s.state.hp == hp - 8,"spitter resolves configured damage")
	s.start(0,147,"optional")
	enemy(s,"enemy.cinder_spitter",Vector2(750,530))
	s.update_enemies()
	h = s.state.hazards[0].duplicate()
	s.state.position += Vector2(0,100)
	s.state.tick = h.until
	s.update_hazards()
	check(s.state.hp == s.config.saint.structure,"moving away avoids locked blast")
	s.start(0,147,"optional")
	enemy(s,"enemy.forklift_brute",Vector2(580,530))
	var before = s.state.position
	s.update_enemies()
	check(s.state.position.distance_to(before) > 40 and s.state.hp < s.config.saint.structure,"brute contact pushes and damages")
	var b = Sim.new()
	b.restore(s.snapshot())
	for i in range(600):
		s.step(Vector2.from_angle(i * 0.02))
		b.step(Vector2.from_angle(i * 0.02))
	check(s.state_hash() == b.state_hash(),"new enemies preserve save replay determinism")
	print("VARIETY: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
