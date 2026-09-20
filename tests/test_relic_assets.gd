extends SceneTree
func _initialize():
	var manifest = JSON.parse_string(FileAccess.get_file_as_string("res://assets/relic-pack/animations.json"))
	var checks = 0
	for clip in manifest.clips:
		var frames = load("res://assets/relic-pack/pixels/"+clip.id+".tres") as SpriteFrames
		assert(frames != null)
		assert(frames.get_frame_count("manifest") == 12)
		assert(not frames.get_animation_loop("manifest"))
		assert(absf(12000.0/frames.get_animation_speed("manifest")-clip.duration_ms) < 0.01)
		for i in range(12):
			var tex = frames.get_frame_texture("manifest",i) as AtlasTexture
			assert(tex.region == Rect2(i*128,0,128,128))
			checks += 1
	print("RELIC ASSETS: %d atlas frames and 10 animation resources validated" % checks)
	quit()
