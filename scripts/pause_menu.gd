extends Control

var button_type = null

func _ready():
	$AnimationPlayer.play("RESET")
	hide()

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("Blur")
	await $AnimationPlayer.animation_finished
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func paused():
	
	show()
	get_tree().paused = true
	$AnimationPlayer.play("Blur")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func testEsc():
	if Input.is_action_just_pressed("scape") and get_tree().paused == false:
		paused()
	elif Input.is_action_just_pressed("scape") and get_tree().paused == true:
		resume()
	
func _on_resume_pressed() -> void:
	resume()
func _on_restart_pressed() -> void:
	resume()
	get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	button_type = "MainMenu"
	$ColorRect.show()
	$ColorRect/Fade_Timer.start()
	$ColorRect/AnimationPlayer.play("fade_in")

func _process(_delta):
	testEsc()

func _on_fade_timer_timeout() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
