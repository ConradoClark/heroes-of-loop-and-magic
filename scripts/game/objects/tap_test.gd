extends Actor

class_name TapTest

@onready var area: Area2D = $Area
@onready var sprite: Sprite2D = $Sprite

func _ready():
    pass

func _physics_process(delta: float) -> void:
    var targets = area.get_overlapping_areas()
    for target in targets:
        _on_area_entered(target)
    
func _on_area_entered(target: Area2D):
    var target_area = target as TapInkArea
    if not target_area: return
    sprite.modulate = Color(1.-sprite.modulate.r, 1., 1., 1.)
    target_area.queue_free()
