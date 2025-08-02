extends Node

class_name PathManager

signal on_path_created(id: int, shape: PackedVector2Array)
signal on_path_destroyed(id: int)
signal on_path_start(follower: PathFollower, id: int)
signal on_path_loop(follower: PathFollower, id: int)

signal pause_status_changed(status: bool)

var ink_manager: InkManager
var is_paused: bool = false

func _ready():
    World.require("ink_manager", _on_ink_manager)
    World.register("path_manager", self)
    
func _on_ink_manager(obj: InkManager):
    ink_manager = obj
    ink_manager.on_closed_shape.connect(_on_closed_shape)
    ink_manager.on_shape_destroyed.connect(_on_path_destroyed)

func _on_closed_shape(instance_id: int, shape: PackedVector2Array):
    on_path_created.emit(instance_id, shape.duplicate())

func _on_path_destroyed(instance_id: int):
    on_path_destroyed.emit(instance_id)

func pause_paths():
    is_paused = true
    pause_status_changed.emit(true)

func unpause_paths():
    is_paused = false
    pause_status_changed.emit(false)
