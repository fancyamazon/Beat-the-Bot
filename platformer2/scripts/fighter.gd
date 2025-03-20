class_name Fighter extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -450.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var jumps_used = 0
var JUMPS_MAX = 2

#var team = 0
#var can_double_jump = true

var facing_dir: int=1
var direction = 0 

var strafe_direction

#dashing------
var DASH_SPEED = 800.0
var DASH_DURATION = 0.2
var DASH_COOLDOWN = 0.5

var can_move=true

var is_dashing = false
#var current_action = "idle"

#dash
var can_dash = true
var dash_direction = Vector2.ZERO
var dash_timer = 0.0
@onready var timer: Timer = $DashTimer # Get the Timer node 

#cooldowns
var on_attack_cooldown = false
var on_dash_cooldown = false
var attack_cooldown = 0.5 # seconds
@onready var attack_timer: Timer = $AttackTimer

var RANGED_START=0.5
@onready var ranged_charge_timer: Timer=$ranged_charge_timer


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

# ------------------------------ BEGIN FUNCTIONS ---------------------------------- #
#make it globally known that this is the player

func get_team():
	return "player"

func _ready():

	add_to_group(get_team())
	$AnimatedSprite2D/PlayerHurtBox.add_to_group("hurtbox")
	#$AnimatedSprite2D/PlayerHitBox.add_to_group("hitbox")
	health_bar._init_health(health)
	if is_in_group("player"):
		print("player")
		health_bar.position.x = 200
	else:
		print("bot")
		health_bar.position.x = 700
	
func action_dash():
	if (not is_dashing) and (not on_dash_cooldown):
		animated_sprite_2d.play("dash")
		on_dash_cooldown = true
		dash_direction = Vector2(velocity.x, 0).normalized()#velocity.normalized()  # Get direction of movement

			# Check if the player isn't moving (using a threshold for precision)
		if dash_direction.length() < 0.1:  # Effectively not moving
				
			if animated_sprite_2d.scale.x == -2:  # Facing left (scale.x < 0)
				dash_direction = Vector2(-1, 0)  # Dash left
			else:  # Facing right (scale.x > 0)
				dash_direction = Vector2(1, 0)   # Dash right
		is_dashing = true
		dash_timer = DASH_DURATION
		
		#print('dashed')
		timer.start(DASH_COOLDOWN)
		#print(timer.time_left)

func action_jump():
	if(can_move):
		if jumps_used < JUMPS_MAX:
			#print("jumping...")
			#print("currently " + str(jumps_used))
			animated_sprite_2d.play("jumping")
			velocity.y = JUMP_VELOCITY
			jumps_used += 1
			#print("now " + str(jumps_used))
func _physics_process(delta: float) -> void:
	#animations
	# Dash
	if is_on_floor() and jumps_used >0:
		#print("RESET!")
		jumps_used = 0
		animated_sprite_2d.play("jumping-landing")
	

	if not is_on_floor():
		velocity += get_gravity() * delta
	
	decide_actions()
	
	if timer.time_left != 0:
		print(timer.time_left)


	
	if is_dashing:
		velocity.y = 0 #no grav/fall during dash
		velocity = dash_direction * DASH_SPEED
		#print(animated_sprite_2d.animation.is_p)
		
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false

	
	set_sprite(direction)
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 50)
	
	if(!can_move):
		velocity.x=0
	move_and_slide()

	
func action_strafe(input_dir: int):
	if not can_move:
		return

	if input_dir == 0:
		if strafe_direction != 0:
			animated_sprite_2d.play("idle") #or a strafe idle animation
		strafe_direction = 0
	else:
		if strafe_direction == 0:
			animated_sprite_2d.play("running") #or a strafe running animation
		strafe_direction = input_dir

	# Apply velocity based on input_dir, but without flipping the sprite
	velocity.x = 1.5*input_dir * SPEED #move speed is a variable
	#velocity = move_and_slide(velocity, Vector2.UP) #or however you apply velocity




