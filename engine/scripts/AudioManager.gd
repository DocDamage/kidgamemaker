extends Node

const ASSET_ROOT := "res://data/assets"

var main_context: Node = null
var audio_debug: bool = false
var bpm_sequence: Array = []

var current_step_index: int = 0
var step_timer: float = 0.0
var step_duration: float = 0.15
var sample_rate: float = 44100.0

var _bgm_player: AudioStreamPlayer = null
var _sfx_cache: Dictionary = {}
var _active_sfx_players: Array[AudioStreamPlayer] = []


func configure(context: Node) -> void:
	main_context = context


func cleanup() -> void:
	_stop_active_sfx()
	_stop_bgm()
	_sfx_cache.clear()


func fill_audio_buffer() -> void:
	if _bgm_player == null or not _bgm_player.playing:
		return
	var playback := _bgm_player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback == null:
		return

	var frames_to_fill := playback.get_frames_available()
	if frames_to_fill <= 0:
		return

	var buffer := PackedVector2Array()
	buffer.resize(frames_to_fill)

	for i in range(frames_to_fill):
		step_timer += 1.0 / sample_rate
		if step_timer >= step_duration:
			step_timer = 0.0
			current_step_index = (current_step_index + 1) % 8

		var sample_val := 0.0

		if bpm_sequence.size() >= 4:
			if int(bpm_sequence[0][current_step_index]) == 1:
				var t := step_timer
				if t < 0.1:
					var freq: float = lerp(150.0, 40.0, t / 0.1)
					var env := (1.0 - t / 0.1)
					sample_val += sin(t * TAU * freq) * 0.3 * env

			if int(bpm_sequence[1][current_step_index]) == 1:
				var t := step_timer
				if t < 0.12:
					var noise_val := (randf() * 2.0 - 1.0)
					var env := (1.0 - t / 0.12)
					sample_val += noise_val * 0.15 * env

			if int(bpm_sequence[2][current_step_index]) == 1:
				var t := step_timer
				if t < 0.04:
					var noise_val := (randf() * 2.0 - 1.0)
					var env := (1.0 - t / 0.04)
					sample_val += noise_val * 0.05 * env

			if int(bpm_sequence[3][current_step_index]) == 1:
				var notes := [130.81, 155.56, 196.00, 233.08, 261.63, 196.00, 155.56, 130.81]
				var freq: float = float(notes[current_step_index % notes.size()])
				var t := step_timer
				if t < 0.15:
					var wave_val := 1.0 if sin(t * TAU * freq) > 0.0 else -1.0
					var env := (1.0 - t / 0.15)
					sample_val += wave_val * 0.1 * env

		sample_val = clamp(sample_val, -1.0, 1.0)
		buffer[i] = Vector2(sample_val, sample_val)

	for frame in buffer:
		playback.push_frame(frame)


func stop_bgm() -> void:
	_stop_bgm()


func play_theme_bgm(theme: String) -> void:
	if _audio_disabled_for_headless():
		return
	_stop_bgm()

	var bgm_path := ""
	match theme:
		"space":
			bgm_path = "res://data/assets/audio/space_bgm.wav"
		"candy":
			bgm_path = "res://data/assets/audio/candy_bgm.wav"
		"jungle":
			bgm_path = "res://data/assets/audio/jungle_bgm.wav"
		"ice":
			bgm_path = "res://data/assets/audio/ice_bgm.wav"
		"volcano":
			bgm_path = "res://data/assets/audio/volcano_bgm.wav"
		"custom":
			var generator := AudioStreamGenerator.new()
			generator.mix_rate = sample_rate
			generator.buffer_length = 0.1
			_bgm_player = AudioStreamPlayer.new()
			_bgm_player.stream = generator
			_bgm_player.volume_db = -10.0
			add_child(_bgm_player)
			_bgm_player.play()
			print("Playing custom synthesized beat composer sequence")
			return

	if bgm_path != "":
		var stream = _load_wav_file(bgm_path)
		if stream != null:
			stream.loop = true
			_bgm_player = AudioStreamPlayer.new()
			_bgm_player.stream = stream
			_bgm_player.volume_db = -10.0
			add_child(_bgm_player)
			_bgm_player.play()
			print("Playing BGM theme: ", theme)


