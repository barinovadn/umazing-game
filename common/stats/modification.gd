extends Resource
class_name Modification

enum Operation {
	decrease,
	increase,
	multiply,
	divide
}

var duration: float = 0
var value: float = 0
var operation: Operation
var creation_time: float
