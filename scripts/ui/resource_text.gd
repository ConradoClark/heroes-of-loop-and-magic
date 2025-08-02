extends Label

class_name ResourceText

@export var resource: String
@export var is_temporary: bool
@export var digits: int = 3 

func _ready():
    World.require("player_resources", _on_player_resources)

func _on_player_resources(obj: PlayerResources):
    if is_temporary:
        obj.on_temp_resource_changed.connect(_on_resource_changed)
        obj.on_clear_temp_resources.connect(_on_clear)
    else:
        obj.on_resource_changed.connect(_on_resource_changed)
    if obj.resources.has(resource):
        _on_resource_changed(resource, 0, obj[resource])

func _on_resource_changed(res: String, amount: int, total: int):
    if res != resource: return
    text = "%0*d" % [digits, total]
    if is_temporary:
        text = str(total)
        visible = total != 0
        text = "+" if total >0 else "-" + text

func _on_clear():
    text = "%0*d" % [digits, 0]
    if is_temporary:
        visible = false
