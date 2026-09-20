extends "res://game/main.gd"
var asset_id = "nailer"
var sample = 0.0
func _ready(): pass
func _process(_delta): pass
func _physics_process(_delta): pass
func _draw():
	var origin = Vector2(24,64)
	if asset_id == "bell": origin = Vector2(64,20)
	elif asset_id == "cable": origin = Vector2(28,64)
	elif asset_id == "censer": origin = Vector2(56,104)
	var effect = {"from":origin,"to":origin+Vector2(72,0),"shape":asset_id,"presented_at":0,"duration_ms":1000}
	visual_clock_override = int(sample*1000)
	var fade = presentation_fade(effect)
	match asset_id:
		"nailer", "mercy_rail": draw_manifested_nailer_geometry(origin,Vector2.RIGHT,asset_id=="mercy_rail",sample,fade)
		"bell": draw_manifested_bell(effect,sample,fade)
		"cable": draw_manifested_cable(effect,sample,fade)
		"censer": draw_manifested_censer(effect,sample,fade)
