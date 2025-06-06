class_name Fighter extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

### Basic movement abilities
const SPEED = 400.0
const JUMP_VELOCITY = -450.0
const JUMPS_MAX = 2
var jumps_used = 0

### Attack damages
const MELEE_ATTACK_DAMAGE = 30
const RANGED_ATTACK_DAMAGE = 5
const CHARGED_ATTACK_DAMAGE = 35

### Directions
var facing_dir: int = 1
var direction = 0
var strafe_direction

### Movement lock
var movement_locked = false
var can_move = true

### Hitboxes and hurtboxes
@onready var hitbox: Hitbox = $AnimatedSprite2D/Hitbox
@onready var hurtbox: Hurtbox = $AnimatedSprite2D/Hurtbox
@onready var hitbox_collision: CollisionShape2D = $AnimatedSprite2D/Hitbox/CollisionShape2D

### Dash
const DASH_SPEED = 800.0
const DASH_DURATION = 0.2
const DASH_COOLDOWN = 0.5

var is_dashing = false
var dash_direction = Vector2.ZERO
var dash_duration_timer = 0.0
@onready var dash_cooldown_timer: Timer = $DashTimer # Get the Timer node 

### Cooldowns
var on_attack_cooldown = false
var on_dash_cooldown = false
const ATTACK_COOLDOWN = 0.5 # seconds
@onready var attack_timer: Timer = $AttackTimer

@onready var range_timer: Timer = $RangeTimer
const RANGE_COOLDOWN = 0.3
var on_range_cooldown=false

### Charged ranged attacks
@onready var charged_attack_timer: Timer = $ChargedAttackTimer
var charged_status = 0 # 0 = not started, 1 = in the process, 2 = finished
var charging_duration = 1.0 # seconds

### Grappling
const GRAPPLE_LENGTH = 200.0  # Ad$ChargedAttackTimerjust as needed
@onready var grapple_point = null #point where the player is grappling to
@onready var grapple_controller: Node2D = $GrappleController
@onready var grappling_line_2d: Line2D = $GrappleController/Line2D
var is_grappling = false
	
	
### Health and healthbar
var health = 100
@onready var health_bar: ProgressBar = $HealthCanvas/HealthBar
@onready var character_label: Label = $HealthCanvas/CharacterLabel

### Ranged projectile
@onready var main = get_tree().get_root().get_node("Game")
@onready var bullet = load(GAME.SCENEPATH["bullet"])
@export var spawn_offset: Vector2 = Vector2(20, -20)

### Shielding
var is_shielding = false
const SHIELD_REDUCTION = 0.7
const SHIELD_HEALTH = 50
var remaining_shield_health = SHIELD_HEALTH

### Falling through platform while crouching
@onready var collision_shape = $CollisionShape2D
@onready var floor_ray_left: RayCast2D = $FloorRayLeft # Points down at floor from the bottom of the character
@onready var floor_ray_right: RayCast2D = $FloorRayRight
var is_falling_through = false
const FALL_TIMER_SEC = 0.1 # seconds

### Particle/Effects
@onready var gear_particles = $GPUParticles2D

signal on_damage_taken(dmg_amt)
signal on_damage_dealt(dmg_amt)

### Getting held animations like crouch to work
var on_floor_last_frame = true
#first 3 are cancellable
#last 3 are defining (input locked once used)
var held_anims = ["idle", "running", "jumping", "shield", "crouch", "grapple"]
var held_actions = [true, false, false, false, false, false]
# held animations in order of priority
var is_crouching = false

### Bad Manners
var bm = false
var playerDead = false
var doingBM = false

### ------------------------------ BEGIN FUNCTIONS ---------------------------------- ###
# Globally announce that this is the player. 
# Bots override this in their own function

func get_team():
	return "player"

func init_on_behavior_swap(current_health : int, label : String):
	health_bar._init_health(health)
	health = current_health
	health_bar.health = health
	
	character_label.text = label
	
func _ready():	
	# Aligning player/bot healthbars and labels
	if get_team() == "player":
		health_bar.position.x = 200
		character_label.position.x = 200
	else:
		health_bar.position.x = 700
		character_label.position.x = 700
	
	# Set the character label to a bit above the health bar (negative = higher)
	character_label.position.y = health_bar.position.y - 20
	
	# Hitbox initialization
	hitbox.damage = MELEE_ATTACK_DAMAGE # Set the damage of the melee attack
	hitbox_collision.disabled = true
	
	# New instantiation of the material so it doesn't share it across fighter.gd
	if animated_sprite_2d.material:
		animated_sprite_2d.material = animated_sprite_2d.material.duplicate()
	
	# Make sure the grapple controller knows its team
	grapple_controller.team = get_team()

