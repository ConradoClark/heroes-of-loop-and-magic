extends Node

class_name SetMusic2

@export var stream: AudioStream

func _ready():
    SoundManager.set_music2(stream)
    SoundManager.stop_music()
