extends Node

class_name Speak

@export var scale_magnitude: Vector2
@export var duration: float
@export var target: Node2D
@export var auto_animate: bool
var tween: Tween
var animating: bool = false

func _ready():
    if auto_animate:
        start_animation.call_deferred()

func start_animation():
    if animating: return
    animating = true
    if tween:
        tween.kill()
    tween = create_tween()
    tween.tween_property(target, "scale:x", scale_magnitude.x, duration*.25)\
        .set_ease(Tween.EASE_IN_OUT)\
        .set_trans(Tween.TRANS_QUAD)
    await tween.finished
    if not animating: return
    while (animating):
        if tween:
            tween.kill()
        tween = create_tween()
        tween.tween_property(target, "scale:y", scale_magnitude.y, duration*.5)\
            .set_ease(Tween.EASE_OUT)\
            .set_trans(Tween.TRANS_SPRING)
        tween.set_parallel(true)
        tween.tween_property(target, "scale:x", 1., duration*.5)\
            .set_ease(Tween.EASE_IN_OUT)\
            .set_trans(Tween.TRANS_SPRING)
        tween.set_parallel(false)
        tween.tween_property(target, "scale:y", 1., duration*.5)\
            .set_ease(Tween.EASE_OUT)\
            .set_trans(Tween.TRANS_SPRING)
        tween.set_parallel(true)
        tween.tween_property(target, "scale:x", scale_magnitude.x, duration*.5)\
            .set_ease(Tween.EASE_IN_OUT)\
            .set_trans(Tween.TRANS_SPRING)
        while tween.is_running():
            if not animating:
                tween.kill()
                return
            await get_tree().process_frame

func stop_animation():
    if not animating: return
    animating = false
    await get_tree().process_frame
    if tween:
        tween.kill()
    tween = create_tween()
    tween.tween_property(target, "scale", Vector2.ONE, duration*.25)\
            .set_ease(Tween.EASE_OUT)\
            .set_trans(Tween.TRANS_QUAD)  
    await tween.finished
