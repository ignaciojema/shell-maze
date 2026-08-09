extends CharacterBody3D


@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var timer = $Timer

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

var tilt_duration:= 0.0

@export var tilt_speed:= 7.0
@export var tilt_amount := 0.4

## METHODS
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)	# Hide mouse
	Engine.max_fps = 60

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
	if Input.is_action_pressed("sprint") && stamina > 0:
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
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

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
		$AudioStreamPlayer3D.play()
		velocity.x = lerp(velocity.x, direction.x * speed, delta * INERTIA_COEF)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * INERTIA_COEF)

	stamina = clamp(stamina, 0, MAX_STAMINA)

	move_and_slide()


# Handle stamina regen cooldown
func _on_timer_timeout() -> void:
	can_regen = true
