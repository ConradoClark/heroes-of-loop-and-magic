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
    if parameters.has("armor"):
        player_resources.add_resource("armor", parameters["armor"])
    if parameters.has("gold_bonus"):
        player_resources.loop_bonus_max["gold"] += parameters["gold_bonus"]
