extends Node2D
class_name Stat

var min_value: float
var max_value: float
var modifications: Dictionary[String, Modification]


var value: float:
	get():
		var return_value = value
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
		return return_value


func add_modifier(mod_name:String, mod: Modification) -> void:
	mod.creation_time = Time.get_unix_time_from_system()
	modifications[mod_name] = mod


func remove_modifier(mod_name) -> void:
	modifications.erase(mod_name)


func _process(_delta: float) -> void:
	for key in modifications.keys():
			var el = modifications[key]
			if Time.get_unix_time_from_system() > el.creation_time + el.duration:
				remove_modifier(key)
