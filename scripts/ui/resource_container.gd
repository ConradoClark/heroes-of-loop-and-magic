extends HBoxContainer

class_name ResourceContainer

@export var resource: String
@export var texture: Texture2D
@onready var resource_text: ResourceText = $ResourceText
var resource_text_temp: ResourceText 
@onready var texture_rect: TextureRect = $TextureRect

func _ready():
    resource_text_temp = get_node_or_null("ResourceTextTemp")
    resource_text.resource = resource
    texture_rect.texture = texture
    if resource_text_temp:
        resource_text_temp.resource = resource
