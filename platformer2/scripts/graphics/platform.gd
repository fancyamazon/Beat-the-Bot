extends AnimatableBody2D
class_name FallablePlatform

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@export var moving: bool

### Moving
@export var SPEED = randi_range(50, 150)
@export var RANGE = randi_range(150, 250)

### Get it to move
var start_position
var direction = -1 if randf() < 0.5 else 1 # Randomly -1 or 1

func _ready():
	start_position = position
	
	# If we set the platform to invisible, it doesn't collide
	if visible == false:
		set_collision_layer_value(1, false)
		set_collision_mask_value(1, false)
	else:
		set_collision_layer_value(1, true)
		set_collision_mask_value(1, true)
		
func _physics_process(delta):
	if moving:
		position.x += SPEED * delta * direction
		# Note that we expanded this code instead of used abs(), because of 
		# Frame glitches where it would infinitely switch directions
		if position.x - start_position.x >= RANGE and direction == 1:
			direction = -1
		elif start_position.x - position.x >= RANGE and direction == -1:
			direction = 1
