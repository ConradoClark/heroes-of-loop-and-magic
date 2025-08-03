extends Node

class_name ResourceGiver

@export var source_name: String
@export var resource_name: String
@export var starting_amount: int
@export var maximum_amount: int
@export var given_amount: int = 1
@export var area: Area2D
@export var active: bool
@export var label: Label
@export var refresh_delay: float = 5.
@export var progress_border: Control
@export var progress_bar: Control 
var area_shape: RectangleShape2D
var current_amount: int

var label_effect: Tween

var path_manager: PathManager
var resources: PlayerResources
var passed_through_by: Dictionary[Area2D, bool] = {}
var paths: Dictionary[int, bool] = {}
var followers: Dictionary[Area2D, PathFollower] = {}
var floating_manager: FloatingManager
const FLOATING_RESOURCE = preload("res://scenes/ui/floating/floating_resource.tscn")
const FLOATING_BONUS = preload("res://scenes/ui/floating/floating_bonus.tscn")
const FLOATING_EMPTY = preload("res://scenes/ui/floating/floating_empty.tscn")
var refresh_timer: Timer

func _ready():
    current_amount = starting_amount
    area.area_entered.connect(_on_unit_entered)
    area_shape = area.shape_owner_get_shape(0,0)
    _create_refresh_timer()
    World.require("player_resources", _on_resources)
    World.require("path_manager", _on_path_manager)
    World.require("floating_manager", World.populate(self, "floating_manager"))
    
func _create_refresh_timer():
    refresh_timer = Timer.new()
    refresh_timer.wait_time = refresh_delay * randf_range(0.95, 1.1)
    refresh_timer.timeout.connect(_on_refresh)
    add_child(refresh_timer)
    if current_amount != maximum_amount:
        refresh_timer.start(randf_range(0., refresh_timer.wait_time*.5))
    progress_border.visible = current_amount != maximum_amount
    
func _on_refresh():
    if not active: return
    progress_border.visible = current_amount != maximum_amount
    if current_amount == maximum_amount: return
    current_amount += 1
    if current_amount == maximum_amount:
        refresh_timer.stop()
    _update_text_label()

func _process(delta: float) -> void:
    if not active: return
    if refresh_timer.is_stopped(): return
    var progress = refresh_timer.wait_time - refresh_timer.time_left
    progress_bar.custom_minimum_size = Vector2(lerp(0., 75., progress / refresh_timer.wait_time), 0)

func _update_text_label():
    if not label: return
    label.text = "%s/%s" % [current_amount, maximum_amount]
    if label_effect:
        label_effect.kill()
    label_effect = create_tween()
    label_effect.tween_property(label, "scale", Vector2(1.2,1.2), 0.35)\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_SPRING)
    label_effect.tween_property(label, "scale", Vector2.ONE, 0.35)\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_SPRING)        
    
func _on_resources(obj: PlayerResources):
    resources = obj
    
func _on_path_manager(obj: PathManager):
    path_manager = obj
    path_manager.on_path_created.connect(_on_path_created)
    path_manager.on_path_start.connect(_on_path_start)
    path_manager.on_path_destroyed.connect(_on_path_destroyed)
    path_manager.on_path_loop.connect(_on_path_loop)
    path_manager.pause_status_changed.connect(_pause_status_changed)
    
func _pause_status_changed(status: bool):
    if refresh_timer.is_stopped(): return
    refresh_timer.paused = status
    
func _on_path_created(id: int, shape: PackedVector2Array):
    var rect = area_shape.get_rect()
    rect.position += area.global_position
    rect.size *= 1.2
    for p in shape:
        if rect.has_point(p):
            paths[id] = true
            return

func _on_path_destroyed(id:int):
    if paths.has(id):
        paths.erase(id)
    for key in followers:
        var follower = followers[key]
        if follower.current_path_id == id:
            followers.erase(key)
        
func _on_path_start(follower:PathFollower, id: int):
    if follower.area:
        passed_through_by.erase(follower.area)
        followers[follower.area] = follower
        
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
    var amount = given_amount
    if source_name and resources.bonus_by_source.has(source_name):
        amount += resources.bonus_by_source[source_name]
    amount = min(current_amount, amount)
    if amount == 0:
        _show_empty.call_deferred()
        return
    var resource_cost = amount
    if current_amount == maximum_amount:
        refresh_timer.start()
        progress_border.visible = true
    current_amount -= resource_cost
    _update_text_label()
    var loop_bonus = 1 if not resources.loop_bonus_max.has(resource_name) else resources.loop_bonus_max[resource_name]
    if followers.has(target):
        var passed_thresholds = followers[target].loop_count / resources.loop_bonus_threshold
        if passed_thresholds > 0:
            amount += min(loop_bonus, passed_thresholds)
            _show_bonus_effect.call_deferred()
    var result = resources.add_resource(resource_name, amount)
    if result:
        var floating = FLOATING_RESOURCE.instantiate() as FloatingResource
        floating.amount = amount
        floating.resource = resource_name
        var pos = area.global_position + Vector2(0, -15) + Fx.random_inside_unit_circle()*10
        floating_manager.spawn_floating_object(floating, pos)
    passed_through_by[target] = true
    
func _show_empty():
    var floating = FLOATING_EMPTY.instantiate()
    var pos = area.global_position + Vector2(randf_range(-15, 15), 0) + Fx.random_inside_unit_circle()*15
    floating_manager.spawn_floating_object(floating, pos, FloatingContent.Effect.FloatScale)

func _show_bonus_effect():
    await get_tree().create_timer(randf_range(0.1, 0.3), false).timeout
    var floating = FLOATING_BONUS.instantiate()
    var pos = area.global_position + Vector2(randf_range(-30, 30), 25) + Fx.random_inside_unit_circle()*15
    floating_manager.spawn_floating_object(floating,pos, FloatingContent.Effect.FloatScale)
    
