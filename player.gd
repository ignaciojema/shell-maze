extends CharacterBody3D


@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var timer = $Timer

## CONSTANTS
const WALK_SPEED = 5.0
const SPRINT_SPEED = 15.0
const INERTIA_COEF = 7.0
const SENSITIVITY = 0.003
const MAX_STAMINA = 100.0

## VARIABLES
var speed = WALK_SPEED
var stamina := MAX_STAMINA
var can_regen := false
var depleting_speed := 10.0
var recovering_speed := 10.0

## FUNCTIONS

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))


func _physics_process(delta: float) -> void:
	print(stamina)

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle sprint
	if Input.is_action_pressed("sprint") && stamina > 0:
		speed = SPRINT_SPEED
		stamina -= depleting_speed * delta
	else:
		speed = WALK_SPEED

	# Handle stamina
	if can_regen == true:
		stamina += recovering_speed * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Check movement
	if input_dir != Vector2.ZERO:
		print("Moving")
		timer.start()
		can_regen = false

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * INERTIA_COEF)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * INERTIA_COEF)

	stamina = clamp(stamina, 0, MAX_STAMINA)

	move_and_slide()


func _on_timer_timeout() -> void:
	can_regen = true
	print("Can regen")
