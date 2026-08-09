extends CharacterBody3D

@onready var nav = $NavigationAgent3D

var speed = 3.5

var angle_cone_of_vision := deg_to_rad(30.0)
var max_view_distance := 800.0
var angle_between_rays := deg_to_rad(5.0)
var current_target: Node3D = null

func _ready() -> void:
	generate_raycasts()

func generate_raycasts() -> void:
	var ray_count : int = int(angle_cone_of_vision / angle_between_rays)

	for index in ray_count:
		var ray := RayCast3D.new()
		ray.add_exception(self) # Avoiding collision with itself
		ray.position.y = 1.5 # Fix ray position
		
		var angle := angle_between_rays * (index - ray_count / 2.0)
		var direction := Vector3.FORWARD.rotated(Vector3.UP, angle)
		ray.target_position = direction * max_view_distance
		add_child(ray)
		ray.enabled = true
		
func _physics_process (delta: float):
	# Applying gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Check raycast collision on player
	var seen_player: Node3D = null
	for child in get_children():
		if child is RayCast3D and child.is_colliding():
			var collider = child.get_collider()
			if collider and collider.is_in_group("player"):
				seen_player = collider
				break # Player is found. stop checking
	# Chase logic + music activation
	if seen_player != null:
		if current_target != seen_player:
			current_target = seen_player
			if "is_being_chased" in current_target:
				current_target.is_being_chased = true # Music activation
		nav.target_position = current_target.global_position
	else: 
		if current_target != null:
			if "is_being_chased" in current_target:
				current_target.is_being_chased = false # Deactivate music
			current_target = null
	if current_target != null and not nav.is_navigation_finished():
		var next_location = nav.get_next_path_position()
		var current_location = global_transform.origin
		var new_velocity = (next_location - current_location).normalized() * speed
		velocity.x = move_toward(velocity.x, new_velocity.x, 0.25)
		velocity.z = move_toward(velocity.z, new_velocity.z, 0.25)
	else: 
	# Stop if player lost
		velocity.x = move_toward(velocity.x, 0.0, 0.25)
		velocity.z = move_toward(velocity.z, 0.0, 0.25)
		move_and_slide()
