extends Node

class_name LineDrawer

@export_file("*.tscn") var line_template: String
@export var line_container: Node2D
@export var step: float
var pressed := false
var last_position: Vector2
var line_prefab: PackedScene
var current_line: MarkerLine
var moving_line: MarkerLine
var tolerance: float = .50
var ink_manager: InkManager
var blocker: Blocker
const LOOP = preload("res://audio/sfx/loop.ogg")
var loop_stream: AudioStreamPlayer
func _ready():
    line_prefab = load(line_template)
    blocker = Blocker.new()
    add_child(blocker)
    World.register("line_drawer", self)
    World.require("ink_manager", _on_ink_manager)
    
func _on_ink_manager(obj: InkManager):
    ink_manager = obj

func _input(event: InputEvent) -> void:
    if blocker.is_blocked():
        #if blocked and drawing, what to do?
        return
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            pressed = event.pressed
        else: return
        if pressed:
            loop_stream = SoundManager.play_sound(LOOP)
            _spawn_line(event.position)
        elif event.is_released():
            loop_stream.stop()
            SoundManager.audio_finished(loop_stream)
            var is_closed = _detect_closed_shape()
            if is_closed:
                if moving_line:
                    _disappear_on_release.call_deferred(moving_line)
                moving_line = current_line
            else:
                _disappear_on_release.call_deferred(current_line)
    elif event is InputEventMouseMotion and pressed:
        var distance = abs(event.position-last_position).length()
        if distance > step:
            current_line.add_point(event.position)
            last_position = event.position
            #if _detect_circle():
            #    _disappear_on_release.call_deferred(current_line)
            #    _spawn_line(event.position)

func _spawn_line(pos: Vector2):
    current_line = line_prefab.instantiate() as MarkerLine
    current_line.clear_points()
    current_line.add_point(pos)
    line_container.add_child(current_line)
    last_position = pos
    
func _detect_closed_shape() -> bool:
    if not current_line: return false
    var total_points = len(current_line.points)
    if total_points < 10: return false
    var x_min = null
    var y_min = null
    var x_max = null
    var y_max = null
    for p in current_line.points:
        if not x_min or p.x < x_min:
            x_min = p.x
        if not y_min or p.y < y_min:
            y_min = p.y
        if not x_max or p.x > x_max:
            x_max = p.x
        if not y_max or p.y > y_max:
            y_max = p.y
    var center = Vector2(x_min + (x_max - x_min) * .5, y_min + (y_max - y_min) * .5)
    var distance = (center - Vector2(x_min, y_min)).length()
    var dist_tolerance = distance * tolerance
    var is_closing = false
    var last_ones = current_line.points.slice(-3)
    for p in last_ones:
        if p.distance_to(current_line.points[0]) < dist_tolerance:
            is_closing = true
            break
    if is_closing and ink_manager:
        ink_manager.on_closed_shape.emit(current_line.get_instance_id(), current_line.points)
    return is_closing
          
func _detect_circle() -> bool:
    var total_points = len(current_line.points)
    if total_points < 10: return false
    var x_min = null
    var y_min = null
    var x_max = null
    var y_max = null
    for p in current_line.points:
        if not x_min or p.x < x_min:
            x_min = p.x
        if not y_min or p.y < y_min:
            y_min = p.y
        if not x_max or p.x > x_max:
            x_max = p.x
        if not y_max or p.y > y_max:
            y_max = p.y
    var center = Vector2(x_min + (x_max - x_min) * .5, y_min + (y_max - y_min) * .5)
    var distance = (center - Vector2(x_min, y_min)).length()
    var dist_tolerance = distance * tolerance
    var is_closing = false
    var last_ones = current_line.points.slice(-3)
    for p in last_ones:
        if p.distance_to(current_line.points[0]) < dist_tolerance:
            is_closing = true
            break
    if not is_closing: return false
    var match_count = 0.
    for ix in len(current_line.points):
        var p = current_line.points[ix]
        var p_dist = center.distance_to(p)
        if abs(center.distance_to(p) - distance) < dist_tolerance:
            match_count +=1
    var is_circle = match_count > 0.9*total_points
    if is_circle and ink_manager:
        ink_manager.on_circle.emit(current_line.type, center,\
            distance*2, match_count/float(total_points))
    return is_circle
    
func _disappear_on_release(line: Line2D):
    if not line: return
    ink_manager.on_shape_destroyed.emit(line.get_instance_id())
    var tween = create_tween()
    tween.tween_property(line, "width", 0., .3)\
        .set_ease(Tween.EASE_IN)\
        .set_trans(Tween.TRANS_QUAD)
    await tween.finished
    if line: line.queue_free()
