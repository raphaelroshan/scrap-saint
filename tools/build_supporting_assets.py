"""Package untouched generated PNGs with Godot animation scenes and a web gallery.

Pillow only inspects alpha bounds; it never rewrites the artwork.
Run after placing art and source-manifest.json in assets/supporting-art.
"""
import hashlib
import html
import json
import re
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
PACK = ROOT / 'assets/supporting-art'


def track(path, values, duration):
    times = ', '.join(str(duration * i / (len(values)-1)) for i in range(len(values)))
    return path, times, ', '.join(values)


def animation(name, duration, loop, tracks):
    out = f'[sub_resource type="Animation" id="{name}"]\nresource_name = "{name}"\nlength = {duration}\nloop_mode = {1 if loop else 0}\n'
    for i, (path, times, values) in enumerate(tracks):
        out += f'tracks/{i}/type = "value"\ntracks/{i}/path = NodePath("Visual:{path}")\ntracks/{i}/interp = 1\ntracks/{i}/enabled = true\ntracks/{i}/keys = {{"times": PackedFloat32Array({times}), "transitions": PackedFloat32Array({", ".join("1" for _ in times.split(","))}), "update": 0, "values": [{values}]}}\n'
    return out + '\n'


def build():
    entries = json.loads((PACK / 'source-manifest.json').read_text(encoding='utf-8'))
    (PACK/'scenes').mkdir(exist_ok=True)
    cards = []
    for e in entries:
        path = PACK/'art'/f'{e["slug"]}.png'
        with Image.open(path) as im:
            assert im.mode == 'RGBA', path
            alpha = im.getchannel('A')
            raw_bounds = alpha.getbbox()
            # Ignore near-invisible generator alpha noise when choosing display scale.
            # The source texture itself remains untouched.
            bounds = alpha.point(lambda v: 255 if v > 16 else 0).getbbox()
            assert bounds and alpha.getextrema()[0] == 0, path
            w, h = im.size
        e.update(size=[w,h], alpha_bounds=list(raw_bounds), visible_bounds=list(bounds), visible_alpha_threshold=16, sha256=hashlib.sha256(path.read_bytes()).hexdigest())
        scale = 160/max(bounds[2]-bounds[0], bounds[3]-bounds[1])
        offset = ((w-bounds[0]-bounds[2])/2, (h-bounds[1]-bounds[3])/2)
        kind=e['motion']
        duration={'scuttle':.36,'charge':1.2,'hover':1.8,'bob':1.6,'reveal':.5}[kind]
        loop=kind in ('scuttle','hover','bob')
        tracks=[]
        if kind=='scuttle':
            tracks=[track('position',['Vector2(0,0)','Vector2(0,-3)','Vector2(0,0)','Vector2(0,-3)','Vector2(0,0)'],duration),track('rotation',['-0.025','0.025','-0.025','0.025','-0.025'],duration)]
        elif kind=='charge':
            tracks=[track('position',['Vector2(0,0)','Vector2(-12,0)','Vector2(24,0)','Vector2(9,0)','Vector2(0,0)'],duration),track('scale',['Vector2(1,1)','Vector2(.91,1.06)','Vector2(1.08,.94)','Vector2(1,1)','Vector2(1,1)'],duration)]
        elif kind in ('hover','bob'):
            tracks=[track('position',['Vector2(0,0)','Vector2(0,-7)','Vector2(0,0)'],duration)]
        else:
            tracks=[track('scale',['Vector2(.6,.6)','Vector2(1.06,1.06)','Vector2(1,1)'],duration),track('modulate',['Color(1,1,1,0)','Color(1,1,1,1)','Color(1,1,1,1)'],duration)]
        reset=[track('position',['Vector2(0,0)','Vector2(0,0)'],.001),track('rotation',['0','0'],.001),track('scale',['Vector2(1,1)','Vector2(1,1)'],.001),track('modulate',['Color(1,1,1,1)','Color(1,1,1,1)'],.001)]
        collect=[track('position',['Vector2(0,0)','Vector2(0,-12)','Vector2(0,-24)'],.24),track('scale',['Vector2(1,1)','Vector2(1.12,1.12)','Vector2(.3,.3)'],.24),track('modulate',['Color(1,1,1,1)','Color(1,1,1,1)','Color(1,1,1,0)'],.24)]
        text='[gd_scene load_steps=6 format=3]\n\n'+f'[ext_resource type="Texture2D" path="res://assets/supporting-art/art/{e["slug"]}.png" id="Texture"]\n\n'
        text+=animation('RESET',.001,False,reset)+animation(kind,duration,loop,tracks)+animation('collect',.24,False,collect)
        text+=f'[sub_resource type="AnimationLibrary" id="Library"]\n_data = {{&"RESET": SubResource("RESET"), &"{kind}": SubResource("{kind}"), &"collect": SubResource("collect")}}\n\n'
        text+=f'[node name="{e["slug"]}" type="Node2D"]\n\n[node name="Visual" type="Node2D" parent="."]\n\n[node name="Sprite" type="Sprite2D" parent="Visual"]\ntexture_filter = 2\ntexture = ExtResource("Texture")\nscale = Vector2({scale},{scale})\noffset = Vector2({offset[0]},{offset[1]})\n\n[node name="AnimationPlayer" type="AnimationPlayer" parent="."]\nlibraries = {{&"": SubResource("Library")}}\n'
        text = re.sub(r'(?<=[(,])\.(\d)', r'0.\1', text)
        (PACK/'scenes'/f'{e["slug"]}.tscn').write_text(text,encoding='utf-8')
        e.update(scene=f'scenes/{e["slug"]}.tscn',duration=duration,loop=loop,display_extent=160)
        cards.append(f'<article><h2>{html.escape(e["name"])}</h2><div class="stage"><img class="{kind}" src="art/{e["slug"]}.png" alt="{html.escape(e["name"])}"></div><p>{kind} · {duration}s</p><code>{e["id"]}</code><div class="small"><img src="art/{e["slug"]}.png" alt="48px sample"></div></article>')
    (PACK/'manifest.json').write_text(json.dumps({'method':'Untouched generated painted cutouts; whole-sprite motion studies. No articulated gait or gameplay integration.','assets':entries},indent=2)+'\n',encoding='utf-8')
    page='''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width"><title>Scrap Saint — supporting art</title><style>
*{box-sizing:border-box}body{margin:0;background:#152327;color:#e8ddbd;font:16px system-ui;padding:32px}h1{font:32px Georgia;margin:0 0 12px}p{color:#aabcb9}header{max-width:1000px;margin:auto}button{background:#d3b779;color:#152327;border:0;padding:12px 20px;cursor:pointer}main{max-width:1300px;margin:24px auto;display:grid;grid-template-columns:repeat(3,1fr);gap:16px}article{background:#203237;border:1px solid #49605e;border-radius:8px;padding:18px}h2{font:22px Georgia;margin:0}.stage{height:210px;display:grid;place-items:center}.stage img{width:200px;height:200px;object-fit:contain}.small{height:52px;text-align:right}.small img{width:48px;height:48px;object-fit:contain}code{font-size:12px;color:#d0b87d}.scuttle{animation:scuttle .36s linear infinite}.charge{animation:charge 1.2s infinite}.hover{animation:bob 1.8s ease-in-out infinite}.bob{animation:bob 1.6s ease-in-out infinite}.reveal{animation:reveal 2s infinite}@keyframes scuttle{0%,100%{transform:rotate(-1.4deg)}25%,75%{transform:translateY(-3px) rotate(1.4deg)}50%{transform:rotate(-1.4deg)}}@keyframes charge{0%,100%{transform:none}25%{transform:translateX(-12px) scale(.91,1.06)}50%{transform:translateX(24px) scale(1.08,.94)}75%{transform:translateX(9px)}}@keyframes bob{50%{transform:translateY(-7px)}}@keyframes reveal{0%{transform:scale(.6);opacity:0}12.5%{transform:scale(1.06);opacity:1}25%,100%{transform:scale(1);opacity:1}}.paused img{animation:none!important}@media(prefers-reduced-motion:reduce){img{animation:none!important}}@media(max-width:800px){main{grid-template-columns:1fr}}
</style><header><h1>Objects that remember their work</h1><p>Scrap Saint · painted supporting assets · motion studies, not gameplay footage.<br>Enemies / field pickups / upgrades. Small samples show the original canvas at 48px.</p><button onclick="document.body.classList.toggle('paused');this.setAttribute('aria-pressed',document.body.classList.contains('paused'))" aria-pressed="false">Toggle reduced motion</button></header><main>'''+''.join(cards)+'</main></html>'
    (PACK/'preview.html').write_text(page,encoding='utf-8')
    print(f'Packaged {len(entries)} painted assets and Godot animation scenes')


if __name__ == '__main__':
    build()
