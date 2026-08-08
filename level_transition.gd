extends CanvasLayer


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in":
		get_tree().change_scene_to_file("res://level_1.tscn")
	else:
		$AnimationPlayer.play("fade_in")
