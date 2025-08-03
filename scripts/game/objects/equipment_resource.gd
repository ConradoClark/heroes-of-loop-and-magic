extends RewardResource

class_name EquipmentResource

enum Type{
    Weapon,
    Shield
}

@export var type: Type
@export var texture_equipped: Texture2D
@export var damage: int
@export var armor   : int
@export var speed_multiplier: float = 1.
@export_file("*.tscn") var extra_effect: String
