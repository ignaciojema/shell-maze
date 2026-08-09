extends Node3D

@onready var target = $SubViewportContainer/SubViewport/Player

func _ready():
	$ColorRect/AnimationPlayer.play("fade_out")
	await get_tree().create_timer(1.0).timeout
	$ColorRect.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	get_tree().call_group("enemy", "target_position", target.global_transform.origin)
