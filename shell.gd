extends Area3D

## CONSTANTS
@onready var audio = $AudioStreamPlayer3D

## VARIABLES

## METHODS

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.inc_score()
		visible = false
		monitoring = false
		audio.play()
		await audio.finished
		queue_free()
