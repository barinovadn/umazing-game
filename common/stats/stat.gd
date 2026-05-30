extends Resource
class_name Stat

signal value_changed()

@export var min_value: float = -INF
@export var max_value: float = INF
@export var modifications: Dictionary[String, Modifier]
@export var base_value: float:
	set(some_value):
		base_value = some_value
		if base_value < min_value:
			base_value = min_value
		elif base_value > max_value:
			base_value = max_value
		value_changed.emit()

var _timers: Dictionary[String, Timer]
var value: float:
	get():
		var return_value = base_value
		var late_modifications: Dictionary[String, Modifier]
		modifications.keys()
		for key in modifications.keys():
			var el = modifications[key]
			match el.operation:
				el.Operation.decrease:
					return_value -= el.value
				el.Operation.increase:
					return_value += el.value
				el.Operation.multiply:
					late_modifications[key] = el
				el.Operation.divide:
					late_modifications[key] = el
		
		for key in late_modifications.keys():
			var el = late_modifications[key]
			match el.operation:
				el.Operation.multiply:
					return_value *= el.value
				el.Operation.divide:
					return_value /= el.value
		
		if return_value < min_value:
			return_value = min_value
		elif return_value > max_value:
			return_value = max_value
		
		return return_value


func add_modifier(mod_id: String, mod: Modifier):
	mod.creation_time = Time.get_unix_time_from_system()
	modifications[mod_id] = mod
	value_changed.emit()
	if mod.duration:
		if _timers.has(mod_id):
			var existing_timer: Timer = _timers[mod_id]
			existing_timer.wait_time = mod.duration + 0.05
			existing_timer.start()
		else:
			var new_timer: Timer = Timer.new()
			new_timer.one_shot = true
			new_timer.wait_time = mod.duration + 0.05
			
			Game.timers.add_child(new_timer)
			_timers[mod_id] = new_timer
			
			new_timer.timeout.connect(func(): remove_modifier(mod_id))
			new_timer.start()
			
			

func remove_modifier(mod_id: String):
	if _timers.has(mod_id):
		var timer: Timer = _timers[mod_id]
		if is_instance_valid(timer):
			timer.queue_free()
		_timers.erase(mod_id)
		
	if modifications.has(mod_id):
		modifications.erase(mod_id)
		value_changed.emit()

func remote_all_modifiers():
	for key in _timers.keys():
		var timer = _timers[key]
		timer.queue_free()
		_timers.erase(key)
		modifications.erase(key)
