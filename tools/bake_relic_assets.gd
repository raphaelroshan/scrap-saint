extends SceneTree
const Canvas = preload("res://tools/relic_asset_canvas.gd")
const OUT = "res://assets/relic-pack/pixels"
const N = 12
func _initialize(): call_deferred("bake")
func bake():
	DirAccess.make_dir_recursive_absolute(OUT)
	var view = SubViewport.new()
	view.size = Vector2i(64,64)
	view.transparent_bg = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(view)
	var canvas = Canvas.new()
	canvas.scale = Vector2(0.5,0.5)
	view.add_child(canvas)
	var rows = []
	var names = ["nailer","mercy_rail","bell","cable","censer"]
	var shapes = ["line","rail","cone","tether","censer"]
	var contact = Image.create(1536,1280,false,Image.FORMAT_RGBA8)
	contact.fill(Color("17292d"))
	var row_index = 0
	for k in range(names.size()):
		for reduced in [false,true]:
			canvas.asset_id = names[k]
			canvas.reduced_fx = reduced
			var id = names[k] + ("_reduced" if reduced else "")
			var duration = canvas.WEAPON_FX_DURATION_MS[shapes[k]]
			var atlas = Image.create(128*N,128,false,Image.FORMAT_RGBA8)
			atlas.fill(Color.TRANSPARENT)
			for i in range(N):
				canvas.sample = float(i)/float(N-1)
				canvas.queue_redraw()
				await process_frame
				await RenderingServer.frame_post_draw
				var frame = view.get_texture().get_image()
				frame.convert(Image.FORMAT_RGBA8)
				frame.resize(128,128,Image.INTERPOLATE_NEAREST)
				atlas.blit_rect(frame,Rect2i(0,0,128,128),Vector2i(i*128,0))
			atlas.save_png(OUT+"/"+id+".png")
			contact.blend_rect(atlas,Rect2i(0,0,1536,128),Vector2i(0,row_index*128))
			var text = "[gd_resource type=\"SpriteFrames\" load_steps=14 format=3]\n\n[ext_resource type=\"Texture2D\" path=\"res://assets/relic-pack/pixels/%s.png\" id=\"1\"]\n" % id
			var frames = []
			for i in range(N):
				text += "\n[sub_resource type=\"AtlasTexture\" id=\"F%d\"]\natlas = ExtResource(\"1\")\nregion = Rect2(%d,0,128,128)\n" % [i,i*128]
				frames.append('{"duration":1.0,"texture":SubResource("F%d")}' % i)
			text += "\n[resource]\nanimations = [{\"frames\":[%s],\"loop\":false,\"name\":&\"manifest\",\"speed\":%f}]\n" % [",".join(frames),float(N)*1000.0/duration]
			var f = FileAccess.open(OUT+"/"+id+".tres",FileAccess.WRITE)
			f.store_string(text)
			f.close()
			rows.append({"id":id,"duration_ms":duration,"frames":N,"cell":[128,128],"native_render":[64,64],"direction":"right","loop":false,"anchor": [64,20] if names[k]=="bell" else ([56,104] if names[k]=="censer" else ([28,64] if names[k]=="cable" else [24,64]))})
			row_index += 1
	contact.save_png("res://assets/relic-pack/contact-sheet.png")
	var manifest = FileAccess.open("res://assets/relic-pack/animations.json",FileAccess.WRITE)
	manifest.store_string(JSON.stringify({"godot":Engine.get_version_info().string,"method":"Native procedural mechanism geometry baked at 64px, nearest-neighbor 2x. Not painted-art animation.","clips":rows},"  "))
	manifest.close()
	view.queue_free()
	await process_frame
	print("BAKED: 10 animation strips, 120 frames, SpriteFrames resources and contact sheet")
	quit()
