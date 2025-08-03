extends Panel

class_name Tooltip
@onready var label: RichTextLabel = $Label

var showing: Dictionary[int, String] = {}
var current_text: String

func show_tip(source: int, msg: String):
    showing[source] = msg
    label.text = msg
    visible = true

func hide_tip(source: int):
    if len(showing) == 0:
        return
    var was_showing = label.text == showing[source]
    showing.erase(source)
    if len(showing) == 0:
        visible = false
    elif was_showing:
        current_text = showing.values()[0]

func _process(delta: float) -> void:
    if not visible: return
    var screen_size = Vector2(960,540)
    var mouse_pos = get_global_mouse_position() 
    var pos = Vector2(-120,-60) if mouse_pos.x > (screen_size.x*.5) else Vector2(-30,-60)
    global_position = mouse_pos + pos
