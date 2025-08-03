extends Node

class_name PlayerHealth

@export var bar: ColorRect
@export var proportion: float

var player_resources: PlayerResources
var tween: Tween

func _ready():
    World.require("player_resources", _on_resources)
    
func _on_resources(obj: PlayerResources):
    player_resources = obj
    player_resources.on_health_changed.connect(_health_changed)
    
func _health_changed(amount: int, health: int):
    if tween:
        tween.kill()
    tween = create_tween()
    tween.tween_property(bar, "custom_minimum_size:x", (float(health)/player_resources.max_health) * proportion, .5)\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_QUAD)
