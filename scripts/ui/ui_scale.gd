extends Node

class_name UIScale

@export var reference: Control
@export var is_showing: bool
@export var duration: float
var tween: Tween

func _ready():
    reference.visible = is_showing
    if not is_showing:
        reference.scale = Vector2(0.01,0.01)

func fade_in():
    if is_showing: return
    is_showing = true
    reference.visible = true
    if tween:
        tween.kill()
    tween = create_tween()
    tween.tween_property(reference, "scale", Vector2(1.2, 1.2), duration*.75)\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_SPRING)
    tween.tween_property(reference, "scale", Vector2.ONE, duration*.25)\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_ELASTIC)

func fade_out():
    if not is_showing: return
    is_showing = false
    if tween:
        tween.kill()
    tween = create_tween()
    tween.tween_property(reference, "scale", Vector2(0.01, 0.01), duration)\
        .set_ease(Tween.EASE_IN)\
        .set_trans(Tween.TRANS_BACK)
    await tween.finished
    reference.visible = false
