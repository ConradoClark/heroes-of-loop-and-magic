extends Node

class_name Tutorial

var line_drawer: LineDrawer
var message_box: MessageBox
var speak: Speak

func _ready():
    World.require("line_drawer", _on_line_drawer)
    World.require("message_box", _on_message_box)
    if Flags.should_play_tutorial and not Flags.played_tutorial:
        play_tutorial.call_deferred()
    
func _on_line_drawer(obj: LineDrawer):
    line_drawer = obj
    
func _on_message_box(obj: MessageBox):
    message_box = obj
    
func play_tutorial():
    Flags.played_tutorial = true
    await World.wait_for_objects(["line_drawer", "message_box", "cinematic_king",
        "king_bobble", "king_speak", "lumbermill_fade", "tutorial_text",
        "path_manager", "lumbermill_resource", "goldmine_resource", "goldmine_fade",
        "player_resources", "resources_fade"])
    line_drawer.blocker.block("tutorial")
    var king = World.require("cinematic_king") as Actor
    var bobble = World.require("king_bobble") as Bobble
    speak = World.require("king_speak") as Speak
    king.global_position.y = -85
    var tween = create_tween()
    tween.tween_property(king, "global_position:y", 200, 3.)
    await tween.finished
    bobble.stop_bobble()
    await message_box.show_box()
    await message_box.message("My precious kingdom is falling to pieces...",_start_speak, _stop_speak)
    await message_box.message("I have no option, so I expect you to understand.",_start_speak, _stop_speak)
    await message_box.message("I'm invoking you, [wave]the God of Loop[/wave], to guide me",_start_speak, _stop_speak)
    await message_box.message("Take me as your servant, and help me save my people!",_start_speak, _stop_speak)
    await message_box.hide_box()
    var lumbermill_fade = World.require("lumbermill_fade") as FadeScale
    await lumbermill_fade.start_animation()
    await message_box.message("This is a lumbermill. It's a building that provides wood for the king.")
    await message_box.message("Every movement ordered by you, [wave]the God of Loop[/wave], must be a closed looping shape.")
    await message_box.message("Use the Rodent Sceptre (a.k.a your mouse) to click and drag a circular shape.")
    await message_box.message("The shape must go through the lumbermill for you to collect the resource.")
    await message_box.hide_box()
    line_drawer.blocker.unblock("tutorial")
    var tutorial_text = World.require("tutorial_text") as RichTextLabel
    tutorial_text.text = "[center][wave]Click and drag to make a looping path through the lumbermill"
    tutorial_text.visible = true
    var path_manager = World.require("path_manager") as PathManager
    await path_manager.on_path_created
    var lumbermill_resource = World.require("lumbermill_resource") as ResourceGiver
    while len(lumbermill_resource.paths) <= 0:
        await get_tree().process_frame
        tutorial_text.text = "[center][wave]Try again, the path is not going through the lumbermill"
        tutorial_text.visible = true
        await path_manager.on_path_created 
    tutorial_text.text = "[center][wave]Nice, watch as the king goes and collects the resource"
    tutorial_text.visible = true
    await path_manager.on_path_loop
    tutorial_text.visible = false
    path_manager.pause_paths()
    await message_box.message("Once the king loops around, he is able to collect the resource again.")
    await message_box.message("Resources regenerate on a cooldown, so plan your loops accordingly.")
    await message_box.hide_box()
    path_manager.unpause_paths()
    var goldmine_fade = World.require("goldmine_fade") as FadeScale
    goldmine_fade.start_animation()
    var goldmine_resource = World.require("goldmine_resource") as ResourceGiver
    goldmine_resource.active = true
    tutorial_text.text = "[center][wave]Collect 5 wood and 5 gold"
    tutorial_text.visible = true
    var resources_fade = World.require("resources_fade") as UIFade
    resources_fade.fade_in()
    var resources = World.require("player_resources") as PlayerResources
    while not resources.check({ "wood": 5, "gold":5}):
        await get_tree().process_frame
    tutorial_text.visible = false
    path_manager.pause_paths()
    await message_box.message("Staying on a loop for long gives resource bonuses.")
    await message_box.message("Use your resources to buy upgrades.")
    await message_box.message("Monsters will show up after some time. Be prepared to fight them.")
    await message_box.hide_box()
    path_manager.unpause_paths()
    tutorial_text.text = "[center][wave]Get ready to battle"
    tutorial_text.visible = true
func _start_speak():
    speak.start_animation()    

func _stop_speak():
    speak.stop_animation()
