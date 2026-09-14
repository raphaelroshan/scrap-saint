extends SceneTree
const Sim = preload("res://game/simulation.gd")
var checks = 0
var failures = 0

func check(ok: bool, label: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", label)

func connected(nodes: Dictionary, excluded: Vector2i) -> bool:
	var visited = {}
	var queue = []
	for key in nodes:
		if key != excluded:
			queue.append(key)
			visited[key] = true
			break
	var head = 0
	while head < queue.size():
		var key = queue[head]
		head += 1
		for delta in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var next = key + delta
			if next != excluded and nodes.has(next) and not visited.has(next):
				visited[next] = true
				queue.append(next)
	return visited.size() == nodes.size() - (1 if nodes.has(excluded) else 0)

func _initialize():
	var sim = Sim.new()
	sim.start()
	var arena = sim.arena
	check(arena.bounds.size / arena.data.pixels_per_metre == Vector2(40, 28), "40 by 28 logical metres")
	check(arena.walkable(sim.state.position, 16) and arena.walkable(sim.relay_position(), 35), "start and relay clear")
	var nodes = {}
	for x in range(40):
		for y in range(28):
			var p = arena.bounds.position + Vector2(x * 40 + 20, y * 40 + 20)
			if arena.walkable(p, 16): nodes[Vector2i(x, y)] = p
	check(connected(nodes, Vector2i(-1, -1)), "all traversable grid cells connected")
	var no_bottleneck = true
	for key in nodes:
		if not connected(nodes, key): no_bottleneck = false
	check(no_bottleneck, "removing any one grid cell leaves routes connected: no single-exit pocket")
	var p = arena.move_body(Vector2(300, 380), Vector2(400, 0), 16)
	check(p.x < 334, "large displacement cannot tunnel through press")
	p = arena.move_body(Vector2(330, 380), Vector2(60, 60), 16)
	check(p.x < 334 and p.y > 420, "contact slides along press")
	check(arena.walkable(arena.move_body(Vector2(200, 200), Vector2(-1000, -1000), 16), 16), "large displacement stays inside arena")
	for radius in [10, 14, 18, 35]:
		for entry in arena.data.entries:
			p = arena.point(entry.from).lerp(arena.point(entry.to), 0.5)
			for tick in range(1800):
				p = arena.move_body(p, arena.direction_to(p, sim.relay_position(), radius) * 2, radius)
				if p.distance_to(sim.relay_position()) < 5: break
			check(p.distance_to(sim.relay_position()) < 5, "entry reaches relay for radius %d: %s" % [radius, entry.id])
	for endpoints in [[Vector2(260, 400), Vector2(550, 450)], [Vector2(850, 450), Vector2(550, 450)], [Vector2(550, 650), Vector2(550, 250)]]:
		p = endpoints[0]
		for tick in range(1200):
			p = arena.move_body(p, arena.direction_to(p, endpoints[1], 16) * 2, 16)
		check(p.distance_to(endpoints[1]) < 5, "route around machine or out of alcove")
	sim.state.position = Vector2(550, 650)
	sim.state.hp = 50
	for i in range(60): sim.step(Vector2.ZERO)
	check(sim.state.hp <= 50 and sim.state.progress == 0, "alcove gives no hidden healing or relay progress")
	var other = Sim.new()
	sim.start(0, 104729)
	other.start(0, 104729)
	for i in range(600):
		var input = Vector2.from_angle(i * 0.01) * 2
		sim.step(input)
		other.step(input)
	check(sim.state_hash() == other.state_hash(), "600 tick seeded movement and spawns repeat")
	other.restore(sim.snapshot())
	for i in range(120):
		sim.step(Vector2.LEFT)
		other.step(Vector2.LEFT)
	check(sim.state_hash() == other.state_hash(), "navigation cache does not affect save continuation")
	sim.start()
	var origin = sim.state.position
	sim.step(Vector2.ONE * 20)
	check(sim.state.position.distance_to(origin) <= sim.config.saint.speed / 60.0 + 0.001, "diagonal input has no speed exploit")
	var legacy = sim.snapshot()
	legacy.erase("arena_id")
	var before = sim.state_hash()
	check(not sim.restore(legacy) and sim.state_hash() == before, "old-layout save rejected without changing current run")
	print("ARENA: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
