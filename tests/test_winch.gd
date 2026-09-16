extends SceneTree
const Sim = preload("res://game/simulation.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:
		failures+=1
		printerr("FAIL: ",label)
func _initialize():
	var s=Sim.new()
	s.start(0,147,"optional")
	s.state.position=Vector2(550,550)
	s.state.weapons=[s.make_weapon("weapon.penance_winch")]
	for p in [Vector2(550,650),Vector2(550,900)]:
		s.spawn("enemy.forklift_brute")
		s.state.enemies.back().p=p
	var near=s.state.enemies[0]
	var far=s.state.enemies[1]
	var hp=far.hp
	s.update_weapons()
	check(s.state.weapons[0].winch.target==far.id,"farthest eligible enemy locked")
	for tick in range(1,30):
		s.state.tick=tick
		s.update_weapons()
	check(far.hp==hp,"no early damage")
	s.state.tick=30
	s.update_weapons()
	check(far.hp==hp-34 and near.hp==near.max_hp,"hook damages only locked enemy")
	var b=Sim.new()
	b.restore(s.snapshot())
	for tick in range(31,80):
		s.state.tick=tick
		b.state.tick=tick
		s.update_weapons()
		b.update_weapons()
	check(s.state_hash()==b.state_hash(),"mid-hook save replay")
	check(far.p.y<900 and far.p.distance_to(s.state.position)>=110,"pull moves target and respects stopping distance")
	check(far.hp==hp-34,"one damage event per cycle")
	check(s.state.weapons[0].winch.is_empty(),"arm finishes retracting")
	var before=s.state_hash()
	s.command("pause")
	var paused=s.state_hash()
	s.step(Vector2.ONE)
	check(s.state_hash()==paused,"pause freezes phases")
	s.command("pause")
	s.state.tick=210
	s.update_weapons()
	var locked=s.state.weapons[0].winch.target
	for e in s.state.enemies:
		if e.id==locked:e.hp=0
	s.state.tick=240
	s.update_weapons()
	check(not s.state.weapons[0].winch.caught,"dead target cannot be hooked")
	s.enter_shop()
	check(not s.state.weapons[0].has("winch"),"shop clears incomplete arm cycle")
	s.state.offers[0]="weapon.penance_winch"
	s.state.scrap=100
	check(s.command("buy",0)=="OK" and s.state.weapons[0].rank==2,"shop combines winch ranks")

	s.start(0,147,"optional")
	s.state.weapons=[s.make_weapon("weapon.penance_winch")]
	var obstacle=s.arena.obstacles[0]
	s.state.position=Vector2(obstacle.position.x-60,obstacle.get_center().y)
	s.spawn("enemy.rivet_hound")
	s.state.enemies[0].p=Vector2(obstacle.end.x+60,obstacle.get_center().y)
	s.update_weapons()
	check(not s.state.weapons[0].has("winch"),"solid machine blocks initial hook path")
	s.state.enemies[0].p=s.state.position+Vector2(0,120)
	s.update_weapons()
	check(s.state.weapons[0].winch.target==s.state.enemies[0].id,"clear target eligible")
	for tick in range(1,63):
		s.state.tick=tick
		s.update_weapons()
	check(absf(s.state.position.distance_to(s.state.enemies[0].p)-110)<0.1,"pull clamps exactly at safe stopping distance")
	check(s.arena.walkable(s.state.enemies[0].p,s.state.enemies[0].radius),"pulled body remains outside solid geometry")
	s.state.tick=210
	s.state.weapons[0].winch={}
	s.state.enemies[0].p=s.state.position+Vector2(0,150)
	s.update_weapons()
	s.state.enemies[0].p=Vector2(obstacle.end.x+60,obstacle.get_center().y)
	var health=s.state.enemies[0].hp
	s.state.tick=240
	s.update_weapons()
	check(s.state.enemies[0].hp==health and not s.state.weapons[0].winch.caught,"moving behind cover before hook cancels hit")
	print("WINCH: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