### -------------------------------- PHYSICS, MOVEMENT OV -------------------------------- ### 

func _physics_process(delta: float) -> void:
	if health < 100:
		if get_team() == "bot":
			health += GAME.BOTS_PASSIVE_HEALING
		elif get_team() == "player":
			health += GAME.PLAYER_PASSIVE_HEALING
	health_bar.health = health

	# Dash
	if is_on_floor():
		if jumps_used > 0 and can_move:
		#print("RESET!")
			jumps_used = 0
		if on_floor_last_frame == false and not is_grappling and not is_crouching:
			animated_sprite_2d.play("jumping-landing")
	on_floor_last_frame = is_on_floor()
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	decide_actions()
	set_sprite()
	
	if !movement_locked:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, 50)
	else:
		velocity.x = move_toward(velocity.x, 0, 5)
	
	## NOTE: is_dashing must occur after "velocity.x = direction * SPEED", since dash overrides movement.
	if is_dashing: 
		velocity.y = 0 #no grav/fall during dash
		velocity = dash_direction * DASH_SPEED
		
		dash_duration_timer -= delta
		if dash_duration_timer <= 0:
			is_dashing = false
	
	if(!can_move):
		velocity.x = 0
		
	move_and_slide()

func decide_actions():
	pass

### -------------------------------- MOVEMENT (Dash, Jump, Strafe, Walk, Crouch, TP) -------------------------------- ### 

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
		dash_duration_timer = DASH_DURATION
		
		#print('dashed')
		dash_cooldown_timer.start(DASH_COOLDOWN)
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
	if !can_move or movement_locked:
		return
	if input_dir == 0 and direction != 0:
		animated_sprite_2d.play("idle")
	elif input_dir != 0 and direction == 0:
		animated_sprite_2d.play("running")
	direction = input_dir

func action_crouch():
	if movement_locked:
		return
	movement_locked = true
	is_crouching = true
	
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
			is_falling_through = true
			set_collision_mask_value(1, false)
			
			await get_tree().create_timer(FALL_TIMER_SEC).timeout
			
			set_collision_mask_value(1, true)
			is_falling_through = false

func action_crouch_release():
	is_crouching = false
	movement_locked = false
	animated_sprite_2d.play("crouch-release")

func action_teleport():
	if not GAME.CAN_TELEPORT or movement_locked:
		return
		
	global_position = get_global_mouse_position()
	velocity.y = 0
	jumps_used = 0
	
func action_bad_manner():
	if doingBM:
		return
	
	doingBM = true
	for TIMES in range(5):
		await get_tree().create_timer(0.3).timeout
		action_crouch()
		await get_tree().create_timer(0.3).timeout
		action_crouch_release()
		action_jump()
		await get_tree().create_timer(0.5).timeout
		action_walk(1)
		await get_tree().create_timer(0.15).timeout
		action_walk(-1)
	
### -------------------------------- SPRITE -------------------------------- ### 

func set_sprite():
	if direction > 0:
		facing_dir = 1
		animated_sprite_2d.scale.x = 2
		grappling_line_2d.set_point_position(0, Vector2(21, -44))
	elif direction < 0:
		facing_dir = -1
		animated_sprite_2d.scale.x = -2
		grappling_line_2d.set_point_position(0, Vector2(-21, -44))

### -------------------------------- DAMAGE (taking damage, melee, ranged, charged, shielding) -------------------------------- ### 

func take_damage(amount: int) -> void:
	var tween=get_tree().create_tween() #for blink effect
	tween.tween_method(set_shader_blink_intensity,1.0,0.0,0.5)
	
	if GAME.INVINCIBILITY:
		return
	
	if(is_shielding):
		# Take less damage when shielded
		remaining_shield_health -= amount*SHIELD_REDUCTION
		if remaining_shield_health > 0:
			health -= amount*(1-SHIELD_REDUCTION)
		else: 
			action_shield_down()
			health -= amount
	else:
		health -= amount
	health_bar.health = health
	#particle effect on hit
	gear_particles.restart()
	gear_particles.emitting=true
	
	if health <= 0 and get_team() == "player":
		#print("player health<0")
		playerDead = true
		player_death()
		
		#bm=true
		#print("fighter" + str(bm))
		#self.set_visible(false)
		#await get_tree().create_timer(3.3).timeout
		#
		#call_deferred("reload_scene")
	elif health <= 0 and get_team() == "bot":
		get_parent().queue_free()
		self.queue_free()
	#else:
	#	print("Player health left: ", health)
	if get_team() == "player":
		on_damage_dealt.emit(0)
		get_parent().get_parent().get_node("Bot").get_node("Fighter").on_damage_dealt.emit(amount)
	else:
		on_damage_taken.emit(amount)
	
	
	# if get_team() == "player" and 

