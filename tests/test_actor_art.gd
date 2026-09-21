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
	var major_specs = {
		"elite.memory_crane": ["idle","copy","stunned"],
		"boss.foreman_engine": ["schedule","workers","final_orders","stunned"],
	}
	for id in major_specs:
		check(art.assets.has(id),"major has painted assembly: "+id)
		for state in major_specs[id]:
			check(art.assets[id].states.has(state),"major has state: "+id+"/"+state)
			for component in art.assets[id].states[state]:
				check(art.textures.has(component.path),"major component texture is cached")
				var source = component.region
				var texture = art.textures[component.path]
				check(Rect2(Vector2.ZERO,texture.get_size()).encloses(Rect2(source[0],source[1],source[2],source[3])),"major component region is valid")
				check(art.major_component_rect(component,Vector2.ZERO).size.x > 0 and art.major_component_rect(component,Vector2.ZERO).size.y > 0,"major component has a rendered extent")
	var crane = {"id": 901, "type": "elite.memory_crane", "phase": 0, "stun": 0, "flash": 0, "p": Vector2(400,400)}
	check(art.major_state(crane,[],120) == "idle","Memory Crane rests without a copied hazard")
	var copy_hazard = {"source_id":901,"until":180,"p":Vector2(600,400)}
	check(art.major_state(crane,[copy_hazard],120) == "copy","Memory Crane aims during an authoritative copied hazard")
	crane.stun = 180
	check(art.major_state(crane,[copy_hazard],120) == "stunned","stun overrides Memory Crane copy pose")
	var foreman = {"id": 902, "type": "boss.foreman_engine", "phase": 0, "stun": 0, "flash": 0, "p": Vector2(400,400)}
	for phase in range(3):
		foreman.phase = phase
		check(art.major_state(foreman,[],120) == ["schedule","workers","final_orders"][phase],"Foreman phase selects mechanical state %d" % phase)
	foreman.stun = 180
	check(art.major_state(foreman,[],120) == "stunned","stun overrides Foreman phase pose")
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
	game.sim.start(0,147,"optional")
	game.sim.state.wave = 6
	game.sim.spawn("elite.memory_crane")
	var major_hash = game.sim.state_hash()
	game.queue_redraw()
	await process_frame
	check(major_hash == game.sim.state_hash(),"painting a major actor does not alter simulation state")
	game.queue_free()
	await process_frame
	print("ACTOR ART: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
