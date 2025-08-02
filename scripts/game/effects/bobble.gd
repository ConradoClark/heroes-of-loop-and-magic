extends Node

class_name Bobble

@export var rotation_magnitude: float
@export var duration: float
@export var target: Node2D
@export var auto_bobble: bool
var tween: Tween
var bobbling: bool = false

func _ready():
    if auto_bobble:
        start_bobble.call_deferred()

func start_bobble():
    if bobbling: return
    bobbling = true
    if tween:
        tween.kill()
    tween = create_tween()
    tween.tween_property(target, "global_rotation_degrees", -rotation_magnitude, duration*.25)\
        .set_ease(Tween.EASE_IN_OUT)\
        .set_trans(Tween.TRANS_QUAD)
    await tween.finished
    if not bobbling: return
    while (bobbling):
        if tween:
            tween.kill()
        tween = create_tween()
        tween.tween_property(target, "global_rotation_degrees", rotation_magnitude, duration*.5)\
            .set_ease(Tween.EASE_IN_OUT)\
            .set_trans(Tween.TRANS_QUAD)
        tween.tween_property(target, "global_rotation_degrees", -rotation_magnitude, duration*.5)\
            .set_ease(Tween.EASE_IN_OUT)\
            .set_trans(Tween.TRANS_QUAD)
        while tween.is_running():
            if not bobbling:
                tween.kill()
                return
            await get_tree().process_frame

func stop_bobble():
    if not bobbling: return
    bobbling = false
    await get_tree().process_frame
    if tween:
        tween.kill()
    tween = create_tween()
    tween.tween_property(target, "global_rotation_degrees", 0, duration*.25)\
            .set_ease(Tween.EASE_OUT)\
            .set_trans(Tween.TRANS_QUAD)  
    await tween.finished
