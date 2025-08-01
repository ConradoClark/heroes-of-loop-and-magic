extends Node2D

class_name Actor

var reference_transform: Node2D
var actor_id: String
var parameters: Dictionary[String,Variant]

func _ready():
  actor_id = name + "_" + str(get_instance_id())

var register_signals: Dictionary[String, Signal]
var unregister_signals: Dictionary[String, Signal]
var signal_container: Dictionary[String, RefCounted]

static func find(node: Node) -> Actor:
  if node is Actor: return node as Actor
  var current_node = node
  var parent = current_node.get_parent()
  while parent != null:
    if parent is Actor:
      return parent as Actor
    current_node = parent
    parent = current_node.get_parent()
  return null

func register(name: String, object: Object):
  parameters[name] = object
  var registration = _get_or_add_signal(register_signals, name)
  registration.emit(object)

func unregister(name: String, object: Object):
  parameters.erase(name)
  register_signals.erase(name)
  var registration = _get_or_add_signal(unregister_signals, name)
  registration.emit(object)
  _remove_unregister_event.call_deferred()
  
func unregister_all():
  parameters.clear()
  register_signals.clear()
  unregister_signals.clear()
  signal_container.clear()

func _remove_unregister_event(name: String):
  unregister_signals.erase(name)
  
func wait_for_object(name: String):
  if parameters.has(name):
    return
  if not register_signals.has(name):
    require(name, World.noop)
  await register_signals[name]

func require(name: String, on_available: Callable) -> Object:
  if not parameters.has(name):
    if on_available:
      var registration = _get_or_add_signal(register_signals, name)
      registration.connect(on_available, CONNECT_ONE_SHOT)
    return null
  if on_available: on_available.call(parameters[name])
  return parameters[name]
  
func _get_or_add_signal(registry: Dictionary[String, Signal], name: String) -> Signal:
  if not registry.has(name):
    signal_container[name] = SignalRegister.new()
    registry[name] = Signal(signal_container[name], "register_signal")
  return registry[name]
