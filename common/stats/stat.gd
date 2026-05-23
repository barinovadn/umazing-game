extends Resource
class_name Stat

signal value_changed()

@export var min_value: float = -INF
@export var max_value: float = INF
@export var modifications: Dictionary[String, Modification]
@export var base_value: float:
	set(some_value):
		base_value = some_value
		if base_value < min_value:
			base_value = min_value
		elif base_value > max_value:
			base_value = max_value
		value_changed.emit()

var value: float:
	get():
		var return_value = base_value
		var late_modifications: Dictionary[String, Modification]
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


func add_modifier(mod_name: String, mod: Modification) -> void:
	mod.creation_time = Time.get_unix_time_from_system()
	modifications[mod_name] = mod
	value_changed.emit()
	Game.get_tree().create_timer(mod.duration + 0.05).timeout.connect(check_modifications)


func remove_modifier(mod_name) -> void:
	modifications.erase(mod_name)
	value_changed.emit()


func check_modifications() -> void:
	for key in modifications.keys():
		var el = modifications[key]
		if Time.get_unix_time_from_system() > el.creation_time + el.duration:
			remove_modifier(key)
