extends Node

class_name PathFollower

@export var viewport_proportion: float = .5
@export var reference: Node2D
@export var speed: float
var ink_manager: InkManager
var current_points: PackedVector2Array
var current_index: int = 0
var tolerance: float = 1.
var _moving: bool = false

func _ready():
    World.require("ink_manager", _on_ink_manager)
    
func _on_ink_manager(obj: InkManager):
    ink_manager = obj
    ink_manager.on_closed_shape.connect(_on_closed_shape)

func _on_closed_shape(points: PackedVector2Array):
    current_points = points.duplicate()
    for ix in len(current_points):
        current_points.set(ix, current_points[ix]*viewport_proportion)
    current_points[len(current_points)-1] = current_points[0]
    current_index = 0
    _move.call_deferred(current_points[0])
    
func _move(pos: Vector2):
    if _moving:
        _moving = false
        await get_tree().process_frame
    _moving = true
    while _moving:
        while (pos - reference.global_position).length() > tolerance:
            if not _moving: break 
            var current_pos = reference.global_position
            var dir = (pos - current_pos).normalized() * speed
            reference.global_position += dir * get_process_delta_time()
            await get_tree().process_frame
        if not _moving: break
        reference.global_position = pos
        current_index += 1
        if current_index >= len(current_points):
            current_index = 0
        pos = current_points[current_index]
        await get_tree().process_frame
