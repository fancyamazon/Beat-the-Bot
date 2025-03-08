extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -450.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var can_double_jump = true

#dashing------
var DASH_SPEED = 800.0
var DASH_DURATION = 0.2
var DASH_COOLDOWN = 0.5

var is_dashing = false
var can_dash = true
var dash_direction = Vector2.ZERO
var dash_timer = 0.0
@onready var timer = $DashTimer  # Get the Timer node

#grapple----
var GRAPPLE_LENGTH = 200.0  # Adjust as needed
@onready var grapple_point = null #point where the player is grappling to
var is_grappling = false

#make it globally known that this is the player
func _ready():
	add_to_group("player")
	
#health
var health = 100

func _physics_process(delta: float) -> void:
	#animations
		

	# Dash
	if Input.is_action_just_pressed("dash") and not is_dashing:
		dash_direction = Vector2(velocity.x, 0).normalized()#velocity.normalized()  # Get direction of movement

		# Check if the player isn't moving (using a threshold for precision)
		if dash_direction.length() < 0.1:  # Effectively not moving
			
			if animated_sprite_2d.flip_h:  # Facing left (scale.x < 0)
				dash_direction = Vector2(-1, 0)  # Dash left
			else:  # Facing right (scale.x > 0)
				dash_direction = Vector2(1, 0)   # Dash right
	
	

		is_dashing = true
		dash_timer = DASH_DURATION

	if is_dashing:
		velocity.y = 0 #no grav/fall during dash
		velocity = dash_direction * DASH_SPEED
		#print(animated_sprite_2d.animation.is_p)
		
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			# Add a small cooldown if you want
			#await get_tree().create_timer(0.2).finished #example cooldown
	#grapple
	if Input.is_action_just_pressed("grapple"):  # Replace "grapple" with your action name
		if not is_grappling:
			_start_grapple()
		else:
			_stop_grapple()

	if is_grappling:
		_update_grapple(delta)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Mid-Air Jump
	if Input.is_action_just_pressed("jump") and can_double_jump:
		velocity.y = JUMP_VELOCITY
		can_double_jump = false # Disable until player lands

	# Reset mid-air jump when on the floor
	if is_on_floor():
		can_double_jump = true
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	#animation facing direction
	if direction >0:
		animated_sprite_2d.flip_h=false
	elif direction<0:
		animated_sprite_2d.flip_h=true

	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 50)

	move_and_slide()
	
	if is_dashing:
		animated_sprite_2d.play("dash")
	elif not is_on_floor():
		animated_sprite_2d.play("jumping")
	elif (velocity.x > 1 || velocity.x < -1):
		animated_sprite_2d.play("running")
	elif Input.is_action_pressed("crouch"):  # Check for crouch FIRST
		animated_sprite_2d.animation = "crouch"
	else:
		animated_sprite_2d.play("idle")
	
func _start_grapple():
	var mouse_pos = get_global_mouse_position()
	grapple_point = mouse_pos #for now, just grapple to mouse position
	is_grappling = true

func _update_grapple(delta):
	# Calculate direction to grapple point
	var grapple_direction = (grapple_point - global_position).normalized()

	# Apply force towards grapple point (you might want to tune this)
	velocity = grapple_direction * 400 #example force

func _stop_grapple():
	is_grappling = false
	grapple_point = null #release grapple point
	# You might want to add some swing/momentum handling here

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		print("Enemy died")
	else:
		print("Enemy health left: ", health)
