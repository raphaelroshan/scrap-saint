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
