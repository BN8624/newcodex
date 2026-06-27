# 절차적 효과음을 생성해 전투와 UI 반응음을 재생하는 오디오 매니저
extends Node
class_name SoundManager

const MIX_RATE := 22050.0

var player: AudioStreamPlayer
var playback: AudioStreamGeneratorPlayback
var active := []


func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		set_process(false)
		return
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = MIX_RATE
	stream.buffer_length = 0.18
	player = AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = -9.0
	add_child(player)
	player.play()
	playback = player.get_stream_playback()
	set_process(true)


func _process(_delta: float) -> void:
	if playback == null:
		return
	while playback.get_frames_available() > 0:
		var sample := _next_sample()
		playback.push_frame(Vector2(sample, sample))


func _exit_tree() -> void:
	if player != null:
		player.stop()
	playback = null
	active.clear()


func play(sound_id: String) -> void:
	match sound_id:
		"hit":
			_add_tone(420.0, 0.055, 0.18, 2.6, 1)
		"crit":
			_add_tone(760.0, 0.09, 0.22, 2.2, 0)
			_add_tone(1140.0, 0.05, 0.14, 2.0, 0)
		"reward":
			_add_tone(520.0, 0.07, 0.16, 1.9, 0)
			_add_tone(820.0, 0.09, 0.14, 1.8, 0)
		"level":
			_add_tone(620.0, 0.08, 0.16, 1.6, 0)
			_add_tone(930.0, 0.11, 0.18, 1.4, 0)
			_add_tone(1240.0, 0.13, 0.15, 1.4, 0)
		"skill":
			_add_tone(180.0, 0.08, 0.22, 1.2, 1)
			_add_tone(620.0, 0.18, 0.2, 1.5, 0)
		"boss":
			_add_tone(120.0, 0.2, 0.25, 0.9, 1)
			_add_tone(240.0, 0.12, 0.2, 1.1, 1)
		"clear":
			_add_tone(520.0, 0.12, 0.16, 1.2, 0)
			_add_tone(780.0, 0.12, 0.15, 1.2, 0)
			_add_tone(1040.0, 0.18, 0.14, 1.0, 0)
		"button":
			_add_tone(360.0, 0.045, 0.12, 2.0, 0)


func _add_tone(freq: float, duration: float, volume: float, decay: float, wave: int) -> void:
	active.append({
		"freq": freq,
		"duration": duration,
		"remaining": duration,
		"volume": volume,
		"decay": decay,
		"wave": wave,
		"phase": 0.0
	})


func _next_sample() -> float:
	var sample := 0.0
	for i in range(active.size() - 1, -1, -1):
		var tone: Dictionary = active[i]
		var remaining := float(tone["remaining"])
		if remaining <= 0.0:
			active.remove_at(i)
			continue

		var phase := float(tone["phase"])
		var freq := float(tone["freq"])
		var duration := float(tone["duration"])
		var life: float = clamp(remaining / duration, 0.0, 1.0)
		var envelope: float = pow(life, float(tone["decay"])) * min(1.0, remaining * 80.0)
		var wave_value := sin(phase)
		if int(tone["wave"]) == 1:
			wave_value = 1.0 if sin(phase) >= 0.0 else -1.0
		sample += wave_value * float(tone["volume"]) * envelope
		phase += TAU * freq / MIX_RATE
		remaining -= 1.0 / MIX_RATE
		tone["phase"] = phase
		tone["remaining"] = remaining
		active[i] = tone
	return clamp(sample, -0.75, 0.75)
