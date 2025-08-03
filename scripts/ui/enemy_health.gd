extends Node

class_name EnemyHealth

@export var bar: ColorRect
@export var proportion: float

var battle_manager: BattleManager
var tween: Tween

func _ready():
    World.require("battle_manager", _on_battle_manager)
    
func _on_battle_manager(obj: BattleManager):
    battle_manager = obj
    battle_manager.on_battle_start.connect(_battle_start)
    battle_manager.enemy_damaged.connect(_health_changed)
    
func _battle_start(enemy: EnemyResource):
    bar.custom_minimum_size.x = proportion
    
func _health_changed(amount: int, health: int, max_health:int):
    if tween:
        tween.kill()
    tween = create_tween()
    tween.tween_property(bar, "custom_minimum_size:x", (float(health)/max_health) * proportion, .5)\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_QUAD)
