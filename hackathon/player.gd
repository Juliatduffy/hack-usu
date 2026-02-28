extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite = $AnimatedSprite2D

@onready var dead : bool = false
@onready var duck : bool = false

func _ready():
	add_to_group("player")
	
func die() -> void:
	#print("Player died")
	dead = true
	animated_sprite.play("squish")
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://End.tscn")
	
func _physics_process(delta: float) -> void:
	$normal.disabled = false
	$small.disabled = true
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if dead:
		return
		
	if Input.is_action_pressed("ui_down"):
		if Input.is_action_pressed("ui_left"):
			animated_sprite.play("duck_l")
		else:
			animated_sprite.play("duck_r")
		$normal.disabled = true
		$small.disabled = false
		duck = true
		
	move_and_slide()
	#normally use big hit box
	
	# Handle jump.
	if not duck:
		if Input.is_action_pressed("ui_up") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			if Input.is_action_pressed("ui_left"):
				if animated_sprite.animation != "jump_l":
					animated_sprite.play("jump_l")
			else:
				if animated_sprite.animation != "jump_r":
					animated_sprite.play("jump_r")

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
			
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
		if not is_on_floor():
			velocity += get_gravity() * delta
			
			if Input.is_action_pressed("ui_right"):
				if animated_sprite.animation != "fall_r":
					animated_sprite.play("fall_r")

			if Input.is_action_pressed("ui_left"):
				if animated_sprite.animation != "fall_l":
					animated_sprite.play("fall_l")
		else:
			if Input.is_action_pressed("ui_left"):
				animated_sprite.play("walk_l")
			else:
				animated_sprite.play("walk_r")
					

		move_and_slide()
	
	
	if $Camera2D.limit_right > get_node("../right_wall").global_position.x:
		$Camera2D.limit_right = int(get_node("../right_wall").global_position.x)
		
	if $Camera2D.limit_left < get_node("../left_wall").global_position.x:
		$Camera2D.limit_left = int(get_node("../left_wall").global_position.x)
		
	if $Camera2D.limit_bottom < get_node("../floor").global_position.y + 1000:
		$Camera2D.limit_bottom = int(get_node("../floor").global_position.y)
		
	duck = false
