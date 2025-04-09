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

#
var movement_locked = false

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

#@onready var range_timer: Timer = $RangeTimer
#@onready var range_timer: Timer=$RangeTimer
@onready var range_timer: Timer = $RangeTimer
var range_cooldown=0.3
var on_range_cooldown=false

#var RANGED_START=0.5
#@onready var ranged_charge_timer: Timer=$ranged_charge_timer


#grapple----
var GRAPPLE_LENGTH = 200.0  # Adjust as needed
@onready var grapple_point = null #point where the player is grappling to
var is_grappling = false
var gravity_affected = true
@onready var grappling_line_2d: Line2D = $grapple_controller/Line2D
	
#health and healthbar
var health = 100
@onready var health_bar: ProgressBar = $HealthCanvas/HealthBar
@onready var character_label: Label = $HealthCanvas/CharacterLabel

#ranged projectile----
@onready var main=get_tree().get_root().get_node("Game")
@onready var bullet=load("res://scenes/bullet.tscn")
@export var spawn_offset: Vector2 = Vector2(20, -20)

#shield----
var is_shielding=false
const SHIELD_REDUCTION=0.1
const SHIELD_HEALTH=50
var can_move=true    #cannot move while shielded


#for debugging -- don't die
var dying = false

# ------------------------------ BEGIN FUNCTIONS ---------------------------------- #
#make it globally known that this is the player. bots override this in their own function

func get_team():
	return "player"

func _ready():

	add_to_group(get_team())
	$AnimatedSprite2D/PlayerHurtBox.add_to_group("hurtbox")
	#$AnimatedSprite2D/PlayerHitBox.add_to_group("hitbox")d
	health_bar._init_health(health)
	if is_in_group("player"):
		print("aligning <player> healthbar + label")
		health_bar.position.x = 200
		character_label.position.x = 200
	else:
		print("aligning <bot> healthbar + labelbot")
		health_bar.position.x = 700
		character_label.position.x = 700
	character_label.position.y = health_bar.position.y-20
	
func action_dash():
	if can_move and (not is_dashing) and (not on_dash_cooldown) and !movement_locked:
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
	if(can_move and not movement_locked):
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
	if is_on_floor() and jumps_used >0 and can_move:
		#print("RESET!")
		jumps_used = 0
		animated_sprite_2d.play("jumping-landing")
	

	if not is_on_floor() and gravity_affected:
		velocity += get_gravity() * delta
	
	decide_actions()
	


	
	if is_dashing:
		velocity.y = 0 #no grav/fall during dash
		velocity = dash_direction * DASH_SPEED
		#print(animated_sprite_2d.animation.is_p)
		
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false

	
	set_sprite(direction)
	
	if !movement_locked:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, 50)
	
	if(!can_move):
		velocity.x=0
	move_and_slide()

	
func action_strafe(input_dir: int):
	if not can_move or movement_locked:
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
	velocity.x = 3*input_dir * SPEED #move speed is a variable
	#velocity = move_and_slide(velocity, Vector2.UP) #or however you apply velocity




func action_walk(input_dir: int):
	direction = input_dir
	
	if(!can_move or movement_locked):
		return
	if input_dir == 0 && direction != 0:
		animated_sprite_2d.play("idle")
	elif input_dir != 0 && direction == 0:
		animated_sprite_2d.play("running")
	
	
func set_sprite(direction: int):
	if direction >0:
		facing_dir=1
		spawn_offset= Vector2(20, -20)
		animated_sprite_2d.scale.x=2
		grappling_line_2d.set_point_position(0, Vector2(21, -44))
	elif direction<0:
		facing_dir=-1
		spawn_offset= Vector2(20, 20)
		animated_sprite_2d.scale.x=-2
		grappling_line_2d.set_point_position(0, Vector2(-21, -44))

func take_damage(amount: int) -> void:
	if(is_shielding):
		#take less damage when shileded, SHIELD_REDUCTION set at the top
		health -= amount*SHIELD_REDUCTION
	else:
		health -= amount
	health_bar.health = health
	if health <= 0 && is_in_group("player"):
		get_tree().reload_current_scene()
	elif health <= 0 && is_in_group("bot"):
		self.queue_free()
	#else:
	#	print("Player health left: ", health)

