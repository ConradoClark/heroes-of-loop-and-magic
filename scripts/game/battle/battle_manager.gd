extends Node

class_name BattleManager

@export var battle_ui: UIScale
@export var blackout: ColorRect
@export var hero_texture: TextureRect
@export var enemy_texture: TextureRect
@export var damage_color: Color = Color.WHITE
@export var armor_color: Color = Color.WHITE

var blackout_tween: Tween
var encounter_manager: EncounterManager
var player_resources: PlayerResources
var floating_manager: FloatingManager
var hero_timer: Timer
var enemy_timer: Timer

var hero_tween: Tween
var enemy_tween: Tween
var current_enemy: EnemyResource
var current_enemy_health: int
var current_armor: int

var armor_container: HFlowContainer

signal on_battle_start(enemy: EnemyResource)
signal on_battle_end(enemy: EnemyResource, victory: bool)
signal enemy_damaged(amount: int, health: int, max_health: int)

const FLOATING_BATTLE_NUMBER = preload("res://scenes/ui/floating/floating_battle_number.tscn")
const FLOATING_BLOCK = preload("res://scenes/ui/floating/floating_block.tscn")
const SHIELD = preload("res://textures/ui/icons/shield.png")

func _ready():
    hero_timer = _create_timer()
    enemy_timer = _create_timer()
    hero_timer.timeout.connect(_on_hero_attack)
    enemy_timer.timeout.connect(_on_enemy_attack)
    hero_texture.material = hero_texture.material.duplicate()
    enemy_texture.material = hero_texture.material.duplicate()
    World.register("battle_manager", self)
    World.require("encounter_manager", _on_encounter_manager)
    World.require("player_resources", _on_player_resources)
    World.require("floating_manager", World.populate(self, "floating_manager"))
    World.require("armor_container", World.populate(self, "armor_container"))
    
func _on_player_resources(obj: PlayerResources):
    player_resources = obj

func _create_timer() -> Timer:
    var timer = Timer.new()
    timer.wait_time = 1.
    add_child(timer)
    return timer

func _on_encounter_manager(obj: EncounterManager):
    encounter_manager = obj
    encounter_manager.on_encounter_start.connect(_on_encounter_start)
    
func _on_encounter_start(enemy: EnemyResource):
    on_battle_start.emit(enemy)
    _load_armor()
    hero_texture.scale = Vector2.ONE
    hero_texture.rotation_degrees = 0.
    enemy_texture.scale = Vector2.ONE
    enemy_texture.rotation_degrees = 0.
    enemy_texture.texture = enemy.enemy_texture
    battle_ui.fade_in()
    fade_blackout.call_deferred()
    await get_tree().create_timer(1.).timeout
    current_enemy = enemy
    _fight.call_deferred(enemy)
    
func _load_armor():
    for c in armor_container.get_children():
        c.queue_free()
    if not player_resources.resources.has("armor"): return
    for i in player_resources.resources["armor"]:
        var icon = TextureRect.new()
        icon.texture = SHIELD
        armor_container.add_child(icon)
    current_armor = player_resources.resources["armor"]

func _fight(enemy: EnemyResource):
    current_enemy_health = enemy.max_health
    enemy_timer.wait_time = enemy.attack_frequency
    var multi = player_resources.weapon.speed_multiplier * player_resources.shield.speed_multiplier
    if multi <= 0 or multi>10:
        multi = 10
    hero_timer.wait_time = 1 / multi
    hero_timer.start()
    enemy_timer.start()
    
func _on_hero_attack():
    if hero_tween:
        hero_tween.kill()
    hero_tween = create_tween()
    hero_tween.tween_property(hero_texture, "position:x", 30, .3)\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_EXPO)
    hero_tween.tween_property(hero_texture, "position:x", 0, .5)\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_QUAD)
    await get_tree().create_timer(0.3).timeout
    var dmg = player_resources.calculate_damage()
    var pos = enemy_texture.get_global_rect().get_center() + Fx.random_inside_unit_circle() * 10 + Vector2(0, -20)
    _show_damage_number(pos, dmg)
    _damage_enemy(dmg)
    _damage_blink(enemy_texture)

func _damage_enemy(dmg: int):
    if current_enemy_health <0: return
    current_enemy_health = clamp(current_enemy_health-dmg, 0, current_enemy.max_health)
    enemy_damaged.emit(dmg, current_enemy_health, current_enemy.max_health)
    if current_enemy_health <=0:
        _enemy_defeat.call_deferred()

