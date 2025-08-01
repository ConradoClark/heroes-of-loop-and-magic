extends Node

class_name InkManager

@export var inks: Dictionary[String, Script]

signal on_closed_shape(points: PackedVector2Array)
signal on_circle(type: String, center: Vector2, diameter: float, perfection: float)

func _ready():
    World.register("ink_manager", self)
    on_circle.connect(_on_circle)
    
func _on_circle(type: String, center: Vector2, diameter: float, perfection: float):
    if not inks.has(type): return
    var ink_node = Ink.new()
    ink_node.set_script(inks[type])
    add_child(ink_node)
    ink_node.make(center, diameter, perfection)
