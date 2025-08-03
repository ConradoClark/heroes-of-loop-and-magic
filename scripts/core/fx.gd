extends Node

func call_delayed(seconds: float, fn: Callable):
    await get_tree().create_timer(seconds, false).timeout
    fn.call()

func change_scene(scene: String):
  var instance = load(scene).instantiate()
  World.unregister_all()
  get_tree().root.add_child(instance)
  await get_tree().process_frame
  var old_scene = get_tree().current_scene
  get_tree().current_scene = instance
  old_scene.free()

func random_inside_unit_circle() -> Vector2:
    var theta = randf() * TAU
    return Vector2(cos(theta), sin(theta)) * sqrt(randf())
