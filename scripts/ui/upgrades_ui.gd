extends HBoxContainer

class_name UpgradesUI

var player_resources: PlayerResources
const UPGRADE_TEMPLATE = preload("res://scenes/ui/upgrade_template.tscn")
func _ready():
    World.require("player_resources", _on_player_resources)

func _on_player_resources(obj: PlayerResources):
    player_resources = obj
    _load_upgrades.call_deferred()
    
func _load_upgrades():
    for c in get_children():
        c.queue_free()
    for p in player_resources.available_upgrades:
        _add_upgrade(p)
        
func _add_upgrade(upgrade: UpgradeResource):
    var obj = UPGRADE_TEMPLATE.instantiate() as UpgradeCard
    add_child(obj)
    obj.load_upgrade(upgrade)
