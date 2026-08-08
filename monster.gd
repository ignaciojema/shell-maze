extends CharacterBody3D

@onready var nav = $NavigationAgent3D

var speed = 3.5

var angle_cone_of_vision := deg_to_rad(30.0)
var max_view_distance := 800.0
var angle_between_rays := deg_to_rad(5.0)

func generate_raycasts() -> void:
	var ray_count := angle_cone_of_vision / angle_between_rays

	for index in ray_count:
		var ray := RayCast2D.new()
		var angle := angle_between_rays * (index - ray_count / 2.0)
		ray.cast_to = Vector2.UP. rotated(angle) * max_view_distance
		add_child(ray)
		ray.enabled = true

#func _physics_process (delta: float):
#	var target = null
#	for ray in get_children():
#		if ray.is_colliding() and ray.get_collider().is_in_group("player"):
#			target = ray.get_collider()
#		break
#
#	var does_see_player := target != null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y -= 2

	var next_location = nav.get_next_path_position()
	var current_location = global_transform.origin
	var new_velocity = (next_location - current_location).normalized() * speed

	velocity = velocity.move_toward(new_velocity, 0.25)

	move_and_slide()

func target_position(target):
	nav.target_position = target
