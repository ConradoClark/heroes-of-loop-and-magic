extends Ink

# Ink used to switch things, and hit enemies with blunt force
class_name TapInk

const TAP_INK_AREA = preload("res://scenes/inks/tap_ink_area.tscn")
var ink_container: Node2D

func _ready():
    World.require("ink_container", _on_ink_container)
    
func _on_ink_container(obj: Node2D):
    ink_container = obj

func make(center: Vector2, diameter: float, perfection: float):
    var obj = TAP_INK_AREA.instantiate() as TapInkArea
    obj.radius = diameter*.5
    obj.perfection = perfection
    obj.global_position = center
    ink_container.add_child(obj)
