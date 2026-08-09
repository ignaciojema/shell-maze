extends Node2D

var button_type = null

func _on_main_menu_button_pressed() -> void:
	button_type = "Back"
	$ColorRect.show()
	$ColorRect/Fade_Timer.start()
	$ColorRect/AnimationPlayer.play("fade_in")


func _on_fade_timer_timeout() -> void:
	if button_type == "Back" :
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _ready():
	$FadeOut/AnimationPlayer.play("fade_out")
	await get_tree().create_timer(1.0).timeout
	$FadeOut.hide()