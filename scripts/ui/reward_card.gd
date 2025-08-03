extends Control

class_name RewardCard
@export var test_reward: RewardResource
@onready var title: Label = $Panel/Header/Title
@onready var item_icon: TextureRect = $Panel/Margin/Content/ItemIcon
@onready var item_description: Label = $Panel/Margin/Content/ItemDescription
@onready var flavor: Label = $Panel/Bottom/Flavor
@onready var panel: Panel = $Panel
@onready var header: Panel = $Panel/Header
@onready var wood: TextureRect = $Panel/Margin/Content/HBoxContainer/Wood
@onready var gold: TextureRect = $Panel/Margin/Content/HBoxContainer/Gold
@onready var crystal: TextureRect = $Panel/Margin/Content/HBoxContainer/Crystal
@onready var upgrade_with: Label = $Panel/Margin/Content/UpgradeWith
@onready var ui_scale: UIScale = $UIScale

var panel_style: StyleBoxFlat
var reward: RewardResource
var selected: bool
var reward_manager: RewardManager
var tween: Tween

func _ready():
    panel_style = panel.get("theme_override_styles/panel").duplicate()
    panel.set("theme_override_styles/panel", panel_style)
    header.set("theme_override_styles/panel", panel_style)
    panel.mouse_entered.connect(_mouse_entered)
    panel.mouse_exited.connect(_mouse_exited)
    World.require("reward_manager", _on_reward_manager)
    if test_reward:
        load_reward(test_reward)
    
func _on_reward_manager(obj: RewardManager):
    reward_manager = obj
    
func _input(event: InputEvent):
    if selected: return
    if event is InputEventMouseButton:
        if not panel.get_global_rect().has_point(get_global_mouse_position()): return
        if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
            _select_reward()
    if event is InputEventScreenTouch:
        if not panel.get_global_rect().has_point(event.position): return
        if event.is_pressed():
            _select_reward()
            
func _select_reward():
    selected = true
    await _animate_select()
    if reward_manager and reward:
        reward_manager.select_reward(reward)

func _animate_select():
    if tween:
        tween.kill()
    tween = create_tween()
    tween.tween_property(self, "modulate", Color.TRANSPARENT, .5)\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_BACK)\
        .set_delay(0.5)
    tween.set_parallel(true)
    tween.tween_property(self, "position", Vector2(0,-40), 1.)
    await tween.finished

func _mouse_entered():
    panel_style.bg_color = Color("d5f66e")
    
func _mouse_exited():
    panel_style.bg_color = Color("dfcbbf")
    
func load_reward(obj: RewardResource):
    ui_scale.fade_in()
    reward = obj
    title.text = reward.display_name
    item_icon.texture = reward.texture_reward
    item_description.text = reward.description
    flavor.text = reward.flavor_text
    upgrade_with.visible = len(reward.upgrades_with) > 0
    wood.visible = reward.upgrades_with.has("wood")
    gold.visible = reward.upgrades_with.has("gold")
    crystal.visible = reward.upgrades_with.has("crystal")
