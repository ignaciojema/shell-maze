extends Node

@onready var target = $Player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	get_tree().call_group("enemy", "target_position", target.global_transform.origin)
