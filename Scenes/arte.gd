extends Node2D

func _ready():
	$ColorRect/AnimationPlayer.play("fade_out")
	await get_tree().create_timer(1.0).timeout
	$ColorRect.hide()
