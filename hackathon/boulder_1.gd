extends RigidBody2D

func _ready():
	# Connect the Area2D child's signal to this script
	$Area2D.connect("body_entered", _on_area_body_entered)

func _on_area_body_entered(body: Node2D):
	# Check if the thing we hit is the player
	if body.is_in_group("player"):
		print("Boulder hit the player!")
		body.die()
		queue_free()               # Destroy the boulder on impact
