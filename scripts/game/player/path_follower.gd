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
var floating_manager: FloatingManager
var player_resources: PlayerResources
var current_points: PackedVector2Array
var current_index: int = 0
var closest_ix:int = 0
var tolerance: float = 1.
var _moving: bool = false
var current_path_id: int
var loop_count = 0
const FLOATING_LOOP = preload("res://scenes/ui/floating/floating_loop.tscn")

func _ready():
    World.require("ink_manager", _on_ink_manager)
    World.require("path_manager", _on_path_manager)
    World.require("floating_manager", World.populate(self, "floating_manager"))
    World.require("player_resources", World.populate(self, "player_resources"))
    
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
    
    var closest = null
    closest_ix = 0
    for ix in len(current_points):
        var p = current_points[ix]
        var length = (p - reference.global_position).length()
        if not closest or length < closest:
            closest = length
            closest_ix = ix
    current_index = closest_ix
    current_path_id = id
    path_manager.on_path_start.emit(self, id)
    loop_count = 0
    _move.call_deferred(current_points[closest_ix] + offset)
    
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
            var dir = (pos - current_pos).normalized() * (speed * player_resources.speed_multiplier)
            reference.global_position += dir * get_process_delta_time()
            await get_tree().process_frame
        if not _moving: break
        reference.global_position = pos
        current_index += 1
        if current_index >= len(current_points):
            current_index = 0
        if current_index == closest_ix:
            loop_count+=1
            _spawn_loop_text_effect.call_deferred()
            path_manager.on_path_loop.emit(self, current_path_id)
        pos = current_points[current_index] + offset
        await get_tree().process_frame
    if bobble:
        bobble.stop_bobble()

func _spawn_loop_text_effect():
    var obj = FLOATING_LOOP.instantiate()
    floating_manager.spawn_floating_object(obj, reference.global_position + Vector2(0,-20) + Fx.random_inside_unit_circle()*15,
        FloatingContent.Effect.Fade)
