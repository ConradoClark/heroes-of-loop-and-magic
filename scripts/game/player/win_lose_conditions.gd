extends Node

class_name WinLoseConditions

@export var defeat_panel: UIScale
@export var victory_panel: UIScale
@export var retry_button: Button
@export var continue_button: Button
@export var level_select_buttons: Array[Button]
@export_file("*.tscn") var next_level: String

var battle_manager: BattleManager
var screen_transition: ScreenTransition
var reward_manager: RewardManager
var encounter_manager: EncounterManager

func _ready():
    if retry_button: retry_button.pressed.connect(_on_retry)
    if continue_button: continue_button.pressed.connect(_on_continue)
    for button in level_select_buttons:
        button.pressed.connect(_on_level_select)
    World.require("battle_manager", _on_battle_manager)
    World.require("screen_transition", World.populate(self, "screen_transition"))
    World.require("reward_manager", _on_reward_manager)
    World.require("encounter_manager", World.populate(self, "encounter_manager"))
    
func _on_reward_manager(obj: RewardManager):
    reward_manager = obj
    reward_manager.on_reward_chosen.connect(_on_reward_chosen)
    
func _on_reward_chosen():
    encounter_manager.end_encounter()

func _on_battle_manager(obj: BattleManager):
    battle_manager = obj
    battle_manager.on_battle_end.connect(_on_battle_end)
    
func _on_retry():
    defeat_panel.fade_out()
    await screen_transition.hide_transition()
    Fx.change_scene(get_tree().current_scene.scene_file_path)

func _on_level_select():
    defeat_panel.fade_out()
    await screen_transition.hide_transition()
    # TODO: CHANGE TO LEVEL SELECT SCREEN
    #Fx.change_scene(get_tree().current_scene.scene_file_path)

func _on_continue():
    defeat_panel.fade_out()
    await screen_transition.hide_transition()
    Fx.change_scene(next_level)
    
func _on_battle_end(enemy: EnemyResource, victory: bool):
    if victory:
        if enemy.is_boss:
            victory_panel.fade_in()
            pass
        else:
            #show rewards
            reward_manager.show_reward_screen(enemy)
        return
    else:
        defeat_panel.fade_in()
