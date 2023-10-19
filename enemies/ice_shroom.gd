extends "res://enemies/enemy_base.gd"

@onready var smash_particles = $SmashParticles


func _physics_process(delta):
	super._physics_process(delta)
	if is_attacking and skin.frame == 6 and not smash_particles.emitting:
		smash_particles.restart()
		#smash_particles.emitting = true
