extends Node2D
var button_type = null

func _on_start_pressed() -> void:
	button_type = "Start"
	$ColorRect.show()
	$ColorRect/Fade_Timer.start()
	$ColorRect/AnimationPlayer.play("fade_in")
	

func _on_credits_pressed() -> void:
	button_type = "Credits"
	$ColorRect.show()
	$ColorRect/Fade_Timer.start()
	$ColorRect/AnimationPlayer.play("fade_in")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_fade_timer_timeout() -> void:
	if button_type == "Start" :
		get_tree().change_scene_to_file("res://Scenes/Arte.tscn")
	elif button_type == "Credits" :
		get_tree().change_scene_to_file("res://Scenes/Credits.tscn")
		
func _ready():
	$FadeOut/AnimationPlayer.play("fade_out")
	await get_tree().create_timer(1.0).timeout
	$FadeOut.hide()
