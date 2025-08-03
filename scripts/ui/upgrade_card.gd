extends Control

class_name UpgradeCard

@export var test_upgrade: UpgradeResource
@onready var title: Label = $Panel/Header/Title
@onready var item_icon: TextureRect = $Panel/Margin/Content/ItemIcon
@onready var item_description: Label = $Panel/Margin/Content/ItemDescription
@onready var panel: Panel = $Panel
@onready var header: Panel = $Panel/Header
@onready var ui_scale: UIScale = $UIScale
@onready var cost_container: HBoxContainer = $Panel/Bottom/CostContainer

var panel_style: StyleBoxFlat
var upgrade: UpgradeResource
var selected: bool
var player_resources: PlayerResources
var tween: Tween
var blinking: bool
var message_box: MessageBox

const RESOURCE_COST = preload("res://scenes/ui/resource_cost.tscn")
const GOLD = preload("res://textures/ui/icons/gold.png")
const WOOD = preload("res://textures/ui/icons/wood.png")

func _ready():
    panel_style = panel.get("theme_override_styles/panel").duplicate()
    panel.set("theme_override_styles/panel", panel_style)
    header.set("theme_override_styles/panel", panel_style)
    panel.mouse_entered.connect(_mouse_entered)
    panel.mouse_exited.connect(_mouse_exited)
    World.require("player_resources", _on_player_resources)
    World.require("message_box")
    if test_upgrade:
        load_upgrade(test_upgrade)
        
func _on_message_box(obj: MessageBox):
    message_box = obj
    
func _on_player_resources(obj: PlayerResources):
    player_resources = obj
    
func _input(event: InputEvent):
    if selected: return
    if message_box and message_box.showing: return
    if event is InputEventMouseButton:
        if not panel.get_global_rect().has_point(get_global_mouse_position()): return
        if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
            _select_upgrade()
    if event is InputEventScreenTouch:
        if not panel.get_global_rect().has_point(event.position): return
        if event.is_pressed():
            _select_upgrade()
            
func _select_upgrade():
    if not player_resources.pay(upgrade.cost): 
        _blink_cost.call_deferred()
        return
    selected = true
    var obj = Node.new()
    obj.set_script(upgrade.upgrade_script)
    obj.set("parameters", upgrade.parameters)
    player_resources.add_child(obj)
    await _animate_select()
    
func _blink_cost():
    if blinking: return
    blinking = true
    for i in 6:
        if selected: break
        cost_container.visible = !cost_container.visible
        await get_tree().create_timer(0.25).timeout
    blinking = false
    cost_container.visible = true

func _animate_select():
    if tween:
        tween.kill()
    tween = create_tween()
    tween.tween_property(self, "scale", Vector2(1.2,1.2), .25)\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_QUAD)
    tween.tween_property(self, "scale", Vector2.ONE, .25)\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_BACK)
    await tween.finished
    tween.kill()
    if upgrade and upgrade.next_resource: 
        upgrade = upgrade.next_resource
        load_upgrade(upgrade)
        selected = false
        return
    tween = create_tween()
    tween.tween_property(self, "modulate", Color.TRANSPARENT, .5)\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_BACK)\
        .set_delay(0.5)
    tween.set_parallel(true)
    tween.tween_property(self, "global_position", global_position + Vector2(0,-40), 1.)
    await tween.finished
    queue_free()

func _mouse_entered():
    panel_style.bg_color = Color("d5f66e")
    
func _mouse_exited():
    panel_style.bg_color = Color("dfcbbf")
    
func load_upgrade(obj: UpgradeResource):
    ui_scale.fade_in()
    upgrade = obj
    title.text = upgrade.display_name
    item_icon.texture = upgrade.texture
    item_description.text = upgrade.description
    for c in cost_container.get_children():
        c.queue_free()
    for key in upgrade.cost:
        _add_cost_indicator(key, upgrade.cost[key])
        
func _add_cost_indicator(res: String, amount: int):
    var obj = RESOURCE_COST.instantiate() as ResourceCost
    cost_container.add_child(obj)
    match res:
        "wood": obj.icon.texture = WOOD
        "gold": obj.icon.texture = GOLD
    obj.label.text = str(amount)
