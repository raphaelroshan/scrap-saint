extends SceneTree

func _initialize():
	call_deferred("run")

func run():
	var entries: Array = JSON.parse_string(FileAccess.get_file_as_string("res://assets/supporting-art/manifest.json")).assets
	assert(entries.size() == 9)
	for e in entries:
		var packed = load("res://assets/supporting-art/" + e.scene)
		assert(packed is PackedScene)
		var scene = packed.instantiate()
		root.add_child(scene)
		var player: AnimationPlayer = scene.get_node("AnimationPlayer")
		var visual: Node2D = scene.get_node("Visual")
		var sprite: Sprite2D = visual.get_node("Sprite")
		assert(sprite.texture.get_width() == e.size[0])
		var anim = player.get_animation(e.motion)
		assert(is_equal_approx(anim.length, e.duration))
		assert(anim.loop_mode == (Animation.LOOP_LINEAR if e.loop else Animation.LOOP_NONE))
		for name in player.get_animation_list():
			var clip = player.get_animation(name)
			for i in range(clip.get_track_count()):
				assert(scene.has_node(NodePath(str(clip.track_get_path(i)).split(":")[0])))
		player.play(e.motion)
		player.seek(0, true)
		var before = [visual.position, visual.scale, visual.rotation, visual.modulate]
		player.seek(e.duration * 0.25, true)
		assert(before != [visual.position, visual.scale, visual.rotation, visual.modulate])
		player.play("collect")
		player.seek(0.24, true)
		assert(is_zero_approx(visual.modulate.a))
		player.play("RESET")
		player.advance(0)
		assert(visual.position == Vector2.ZERO and visual.scale == Vector2.ONE and visual.modulate == Color.WHITE)
		scene.queue_free()
	await process_frame
	print("PASS: nine painted scenes; animation targets, motion, collection and reset verified")
	quit()
