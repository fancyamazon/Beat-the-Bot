class_name Fighter extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

### Basic movement abilities
const SPEED = 400.0
const JUMP_VELOCITY = -450.0
var JUMPS_MAX = 2
var jumps_used = 0

### Directions
var facing_dir: int = 1
var direction = 0
var strafe_direction

### Movement lockS
var movement_locked = false
var can_move = true

### Dash
var DASH_SPEED = 800.0
var DASH_DURATION = 0.2
var DASH_COOLDOWN = 0.5

var is_dashing = false
var can_dash = true
var dash_direction = Vector2.ZERO
var dash_timer = 0.0
@onready var timer: Timer = $DashTimer # Get the Timer node 

### Cooldowns
var on_attack_cooldown = false
var on_dash_cooldown = false
var attack_cooldown = 0.5 # seconds
@onready var attack_timer: Timer = $AttackTimer

@onready var range_timer: Timer = $RangeTimer
var range_cooldown=0.3
var on_range_cooldown=false

### Charged ranged attacks
@onready var charged_attack_timer: Timer = $ChargedAttackTimer
var charged_status = 0 # 0 = not started, 1 = in the process, 2 = finished
var charging_duration = 1.0 # seconds
var charged_attack_damage = 35

### Grappling
var GRAPPLE_LENGTH = 200.0  # Ad$ChargedAttackTimerjust as needed
@onready var grapple_point = null #point where the player is grappling to
var is_grappling = false
var gravity_affected = true
@onready var grapple_controller: Node2D = $GrappleController
@onready var grappling_line_2d: Line2D = $GrappleController/Line2D
	
### Health and healthbar
var health = 100
@onready var health_bar: ProgressBar = $HealthCanvas/HealthBar
@onready var character_label: Label = $HealthCanvas/CharacterLabel

### Ranged projectile
@onready var main=get_tree().get_root().get_node("Game")
@onready var bullet=load("res://scenes/bullet.tscn")
@export var spawn_offset: Vector2 = Vector2(20, -20)

### Shielding
var is_shielding=false
const SHIELD_REDUCTION=0.1
const SHIELD_HEALTH=50

### Falling through platform while crouching
@onready var collision_shape = $CollisionShape2D
@onready var floor_ray_left: RayCast2D = $FloorRayLeft # Points down at floor from the bottom of the character
@onready var floor_ray_right: RayCast2D = $FloorRayRight
var is_falling_through = false
var fall_timer_sec = 0.1 # seconds

### Dev tools for debugging
var invincibility = false # Unable to die when true

### ------------------------------ BEGIN FUNCTIONS ---------------------------------- ###
# Globally announce that this is the player. 
# Bots override this in their own function

func get_team():
	return "player"

func _ready():
	add_to_group(get_team())
	$AnimatedSprite2D/HurtBox.add_to_group("hurtbox")
	$AnimatedSprite2D/HitBox.add_to_group("hitbox")
	health_bar._init_health(health)
	if is_in_group("player"):
		print("aligning <player> healthbar + label")
		health_bar.position.x = 200
		character_label.position.x = 200
		
		print("aligning <player> collision layers")
		#set_collision_layer_value(3, true)
		set_collision_mask_value(1, true)
		#set_collision_mask_value(3, true)
		$AnimatedSprite2D/HitBox.set_collision_layer_value(2, true)
		$AnimatedSprite2D/HitBox.set_collision_mask_value(2, true)
		$AnimatedSprite2D/HurtBox.set_collision_layer_value(3, true)
		$AnimatedSprite2D/HurtBox.set_collision_mask_value(3, true)

		#print("collision layer is 3 = " + str(get_collision_layer_value(3)))
	else:
		print("aligning <bot> healthbar + labelbot")
		health_bar.position.x = 700
		character_label.position.x = 700
		
		print("aligning <bot> collision layers")
		#set_collision_layer_value(2, true)
		set_collision_mask_value(1, true)
		#set_collision_mask_value(2, true)
		$AnimatedSprite2D/HitBox.set_collision_layer_value(3, true)
		$AnimatedSprite2D/HitBox.set_collision_mask_value(3, true)
		$AnimatedSprite2D/HurtBox.set_collision_layer_value(2, true)
		$AnimatedSprite2D/HurtBox.set_collision_mask_value(2, true)
	
	# Set the character label to a bit above the health bar (negative = higher)
	character_label.position.y = health_bar.position.y-20

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
	#set_sprite(direction)
	
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
		health -= amount*(1-SHIELD_REDUCTION)
	else:
		health -= amount
	health_bar.health = health
	if health <= 0 && is_in_group("player") && !invincibility:
		get_tree().reload_current_scene()
	elif health <= 0 && is_in_group("bot"):
		self.queue_free()
	#else:
	#	print("Player health left: ", health)

func action_melee(): 
	if not on_attack_cooldown and can_move:
		animated_sprite_2d.play("melee-attack-uncharged")
		$AnimatedSprite2D/HitBox.monitoring = true
		on_attack_cooldown = true
		attack_timer.start(attack_cooldown)
	
func _on_attack_timer_timeout() -> void:
	$AnimatedSprite2D/HitBox.monitoring = false
	on_attack_cooldown = false
	
func _on_range_timer_timeout() -> void:
	on_range_cooldown=false


