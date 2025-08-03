extends Control

class_name FloatingContent

@export var effect: Effect
var tween: Tween

enum Effect{
    FloatUp,
    Fade,
    FloatScale
}

func _ready():
    match effect:
        Effect.FloatUp: float_up.call_deferred()
        Effect.Fade: fade.call_deferred()
        Effect.FloatScale: float_scale.call_deferred()
            
func float_up():
    if tween:
        tween.kill()
    tween = create_tween()
    tween.tween_property(self, "global_position:y", global_position.y - 35, 1.)\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_QUAD)
    tween.set_parallel(true)
    tween.tween_property(self, "modulate", Color.TRANSPARENT, 1.5)\
        .set_delay(1.)
    var scale_tween = create_tween()
    scale_tween.tween_property(self, "scale", Vector2(1.1,1.1), 0.5)\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_SPRING)
    scale_tween.tween_property(self, "scale", Vector2.ONE, 0.5)\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_BOUNCE)
    await scale_tween.finished
    await tween.finished
    queue_free()
    
func float_scale():
    if tween:
        tween.kill()
    tween = create_tween()
    tween.tween_property(self, "global_position:y", global_position.y - 15, .5)\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_QUAD)
    tween.set_parallel(true)
    tween.tween_property(self, "modulate", Color.TRANSPARENT, 1.)\
        .set_delay(.5)
    var scale_tween = create_tween()
    scale_tween.tween_property(self, "scale", Vector2(1.3,1.3), 0.35)\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_SPRING)
    scale_tween.tween_property(self, "scale", Vector2.ONE, 0.35)\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_BOUNCE)
    await scale_tween.finished
    await tween.finished
    queue_free()

func fade():
    if tween:
        tween.kill()
    tween = create_tween()
    tween.tween_property(self, "modulate", Color.TRANSPARENT, 1.5)\
        .set_delay(1.)
    await tween.finished
    queue_free()
