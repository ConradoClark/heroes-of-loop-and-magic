extends Node

class_name PathFollower

@export var viewport_proportion: float = .5
@export var reference: Node2D
@export var speed: float
@export var area: Area2D
@export var bobble: Bobble
@export var offset: Vector2
var ink_manager: InkManager
var path_manager: PathManager
var current_points: PackedVector2Array
var current_index: int = 0
var tolerance: float = 1.
var _moving: bool = false
var current_path_id: int

func _ready():
    World.require("ink_manager", _on_ink_manager)
    World.require("path_manager", _on_path_manager)
    
func _on_path_manager(obj: PathManager):
    path_manager = obj
    
func _on_ink_manager(obj: InkManager):
    ink_manager = obj
    ink_manager.on_closed_shape.connect(_on_closed_shape)

func _on_closed_shape(id: int, points: PackedVector2Array):
    current_points = points.duplicate()
    for ix in len(current_points):
        current_points.set(ix, current_points[ix]*viewport_proportion)
    current_points[len(current_points)-1] = current_points[0]
    current_index = 0
    current_path_id = id
    path_manager.on_path_start.emit(self, id)
    _move.call_deferred(current_points[0] + offset)
    
func _move(pos: Vector2):
    if _moving:
        _moving = false
        await get_tree().process_frame
    _moving = true
    if bobble:
        await get_tree().process_frame
        bobble.start_bobble()
    while _moving:
        while (pos - reference.global_position).length() > tolerance:
            if not _moving: break 
            if path_manager.is_paused:
                if bobble: bobble.stop_bobble()
                while path_manager.is_paused:
                    await get_tree().process_frame
                if bobble: bobble.start_bobble()
            var current_pos = reference.global_position
            var dir = (pos - current_pos).normalized() * speed
            reference.global_position += dir * get_process_delta_time()
            await get_tree().process_frame
        if not _moving: break
        reference.global_position = pos
        current_index += 1
        if current_index >= len(current_points):
            current_index = 0
            path_manager.on_path_loop.emit(self, current_path_id)
        pos = current_points[current_index] + offset
        await get_tree().process_frame
    if bobble:
        bobble.stop_bobble()
