extends Node2D

### Properties
@export var REST_LENGTH = 0
@export var STIFFNESS = 20.0
@export var DAMPING = 5

### Hit detection
@onready var player := get_parent()
@onready var ray := $RayCast2D
@onready var rope := $Line2D
var target: Vector2

var launched = false

## This is to solve for moving platforms. 
var collider: Object
var offset_from_center: Vector2 # how far it is from the center of the platform

func _ready():
	rope.hide()

func _physics_process(delta: float) -> void:
	if launched:
		handle_grapple(delta)

func _process(delta):
	ray.look_at(get_global_mouse_position())
	
	### NOTE -- when this is commented, grapple is ~twice as slow.
	if launched:
		handle_grapple(delta)

func launch():
	if ray.is_colliding():
		launched = true
		target = ray.get_collision_point()
		collider = ray.get_collider()
		if collider is Node2D:
			offset_from_center = target - collider.global_position
		else:
			offset_from_center = Vector2.ZERO

		rope.show()

func retract():
	launched = false
	rope.hide()
	collider = null

func handle_grapple(delta):
	# Handling if the collider disappeared
	if not is_instance_valid(collider):
		retract()
		return
		
	target = collider.global_position + offset_from_center

	var target_dir = player.global_position.direction_to(target)
	var target_dist = player.global_position.distance_to(target)
	
	var displacement = target_dist - REST_LENGTH
	
	var force = Vector2.ZERO
	
	if displacement > 0:
		var spring_force_magnitude = 2000#STIFFNESS * displacement
		var spring_force = target_dir * spring_force_magnitude
		
		var vel_dot = player.velocity.dot(target_dir)
		var damping = -DAMPING * vel_dot * target_dir
		
		force = 2*spring_force + damping

	if displacement < 10 and (abs((force*delta).x) < 5 or abs((force*delta).y) < 5):
		player.velocity = Vector2.ZERO # When near the target and very low speed, stop moving (prevents shakiness)
	else:
		player.velocity += force * delta
	
	update_rope()

func update_rope():
	rope.set_point_position(1, to_local(target))
