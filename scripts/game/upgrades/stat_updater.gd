extends Node

class_name StatUpdater

var parameters: Dictionary[String, Variant] = {}
var player_resources: PlayerResources

func _ready():
    World.require("player_resources", World.populate(self, "player_resources"))
    _apply.call_deferred()

func _apply():
    if parameters.has("move_speed_multiplier"):
        player_resources.speed_multiplier = parameters["move_speed_multiplier"]
    if parameters.has("damage"):
        player_resources.add_resource("damage", parameters["damage"])
