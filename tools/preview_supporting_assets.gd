extends SceneTree
## Isolated presentation gallery. Never loads or modifies simulation state.
var players: Array[AnimationPlayer] = []
var entries: Array = []
var elapsed := 0.0
var frozen := false

func _initialize():
	call_deferred("setup")

func label_at(text: String, at: Vector2, size: int, color := Color("e8ddbd")):
	var label := Label.new()
	label.text = text
	label.position = at
	label.add_theme_font_size_override("font_size", size)
	label.modulate = color
	root.add_child(label)

func setup():
	root.size = Vector2i(1440, 1000)
	root.content_scale_size = Vector2i(1440, 1000)
	entries = JSON.parse_string(FileAccess.get_file_as_string("res://assets/supporting-art/manifest.json")).assets
	label_at("SCRAP SAINT / Supporting painted assets", Vector2(36, 20), 28)
	label_at("Isolated whole-sprite motion studies | Space: reduced motion | No gameplay integration", Vector2(36, 57), 17)
	for i in range(entries.size()):
		var e: Dictionary = entries[i]
		var at := Vector2(36 + (i % 3) * 466, 100 + (i / 3) * 292)
		var panel := ColorRect.new()
		panel.position = at
		panel.size = Vector2(438, 274)
		panel.color = Color("203237")
		root.add_child(panel)
		label_at(e.name, at + Vector2(16, 10), 23)
		label_at(e.id, at + Vector2(16, 242), 14, Color("cbb67d"))
		var scene = load("res://assets/supporting-art/" + e.scene).instantiate()
		scene.position = at + Vector2(200, 143)
		root.add_child(scene)
		var player: AnimationPlayer = scene.get_node("AnimationPlayer")
		players.append(player)
		player.play(e.motion)
		player.pause()
		var small = scene.get_node("Visual/Sprite").duplicate()
		small.position = at + Vector2(386, 209)
		small.scale *= 0.3
		root.add_child(small)
		label_at("48 px", at + Vector2(366, 245), 12)
	if "--capture" in OS.get_cmdline_user_args():
		frozen = true
		DirAccess.make_dir_recursive_absolute("res://assets/supporting-art/evidence")
		for t in [0.12, 0.36, 0.72]:
			sample(t)
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://assets/supporting-art/evidence/gallery-%d.png" % int(t * 1000))
		print("Captured painted asset gallery at 1440x1000, times .12/.36/.72s")
		quit()

func sample(time: float):
	for i in range(players.size()):
		players[i].seek(fmod(time, float(entries[i].duration) + (0.0 if entries[i].loop else 0.8)), true)

func _process(delta):
	if Input.is_physical_key_pressed(KEY_SPACE):
		for player in players:
			player.play("RESET")
			player.advance(0)
			player.pause()
	elif not frozen:
		elapsed += delta
		for i in range(players.size()):
			if players[i].current_animation != entries[i].motion:
				players[i].play(entries[i].motion)
				players[i].pause()
		sample(elapsed)
	return false
