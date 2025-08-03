extends Node

class_name LevelSelector

@export var levels: Dictionary[Button, String] = {}
var screen_transition: ScreenTransition
const ACCEPT = preload("res://audio/sfx/accept.ogg")
func _ready():
    World.require("screen_transition", World.populate(self, "screen_transition"))
    _hook.call_deferred()
            
func _hook():
    for key in levels:
        key.pressed.connect(func():
            SoundManager.play_sound(ACCEPT)
            await screen_transition.hide_transition()
            Fx.change_scene(levels[key])
        )
