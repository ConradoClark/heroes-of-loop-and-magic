extends Node

var sound_players: Array[AudioStreamPlayer] = []
var sounds_dict = {}

var free: Array[AudioStreamPlayer] = []
var music: AudioStreamPlayer = AudioStreamPlayer.new()
var music2: AudioStreamPlayer = AudioStreamPlayer.new()

var target_db_music: float = -24
var music_pos: float

var target_db_music2: float = -24
var music2_pos: float
var tween: Tween
var tween2: Tween

func set_music(song: AudioStream):
  await get_tree().create_timer(0.5).timeout
  if not music.playing or music.stream != song:
    music.volume_db = -40.
    _fade_music_in()
    music.stream = song
    #music.play()

func pause_music():
  music_pos = music.get_playback_position()
  music.stop()
  
func unpause_music():
  music.play()
  music.seek(music_pos)
    
func _fade_music_in():
  if tween:
    tween.kill()
  tween = get_tree().create_tween()
  tween.tween_property(music, "volume_db", target_db_music, 1)
    
func stop_music():
  if not music.playing or not music.stream: return
  music.stop()

func set_music2(song: AudioStream):
  await get_tree().create_timer(0.5).timeout
  if not music2.playing or music2.stream != song:
    music2.volume_db = -40.
    _fade_music_in2()
    music2.stream = song
    #music2.play()
    
func pause_music2():
  music2_pos = music2.get_playback_position()
  music2.stop()
  
func unpause_music2():
  music2.play()
  music2.seek(music2_pos)
    
func _fade_music_in2():
  if tween2:
    tween2.kill()
  tween2 = get_tree().create_tween()
  tween2.tween_property(music2, "volume_db", target_db_music2, 1)
    
func stop_music2():
  if not music.playing or not music.stream: return
  music.stop()
  
func lower_music_volume():
  if not music.playing or not music.stream: return
  target_db_music = -15.
  music.volume_db = target_db_music
  
func normal_music_volume():
  if not music.playing or not music.stream: return
  target_db_music = -6.
  music.volume_db = target_db_music

func _ready():
  music.process_mode = Node.PROCESS_MODE_ALWAYS
  music2.process_mode = Node.PROCESS_MODE_ALWAYS
  add_child(music)
  add_child(music2)
  for channel in 16:
    var p = AudioStreamPlayer.new()
    p.volume_db = -5
    add_child(p)
    free.append(p)
    sound_players.append(p)
    p.finished.connect(audio_finished.bind(p))
    p.bus = 'master'

func audio_finished(stream: AudioStreamPlayer):
 free.append(stream)

func play_sound(sound: AudioStream, min_pitch: float = 1., max_pitch: float = 1.) -> AudioStreamPlayer:
  if free.is_empty(): return
  var player = free.pop_front()
  player.pitch_scale = randf_range(min_pitch, max_pitch)
  player.stream = sound
  player.play()
  return player
