extends Node

class_name ResourceRegistrar

@export var actor: Actor
@export var object: Resource
@export var registry_name: String

func _ready():
  actor.register(registry_name, object)
