extends SceneTree
const Sim = preload("res://game/simulation.gd")
var checks = 0
var failures = 0
func check(ok,label):
	checks += 1
	if not ok:
		failures += 1
		printerr("ROAD ECHO FAIL: ",label)
func clear_site(s):
	s.state.wave = s.current_wave_count()
	s.state.boss_dead = true
	s.step(Vector2.ZERO)
	s.command("continue_site_clear")
func brass(splice: bool):
	var s = Sim.new()
	s.start(0,147,"optional")
	clear_site(s)
	s.state.scrap = 40 # Authored fixture budget, not a natural economy claim.
	s.command("choose_route","route.brass_choir")
	var before = s.state.scrap
	check(s.command("choose_road_option","choice.brass.splice" if splice else "choice.brass.cross") == "OK","real road decision accepted")
	check(s.state.scrap == before-(2 if splice else 0),"existing price unchanged")
	check(s.state.hp == (100 if splice else 88),"existing structure outcome unchanged")
	return s
func validate_echo(s,suffix):
	var original = s.current_route().road_nodes[s.state.travel_step].duplicate(true)
	var hash_before = s.state_hash()
	var node = s.current_road_node()
	check(str(node.get("story_id","")).ends_with(suffix),"correct saved-choice response")
	check(node.choices == original.choices and node.risk == original.risk,"choices and warning preserved")
	for i in range(8): s.current_road_node()
	check(s.state_hash() == hash_before,"reading is read-only")
	check(s.current_route().road_nodes[s.state.travel_step] == original,"content never mutated")
	var copy = Sim.new()
	check(copy.restore(s.snapshot()),"snapshot restores")
	check(copy.state_hash() == hash_before and copy.current_road_node() == node,"response survives save/reload exactly")
func _initialize():
	for splice in [true,false]:
		for route in ["route.pale_archive","route.red_foundry"]:
			var s = brass(splice)
			var suffix = "splice" if splice else "cross"
			validate_echo(s,suffix)
			check(s.command("choose_road_option","choice.brass.pass") == "OK","Ada's free option remains available")
			s.command("begin_site")
			clear_site(s)
			check(s.command("choose_route",route) == "OK","connected later road accepted")
			validate_echo(s,suffix)
			s.state.road_flags.clear()
			check(not s.current_road_node().has("story_id"),"no-flag legacy fallback")
	var rootworks = Sim.new()
	rootworks.start(0,147,"optional")
	clear_site(rootworks)
	rootworks.state.scrap = 40
	rootworks.command("choose_route","route.rootworks")
	rootworks.command("choose_road_option","choice.rootworks.ford")
	rootworks.command("choose_road_option","choice.rootworks.pass")
	rootworks.command("begin_site")
	clear_site(rootworks)
	check(rootworks.command("choose_route","route.red_foundry") == "OK","Rootworks reaches shared Foundry road")
	check(not rootworks.current_road_node().has("story_id"),"Rootworks does not inherit Brass consequence")
	var ids = []
	for echo in rootworks.road_echoes:
		check(echo.id not in ids,"unique story ID")
		ids.append(echo.id)
		var node_ids = []
		var flags = []
		for route in rootworks.routes.values():
			for node in rootworks.road_nodes_for(route):
				node_ids.append(node.id)
				for choice in node.choices: flags.append(choice.flag)
		check(echo.node_ids.all(func(id): return id in node_ids) and echo.requires_flag in flags,"story references real content")
	print("ROAD ECHOES: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
