extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -450.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var can_double_jump = true

var facing_dir: int=1

#dashing------
var DASH_SPEED = 800.0
var DASH_DURATION = 0.2
var DASH_COOLDOWN = 0.5

var is_dashing = false
var can_dash = true
var dash_direction = Vector2.ZERO
var dash_timer = 0.0
@onready var timer: Timer = $DashTimer # Get the Timer node 

var on_attack_cooldown = false
var attack_cooldown = 0.3 # seconds
@onready var attack_timer: Timer = $AttackTimer

#grapple----
var GRAPPLE_LENGTH = 200.0  # Adjust as needed
@onready var grapple_point = null #point where the player is grappling to
var is_grappling = false
	
#health and healthbar
var health = 100
@onready var health_bar: ProgressBar = $CanvasLayer/HealthBar

#ranged projectile----
@onready var main=get_tree().get_root().get_node("Game")
@onready var bullet=load("res://scenes/bullet.tscn")
@export var spawn_offset: Vector2 = Vector2(20, -20)
#charged range projectile
var charging=false

# ------------------------------ BEGIN FUNCTIONS ---------------------------------- #
#make it globally known that this is the player
func _ready():
	add_to_group("player")
	health_bar._init_health(health)
	
func _physics_process(delta: float) -> void:
	#animations
		

	# Dash
	if Input.is_action_just_pressed("dash") and not is_dashing:
		dash_direction = Vector2(velocity.x, 0).normalized()#velocity.normalized()  # Get direction of movement

		# Check if the player isn't moving (using a threshold for precision)
		if dash_direction.length() < 0.1:  # Effectively not moving
			
			if animated_sprite_2d.scale.x == -2:  # Facing left (scale.x < 0)
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
	##grapple
	#if Input.is_action_just_pressed("grapple"):  # Replace "grapple" with your action name
		#if not is_grappling:
			#_start_grapple()
		#else:
			#_stop_grapple()
#
	#if is_grappling:
		#_update_grapple(delta)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Mid-Air Jump
	if Input.is_action_just_pressed("jump") and can_double_jump:
		velocity.y = JUMP_VELOCITY
		can_double_jump = false # Disable until player lands
	
	# Melee Attack
	if Input.is_action_just_pressed("attack") and not on_attack_cooldown:
		deal_damage()
		
	# ranged attack
	if(Input.is_action_just_released("ranged")):
		_shoot()

	# Reset mid-air jump when on the floor
	if is_on_floor():
		can_double_jump = true
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	#animation facing direction
	
	if direction >0:
		facing_dir=1
		spawn_offset= Vector2(20, -20)
		animated_sprite_2d.scale.x=2
	elif direction<0:
		facing_dir=-1
		spawn_offset= Vector2(20, 20)
		animated_sprite_2d.scale.x=-2

	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 50)

	move_and_slide()
	
	if attack_timer.time_left > 0:
		animated_sprite_2d.play("melee-attack-uncharged")
	elif is_dashing:
		animated_sprite_2d.play("dash")
	#elif on_attack_cooldown:
	#	animated_sprite_2d.play("melee-attack-charging") #yes i know this shouldn't go here
	elif Input.is_action_pressed("grapple"):
		animated_sprite_2d.animation = "grappling" # use for anims that don't repeat
	elif not is_on_floor():
		animated_sprite_2d.play("jumping")
	elif Input.is_action_pressed("ranged"):
		#if(Input.is_action_just_released("ranged")):
		animated_sprite_2d.animation="ranged-attack-uncharged"
			#charging=false
		#else:
			#charging=true
		#
		#if(charging==false):
			#animated_sprite_2d.animation ="ranged-attack-uncharged"
		#else:
			#animated_sprite_2d.animation ="ranged-attack-charging"
			#animated_sprite_2d.animation ="ranged-attack-held-charge"
	elif (velocity.x > 1 || velocity.x < -1):
		animated_sprite_2d.play("running")
	elif Input.is_action_pressed("crouch"):  # Check for crouch FIRST
		animated_sprite_2d.animation = "crouch"
	else:
		animated_sprite_2d.play("idle")
	
	#print(attack_timer.time_left)
	
#func _start_grapple():
	#var mouse_pos = get_global_mouse_position()
	#grapple_point = mouse_pos #for now, just grapple to mouse position
	#is_grappling = true
#
#func _update_grapple(delta):
	## Calculate direction to grapple point
	#var grapple_direction = (grapple_point - global_position).normalized()
#
	## Apply force towards grapple point (you might want to tune this)
	#velocity = grapple_direction * 400 #example force
#
#func _stop_grapple():
	#is_grappling = false
	#grapple_point = null #release grapple point
	## You might want to add some swing/momentum handling here

func take_damage(amount: int) -> void:
	health -= amount
	health_bar.health = health
	if health <= 0:
		print("Player died")
	else:
		print("Player health left: ", health)

func deal_damage(): 
	$AnimatedSprite2D/PlayerHitBox.monitoring = true
	on_attack_cooldown = true
	attack_timer.start(attack_cooldown)
	
func _on_attack_timer_timeout() -> void:
	$AnimatedSprite2D/PlayerHitBox.monitoring = false
	on_attack_cooldown = false

func _on_player_hit_box_area_entered(area: Area2D) -> void:
	#print("something entered player hitbox: ----\n", area, area.get_groups(), "\n----\n") # this was for debugging
	if area.is_in_group("hurtbox"):
		area.owner.take_damage(5)
		
func _shoot():
	var instance = bullet.instantiate()
	instance.dir = facing_dir  # Set the bullet's direction to the last pressed direction
	#instance.spawnPos = global_position  # Set the spawn position to the player's position
	instance.spawnPos = global_position + spawn_offset * facing_dir
	instance.spawnRot = rotation  # Set the spawn rotation to the player's rotation (optional)
	main.add_child(instance)  # Add the bullet to the scene

func _on_player_hurt_box_area_entered(area: Area2D) -> void:
	#print("something entered player hurtbox: ----\n", area, area.get_groups(), "\n----\n") # this was for debugging
	if area.is_in_group("hitbox"):
		take_damage(5)