func play_sfx(type: String) -> void:
	if _audio_disabled_for_headless():
		return
	if audio_debug:
		print("Audio debug: play_sfx(", type, ")")
	var sound_path := ""
	match type:
		"coin":
			sound_path = "res://data/assets/audio/coin.wav"
		"jump":
			sound_path = "res://data/assets/audio/jump.wav"
		"hit":
			sound_path = "res://data/assets/audio/hit.wav"

	if sound_path == "":
		return

	var stream: AudioStreamWAV = null
	if _sfx_cache.has(type):
		stream = _sfx_cache[type]
	else:
		stream = _load_wav_file(sound_path)
		if stream != null:
			_sfx_cache[type] = stream

	if stream != null:
		_play_one_shot(stream)


func play_custom_sfx(asset_id: String, default_type: String = "") -> void:
	if _audio_disabled_for_headless():
		return
	if audio_debug:
		print("Audio debug: play_custom_sfx(", asset_id, ", ", default_type, ")")
	if asset_id == "":
		if default_type != "":
			play_sfx(default_type)
		return

	var cache_key := asset_id + "_custom"
	if _sfx_cache.has(cache_key):
		var cached_stream: AudioStreamWAV = _sfx_cache[cache_key]
		if cached_stream != null:
			_play_one_shot(cached_stream)
			return

	if main_context == null or not main_context.has_method("_load_sidecar"):
		if default_type != "":
			play_sfx(default_type)
		return

	var sidecar: Dictionary = main_context._load_sidecar(asset_id)
	var audio_logic: Dictionary = sidecar.get("audio_logic", {})
	var stream_file := str(audio_logic.get("stream_file", ""))

	if stream_file != "":
		var sidecar_path := str(sidecar.get("sidecar_path", ""))
		var resolved_audio_path := stream_file
		if sidecar_path != "":
			resolved_audio_path = sidecar_path.get_base_dir().path_join(stream_file)
		else:
			resolved_audio_path = ASSET_ROOT.path_join(stream_file)

		var stream = _load_wav_file(resolved_audio_path)
		if stream != null:
			_sfx_cache[cache_key] = stream
			_play_one_shot(stream)
			return

	if default_type != "":
		play_sfx(default_type)


func _play_one_shot(stream: AudioStreamWAV) -> void:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = -5.0
	add_child(player)
	player.play()
	_track_sfx_player(player)


func _audio_disabled_for_headless() -> bool:
	return DisplayServer.get_name() == "headless"


func _stop_bgm() -> void:
	if _bgm_player != null and is_instance_valid(_bgm_player):
		_bgm_player.stop()
		_bgm_player.stream = null
		_bgm_player.free()
	_bgm_player = null


func _stop_active_sfx() -> void:
	for player in _active_sfx_players:
		if player != null and is_instance_valid(player):
			player.stop()
			player.stream = null
			player.free()
	_active_sfx_players.clear()


func _track_sfx_player(player: AudioStreamPlayer) -> void:
	_active_sfx_players.append(player)
	player.finished.connect(func():
		_active_sfx_players.erase(player)
		player.stream = null
		player.queue_free()
	)


func _load_wav_file(path: String) -> AudioStreamWAV:
	var resolved_path := path
	if resolved_path.begins_with("file://"):
		resolved_path = resolved_path.replace("file://", "")
		if OS.get_name() == "Windows" and resolved_path.begins_with("/"):
			resolved_path = resolved_path.substr(1)

	var final_fs_path := ProjectSettings.globalize_path(resolved_path)
	if not FileAccess.file_exists(final_fs_path):
		var exe_dir = OS.get_executable_path().get_base_dir()
		var alt_path = exe_dir.path_join(path.replace("res://", ""))
		if FileAccess.file_exists(alt_path):
			final_fs_path = alt_path
		else:
			print("SFX file not found: ", final_fs_path)
			return null

	var file = FileAccess.open(final_fs_path, FileAccess.READ)
	if file == null:
		return null
	var bytes = file.get_buffer(file.get_length())
	if bytes.size() < 44:
		return null

	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	stream.stereo = false
	stream.data = bytes.slice(44)
	return stream
