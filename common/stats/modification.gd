class_name Modifier
extends Resource

enum Operation {
	decrease,
	increase,
	multiply,
	divide,
	}

@export var duration: float = 0
@export var value: float = 0
@export var operation: Operation
@export var creation_time: float
