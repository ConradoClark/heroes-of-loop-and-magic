extends Area2D

class_name TapInkArea

@onready var collision_shape: CollisionShape2D = $CollisionShape
var shape: CircleShape2D
var radius: float
var perfection: float

func _ready():
    shape = CircleShape2D.new()
    shape.radius = radius
    collision_shape.shape = shape
