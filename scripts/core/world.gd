extends Node

var world: Dictionary[String, Object]
var register_signals: Dictionary[String, Signal]
var unregister_signals: Dictionary[String, Signal]
var signal_container: Dictionary[String, RefCounted]
var noop: Callable

@warning_ignore("unused_signal")
signal register_signal(object: Object)

func register(object_name: String, object: Object):
  world[object_name] = object
  var registration = _get_or_add_signal(register_signals, object_name)
  registration.emit(object)

func unregister(object_name: String, object: Object):
  world.erase(object_name)
  register_signals.erase(object_name)
  var registration = _get_or_add_signal(unregister_signals, object_name)
  registration.emit(object)
  _remove_unregister_event.call_deferred()
  
func unregister_all():
  world.clear()
  register_signals.clear()
  unregister_signals.clear()
  signal_container.clear()

func _remove_unregister_event(object_name: String):
  unregister_signals.erase(object_name)
  
func wait_for_object(object_name: String):
  if world.has(object_name):
    return
  if not register_signals.has(object_name):
    require(object_name, noop)
  await register_signals[object_name]

func require(object_name: String, on_available: Callable) -> Object:
  if not world.has(object_name):
    if on_available:
      var registration = _get_or_add_signal(register_signals, object_name)
      registration.connect(on_available, CONNECT_ONE_SHOT)
    return null
  on_available.call(world[object_name])
  return world[object_name]

static func populate(source: Object, obj: String) -> Callable:
    return func(resource: Object):
        source.set(obj, resource)
  
func _get_or_add_signal(registry: Dictionary[String, Signal], object_name: String) -> Signal:
  if not registry.has(object_name):
    signal_container[object_name] = SignalRegister.new()
    registry[object_name] = Signal(signal_container[object_name], "register_signal")
  return registry[object_name]
