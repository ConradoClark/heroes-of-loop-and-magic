extends Node

class_name SetMusic

@export var stream: AudioStream

func _ready():
    SoundManager.set_music(stream)
