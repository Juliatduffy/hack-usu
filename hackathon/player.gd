extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	
	if $Camera2D.limit_right > get_node("../right_wall").global_position.x:
		$Camera2D.limit_right = int(get_node("../right_wall").global_position.x)
		
	if $Camera2D.limit_left < get_node("../left_wall").global_position.x:
		$Camera2D.limit_left = int(get_node("../left_wall").global_position.x)
		
	if $Camera2D.limit_bottom < get_node("../floor").global_position.y + 1000:
		$Camera2D.limit_bottom = int(get_node("../floor").global_position.y)
		
