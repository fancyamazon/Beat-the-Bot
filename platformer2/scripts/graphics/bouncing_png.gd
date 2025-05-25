extends CharacterBody2D

## Goal: Randomly spawn in the PNG, and have it bounce across the screen

var rng = RandomNumberGenerator.new()

const SPEED := 300.0  # pixels per second

func _ready() -> void:
	# Places the bouncing PNG at a random position
	rng.randomize()
	var random_x = rng.randi_range(0, 500)
	var random_y = rng.randi_range(0, 700)

	global_position = Vector2(random_x, random_y)
	
	# Gives it a random velocity
	var random_angle = rng.randf() * TAU
	velocity = Vector2(cos(random_angle), sin(random_angle)).normalized() * SPEED
	
func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())
