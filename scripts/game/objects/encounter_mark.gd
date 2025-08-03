extends TextureRect

class_name EncounterMark

@export var enemy_stats: EnemyResource
@export_multiline var tooltip_message: String

var cleared: bool = false
var fighting: bool = false
var encounter_manager: EncounterManager
var shader_mat: ShaderMaterial
var tooltip: Tooltip

signal on_encounter_trigger

func _ready():
    texture = enemy_stats.enemy_texture
    material = material.duplicate()
    mouse_entered.connect(_mouse_entered)
    mouse_exited.connect(_mouse_exited)
    shader_mat = material
    World.require("encounter_manager", _on_encounter_manager)
    World.require("tooltip", World.populate(self, "tooltip"))
    
func _mouse_entered():
    if not tooltip: return
    if tooltip_message != "":
        tooltip.show_tip(get_instance_id(), tooltip_message)

func _mouse_exited():
    if not tooltip: return
    if tooltip_message != "":
        tooltip.hide_tip(get_instance_id())
    
func _on_encounter_manager(obj: EncounterManager):
    encounter_manager = obj
    encounter_manager.on_move.connect(_check_mark)
    
func _on_clear():
    shader_mat.set_shader_parameter("replace_color", .8)
    
func _check_mark(pos: float):
    if cleared or fighting: return
    if pos < global_position.y:
        on_encounter_trigger.emit()
        encounter_manager.start_encounter(enemy_stats)
        fighting = true
        # if you lose, the encounter never ends, maybe?
        # then the game over screen w/ retry shows up
        await encounter_manager.on_encounter_end
        _on_clear()
        fighting = false
        cleared = true
