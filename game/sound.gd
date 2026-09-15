extends Node
## Original procedural placeholder audio; voice-limited, presentation only.
var players: Array = []
var sounds = {}
var muted = false
var last_play = {}

func _ready():
	for i in range(10):
		var player = AudioStreamPlayer.new()
		player.volume_db = -18
		add_child(player)
		players.append(player)
	for kind in ["line", "cone", "shot", "tether", "orbit", "rail", "beam", "blast", "censer", "winch", "halo", "radial", "repair", "hurt", "relay_hurt", "pickup"]:
		sounds[kind] = synth(kind)

func play(kind: String):
	if muted or not sounds.has(kind): return
	var now = Time.get_ticks_msec()
	if now - last_play.get(kind, -1000) < 65: return
	last_play[kind] = now
	for player in players:
		if not player.playing:
			player.stream = sounds[kind]
			player.play()
			break

func synth(kind: String):
	var duration = 0.35 if kind in ["cone", "rail", "radial", "relay_hurt"] else 0.12
	var frequency = {"beam": 340, "blast": 55, "line": 185, "cone": 420, "shot": 720, "tether": 110, "orbit": 250, "rail": 75, "censer": 145, "winch": 95, "halo": 610, "radial": 360, "repair": 880, "hurt": 70, "relay_hurt": 125, "pickup": 1100}[kind]
	var bytes = PackedByteArray()
	var count = int(duration * 22050)
	bytes.resize(count * 2)
	for i in range(count):
		var t = float(i) / 22050.0
		var envelope = pow(1.0 - float(i) / count, 2)
		var sample = sin(TAU * frequency * t * (1.0 + 0.2 * exp(-t * 30)))
		if kind in ["cone", "radial"]: sample = (sample + sin(TAU * frequency * 2.73 * t) * 0.35) / 1.35
		if kind in ["line", "rail", "tether", "winch"]: sample = sample * 0.55 + sin(i * 37.19) * 0.45 * exp(-t * 30)
		bytes.encode_s16(i * 2, int(sample * envelope * 17000))
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.data = bytes
	return wav
