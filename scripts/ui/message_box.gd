extends Panel

class_name MessageBox

@export var offset: float
var tween: Tween
var original_y: float
var showing: bool = false
@onready var label: RichTextLabel = $Margin/Label
var timer: Timer
var cursor_timer: Timer
@onready var cursor: TextureRect = $CursorMargin/Cursor

var current_voice: AudioStream
var speak_timer: Timer

func _ready():
    original_y = global_position.y
    global_position.y = global_position.y + offset
    timer = Timer.new()
    timer.wait_time = .025
    timer.timeout.connect(_move_text)
    add_child(timer)
    cursor_timer = Timer.new()
    cursor_timer.wait_time = 0.25
    add_child(cursor_timer)
    cursor_timer.timeout.connect(_change_cursor_visibility)
    speak_timer = Timer.new()
    speak_timer.wait_time = 0.05
    speak_timer.timeout.connect(_voice)
    add_child(speak_timer)
    World.register("message_box", self)
    
func _input(event: InputEvent) -> void:
    if event.is_action_released("debug_msgbox"):
        if showing:
            hide_box()
        else:
            message("HELLO FROM DEBUG!")

func _create_tween():
    if tween:
        tween.kill()
    tween = create_tween()

func show_box():
    if showing: return
    showing = true
    _create_tween()
    visible = true
    tween.tween_property(self, "global_position:y", original_y, .5)\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_SPRING)
    await tween.finished
    
func message(msg: String, on_start: Callable = World.noop, on_full_text: Callable = World.noop):
    if not showing:
        await show_box()
    label.visible_characters = 0
    label.visible_ratio = 0
    label.text = msg
    await get_tree().process_frame
    if on_start:
        on_start.call()
    timer.start()
    speak_timer.start()
    _voice()
    while label.visible_ratio < 1:
        if Input.is_action_just_pressed("click"):
            label.visible_ratio = 1
            break
        if label.visible_ratio > 0.9:
            speak_timer.stop()
        await get_tree().process_frame
    speak_timer.stop()
    timer.stop()
    if on_full_text:
        on_full_text.call()
    cursor.visible = true
    cursor_timer.start()
    await get_tree().process_frame
    while not Input.is_action_just_pressed("click"):
        await get_tree().process_frame
    cursor.visible = false
    cursor_timer.stop()

func _move_text():
  label.visible_characters+=1
  
func _voice():
  if current_voice:
    SoundManager.play_sound(current_voice, 0.95, 1.4)

func _change_cursor_visibility():
  cursor.visible = !cursor.visible
    
func hide_box():
    if not showing: return
    await get_tree().process_frame
    showing = false
    _create_tween()
    tween.tween_property(self, "global_position:y", original_y + offset, .5)\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_BOUNCE)
    await tween.finished
    if not showing: 
        visible = false
        label.text = ""
