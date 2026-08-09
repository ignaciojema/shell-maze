extends CharacterBody3D


@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var timer = $Timer
@onready var walk_audio = $WalkAudio
@onready var run_audio = $RunAudio
@onready var stamina_bar = $ProgressBar

## CONSTANTS
const WALK_SPEED = 1.2
const SPRINT_SPEED = 4.1
const INERTIA_COEF = 7.0
const SENSITIVITY = 0.003
const MAX_STAMINA = 100.0

## VARIABLES
var alive := true
var speed := WALK_SPEED
var stamina := MAX_STAMINA
var can_regen := false
var depleting_speed := 10.0
var recovering_speed := 10.0
var score := 0
var audio_blend := 0.0
var tilt_duration:= 0.0

@export var tilt_speed:= 7.0
@export var tilt_amount := 0.4
@export var audio_transition_speed := 5.0

## METHODS
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)	# Hide mouse
	Engine.max_fps = 60
	walk_audio.play()
	run_audio.play()
	
	walk_audio.volume_db = 0.0
	run_audio.volume_db = 0.0

func inc_score():
	score += 1


# Handle camera rotation
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle sprint
	var is_sprinting := Input.is_action_pressed("sprint") && stamina > 0
		
	if is_sprinting:
		speed = SPRINT_SPEED
		stamina -= depleting_speed * delta
	else:
		speed = WALK_SPEED
	
	# Regen stamina
	if can_regen:
		stamina += recovering_speed * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction: Vector3 = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Is the player actually moving?
	var is_moving: bool = direction.length() > 0.01
	
	# Audio crossfade
	if is_moving && is_sprinting:
		audio_blend = lerp(audio_blend, 1.0, delta * audio_transition_speed)
	elif is_moving:
		audio_blend = lerp(audio_blend, 0.0, delta * audio_transition_speed)
	else:
		audio_blend = lerp(audio_blend, 0.0, delta * audio_transition_speed)
	
	# Apply audio volumes
	if is_moving:
		walk_audio.volume_db = lerp(0.0, -80.0, audio_blend)
		run_audio.volume_db = lerp(-80.0, 0.0, audio_blend)
	else: 
		walk_audio.volume_db = lerp(walk_audio.volume_db, -80.0, delta * audio_transition_speed)
		run_audio.volume_db = lerp(run_audio.volume_db, -80.0, delta * audio_transition_speed)
	
	# Check movement to reset timer
	if input_dir != Vector2.ZERO:
		timer.start()
		can_regen = false

	if direction:
		tilt_duration += delta * tilt_speed
		
		camera.rotation_degrees.z = sin(tilt_duration) * tilt_amount
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		tilt_duration = 0.0 
		camera.rotation.z = lerp(camera.rotation.z, 0.0, delta * tilt_speed)
		velocity.x = lerp(velocity.x, direction.x * speed, delta * INERTIA_COEF)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * INERTIA_COEF)

	stamina = clamp(stamina, 0, MAX_STAMINA)
	stamina_bar.value = stamina

	move_and_slide()


# Handle stamina regen cooldown
func _on_timer_timeout() -> void:
	can_regen = true
