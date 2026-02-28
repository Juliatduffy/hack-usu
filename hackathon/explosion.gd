extends Node2D

@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var anim: AnimationPlayer = $AnimationPlayer

func play() -> void:
	particles.emitting = true
	anim.play("explode")           # animate a shockwave sprite, screen shake, etc.
	await anim.animation_finished
	queue_free()
