extends Area2D

@export var max_distance: float = 2000  # Max X position before destroying the bullet
@export var SPEED = 800

var dir: int  # Direction: 1 for right, -1 for left
var spawnPos: Vector2
var spawnRot: float
var velocity: Vector2

func _ready():
	global_position = spawnPos
	global_rotation = spawnRot

func _physics_process(delta: float) -> void:
	# Horizontal movement only
	velocity = Vector2(SPEED * dir, 0)  # Only move horizontally, no vertical movement
	global_position += velocity * delta  # Move the bullet by its velocity
		# Destroy the bullet if it exceeds a certain X position
	if abs(global_position.x) > max_distance:
		queue_free()  # Destroy the bullet
