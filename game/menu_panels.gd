extends RefCounted
## Supporting menus render local preferences and read-only run context.

static func shell(g, label: String, title: String):
	g.draw_rect(Rect2(0,0,1280,800),Color(0.025,0.055,0.06,0.85))
	g.panel(Rect2(72,68,1136,678))
	g.text_at(label,Vector2(100,108),12,g.GOLD)
	g.text_at(title,Vector2(100,154),30,g.PAPER,true)
	g.draw_line(Vector2(100,180),Vector2(1180,180),Color("3a514c"),1)

static func draw_manual(g):
	var page = g.manual_pages[g.tutorial_page]
	shell(g,"FIELD MANUAL / %02d OF %02d" % [g.tutorial_page+1,g.manual_pages.size()],page.title)
	g.panel(Rect2(100,208,330,420),Color("203633"))
	g.text_at(page.eyebrow,Vector2(124,240),13,g.GOLD)
	var center = Vector2(265,385)
	g.draw_arc(center,114,0,TAU,64,Color("526b55"),1,true)
	if page.art == "saint":
		g.draw_saint(center,Vector2.RIGHT,2.6)
		g.draw_set_transform(Vector2.ZERO)
	elif page.art == "enemy.forklift_brute":
		var id = str(page.art)
		var region = g.actor_art.region_for(id)
		var size = region.size * (170.0/maxf(region.size.x,region.size.y))
		g.draw_texture_rect_region(g.actor_art.textures[g.actor_art.assets[id].path],Rect2(center-size*0.5,size),region)
	elif page.art == "repair":
		var id = str(g.sim.config.optional_repairs.machines[1].id)
		var region = g.actor_art.region_for(id,"restored")
		var size = region.size * (180.0/maxf(region.size.x,region.size.y))
		g.draw_texture_rect_region(g.actor_art.textures[g.actor_art.assets[id].path],Rect2(center-size*0.5,size),region)
	elif page.art == "assembly":
		g.arena_art.draw_icon(g,"scrap",center+Vector2(-58,-10),66)
		g.arena_art.draw_icon(g,"relic_shard",center+Vector2(60,-10),66)
		g.text_at("SCRAP",center+Vector2(-89,55),12,g.GOLD)
		g.text_at("SHARDS",center+Vector2(25,55),12,g.GREEN)
	else:
		for i in range(3):
			var p = center+Vector2((i-1)*83,0)
			if i < 2: g.draw_line(p,p+Vector2(83,0),g.MUTED,2)
			g.draw_circle(p,19,g.PANEL)
			g.draw_arc(p,19,0,TAU,24,g.GOLD,2,true)
			g.text_at(str(i+1),p+Vector2(-5,6),16,g.PAPER)
	g.wrapped(page.note,Vector2(124,538),282,15,g.GREEN)
	g.wrapped(page.body,Vector2(470,235),664,18,g.PAPER)
	for i in range(page.steps.size()):
		var y = 360+i*130
		g.text_at("0%d" % (i+1),Vector2(470,y),13,g.GOLD)
		g.text_at(page.steps[i][0],Vector2(513,y),21,g.PAPER,true)
		g.wrapped(page.steps[i][1],Vector2(513,y+32),610,16,g.MUTED)

static func build_settings(g):
	g.button("Sound: " + ("off" if g.settings.state.muted else "on"),Rect2(110,245,300,40),func(): g.toggle_setting("muted"))
	var volume = HSlider.new()
	volume.name = "MasterVolume"
	volume.position = Vector2(130,355)
	volume.size = Vector2(260,30)
	volume.min_value = 0
	volume.max_value = 100
	volume.step = 5
	volume.value = round(g.settings.state.master_volume*100)
	volume.focus_mode = Control.FOCUS_ALL
	volume.tooltip_text = "Master volume. Use left and right to adjust."
	volume.value_changed.connect(func(value):
		g.settings.set_option("master_volume",value/100.0)
		g.settings.apply_presentation()
		g.settings.save_to()
		g.queue_redraw())
	g.ui.add_child(volume)
	g.button("Display: " + ("fullscreen" if g.settings.state.fullscreen else "windowed"),Rect2(110,444,300,42),func(): g.toggle_setting("fullscreen"))
	g.button("Effects: " + ("reduced" if g.settings.state.reduced_effects else "full"),Rect2(490,245,300,40),func(): g.toggle_setting("reduced_effects"))
	g.button("Text: " + ("large" if g.settings.state.ui_scale > 1 else "normal"),Rect2(490,344,300,42),g.cycle_text_scale)
	g.button("Camera motion: " + ("on" if g.settings.state.screen_shake else "off"),Rect2(490,444,300,42),func(): g.toggle_setting("screen_shake"))
	var labels = ["Move up","Move down","Move left","Move right"]
	for i in range(g.Settings.ACTIONS.size()):
		var action = g.Settings.ACTIONS[i]
		var key_name = OS.get_keycode_string(int(g.settings.state.controls[action]))
		g.button(labels[i]+": "+("press a key…" if g.awaiting_binding == action else key_name),Rect2(870,245+i*62,300,42),func(): g.awaiting_binding = action; g.build_ui())
	g.button("Back",Rect2(880,680,300,44),g.close_panel,true).grab_focus()

static func draw_settings(g):
	shell(g,"SETTINGS / SAVED ON CHANGE","Make the workshop readable.")
	for i in range(3):
		var x = 100+i*380
		g.panel(Rect2(x,205,320,405),Color("20302f"))
		g.text_at(["SOUND & DISPLAY","COMFORT","MOVEMENT"][i],Vector2(x+10,230),12,g.GOLD)
	g.text_at("Master volume / %d%%" % round(g.settings.state.master_volume*100),Vector2(130,331),16,g.PAPER)
	g.wrapped("Mute keeps your volume setting.",Vector2(130,400),260,12,g.MUTED)
	g.wrapped("Fewer decorative effects. Attack warnings stay visible.",Vector2(510,309),260,13,g.MUTED)
	g.wrapped("Larger labels and reading text.",Vector2(510,411),260,13,g.MUTED)
	g.wrapped("Turn off camera movement on hits.",Vector2(510,510),260,13,g.MUTED)
	g.wrapped("Arrow keys and the left stick remain available.",Vector2(890,518),260,13,g.MUTED)
	g.wrapped("Press a new key. Escape or controller Back cancels." if g.awaiting_binding != "" else "Select a movement binding to change it.",Vector2(100,654),690,14,g.GREEN)

static func draw_pause(g):
	g.panel(Rect2(170,170,940,440))
	g.text_at("PAUSED / YOUR PILGRIMAGE",Vector2(215,210),12,g.GOLD)
	g.text_at("The machines can wait.",Vector2(215,253),29,g.PAPER,true)
	g.wrapped(str(g.sim.arena.data.name),Vector2(215,310),475,21,g.GREEN)
	g.text_at("Wave %d / %d · %02d:%02d" % [g.sim.state.wave,g.sim.current_wave_count(),int(g.sim.state.tick/3600),int(g.sim.state.tick/60)%60],Vector2(215,362),18,g.PAPER)
	g.text_at("Structure %d / %d" % [maxi(0,g.sim.state.hp),g.sim.saint_max_structure()],Vector2(215,402),16,g.PAPER)
	g.text_at("%d Scrap · %d Relic Shards" % [g.sim.state.scrap,g.sim.state.shards],Vector2(215,440),16,g.GOLD)
	g.wrapped("Take your time. The shift stays still until you resume.",Vector2(215,499),450,15,g.MUTED)
	g.text_at("Escape / Start to resume",Vector2(215,571),13,g.MUTED)
