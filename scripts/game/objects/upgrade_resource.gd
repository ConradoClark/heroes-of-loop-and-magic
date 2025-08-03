extends Resource

class_name UpgradeResource

@export var display_name: String
@export_multiline var description: String
@export var texture: Texture2D
@export var upgrade_script: Script
@export var cost: Dictionary[String, int] = {}
@export var next_resource: UpgradeResource
@export var parameters: Dictionary[String, Variant]
