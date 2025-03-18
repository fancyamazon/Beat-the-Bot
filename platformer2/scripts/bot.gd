extends Fighter

var attacking = false
var shooting = false
var jumping = true
var jump_this_frame = false

func get_team():
	return "bot"

func decide_actions():
	if jump_this_frame:
		action_jump() # jummping every frame wastes the double jump
		jump_this_frame = false
	if attacking:
		action_melee()
		action_ranged()
	elif shooting:
		action_ranged()
	#if len($AnimatedSprite2D/BotRangedSensor.get_overlapping_areas())>0:
	#	print("HOSTILES DETECTED")
	


func _on_bot_sensor_area_entered(area: Area2D) -> void:
	if area.is_in_group("hurtbox"):
		attacking = true # Replace with function body.


func _on_bot_sensor_area_exited(area: Area2D) -> void:
	if area.is_in_group("hurtbox"):
		attacking = false # Replace with function body.


func _on_bot_ranged_sensor_area_entered(area: Area2D) -> void:
	if area.is_in_group("hurtbox"):
		shooting = true # Replace with function body.

func _on_bot_ranged_sensor_area_exited(area: Area2D) -> void:
	if area.is_in_group("hurtbox"):
		shooting = false # Replace with function body.


func _on_behind_sensor_area_entered(area: Area2D) -> void:
	if area.is_in_group("hurtbox"):
		action_walk(-1 * $AnimatedSprite2D.scale.x)
	#else:
	#	action_walk(0)
		


func _on_behind_sensor_area_exited(area: Area2D) -> void:
	if area.is_in_group("hurtbox"):
		action_walk(0)


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
		#action_walk(1)
		pass
		#action_dash() # bot loves throwing itself off walls
		#if position.x < -1326:
			#action_walk(1)
		#	action_dash() # Replace with function body.
			#action_walk(0)
		#else:
			#action_walk(-1)
		#	action_dash()
			#action_walk(0)
# again, signals mess with physics - bot will not move if action_walk is put like this in a signal
