extends RefCounted
## Static, data-owned movement geometry. Low machines do not block weapon fire.
var data: Dictionary
var bounds: Rect2
var obstacles: Array[Rect2] = []
var graphs = {}

func _init():
	data = JSON.parse_string(FileAccess.get_file_as_string("res://content/arenas/collapsed_workshop.json"))
	bounds = rect(data.bounds)
	for machine in data.obstacles: obstacles.append(rect(machine.rect))

func rect(values: Array) -> Rect2:
	return Rect2(values[0], values[1], values[2], values[3])

func point(values: Array) -> Vector2:
	return Vector2(values[0], values[1])

func walkable(p: Vector2, radius: float) -> bool:
	if not bounds.grow(-radius).has_point(p): return false
	for obstacle in obstacles:
		if obstacle.grow(radius).has_point(p): return false
	return true

func clear_line(a: Vector2, b: Vector2, radius: float) -> bool:
	for obstacle in obstacles:
		var r = obstacle.grow(radius)
		if r.has_point(a) or r.has_point(b): return false
		var corners = [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]
		for i in range(4):
			if Geometry2D.segment_intersects_segment(a, b, corners[i], corners[(i + 1) % 4]) != null: return false
	return true

func move_body(origin: Vector2, delta: Vector2, radius: float) -> Vector2:
	# Bounded substeps also cover knockback and future large displacements.
	var count = maxi(1, int(ceil(delta.length() / 4.0)))
	var increment = delta / count
	var p = origin
	for i in range(count):
		var candidate = Vector2(p.x + increment.x, p.y)
		if walkable(candidate, radius): p = candidate
		candidate = Vector2(p.x, p.y + increment.y)
		if walkable(candidate, radius): p = candidate
	return p

func graph_for(radius: float) -> AStar2D:
	if graphs.has(radius): return graphs[radius]
	var graph = AStar2D.new()
	for obstacle in obstacles:
		var r = obstacle.grow(radius + 2)
		for p in [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]:
			if walkable(p, radius): graph.add_point(graph.get_point_count(), p)
	var ids = graph.get_point_ids()
	for i in ids:
		for j in ids:
			if j > i and clear_line(graph.get_point_position(i), graph.get_point_position(j), radius): graph.connect_points(i, j)
	graphs[radius] = graph
	return graph

func direction_to(origin: Vector2, target: Vector2, radius: float) -> Vector2:
	if clear_line(origin, target, radius): return (target - origin).normalized()
	var graph = graph_for(radius)
	graph.add_point(100, origin)
	graph.add_point(101, target)
	for id in graph.get_point_ids():
		if id >= 100: continue
		var p = graph.get_point_position(id)
		if clear_line(origin, p, radius): graph.connect_points(100, id)
		if clear_line(target, p, radius): graph.connect_points(101, id)
	var path = graph.get_point_path(100, 101)
	graph.remove_point(100)
	graph.remove_point(101)
	return (path[1] - origin).normalized() if path.size() > 1 else Vector2.ZERO
