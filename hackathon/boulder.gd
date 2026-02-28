extends RigidBody2D

@export var damage: int = 25
@export var launch_force: Vector2 = Vector2(300, -100)

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var explode_after: float = 2.0
var has_exploded := false

#func _ready() -> void:
	#apply_central_impulse(launch_force)
	#contact_monitor = true
	#max_contacts_reported = 4
	#connect("body_entered", _on_body_entered)
	#sprite.play("roll")  # your rolling animation

#func _on_body_entered(body: Node) -> void:
	#if has_exploded:
		#return
#
	#if body.is_in_group("player"):
		#body.die()
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.die()
		
	# Explode on hitting ground OR player
	explode()
	
func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	connect("body_entered", _on_body_entered)  # must explicitly connect
	apply_central_impulse(launch_force)
	sprite.play("roll")

	await get_tree().create_timer(explode_after).timeout
	explode()

func explode() -> void:
	freeze = true
	sprite.play("explode")
	$Explode.play()
	sprite.animation_finished.connect(queue_free, CONNECT_ONE_SHOT)
