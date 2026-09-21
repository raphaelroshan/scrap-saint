extends RefCounted
## Cached painted textures, read-only pose selection and presentation feedback.
var assets: Dictionary = {}
var textures: Dictionary = {}

func _init():
	var manifest = JSON.parse_string(FileAccess.get_file_as_string("res://assets/actors/manifest.json"))
	for entry in manifest.assets:
		assets[entry.id] = entry
		if not textures.has(entry.path): textures[entry.path] = load(entry.path)
	var major_manifest = JSON.parse_string(FileAccess.get_file_as_string("res://assets/actors/major_assemblies.json"))
	for entry in major_manifest.assets:
		assets[entry.id] = entry
		for state in entry.states.values():
			for component in state:
				if not textures.has(component.path): textures[component.path] = load(component.path)

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

func active_major_hazard(enemy: Dictionary, hazards: Array, tick: int) -> Dictionary:
	for hazard in hazards:
		if int(hazard.get("source_id", -1)) == int(enemy.id) and int(hazard.get("until", 0)) > tick:
			return hazard
	return {}

func major_state(enemy: Dictionary, hazards: Array, tick: int) -> String:
	if int(enemy.get("stun", 0)) > tick: return "stunned"
	if enemy.type == "elite.memory_crane":
		return "copy" if not active_major_hazard(enemy,hazards,tick).is_empty() else "idle"
	if enemy.type == "boss.foreman_engine":
		return ["schedule","workers","final_orders"][clampi(int(enemy.get("phase",0)),0,2)]
	return "idle"

func major_component_rect(component: Dictionary, center: Vector2) -> Rect2:
	var source = component.region
	var source_size = Vector2(source[2],source[3])
	var size = source_size * (float(component.extent) / maxf(source_size.x,source_size.y))
	var offset = Vector2(component.offset[0],component.offset[1])
	return Rect2(center+offset-size*0.5,size)

func draw_major_component(canvas: Node2D, component: Dictionary, center: Vector2, tint: Color):
	var source = component.region
	canvas.draw_texture_rect_region(textures[component.path],major_component_rect(component,center),Rect2(source[0],source[1],source[2],source[3]),tint)

func draw_crane_mechanism(canvas: Node2D, enemy: Dictionary, center: Vector2, hazard: Dictionary, tick: int, reduced: bool):
	var copying = not hazard.is_empty()
	var stunned = int(enemy.get("stun",0)) > tick
	var direction = Vector2(0.82,0.34)
	if copying:
		direction = (Vector2(hazard.p)-enemy.p).normalized()
		if direction == Vector2.ZERO: direction = Vector2.RIGHT
	elif stunned:
		direction = Vector2(0.35,0.94)
	var servo = 0.0 if reduced or stunned else sin(tick*0.11+int(enemy.id))*2.5
	var shoulder = center+Vector2(20,-30)
	var elbow = shoulder+direction*Vector2(27+servo,18).length()
	var tip = shoulder+direction*(61 if copying else 45)
	canvas.draw_line(shoulder,elbow,Color("172226"),9,true)
	canvas.draw_line(shoulder,elbow,Color("9d7045"),5,true)
	canvas.draw_line(elbow,tip,Color("172226"),8,true)
	canvas.draw_line(elbow,tip,Color("c49a58"),4,true)
	canvas.draw_circle(shoulder,6,Color("302b27"))
	canvas.draw_circle(shoulder,3,Color("e4c478"))
	canvas.draw_circle(elbow,5,Color("302b27"))
	canvas.draw_line(tip,tip+Vector2(0,12),Color("7c654f"),2,true)
	canvas.draw_arc(tip+Vector2(3,14),6,PI*0.25,PI*1.35,12,Color("d2b06a"),3,true)
	if copying:
		canvas.draw_line(tip,tip+direction*16,Color("f0d27c"),2,true)
		canvas.draw_arc(shoulder,15+servo, direction.angle()-0.25,direction.angle()+0.25,8,Color(0.79,0.71,0.91,0.9),2,true)

func draw_foreman_mechanism(canvas: Node2D, enemy: Dictionary, center: Vector2, hazards: Array, tick: int, reduced: bool):
	var phase = clampi(int(enemy.get("phase",0)),0,2)
	var warning_count = 0
	for hazard in hazards:
		if int(hazard.get("source_id",-1)) == int(enemy.id) and int(hazard.get("until",0)) > tick: warning_count += 1
	var servo = 0.0 if reduced or int(enemy.get("stun",0)) > tick else sin(tick*0.13+int(enemy.id))*2.0
	var ram_drop = [1.0,7.0,14.0][phase]+servo
	canvas.draw_line(center+Vector2(0,-26),center+Vector2(0,13+ram_drop),Color("202729"),12,true)
	canvas.draw_line(center+Vector2(0,-24),center+Vector2(0,11+ram_drop),Color("a77d47"),6,true)
	canvas.draw_line(center+Vector2(-20,15+ram_drop),center+Vector2(20,15+ram_drop),Color("e2c986"),4,true)
	for i in range(3):
		var lamp = center+Vector2(-17+i*17,-47)
		var lit = i < warning_count or (phase == 1 and i == (tick/12)%3) or phase == 2
		canvas.draw_circle(lamp,4,Color("f0bd55") if lit else Color("493d31"))
		canvas.draw_arc(lamp,6,0,TAU,12,Color("1c2729"),2)
	if phase == 1:
		for side in [-1,1]:
			var hatch = center+Vector2(side*47,5)
			canvas.draw_rect(Rect2(hatch-Vector2(8,11),Vector2(16,22)),Color("253235"),true)
			canvas.draw_line(hatch,hatch+Vector2(side*16,0),Color("d2b06a"),3,true)
	elif phase == 2:
		for side in [-1,1]:
			var jaw = center+Vector2(side*33,24)
			canvas.draw_line(jaw,jaw+Vector2(-side*17,12),Color("c2684f"),6,true)
			canvas.draw_line(jaw+Vector2(-side*17,12),jaw+Vector2(-side*6,17),Color("eed79c"),3,true)

func draw_major(canvas: Node2D, enemy: Dictionary, center: Vector2, tick: int, reduced: bool, hazards: Array):
	var id: String = enemy.type
	if not assets.has(id): return
	var state = major_state(enemy,hazards,tick)
	var tint = Color(1.65,1.65,1.65,1) if int(enemy.get("flash",0)) > tick else Color.WHITE
	for component in assets[id].states[state]: draw_major_component(canvas,component,center,tint)
	if id == "elite.memory_crane": draw_crane_mechanism(canvas,enemy,center,active_major_hazard(enemy,hazards,tick),tick,reduced)
	elif id == "boss.foreman_engine": draw_foreman_mechanism(canvas,enemy,center,hazards,tick,reduced)

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
