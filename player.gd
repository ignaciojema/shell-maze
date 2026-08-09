extends CharacterBody3D

@onready var nav: NavigationAgent3D = $NavigationAgent3D

var speed := 3.5

# Cono de visión ampliado a 120 grados para evitar perder de vista al jugador al girar
var angle_cone_of_vision := deg_to_rad(120.0)
var max_view_distance := 80.0
var angle_between_rays := deg_to_rad(6.0)
var current_target: Node3D = null

func _ready() -> void:
	generate_raycasts()
	# Esperar un frame de físicas para que NavigationServer3D se sincronice
	await get_tree().physics_frame

func generate_raycasts() -> void:
	var ray_count : int = int(angle_cone_of_vision / angle_between_rays)

	for index in ray_count:
		var ray := RayCast3D.new()
		ray.add_exception(self)
		ray.position.y = 1.2 # Altura de los ojos
		
		var angle := angle_between_rays * (index - ray_count / 2.0)
		var direction := Vector3.FORWARD.rotated(Vector3.UP, angle)
		
		ray.target_position = direction * max_view_distance
		add_child(ray)
		ray.enabled = true

func _physics_process(delta: float) -> void:
	# 1. Aplicar gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Comprobar si algún rayo detecta al jugador
	var seen_player: Node3D = null
	for child in get_children():
		if child is RayCast3D and child.is_colliding():
			var collider = child.get_collider()
			if collider and collider.is_in_group("player"):
				seen_player = collider
				break

	# 3. Lógica de persecución y audio
	if seen_player != null:
		if current_target != seen_player:
			current_target = seen_player
			print("¡Monstruo detectó al jugador!")
			if "is_being_chased" in current_target:
				current_target.is_being_chased = true
		
		nav.target_position = current_target.global_position
	else:
		if current_target != null:
			print("Monstruo perdió de vista al jugador.")
			if "is_being_chased" in current_target:
				current_target.is_being_chased = false
			current_target = null

	# 4. Movimiento y rotación del monstruo
	if current_target != null and not nav.is_navigation_finished():
		var next_location = nav.get_next_path_position()
		var current_location = global_position
		var dir = (next_location - current_location)
		dir.y = 0
		
		if dir.length() > 0.1:
			var new_velocity = dir.normalized() * speed
			velocity.x = move_toward(velocity.x, new_velocity.x, 0.25)
			velocity.z = move_toward(velocity.z, new_velocity.z, 0.25)
			
			# Rotar suavemente al monstruo hacia donde camina
			var target_rotation = atan2(-dir.x, -dir.z)
			rotation.y = lerp_angle(rotation.y, target_rotation, delta * 8.0)
	else:
		velocity.x = move_toward(velocity.x, 0.0, 0.25)
		velocity.z = move_toward(velocity.z, 0.0, 0.25)

	move_and_slide()
