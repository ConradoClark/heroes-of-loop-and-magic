extends Node

class_name RewardManager

@export var rewards_slot: Control
@export var rewards_ui: UIScale
@export var skip_button: Button

const REWARD_TEMPLATE = preload("res://scenes/ui/reward_template.tscn")
const FLOATING_RESOURCE = preload("res://scenes/ui/floating/floating_resource.tscn")

var battle_manager: BattleManager
var open: bool
var player_resources: PlayerResources
var floating_manager: FloatingManager
signal on_reward_chosen
signal on_reward_skip

func _ready():
    World.register("reward_manager", self)
    World.require("battle_manager", World.populate(self, "battle_manager"))
    World.require("player_resources", World.populate(self, "player_resources"))
    World.require("floating_manager", World.populate(self, "floating_manager"))
    skip_button.pressed.connect(_on_skip)
    
func _on_skip():
    if not open: return
    rewards_ui.fade_out()
    battle_manager.fade_out_blackout()
    on_reward_skip.emit()
    open = false
    
func select_reward(reward: RewardResource):
    if reward is EquipmentResource:
        player_resources.equip(reward)
    if reward is AddResourceReward:
        player_resources.add_resource(reward.resource, reward.amount)
        var floating = FLOATING_RESOURCE.instantiate() as FloatingResource
        floating.amount = reward.amount
        floating.resource = reward.resource
        var pos = rewards_slot.get_global_mouse_position() + Fx.random_inside_unit_circle()*10
        floating_manager.spawn_floating_object(floating, pos)
    rewards_ui.fade_out()
    battle_manager.fade_out_blackout()
    open = false
    on_reward_chosen.emit()
    
func load_rewards(enemy: EnemyResource):
    for c in rewards_slot.get_children():
        c.queue_free()
    var clone = enemy.rewards.duplicate()
    var rewards:Array[RewardResource] = []
    for i in 3:
        var rng = randi_range(0, len(clone)-1)
        rewards.append(clone[rng])
        _load_reward(clone[rng])
        clone.remove_at(rng)
    rewards_ui.fade_in()
    battle_manager.fade_blackout()

func _load_reward(reward: RewardResource):
    var obj = REWARD_TEMPLATE.instantiate()
    rewards_slot.add_child(obj)
    obj.load_reward(reward)

func show_reward_screen(enemy: EnemyResource):
    open = true
    load_rewards(enemy)
