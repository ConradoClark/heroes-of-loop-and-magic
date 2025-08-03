extends HBoxContainer

class_name FloatingResource

@export var resource: String
@export var amount: int
@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

const RESOURCE_MINUS = preload("res://presets/label_settings/resource_minus.tres")
const RESOURCE_PLUS = preload("res://presets/label_settings/resource_plus.tres")

const GOLD = preload("res://textures/ui/icons/gold.png")
const SHIELD = preload("res://textures/ui/icons/shield.png")
const SWORD = preload("res://textures/ui/icons/sword.png")
const WOOD = preload("res://textures/ui/icons/wood.png")
const HEALTH = preload("res://textures/ui/icons/health.png")

func _ready():
    _set_text.call_deferred()

func _set_text():
    match resource:
        "wood": texture_rect.texture = WOOD
        "gold": texture_rect.texture = GOLD
        "damage": texture_rect.texture = SWORD
        "armor": texture_rect.texture = SHIELD
        "health": texture_rect.texture = HEALTH
    label.label_settings = RESOURCE_PLUS if amount > 0 else RESOURCE_MINUS
    label.text = ("+%s" % amount) if amount > 0 else ("%s" % amount)