func player_death():
	if playerDead:
		#print("entered player_death")
		bm = true
		can_move = false
		movement_locked = true
		on_attack_cooldown = true
		character_label.visible = false
		health_bar.visible = false
		self.set_visible(false)
		await get_tree().create_timer(3.3).timeout
		call_deferred("reload_scene")

func set_shader_blink_intensity(newValue : float):
	#func for blink effect
	animated_sprite_2d.material.set_shader_parameter("blink_intensity",newValue)

func reload_scene():
	if is_inside_tree():
		get_tree().reload_current_scene()

func action_melee(): 
	if not on_attack_cooldown and can_move:
		animated_sprite_2d.play("melee-attack-uncharged")
		hitbox_collision.disabled = false
		on_attack_cooldown = true
		attack_timer.start(ATTACK_COOLDOWN)
	
func _on_attack_timer_timeout() -> void:
	hitbox_collision.disabled = true
	on_attack_cooldown = false

func _on_dash_timer_timeout() -> void:
	on_dash_cooldown = false # Replace with function body.
	#print("dash is ready")

func action_shield():
	if movement_locked:
		return
	
	if GAME.PLAYER_SHIELD_RESETS_HEALTH:
		health = 100
		health_bar.health = health
	
	animated_sprite_2d.play("shield-idle")
	can_move=false
	movement_locked = true
	is_shielding=true
	remaining_shield_health = SHIELD_HEALTH

func action_shield_down():
	
	animated_sprite_2d.play("shield-break")
	can_move=true
	movement_locked = false
	is_shielding=false

func _on_range_timer_timeout() -> void:
	on_range_cooldown=false
		
func action_ranged():
	if(can_move and not on_range_cooldown):
		animated_sprite_2d.play("ranged-attack-uncharged")
		
		create_bullet(RANGED_ATTACK_DAMAGE, "ranged", get_team())
		
		range_timer.start(RANGE_COOLDOWN)
		
		on_range_cooldown = true

func action_charged_attack():
	if movement_locked:
		return
		
	if charged_status == 0:
		animated_sprite_2d.play("ranged-attack-charging") #REPLACE WITH SHOOTING ANIMATION
		charged_status = 1
		charged_attack_timer.start(charging_duration)
		#print("charging started")
	elif charged_status == 1:
		animated_sprite_2d.play("ranged-attack-charging")
	elif charged_status == 2:
		animated_sprite_2d.play("ranged-attack-held-charge")
		
func action_release_charged_attack():
	if charged_status == 0 || charged_status == 1:
		charged_status = 0
		charged_attack_timer.stop()
	elif charged_status == 2:		
		animated_sprite_2d.play("ranged-attack-charged")
		create_bullet(CHARGED_ATTACK_DAMAGE, "charged", get_team())

		if can_move == false:
			can_move = true
		charged_status = 0
		# TODO: reset animation

func _on_charged_attack_timer_timeout() -> void:
	charged_status = 2
	#print("charging complete")
	can_move = false
	#print("movement disabled")

func create_bullet(damage, type, team) -> void:
	var instance = bullet.instantiate()
	
	# Need to set properties before adding to scene so it shows
	instance.dir = facing_dir  # Set to the last pressed direction
	instance.spawnPos = global_position + Vector2(spawn_offset.x * facing_dir, spawn_offset.y)
	instance.spawnRot = rotation  # Set to the player's rotation (optional)
	
	# Need to add to scene FIRST before initializing
	main.add_child(instance)

	instance.initiateBullet(damage, type, team)

### -------------------------------- GRAPPLING -------------------------------- ### 
	
func action_grapple(target: Vector2):
	if(can_move):
		animated_sprite_2d.play("grappling")
		grapple_controller.launch(target)
		movement_locked = true
	is_grappling = true

func action_grapple_retract():
	if(can_move):
		animated_sprite_2d.play("idle")
		grapple_controller.retract()
		movement_locked = false
	is_grappling = false

func action_grapple_deferred():
	action_grapple(get_global_mouse_position())
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation not in ["grappling", "shield-idle", "crouch", "running", "idle"]:
		if (is_shielding):
			animated_sprite_2d.play("shield-idle")
		elif (is_grappling):
			animated_sprite_2d.play("grappling")
		elif is_crouching:
			animated_sprite_2d.play("crouch")
		elif (direction == 0):
			animated_sprite_2d.play("idle") # Replace with function body.func _on_player_animation_finished() -> void:
		else:
			animated_sprite_2d.play("running")
			
