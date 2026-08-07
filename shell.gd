extends Area3D

## CONSTANTS

## VARIABLES

## METHODS

func _on_body_entered(_body: Node3D) -> void:
	Global.score += 1
	queue_free()

