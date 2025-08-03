extends Node

class_name PlayerResources

@export var resources: Dictionary[String, int]
@export var temporary_resources: Dictionary[String,float]
@export var weapon: EquipmentResource
@export var shield: EquipmentResource

signal on_resource_changed(res: String, amount: int, total: int)
signal on_temp_resource_changed(res: String, amount: float, total: float)
signal on_clear_temp_resources

var loop_bonus_threshold = 2
var loop_bonus_max: Dictionary[String,int] = {
    "wood": 1,
    "gold": 1,
    "damage": 1,
    "armor": 1
}
var bonus_by_source: Dictionary[String, int] = {}
var max_health: int = 10
var health: int = 10

var hero_weapon: Sprite2D
var hero_shield: Sprite2D

@export var available_upgrades: Array[UpgradeResource]
var speed_multiplier: float = 1.

signal on_health_changed(amount: int, total:int)

func _ready():
    World.register("player_resources", self)
    World.require("hero_weapon", World.populate(self,"hero_weapon"))
    World.require("hero_shield", World.populate(self,"hero_shield"))
    _setup_damage_resources.call_deferred()
    
func damage(amount: int):
    var prev = health
    health = clamp(health - amount, 0, max_health)
    if prev != health:
        on_health_changed.emit(amount, health)
        
func _setup_damage_resources():
    add_resource("damage", weapon.damage + shield.damage)
    add_resource("armor", weapon.armor + shield.armor)

func add_resource(res: String, amount: int) -> bool:
    if not resources.has(res):
        resources[res] = 0
    var prev = resources[res]
    resources[res] = clamp(resources[res]+amount, 0, 1000000)
    if resources[res] != prev:
        on_resource_changed.emit(res, amount, resources[res])
        return true
    return false

func add_temporary_resource(res: String, amount: float):
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
    
func calculate_damage() -> int:
    return resources["damage"]

func equip(equipment: EquipmentResource):
    if equipment.type == EquipmentResource.Type.Weapon:
        add_resource("damage", -weapon.damage)
        add_resource("armor", -weapon.armor)
        weapon = equipment
        add_resource("damage", weapon.damage)
        add_resource("armor", weapon.armor)
        hero_weapon.texture = equipment.texture_equipped
        pass
    else:
        add_resource("damage", -shield.damage)
        add_resource("armor", -shield.armor)
        shield = equipment
        add_resource("damage", shield.damage)
        add_resource("armor", shield.armor)
        hero_shield.texture = equipment.texture_equipped
        pass
