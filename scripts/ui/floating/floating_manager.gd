extends Node

class_name FloatingManager

@export var floating_container: Control
const FLOATING_CONTENT = preload("res://scenes/ui/floating/floating_content.tscn")

func _ready():
    World.register("floating_manager", self)

func spawn_floating_object(obj: Control, pos: Vector2, effect: FloatingContent.Effect = FloatingContent.Effect.FloatUp):
    var content = FLOATING_CONTENT.instantiate() as FloatingContent
    content.effect = effect
    content.add_child(obj)
    content.global_position = pos
    floating_container.add_child(content)
