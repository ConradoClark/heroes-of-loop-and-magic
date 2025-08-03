extends TextureRect

class_name EncounterMark

@export var enemy_stats: EnemyResource

var cleared: bool = false
var fighting: bool = false
var encounter_manager: EncounterManager
var shader_mat: ShaderMaterial

func _ready():
    texture = enemy_stats.enemy_texture
    material = material.duplicate()
    shader_mat = material
    World.require("encounter_manager", _on_encounter_manager)
    
func _on_encounter_manager(obj: EncounterManager):
    encounter_manager = obj
    encounter_manager.on_move.connect(_check_mark)
    
func _on_clear():
    shader_mat.set_shader_parameter("replace_color", .8)
    
func _check_mark(pos: float):
    if cleared or fighting: return
    if pos < global_position.y:
        encounter_manager.start_encounter(enemy_stats)
        encounter_manager.on_encounter_end.connect(_on_clear, ConnectFlags.CONNECT_ONE_SHOT)
        fighting = true
        # if you lose, the encounter never ends, maybe?
        # then the game over screen w/ retry shows up
        await encounter_manager.on_encounter_end
        fighting = false
        cleared = true
