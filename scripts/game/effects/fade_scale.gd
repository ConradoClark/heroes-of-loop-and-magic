extends Node

class_name FadeScale

@export var scale_magnitude: Vector2
@export var duration: float
@export var target: Node2D
@export var auto_animate: bool
var tween: Tween
var animating: bool = false

func _ready():
    target.visible = false
    if auto_animate:
        start_animation.call_deferred()

func start_animation():
    if animating: return
    animating = true
    target.scale = Vector2(0.01, 0.01)
    target.visible = true
    if tween:
        tween.kill()
    tween = create_tween()
    tween.tween_property(target, "scale:x", scale_magnitude.x, duration*.5)\
        .set_ease(Tween.EASE_IN)\
        .set_trans(Tween.TRANS_SPRING)
    tween.set_parallel(true)
    tween.tween_property(target, "scale:y", scale_magnitude.y, duration*.5)\
        .set_ease(Tween.EASE_IN)\
        .set_trans(Tween.TRANS_SPRING)
    tween.set_parallel(false)
    tween.tween_property(target, "scale", Vector2.ONE, duration*.5)\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_BOUNCE)
    await tween.finished
    animating = false

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
