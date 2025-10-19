extends CharacterBody3D

@export var acceleration := 15.0
@export var brake_force := 25.0
@export var max_speed := 20.0
@export var turn_speed := 2.0
@export var friction := 4.0

var direction_angle := 0.0

func _physics_process(delta: float) -> void:
	handle_input(delta)
	move_and_slide()

func handle_input(delta: float) -> void:
	var accel_input := Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	var steer_input := Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	# Forward vector (bicycle faces -Z)
	var forward := -transform.basis.z

	# Steering — only when moving a bit
	if velocity.length() > 0.5:
		rotate_y(-steer_input * turn_speed * delta)

	# Acceleration & braking
	if accel_input > 0.0:
		velocity += forward * acceleration * accel_input * delta
	elif accel_input < 0.0:
		velocity -= velocity.normalized() * brake_force * abs(accel_input) * delta

	# Clamp top speed
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	# Apply friction when no input
	if accel_input == 0.0:
		velocity = velocity.move_toward(Vector3.ZERO, friction * delta)

	# Apply gravity if needed
	if not is_on_floor():
		velocity.y -= 9.8 * delta
