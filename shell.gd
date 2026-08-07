extends Area3D

## CONSTANTS

## VARIABLES

## METHODS

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.inc_score()
		queue_free()