func _enemy_defeat():
    hero_timer.stop()
    enemy_timer.stop()
    await _enemy_death_animate()
    fade_out_blackout.call_deferred()
    battle_ui.fade_out()
    player_resources.clear_temporary_resources()
    on_battle_end.emit(current_enemy, true)
    
func _enemy_death_animate():
    if enemy_tween:
        enemy_tween.kill()
    enemy_tween = create_tween()
    enemy_tween.tween_property(enemy_texture, "scale", Vector2(0.01, 0.01), 2.)
    enemy_tween.set_parallel(true)
    enemy_tween.tween_property(enemy_texture, "rotation_degrees", 360*10, 2.)
    await enemy_tween.finished
    
func _show_damage_number(pos: Vector2, damage: int, color: Color = Color.TRANSPARENT):
    var obj = FLOATING_BATTLE_NUMBER.instantiate()
    obj.number = damage
    obj.color = color
    floating_manager.spawn_floating_object(obj, pos, FloatingContent.Effect.FloatScale)

func _show_armor_block(pos: Vector2, damage: int, color: Color = Color.TRANSPARENT):
    var obj = FLOATING_BLOCK.instantiate()
    floating_manager.spawn_floating_object(obj, pos, FloatingContent.Effect.FloatScale)

func _on_enemy_attack():
    if enemy_tween:
        enemy_tween.kill()
    enemy_tween = create_tween()
    enemy_tween.tween_property(enemy_texture, "position:x", -30, .3)\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_EXPO)
    enemy_tween.tween_property(enemy_texture, "position:x", 0, .5)\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_QUAD)
    await get_tree().create_timer(0.3).timeout
    var dmg = ceil(current_enemy.damage * randf_range(0.8,1.1))
    dmg = _try_damage_armor(dmg)
    if dmg > 0:
        var pos = hero_texture.get_global_rect().get_center() + Fx.random_inside_unit_circle() * 10 + Vector2(0, -20)
        _show_damage_number(pos, dmg)
        player_resources.damage(dmg)
        if player_resources.health <=0:
            _player_defeat.call_deferred()
        _damage_blink(hero_texture)
    else:
        var pos = hero_texture.get_global_rect().get_center() + Fx.random_inside_unit_circle() * 10 + Vector2(0, -20)
        _show_armor_block(pos, dmg)
        _damage_blink(hero_texture)
    
func _try_damage_armor(damage: int) -> int:
    var remaining = 0
    if damage > current_armor:
        remaining = damage - current_armor
        current_armor = 0
    else:
        current_armor -= damage
    var children = armor_container.get_children()
    var amount_to_remove = len(children) - current_armor
    if amount_to_remove>0:
        for i in amount_to_remove:
            children[i].queue_free()
    return remaining
    
func _player_defeat():
    hero_timer.stop()
    enemy_timer.stop()
    await _hero_death_animate()
    fade_out_blackout.call_deferred()
    battle_ui.fade_out()
    on_battle_end.emit(current_enemy, false)
    
func _hero_death_animate():
    if hero_tween:
        hero_tween.kill()
    hero_tween = create_tween()
    hero_tween.tween_property(hero_texture, "scale", Vector2(0.01, 0.01), 2.)
    hero_tween.set_parallel(true)
    hero_tween.tween_property(hero_texture, "rotation_degrees", 360*10, 2.)
    await hero_tween.finished
    
func _armor_blink(rect: TextureRect):
    var shader_mat = rect.material as ShaderMaterial
    var tween = create_tween()
    tween.tween_method(_tween_shader_mat_param(shader_mat, armor_color), 0., 1., .35)\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_QUAD)
    tween.tween_method(_tween_shader_mat_param(shader_mat, armor_color), 1., 0., .35)\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_QUAD)
    
func _damage_blink(rect: TextureRect):
    var shader_mat = rect.material as ShaderMaterial
    var tween = create_tween()
    tween.tween_method(_tween_shader_mat_param(shader_mat, damage_color), 0., 1., .35)\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_QUAD)
    tween.tween_method(_tween_shader_mat_param(shader_mat, damage_color), 1., 0., .35)\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_QUAD)
    
func _tween_shader_mat_param(mat: ShaderMaterial, color: Color) -> Callable:
    return func(value: float):
        mat.set_shader_parameter("color", Color(color, value*color.a))
    
func fade_blackout():
    if blackout_tween:
        blackout_tween.kill()
    blackout_tween = create_tween()
    blackout_tween.tween_property(blackout, "modulate:a", 0.9, 1.)

func fade_out_blackout():
    if blackout_tween:
        blackout_tween.kill()
    blackout_tween = create_tween()
    blackout_tween.tween_property(blackout, "modulate:a", 0., 1.)
