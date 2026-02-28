extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -600.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var boulder = get_node("boulder_1")

func _ready():
	add_to_group("player")
	
func die():
	animated_sprite.play("squish")
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://End.tscn")
	
func _physics_process(delta: float) -> void:
	move_and_slide()
	#normally use big hit box
	$CollisionShape2D.disabled = false
	$dead_collision.disabled = true
	# Handle jump.
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
		#if velocity.y < 0 and velocity.x > 0:
			#if animated_sprite.animation != "jump_r":
				#animated_sprite.play("jump_r")
#
		#if velocity.y < 0 and velocity.x < 0:
			#if animated_sprite.animation != "jump_l":
				#animated_sprite.play("jump_l")
#
		#if velocity.y > 0 and velocity.x > 0:
			#if animated_sprite.animation != "fall_r":
				#animated_sprite.play("fall_r")
#
		#else:
			#if animated_sprite.animation != "fall_l":
				#animated_sprite.play("fall_l")
	#todo add left looking walk 
	else:
		if Input.is_action_pressed("ui_left"):
			animated_sprite.play("walk_l")
		if Input.is_action_pressed("ui_right"):
			animated_sprite.play("walk_r")
			
	
	#for i in get_slide_collision_count():
		#var collision = get_slide_collision(i)
		#var collider = collision.get_collider()
		#if collider:
			#animated_sprite.play("squish")
		
	move_and_slide()
	
	
	
