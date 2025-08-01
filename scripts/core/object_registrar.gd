extends Node

class_name ObjectRegistrar

var actor: Actor
@export var object: Node
@export var registry_name: String
@export var world: bool

func _ready():
  if not world:
    actor = Actor.find(self)
    actor.register(registry_name, object)
  else:
    World.register(registry_name, object)
