extends SceneTree
var checks = 0
var failures = 0
func check(ok: bool,label: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("ACTOR ART FAIL: ",label)
func _initialize(): call_deferred("run")
func run():
	var game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.set_physics_process(false)
	game.screen = "game"
	game.sim.start(0,147,"optional")
	var art = game.actor_art
	for id in game.sim.config.enemies:
		check(art.assets.has(id),"ordinary enemy has painted art: " + id)
		game.sim.spawn(id)
		var enemy = game.sim.state.enemies[-1]
		var region = art.region_for(id)
		var texture = art.textures[art.assets[id].path]
		check(Rect2(Vector2.ZERO,texture.get_size()).encloses(region),"valid enemy source region")
		check(art.sprite_rect(id,Vector2.ZERO).size.length() > 0,"nonempty game-size sprite")
		check(art.idle_offset(enemy,12,true) == Vector2.ZERO,"reduced effects holds idle motion")
		check(art.assets[id].extent <= float(enemy.radius)*3.0,"silhouette does not dwarf hit footprint")
	for i in range(game.sim.config.optional_repairs.machines.size()):
		game.sim.start(0,147,"optional")
		game.sim.state.hp = 50
		var machine = game.sim.state.machines[i]
		var data = game.sim.config.optional_repairs.machines[i]
		check(art.assets.has(machine.id),"repair station has paired art")
		check(art.repair_state(machine,game.sim.state.active_machine) == "broken","starts broken")
		game.sim.state.position = Vector2(data.position[0]+35,data.position[1])
		for tick in range(90): game.sim.update_optional_repairs()
		check(art.repair_state(machine,game.sim.state.active_machine) == "working","simulation progress selects working feedback")
		check(art.repair_frame(machine) == "broken","in-progress does not show completed artwork")
		for tick in range(90): game.sim.update_optional_repairs()
		check(machine.complete and art.repair_state(machine,game.sim.state.active_machine) == "restored","simulation completion selects restored art")
		check(art.region_for(machine.id,"broken").size == art.region_for(machine.id,"restored").size,"matched repair cells share scale and pivot")
		var texture = art.textures[art.assets[machine.id].path]
		for state in ["broken","restored"]:
			check(Rect2(Vector2.ZERO,texture.get_size()).encloses(art.region_for(machine.id,state)),"valid repair source region")
		var hash_before = game.sim.state_hash()
		game.queue_redraw()
		await process_frame
		check(hash_before == game.sim.state_hash(),"rendering repair state does not award or alter anything")
	game.queue_free()
	await process_frame
	print("ACTOR ART: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
