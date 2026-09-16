extends SceneTree
const Sim = preload("res://game/simulation.gd")
var checks = 0
var failures = 0
func check(ok, label):
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", label)
func _initialize():
	var a = Sim.new()
	a.start(1, 147, "optional")
	a.state.position = Vector2(550,70)
	for i in range(200): a.update_optional_repairs()
	check(not a.state.machines[1].complete and a.state.machines[1].progress == 0, "full-health pump preserves reward")
	check(a.repair_preview(1).status.begins_with("FULL INTEGRITY"), "defer reason is readable")
	var before = a.state_hash()
	a.repair_preview(1)
	check(before == a.state_hash(), "preview is read-only")
	a.state.hp = 90
	for i in range(180): a.update_optional_repairs()
	check(a.state.hp == 100 and a.state.machines[1].complete, "useful pump caps healing")
	a.state.hp = 80
	a.update_optional_repairs()
	check(a.state.hp == 80, "pump cannot reward twice")
	a.start(1, 147, "optional")
	a.state.position = Vector2(1150,560)
	for i in range(200): a.update_optional_repairs()
	check(not a.state.machines[2].complete and a.repair_preview(2).status.begins_with("NO TARGETS"), "empty bell waits")
	a.spawn("enemy.rivet_hound")
	for i in range(180): a.update_optional_repairs()
	check(a.state.machines[2].complete and a.state.enemies[0].stun == 180, "bell grants useful control once")
	a.start(1, 147, "optional")
	a.state.position = Vector2(-70,450)
	for i in range(60): a.step(Vector2.ZERO)
	var progress = a.state.machines[0].progress
	a.hurt_saint(7)
	a.step(Vector2.ZERO)
	check(a.state.machines[0].progress == progress, "damage pauses work")
	check(a.events.any(func(e): return e.kind == "repair_paused"), "pause event explains interruption")
	var b = Sim.new()
	b.restore(a.snapshot())
	for i in range(50):
		a.step(Vector2.ZERO)
		b.step(Vector2.ZERO)
	check(a.state_hash() == b.state_hash() and a.state.machines[0].progress > progress, "resume after recovery reproduces on reload")
	progress = a.state.machines[0].progress
	a.state.position = Vector2(550,450)
	a.step(Vector2.ZERO)
	check(a.state.machines[0].progress == progress, "leaving preserves work")
	a.state.position = Vector2(-70,450)
	a.command("pause")
	a.update_optional_repairs()
	check(a.state.machines[0].progress == progress, "direct repair update respects pause")
	# A hit on the completion tick must interrupt before the reward commits.
	a.start(1,147,"optional")
	a.state.position = Vector2(-70,450)
	a.state.machines[0].progress = 179
	a.state.hazards.append({"p": a.state.position, "from": a.state.position, "until": 1, "radius": 62, "damage": 7, "copy": false})
	a.step(Vector2.ZERO)
	check(not a.state.machines[0].complete and a.state.machines[0].progress == 179, "same-tick hazard prevents completion")
	print("REPAIR QUALITY: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
