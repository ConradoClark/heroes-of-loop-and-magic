extends Node

class_name PlayerResources

@export var resources: Dictionary[String, int]
@export var temporary_resources: Dictionary[String,int]

signal on_resource_changed(res: String, amount: int, total: int)
signal on_temp_resource_changed(res: String, amount: int, total: int)
signal on_clear_temp_resources


func _ready():
    World.register("player_resources", self)

func add_resource(res: String, amount: int):
    if not resources.has(res):
        resources[res] = 0
    var prev = resources[res]
    resources[res] = clamp(resources[res]+amount, 0, 1000000)
    if resources[res] != prev:
        on_resource_changed.emit(res, amount, resources[res])

func add_temporary_resource(res: String, amount: int):
    if not temporary_resources.has(res):
        temporary_resources[res] = 0
    var prev = temporary_resources[res]
    temporary_resources[res] += amount
    if temporary_resources[res] != prev:
        on_temp_resource_changed.emit(res, amount, temporary_resources[res])
        
func clear_temporary_resources():
    temporary_resources.clear()
    on_clear_temp_resources.emit()

func check(values: Dictionary[String,int]) -> bool:
    for key in values:
        if not resources.has(key): return false
        if resources[key] < values[key]: return false
    return true

func pay(values: Dictionary[String, int]) -> bool:
    if check(values):
        for key in values:
            resources[key]-= values[key]
        return true
    return false