func _on_hit_box_area_entered(area: Area2D) -> void:
	#print("something entered player hitbox: ----\n", area, area.get_groups(), "\n----\n") # this was for debugging
	if area.is_in_group("hurtbox") and area.owner.get_team() != get_team():
		area.owner.take_damage(20)
		
func action_ranged():
	if(can_move and not on_range_cooldown):
		animated_sprite_2d.play("ranged-attack-uncharged")
		var instance = bullet.instantiate()
		instance.team = get_team()
		range_timer.start(range_cooldown)
		instance.dir = facing_dir  # Set the bullet's direction to the last pressed direction
		if get_team() == "player":
			#print("player shot")
			#instance.get_node("BulletHitbox").set_collision_layer(7)
			instance.get_node("BulletHitbox").set_collision_layer_value(2, true)
			instance.get_node("BulletHitbox").set_collision_layer_value(3, false)
			instance.get_node("BulletHitbox").set_collision_mask_value(2, true)
			instance.get_node("BulletHitbox").set_collision_mask_value(3, false)
		else:
			#print("bot shot")
			#instance.get_node("BulletHitbox").set_collision_layer(7)
			instance.get_node("BulletHitbox").set_collision_layer_value(3, true)
			instance.get_node("BulletHitbox").set_collision_layer_value(2, false)
			instance.get_node("BulletHitbox").set_collision_mask_value(3, true)
			instance.get_node("BulletHitbox").set_collision_mask_value(2, false)
		#instance.spawnPos = global_position  # Set the spawn position to the player's position
		instance.spawnPos = global_position + spawn_offset * facing_dir
		instance.spawnRot = rotation  # Set the spawn rotation to the player's rotation (optional)
		main.add_child(instance)  # Add the bullet to the scene
		
		on_range_cooldown=true

func _on_hurt_box_area_entered(area: Area2D) -> void:
	#print("something entered player hurtbox: ----\n", area, area.get_groups(), "\n----\n") # this was for debugging
	#print("hurtbox entered. I'm team" + get_team())
	if area.is_in_group("hitbox") and area.owner.get_team() != get_team():
		take_damage(5)

func decide_actions():
	pass
	
func action_grapple():
	if(can_move):
		animated_sprite_2d.play("grappling")
		grapple_controller.launch()
		#gravity_affected = false
		movement_locked = true

func action_grapple_retract():
	if(can_move):
		animated_sprite_2d.play("idle")
		grapple_controller.retract()
		gravity_affected = true
		movement_locked = false

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation not in ["grappling", "crouching"]:
		animated_sprite_2d.play("idle") # Replace with function body.func _on_player_animation_finished() -> void:

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

func action_charged_attack():
	if charged_status == 0:
		### animated_sprite_2d.play("ranged-attack-uncharged") REPLACE WITH SHOOTING ANIMATION
		charged_status = 1
		charged_attack_timer.start(charging_duration)
		print("charging started")
	elif charged_status == 1 || charged_status == 2:
		pass
		
func action_release_charged_attack():
	if charged_status == 0 || charged_status == 1:
		charged_status = 0
		charged_attack_timer.stop()
		print("charging cancelled")
	elif charged_status == 2:
		print("shot")
		var instance = bullet.instantiate()
		instance.team = get_team()
		instance.bullet_type = 1
		instance.damage_dealt = charged_attack_damage
		instance.dir = facing_dir  # Set the bullet's direction to the last pressed direction
		if get_team() == "player":
			#print("player shot")
			#instance.get_node("BulletHitbox").set_collision_layer(7)
			instance.get_node("BulletHitbox").set_collision_layer_value(2, true)
			instance.get_node("BulletHitbox").set_collision_layer_value(3, false)
			instance.get_node("BulletHitbox").set_collision_mask_value(2, true)
			instance.get_node("BulletHitbox").set_collision_mask_value(3, false)
		else:
			#print("bot shot")
			#instance.get_node("BulletHitbox").set_collision_layer(7)
			instance.get_node("BulletHitbox").set_collision_layer_value(3, true)
			instance.get_node("BulletHitbox").set_collision_layer_value(2, false)
			instance.get_node("BulletHitbox").set_collision_mask_value(3, true)
			instance.get_node("BulletHitbox").set_collision_mask_value(2, false)
		#instance.spawnPos = global_position  # Set the spawn position to the player's position
		instance.spawnPos = global_position + spawn_offset * facing_dir
		instance.spawnRot = rotation  # Set the spawn rotation to the player's rotation (optional)
		main.add_child(instance)  # Add the bullet to the scene
		if can_move == false:
			can_move = true
		print("movement re-enabled")
		charged_status = 0
		# TODO: reset animation

func _on_charged_attack_timer_timeout() -> void:
	charged_status = 2
	print("charging complete")
	can_move = false
	print("movement disabled")

func action_crouch():
	animated_sprite_2d.play("crouch")
	if is_on_floor():
		floor_ray_left.force_raycast_update()
		floor_ray_right.force_raycast_update()
		
		var platform = "None"
		if floor_ray_left.is_colliding():
			platform = floor_ray_left.get_collider()
		if floor_ray_right.is_colliding():
			platform = floor_ray_right.get_collider()
		
		if platform is FallablePlatform:
			print("detected Fallable")
			is_falling_through = true
			set_collision_mask_value(1, false)
			
			await get_tree().create_timer(fall_timer_sec).timeout
			
			print("should be 2sec after")
			set_collision_mask_value(1, true)
			is_falling_through = false
