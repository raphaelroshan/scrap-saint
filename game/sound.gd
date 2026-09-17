extends Node
## Original procedural placeholder audio; voice-limited, presentation only.
var players: Array = []
var sounds = {}
var muted = false
var last_play = {}

func _ready():
	for i in range(14):
		var player = AudioStreamPlayer.new()
		player.volume_db = -20
		add_child(player)
		players.append(player)
	for kind in ["line", "cone", "shot", "tether", "orbit", "rail", "beam", "blast", "censer", "winch", "halo", "radial", "ashen_censer", "long_hand", "repair_halo", "funeral_shots", "sermon", "benediction", "consecrated", "parade", "lattice", "repair", "hurt", "relay_hurt", "pickup", "death", "quieted", "evolution", "boss_contract", "machine_restored", "title_commit"]:
		sounds[kind] = synth(kind)

func play(kind: String):
	if muted or not sounds.has(kind): return
	var now = Time.get_ticks_msec()
	if now - last_play.get(kind, -1000) < 65: return
	last_play[kind] = now
	for player in players:
		if not player.playing:
			player.stream = sounds[kind]
			player.volume_db = {
				"evolution": -12.0, "boss_contract": -14.0, "relay_hurt": -14.0,
				"blast": -15.0, "benediction": -15.0, "radial": -15.0,
				"beam": -23.0, "orbit": -23.0, "censer": -23.0,
			}.get(kind, -19.0)
			player.play()
			break

func synth(kind: String):
	var durations = {
		"cone": 0.34, "rail": 0.42, "radial": 0.48, "ashen_censer": 0.42,
		"sermon": 0.40, "consecrated": 0.44, "parade": 0.38, "lattice": 0.38,
		"relay_hurt": 0.34, "evolution": 0.95, "boss_contract": 0.58,
		"machine_restored": 0.52, "title_commit": 0.46, "death": 0.20, "quieted": 0.24,
	}
	var duration = float(durations.get(kind, 0.15))
	var frequency = {"beam": 340, "blast": 55, "line": 185, "cone": 420, "shot": 720, "tether": 110, "orbit": 250, "rail": 75, "censer": 145, "winch": 95, "halo": 610, "radial": 360, "ashen_censer": 132, "long_hand": 88, "repair_halo": 740, "funeral_shots": 620, "sermon": 285, "benediction": 68, "consecrated": 520, "parade": 205, "lattice": 118, "repair": 880, "hurt": 70, "relay_hurt": 125, "pickup": 1100, "death": 92, "quieted": 260, "evolution": 132, "boss_contract": 74, "machine_restored": 440, "title_commit": 196}[kind]
	var bytes = PackedByteArray()
	var count = int(duration * 22050)
	bytes.resize(count * 2)
	for i in range(count):
		var t = float(i) / 22050.0
		var normalized = float(i) / float(maxi(1, count - 1))
		var attack = minf(1.0, normalized * (34.0 if kind in ["evolution", "machine_restored", "title_commit"] else 90.0))
		var envelope = attack * pow(1.0 - normalized, 1.65 if kind in ["evolution", "boss_contract", "machine_restored"] else 2.3)
		var pitch = frequency * (1.0 + 0.16 * exp(-t * 28.0))
		var sample = sin(TAU * pitch * t)
		if kind in ["cone", "radial", "repair_halo", "consecrated", "parade", "evolution", "machine_restored", "title_commit"]:
			sample = (sample + sin(TAU * frequency * 2.01 * t) * 0.28 + sin(TAU * frequency * 3.02 * t) * 0.14) / 1.42
		if kind in ["line", "rail", "tether", "winch", "long_hand", "lattice", "hurt", "relay_hurt", "death"]:
			var metal_noise = sin(i * 37.19) * 0.32 + sin(i * 11.73) * 0.18
			sample = sample * 0.55 + metal_noise * exp(-t * 24.0)
		if kind in ["quieted", "sermon"]: sample *= 0.55 + 0.45 * sin(TAU * 8.0 * t)
		if kind == "boss_contract": sample = sample * 0.7 + sin(TAU * frequency * 0.5 * t) * 0.3
		bytes.encode_s16(i * 2, int(clampf(sample * envelope, -1.0, 1.0) * 16500))
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.data = bytes
	return wav