func action_walk(input_dir: int):
	if(!can_move):
		return
	if input_dir == 0 && direction != 0:
		animated_sprite_2d.play("idle")
	elif input_dir != 0 && direction == 0:
		animated_sprite_2d.play("running")
	direction = input_dir
	
func set_sprite(direction: int):
	if direction >0:
		facing_dir=1
		spawn_offset= Vector2(20, -20)
		animated_sprite_2d.scale.x=2
	elif direction<0:
		facing_dir=-1
		spawn_offset= Vector2(20, 20)
		animated_sprite_2d.scale.x=-2

func take_damage(amount: int) -> void:
	health -= amount
	health_bar.health = health
	if health <= 0:
		get_tree().reload_current_scene()
	#else:
	#	print("Player health left: ", health)

func action_melee(): 
	if not on_attack_cooldown:
		animated_sprite_2d.play("melee-attack-uncharged")
		$AnimatedSprite2D/PlayerHitBox.monitoring = true
		on_attack_cooldown = true
		attack_timer.start(attack_cooldown)
	
func _on_attack_timer_timeout() -> void:
	$AnimatedSprite2D/PlayerHitBox.monitoring = false
	on_attack_cooldown = false


func _on_player_hit_box_area_entered(area: Area2D) -> void:
	print("something entered player hitbox: ----\n", area, area.get_groups(), "\n----\n") # this was for debugging
	if area.is_in_group("hurtbox") and area.owner.get_team() != get_team():
		area.owner.take_damage(20)
		
func action_ranged():
	animated_sprite_2d.play("ranged-attack-uncharged")
	var instance = bullet.instantiate()
	instance.dir = facing_dir  # Set the bullet's direction to the last pressed direction
	if get_team() == "player":
		print("player shot")
		#instance.get_node("BulletHitbox").set_collision_layer(7)
		instance.get_node("BulletHitbox").set_collision_mask_value(3, true)
		instance.get_node("BulletHitbox").set_collision_mask_value(2, false)
	else:
		print("bot shot")
		#instance.get_node("BulletHitbox").set_collision_layer(7)
		instance.get_node("BulletHitbox").set_collision_mask_value(2, true)
		instance.get_node("BulletHitbox").set_collision_mask_value(3, false)
	#instance.spawnPos = global_position  # Set the spawn position to the player's position
	instance.spawnPos = global_position + spawn_offset * facing_dir
	instance.spawnRot = rotation  # Set the spawn rotation to the player's rotation (optional)
	main.add_child(instance)  # Add the bullet to the scene

func _on_player_hurt_box_area_entered(area: Area2D) -> void:
	#print("something entered player hurtbox: ----\n", area, area.get_groups(), "\n----\n") # this was for debugging
	if area.is_in_group("hitbox") and area.owner.get_team() != get_team():
		take_damage(5)

func decide_actions():
	pass
	
func action_grapple():
	animated_sprite_2d.play("grappling")
	$grapple_controller.launch()

func action_grapple_retract():
	animated_sprite_2d.play("idle")
	$grapple_controller.retract()


func _on_player_animation_finished() -> void:
	if animated_sprite_2d.animation not in ["grappling", "crouching"]:
		animated_sprite_2d.play("idle") # Replace with function body.

func _on_dash_timer_timeout() -> void:
	on_dash_cooldown = false # Replace with function body.
	print("dash is ready")
#
#func _input(event):
	#if event.is_action_pressed("ranged"):
		#ranged_charge_timer.start(RANGED_START)
		#print("charging started")
		#if(ranged_charge_timer.timeout):
			#_on_charge_timeout()
#
	#if event.is_action_released("ranged"):
		#print("shot")
		#ranged_charge_timer.stop()
		#if can_move == false:
			#can_move = true
		#print("movement enabled")
#
#func _on_charge_timeout():
	#print("charging complete")
	#can_move = false
	#print("movement disabled")
