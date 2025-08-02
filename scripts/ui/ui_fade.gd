extends Node

class_name UIFade

@export var reference: Control
@export var is_showing: bool
@export var offset: Vector2
@export var duration: float
var initial_position: Vector2
var tween: Tween

func _ready():
    reference.visible = is_showing
    initial_position = reference.global_position
    if not is_showing:
        reference.global_position = initial_position + offset

func fade_in():
    if is_showing: return
    is_showing = true
    reference.visible = true
    if tween:
        tween.kill()
    tween = create_tween()
    tween.tween_property(reference, "global_position", initial_position, duration)\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_SPRING)

func fade_out():
    if not is_showing: return
    is_showing = false
    if tween:
        tween.kill()
    tween = create_tween()
    tween.tween_property(reference, "global_position", initial_position + offset, duration)\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_SPRING)
