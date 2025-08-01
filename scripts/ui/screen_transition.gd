extends CanvasLayer

class_name ScreenTransition

@export var auto_show: bool = true
@export var duration_seconds = 1.
@export var target: float = 13.
@onready var transition: Control = $Transition
var shader: ShaderMaterial
var tween: Tween

func _ready():
    shader = transition.material as ShaderMaterial
    if auto_show:
        transition.visible = true
        show_transition.call_deferred()
    World.register("screen_transition", self)

func show_transition():
    transition.visible = true
    if tween:
        tween.kill()
    tween = create_tween()
    tween.tween_method(_set_value, 0., target, duration_seconds)
    await tween.finished
    
func hide_transition():
    transition.visible = true
    if tween:
        tween.kill()
    tween = create_tween()
    tween.tween_method(_set_value, target, 0., duration_seconds)
    await tween.finished
    
func _set_value(val: float):
    if shader:
        shader.set_shader_parameter("progress", val)
