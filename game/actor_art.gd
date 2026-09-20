extends RefCounted
## Cached painted textures, read-only pose selection and presentation feedback.
var assets: Dictionary = {}
var textures: Dictionary = {}

func _init():
	var manifest = JSON.parse_string(FileAccess.get_file_as_string("res://assets/actors/manifest.json"))
	for entry in manifest.assets:
		assets[entry.id] = entry
		if not textures.has(entry.path): textures[entry.path] = load(entry.path)

func region_for(id: String, state := "base") -> Rect2:
	var values = assets[id].regions[state]
	return Rect2(values[0],values[1],values[2],values[3])

func sprite_rect(id: String, center: Vector2, state := "base") -> Rect2:
	var region = region_for(id,state)
	var size = region.size * (float(assets[id].extent) / maxf(region.size.x,region.size.y))
	return Rect2(center-size*0.5,size)

func idle_offset(enemy: Dictionary, tick: int, reduced: bool) -> Vector2:
	if reduced or int(enemy.get("stun",0)) > tick or int(enemy.get("windup",0)) > tick:
		return Vector2.ZERO
	# A small idle servo/hover cue, not a claimed articulated walk cycle.
	var phase = tick * 0.07 + int(enemy.id) * 0.9
	return Vector2(0,sin(phase) * (1.6 if enemy.type == "enemy.choir_drone" else 0.45))

func draw_enemy(canvas: Node2D, enemy: Dictionary, center: Vector2, tick: int, reduced: bool):
	var id: String = enemy.type
	if not assets.has(id):
		canvas.draw_circle(center,enemy.radius,Color("cb8565"))
		return
	var rect = sprite_rect(id,center + idle_offset(enemy,tick,reduced))
	var tint = Color(1.65,1.65,1.65,1) if int(enemy.flash) > tick else Color.WHITE
	canvas.draw_texture_rect_region(textures[assets[id].path],rect,region_for(id),tint)

func repair_state(machine: Dictionary, active_id: String) -> String:
	if machine.complete: return "restored"
	return "working" if active_id == str(machine.id) else "broken"

func repair_frame(machine: Dictionary) -> String:
	return "restored" if machine.complete else "broken"

func draw_repair(canvas: Node2D, machine: Dictionary, center: Vector2, active_id: String, tick: int, reduced: bool, required_ticks: float):
	var id: String = machine.id
	var state = repair_state(machine,active_id)
	var frame = repair_frame(machine)
	# Compact nonblocking service fixtures, not new navigation obstacles.
	canvas.draw_circle(center + Vector2(0,5),24,Color(0.02,0.035,0.035,0.45))
	canvas.draw_texture_rect_region(textures[assets[id].path],sprite_rect(id,center,frame),region_for(id,frame))
	var lamp = center + Vector2(0,34)
	if state == "restored":
		canvas.draw_line(lamp+Vector2(-5,0),lamp+Vector2(-1,4),Color("b5ead2"),2,true)
		canvas.draw_line(lamp+Vector2(-1,4),lamp+Vector2(6,-4),Color("b5ead2"),2,true)
	elif state == "working":
		var fraction = clampf(float(machine.progress)/required_ticks,0,1)
		canvas.draw_line(lamp-Vector2(16,0),lamp+Vector2(16,0),Color("334f44"),3)
		canvas.draw_line(lamp-Vector2(16,0),lamp+Vector2(-16+32*fraction,0),Color("b5ead2"),3)
		if not reduced:
			var source = center + Vector2(13,-4)
			var phase = float(tick % 12)/12.0
			for i in range(3):
				var direction = Vector2.from_angle(-PI*0.8 + i*0.8)
				canvas.draw_line(source+direction*(3+phase*3),source+direction*(6+phase*6),Color(0.9,0.98,0.79,1-phase),1.5,true)
	else:
		canvas.draw_line(lamp-Vector2(5,0),lamp+Vector2(5,0),Color("c4a164"),2)
