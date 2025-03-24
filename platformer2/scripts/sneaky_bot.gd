extends Fighter

var attacking = false
var shooting = false
var jumping = true
var jump_this_frame = false

# --------- relating to specifically "sneaky" movement 
var in_sensor = false # player is in sensing range
var sneaking_towards = true # sneaking towards the player
var get_player
var run_away = true
var sneak_towards = false
# ---------

func get_team():
	return "bot"

func decide_actions():
	if jump_this_frame:
		action_jump() # jumping every frame wastes the double jump
		jump_this_frame = false
	if in_sensor:
		decide_movement()
	if attacking:
		action_melee()
		action_ranged()
	elif shooting:
		action_ranged()
	#if len($AnimatedSprite2D/BotRangedSensor.get_overlapping_areas())>0:
	#	print("HOSTILES DETECTED")

func decide_movement():
	# Get to a certain range, away. Sneak slowly back in if already in that range
	var player_x = get_player.global_position.x
	var bot_x = global_position.x
	
	var dist = abs(player_x - bot_x)
	if player_x > bot_x:
		if dist < 50:
			run_away = true
			sneak_towards = false
		elif dist > 150:
			# Bot is significantly to the right: charge melee
			# CHARGE_MELEE()
			run_away = false
			sneak_towards = true
		
		if run_away:
			action_strafe(-1)
		if sneak_towards:
			action_strafe(0.5)
	else:
		if dist < 50:
			run_away = true
			sneak_towards = false
		elif dist > 150:
			# Bot is significantly to the right: charge melee
			# CHARGE_MELEE()
			run_away = false
			sneak_towards = true
		
		if run_away:
			action_strafe(1)
		if sneak_towards:
			action_strafe(-0.5)

	shooting = true
	
func _on_bot_sensor_area_entered(area: Area2D) -> void:
	if area.is_in_group("hurtbox"):
		attacking = true # Replace with function body.


func _on_bot_sensor_area_exited(area: Area2D) -> void:
	if area.is_in_group("hurtbox"):
		attacking = false # Replace with function body.
		
func _on_bot_ranged_sensor_area_entered(area: Area2D) -> void:
	if area.is_in_group("hurtbox"):
		in_sensor = true
		get_player = area

func _on_bot_ranged_sensor_area_exited(area: Area2D) -> void:
	if area.is_in_group("hurtbox"):
		shooting = false # Replace with function body.
		in_sensor = false

func _on_behind_sensor_area_entered(area: Area2D) -> void:
	if area.is_in_group("hurtbox"):
		get_player = area
		in_sensor = true
		action_walk(-1 * $AnimatedSprite2D.scale.x) # flip direction

func _on_behind_sensor_area_exited(area: Area2D) -> void:
	if area.is_in_group("hurtbox"):
		action_walk(0)
		in_sensor = false


func _on_jump_timer_timeout() -> void:
	jumping = not jumping # Replace with function body.

 
func _on_jumptimer_2_timeout() -> void: 
	# putting action_jump in here allows the bot to triple jump
	# because it jumps, but is still on the floor that frame, so it resets its jump
	# DO NOT under ANY circumstances put action_jump() under a signal
	if jumping:
		jump_this_frame = true# Replace with function body.


func _on_above_sensor_area_entered(area: Area2D) -> void:
	if area.is_in_group("hurtbox"):
		pass
