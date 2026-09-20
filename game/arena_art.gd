extends RefCounted
## Presentation only. All scenery follows the arena's existing geometry.
const FLOOR = preload("res://assets/environment/workshop_floor.png")
const PRESS = preload("res://assets/environment/salvage_press.png")
const FURNACE = preload("res://assets/environment/cold_furnace.png")
const MANIFOLD = preload("res://assets/environment/service_manifold.png")
const SCRAP = preload("res://assets/supporting-art/art/scrap.png")
const SHARD = preload("res://assets/supporting-art/art/relic_shard.png")
const KIT = preload("res://assets/supporting-art/art/repair_kit.png")
var regions: Dictionary = {}

func _init():
	# Bounds measured at build time, never scan image pixels during rendering.
	var data = JSON.parse_string(FileAccess.get_file_as_string("res://assets/environment/regions.json"))
	for key in data:
		var r = data[key]
		regions[key] = Rect2(r[0], r[1], r[2], r[3])

func palette(site: String) -> Color:
	match site:
		"arena.red_foundry": return Color("8f8075")
		"arena.rootworks_pump": return Color("758f83")
		"arena.pale_archive": return Color("8c919c")
		"arena.null_assembly": return Color("77818d")
		"arena.brass_choir_relay": return Color("928c75")
	return Color("82918c")

func fit_rect(footprint: Rect2, region: Rect2) -> Rect2:
	var available = footprint.grow(-4)
	var factor = minf(available.size.x / region.size.x, available.size.y / region.size.y)
	var size = region.size * factor
	return Rect2(available.get_center() - size * 0.5, size)

func machine_key(machine: Dictionary) -> String:
	if float(machine.rect[2]) > float(machine.rect[3]): return "service_manifold"
	if "furnace" in machine.id or "tank" in machine.id or "boiler" in machine.id: return "cold_furnace"
	return "salvage_press"

func draw_layout(canvas: Node2D, arena, debug: bool):
	var bounds: Rect2 = arena.bounds
	var tint = palette(arena.data.id)
	canvas.draw_rect(bounds, Color("263537"))
	# Fixed material scale across every site. Clip edge tiles instead of
	# stretching their plates; world-space coordinates prevent camera swimming.
	var tile_size = Vector2(384,256)
	for x in range(0, int(ceil(bounds.size.x / tile_size.x))):
		for y in range(0, int(ceil(bounds.size.y / tile_size.y))):
			var at = bounds.position + Vector2(x,y) * tile_size
			var size = (bounds.end-at).min(tile_size)
			canvas.draw_texture_rect_region(FLOOR, Rect2(at,size), Rect2(Vector2.ZERO, size / tile_size * FLOOR.get_size()), Color(tint.r * 0.82, tint.g * 0.82, tint.b * 0.82, 1))
	canvas.draw_rect(bounds, Color(0.04, 0.09, 0.10, 0.20))
	var circuit = bounds.grow(-38)
	canvas.draw_rect(circuit, Color("344543"), false, 14)
	canvas.draw_rect(circuit.grow(-10), Color("4c5147"), false, 1)
	for zone in arena.data.zones:
		var r = arena.rect(zone.rect)
		# Flat faded paint denotes a service lane, never a raised platform.
		canvas.draw_rect(r, Color(0.40, 0.49, 0.44, 0.035))
		for corner in [r.position, r.end]:
			var d = Vector2.ONE if corner == r.position else -Vector2.ONE
			canvas.draw_line(corner, corner + Vector2(22 * d.x, 0), Color("535b4f"), 2)
			canvas.draw_line(corner, corner + Vector2(0, 22 * d.y), Color("535b4f"), 2)
		if debug: canvas.text_at(zone.name, r.position + Vector2(5,18), 10, Color("8da49d"))
	for entry in arena.data.entries:
		var a = arena.point(entry.from)
		var b = arena.point(entry.to)
		canvas.draw_line(a, b, Color("555a4b"), 4)
		for t in [0.12, 0.5, 0.88]:
			var p = a.lerp(b, t)
			canvas.draw_line(p - Vector2(3,3), p + Vector2(3,3), Color("8e815b"), 2)
	for machine in arena.data.obstacles:
		var r: Rect2 = arena.rect(machine.rect)
		# The plinth is the complete physical obstacle, even when its machinery
		# does not occupy every pixel. Everything raised stays inside this rim.
		canvas.draw_rect(r, Color("131f22"))
		canvas.draw_rect(r.grow(-2), Color("414a43"), false, 3)
		var key = machine_key(machine)
		var target = fit_rect(r, regions[key])
		var texture = MANIFOLD if key == "service_manifold" else (FURNACE if key == "cold_furnace" else PRESS)
		canvas.draw_texture_rect_region(texture, target, regions[key], Color(0.78,0.82,0.77,1))
		canvas.draw_line(r.position + Vector2(3,3), Vector2(r.end.x-3,r.position.y+3), Color("6a7363"), 2)
		for x in range(int(r.position.x)+6, int(r.end.x)-6, 18):
			canvas.draw_line(Vector2(x,r.end.y-5),Vector2(x+5,r.end.y-5),Color("93845a"),2)
		if debug: canvas.text_at(machine.name,r.position + Vector2(4,14),9,Color("c6c2a9"))

func draw_icon(canvas: Node2D, key: String, center: Vector2, extent: float):
	var texture = SCRAP if key == "scrap" else (KIT if key == "repair_kit" else SHARD)
	var region: Rect2 = regions[key]
	var size = region.size * (extent / maxf(region.size.x, region.size.y))
	canvas.draw_texture_rect_region(texture, Rect2(center - size * 0.5, size), region)

func draw_pickup(canvas: Node2D, pickup: Dictionary):
	var kit = pickup.kind == "repair_kit"
	canvas.draw_circle(pickup.p + Vector2(0,3), 10 if kit else 7, Color(0.02,0.04,0.04,0.55))
	draw_icon(canvas, pickup.kind, pickup.p, 25 if kit else 18)
	# A fixed small repair indicator remains readable below icon detail size.
	if kit:
		canvas.draw_line(pickup.p + Vector2(-3,15),pickup.p + Vector2(3,15),Color("b5ead2"),2)
