extends Node

class_name ResourceGiver

@export var resource_name: String
@export var starting_amount: int
@export var maximum_amount: int
@export var area: Area2D
@export var active: bool
var area_shape: RectangleShape2D

var path_manager: PathManager
var resources: PlayerResources
var passed_through_by: Dictionary[Area2D, bool] = {}
var paths: Dictionary[int, bool] = {}

func _ready():
    area.area_entered.connect(_on_unit_entered)
    area_shape = area.shape_owner_get_shape(0,0)
    World.require("player_resources", _on_resources)
    World.require("path_manager", _on_path_manager)
    
func _on_resources(obj: PlayerResources):
    resources = obj
    
func _on_path_manager(obj: PathManager):
    path_manager = obj
    path_manager.on_path_created.connect(_on_path_created)
    path_manager.on_path_start.connect(_on_path_start)
    path_manager.on_path_destroyed.connect(_on_path_destroyed)
    path_manager.on_path_loop.connect(_on_path_loop)
    
func _on_path_created(id: int, shape: PackedVector2Array):
    var rect = area_shape.get_rect()
    rect.position += area.global_position
    for p in shape:
        if rect.has_point(p):
            paths[id] = true
            return

func _on_path_destroyed(id:int):
    if paths.has(id):
        paths.erase(id)
        
func _on_path_start(follower:PathFollower, id: int):
    if follower.area:
        passed_through_by.erase(follower.area)
        
func _on_path_loop(follower: PathFollower, id: int):
    if not paths.has(id): return
    passed_through_by.erase(follower.area)
    var overlaps = area.get_overlapping_areas()
    if len(overlaps)>0:
        _on_unit_entered(overlaps[0])

func _on_unit_entered(target: Area2D):
    if not active: return
    if passed_through_by.has(target): return
    if not resources: return
    resources.add_resource(resource_name, 1)
    print("RESOURCE %s ADDED" % resource_name)
    passed_through_by[target] = true