func action_melee(): 
	if not on_attack_cooldown and can_move:
		animated_sprite_2d.play("melee-attack-uncharged")
		$AnimatedSprite2D/PlayerHitBox.monitoring = true
		on_attack_cooldown = true
		attack_timer.start(attack_cooldown)
	
func _on_attack_timer_timeout() -> void:
	$AnimatedSprite2D/PlayerHitBox.monitoring = false
	on_attack_cooldown = false
	
func _on_range_timer_timeout() -> void:
	on_range_cooldown=false


func _on_player_hit_box_area_entered(area: Area2D) -> void:
	print("something entered player hitbox: ----\n", area, area.get_groups(), "\n----\n") # this was for debugging
	if area.is_in_group("hurtbox") and area.owner.get_team() != get_team():
		area.owner.take_damage(20)
		
func action_ranged():
	if(can_move and not on_range_cooldown):
		animated_sprite_2d.play("ranged-attack-uncharged")
		var instance = bullet.instantiate()
		range_timer.start(range_cooldown)
		instance.dir = facing_dir  # Set the bullet's direction to the last pressed direction
		if get_team() == "player":
			#print("player shot")
			#instance.get_node("BulletHitbox").set_collision_layer(7)
			instance.get_node("BulletHitbox").set_collision_layer_value(3, true)
			instance.get_node("BulletHitbox").set_collision_layer_value(2, false)
			instance.get_node("BulletHitbox").set_collision_mask_value(3, true)
			instance.get_node("BulletHitbox").set_collision_mask_value(2, false)
		else:
			#print("bot shot")
			#instance.get_node("BulletHitbox").set_collision_layer(7)
			instance.get_node("BulletHitbox").set_collision_layer_value(2, true)
			instance.get_node("BulletHitbox").set_collision_layer_value(3, false)
			instance.get_node("BulletHitbox").set_collision_mask_value(2, true)
			instance.get_node("BulletHitbox").set_collision_mask_value(3, false)
		#instance.spawnPos = global_position  # Set the spawn position to the player's position
		instance.spawnPos = global_position + spawn_offset * facing_dir
		instance.spawnRot = rotation  # Set the spawn rotation to the player's rotation (optional)
		main.add_child(instance)  # Add the bullet to the scene
		
		on_range_cooldown=true

func _on_player_hurt_box_area_entered(area: Area2D) -> void:
	#print("something entered player hurtbox: ----\n", area, area.get_groups(), "\n----\n") # this was for debugging
	if area.is_in_group("hitbox"):
		take_damage(5)

func decide_actions():
	pass
	
func action_grapple():
	if(can_move):
		animated_sprite_2d.play("grappling")
		$grapple_controller.launch()
		#gravity_affected = false
		movement_locked = true

func action_grapple_retract():
	if(can_move):
		animated_sprite_2d.play("idle")
		$grapple_controller.retract()
		gravity_affected = true
		movement_locked = false


func _on_player_animation_finished() -> void:
	if animated_sprite_2d.animation not in ["grappling", "crouching"]:
		animated_sprite_2d.play("idle") # Replace with function body.

func _on_dash_timer_timeout() -> void:
	on_dash_cooldown = false # Replace with function body.
	#print("dash is ready")
	

	
func action_shield():
	animated_sprite_2d.play("shield-idle")
	can_move=false
	is_shielding=true

		
	#if not is_shielding:
		## Start the "shielding up" animation
		#animated_sprite_2d.play("shield-up")
		#is_shielding = true  # Mark that we are now in the shielding-up state
	#elif is_shielding and not shield_up:
		## If the shielding-up animation has finished and we are still holding the shield
		#if animated_sprite_2d.animation == "shield-up" and animated_sprite_2d.animation_position >= animated_sprite_2d.animation_length:
			## Transition to "shield-idle" once the "shielding-up" animation is complete
			#animated_sprite_2d.play("shield-idle")
			#shield_up = true  # Set shield to up state
	#elif shield_up:
		## If the shield button is released, reset to idle animation
		#if not Input.is_action_pressed("shield"):
			#animated_sprite_2d.play("idle")  # Or whatever default idle animation you use
			#is_shielding = false
			#shield_up = false
func action_shield_down():
	animated_sprite_2d.play("shield-break")
	can_move=true
	is_shielding=false



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
