extends Control

class_name FloatingBattleNumber
@export var number: int
@export var color: Color = Color.TRANSPARENT
@onready var label: RichTextLabel = $Label

func _ready():
    if color != Color.TRANSPARENT:
        label.add_theme_color_override("default_color", color)
    label.text = str(number)
