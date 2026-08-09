extends CharacterBody3D

@onready var nav = $NavigationAgent3D
@onready var idle_timer = $IdleTimer


## STATE MACHINE
enum State {
	IDLE,
	PATROL,
	CHASE
}

## VARIABLES 
var patrol_speed = 3.0
var chase_speed = 5.0
var current_state:= State.PATROL


## METHODS
func _ready() -> void:
	velocity = Vector3.ZERO
	change_state(State.IDLE)


func can_see_player() -> bool:
	return true


func calculate_patrol_direction() -> Vector3:
	return Vector3.ZERO


func calculate_target_direction() -> Vector3:
	var next_location = nav.get_next_path_position()
	var current_location = global_transform.origin
	var new_direction = (next_location - current_location).normalized()
	return new_direction


# State methods
func _exit_state(state: State):
	if state == State.IDLE:
		idle_timer.stop()


# ADD ANIMATIONS
func _enter_state(state: State):
	match state:
		State.IDLE:
			idle_timer.start()
		State.PATROL:
			pass
		State.CHASE:
			pass


func change_state(next_state: State):
	if current_state == next_state:
		return

	_exit_state(current_state)
	current_state = next_state
	_enter_state(next_state)


func _state_idle(_delta):
	velocity.x = 0.0
	velocity.z = 0.0

	if can_see_player():
		change_state(State.CHASE)


func _state_patrol(_delta):
	var direction = calculate_patrol_direction()

	velocity.x = direction.x * patrol_speed
	velocity.z = direction.z * patrol_speed

	if can_see_player():
		change_state(State.CHASE)


func _state_chase(_delta):
	if not can_see_player():
		change_state(State.PATROL)
		return

	var direction = calculate_target_direction()
	var new_velocity = Vector3(direction.x, 0.0, direction.z) * chase_speed

	var horizontal_velocity = Vector3(velocity.x, 0.0, velocity.z)
	horizontal_velocity = horizontal_velocity.move_toward(new_velocity, 0.25)

	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z


func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			_state_idle(delta)
		State.PATROL:
			_state_patrol(delta)
		State.CHASE:
			_state_chase(delta)
		
	# Handle gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		if velocity.y < 0.0:
			velocity.y = 0.0

	look_at(position - velocity)

	move_and_slide()


func target_position(target):
	nav.target_position = target


func _on_idle_timer_timeout() -> void:
	if current_state == State.IDLE:
		change_state(State.PATROL)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		get_tree().change_scene_to_file("res://Scenes/DeathScreen.tscn")
