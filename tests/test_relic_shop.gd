extends SceneTree
const Sim = preload("res://game/simulation.gd")
var checks = 0
var failures = 0
func check(ok, label):
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ",label)
func _initialize():
	var s = Sim.new()
	var b = Sim.new()
	for doctrine in range(3):
		s.start(doctrine,147,"optional")
		s.enter_shop()
		check(s.state.offers.size()==6 and s.state.offers.all(func(id): return id in s.catalogue),"six real relics for each doctrine")
		check(s.state.offers.filter(func(id): return id in s.config.weapons).size()==4,"four weapon choices and two catalysts")
		var unique = {}
		for id in s.state.offers: unique[id]=true
		check(unique.size()==6,"no duplicated cards")
		var before=s.state_hash()
		s.offer_reason(0)
		check(before==s.state_hash(),"preview cannot mutate simulation")
		b.restore(s.snapshot())
		s.command("reroll")
		b.command("reroll")
		check(s.state_hash()==b.state_hash(),"shop restore replay")

	s.start(0,147,"optional")
	s.enter_shop()
	var held=s.state.offers[1]
	s.command("lock",1)
	s.command("reroll")
	check(held in s.state.offers,"locked relic survives refresh")
	s.state.scrap=0
	var rejected=s.state_hash()
	check(s.buy(0)=="INSUFFICIENT_SCRAP" and s.state_hash()==rejected,"unaffordable purchase rejects atomically")
	for id in s.config.catalysts: s.state.catalysts.append(id)
	s.roll_shop()
	check(s.state.offers.all(func(id):return id in s.config.weapons),"exhausted catalysts become weapon choices")
	s.state.offers[0]="service.repair"
	var before=s.state_hash()
	check(s.buy(0)=="INVALID_OFFER" and before==s.state_hash(),"main mode cannot buy old healing services")
	b.restore(s.snapshot())
	check(b.state.offers.all(func(id): return not id.begins_with("service.")),"old shop save migrates to relic cards")
	s.start(0,147,"optional")
	s.state.kills=11
	s.spawn("enemy.rivet_hound")
	s.state.enemies[0].p=s.state.position+Vector2(40,0)
	s.state.enemies[0].hp=1
	s.update_weapons()
	check(s.state.pickups.any(func(p):return p.kind=="repair_kit"),"twelfth defeat drops repair kit")
	var kit=s.state.pickups.filter(func(p):return p.kind=="repair_kit")[0]
	s.state.position=kit.p
	s.update_pickups()
	check(s.state.pickups.has(kit),"full health preserves kit")
	s.state.hp=95
	b.restore(s.snapshot())
	s.update_pickups()
	b.update_pickups()
	check(s.state.hp==100 and not s.state.pickups.has(kit),"kit heals capped and consumed once")
	check(s.state_hash()==b.state_hash(),"kit save replay")
	s.update_pickups()
	check(s.state.hp==100,"no repeated healing")
	print("RELIC SHOP: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
