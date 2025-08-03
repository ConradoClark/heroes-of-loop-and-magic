extends Node

class_name EncounterManager

@export var king_marker: Control
@export var king_speed: float = 1.4
@export var min_y: float
@export var max_y: float

var initial_position: Vector2
var timer: Timer
var active: bool

var path_manager: PathManager

signal on_active_changed(val: bool)
signal on_move(pos: float)
signal on_encounter_start(enemy: EnemyResource)
signal on_encounter_end

func _ready():
    #active = true
    initial_position = king_marker.global_position
    timer = Timer.new()
    timer.wait_time = 0.05
    timer.autostart = true
    timer.timeout.connect(_timeout)
    add_child(timer)
    World.register("encounter_manager", self)
    World.require("path_manager", World.populate(self, "path_manager"))
    
func set_active(value: bool):
    active = value
    on_active_changed.emit(value)

func _timeout():
    if not active: return
    king_marker.global_position.y -= king_speed * .1
    on_move.emit(king_marker.global_position.y)
    
func start_encounter(enemy: EnemyResource):
    set_active(false)
    path_manager.pause_paths()
    on_encounter_start.emit(enemy)

func end_encounter():
    set_active(true)
    path_manager.unpause_paths()
    on_encounter_end.emit()
