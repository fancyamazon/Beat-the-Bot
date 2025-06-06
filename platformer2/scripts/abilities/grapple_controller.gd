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

### Far distance, at least the diagonal of the screen
const FAR_DISTANCE = 3000
var team

var launched = false

## This is to solve for moving platforms. 
var collider: Object
var offset_from_center: Vector2 # how far it is from the center of the platform

func get_team():
	return team

func _ready():
	rope.hide()

func _physics_process(delta: float) -> void:
	if launched:
		handle_grapple(delta)

func _process(delta):
	#ray.look_at(get_global_mouse_position())
	
	### NOTE -- when this is commented, grapple is ~twice as slow.
	if launched:
		handle_grapple(delta)

func is_point_on_screen(world_pos: Vector2) -> bool:
	var inv_canvas_xform: Transform2D = get_tree().root.canvas_transform.affine_inverse()
	var viewport_rect: Rect2 = get_viewport().get_visible_rect()

	var upper_left: Vector2 = inv_canvas_xform * Vector2.ZERO
	var lower_right: Vector2 = inv_canvas_xform * viewport_rect.size

	var screen_bounds_world: Rect2 = Rect2(upper_left, lower_right - upper_left)
	return screen_bounds_world.has_point(world_pos)

func launch(looking_at: Vector2):
	#print("Player global position: ", get_global_mouse_position())
	#print("looking_at: ", looking_at)
	#print("Ray beore look_at: ", ray.global_position)
	ray.position.x -= 4 # STRANGE BUG (this line + adding 4 back later fixes it): up close against wall, phase through. 
	var direction = (looking_at - ray.global_position).normalized()
	ray.target_position = ray.to_local(ray.global_position + direction * FAR_DISTANCE)
	ray.force_raycast_update()
	#print("Ray after look_at: ", ray.global_position)
	if ray.is_colliding():
		target = ray.get_collision_point()
		ray.position.x += 4
		
		#print("Target global:", target)
		#print("Canvas inv * target:", get_viewport().get_canvas_transform().affine_inverse() * target)
		#print("Visible rect:", get_viewport().get_visible_rect())
		
		if ((get_team() == "player" and is_point_on_screen(target)) or \
		   (get_team() == "bot" and player.global_position.distance_to(target) < FAR_DISTANCE)) \
			and GAME.GRAPPLE_LIMITED_TO_SCREEN: # Check that the target is within screen bounds
			launched = true
			#print("target is on screen")
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
