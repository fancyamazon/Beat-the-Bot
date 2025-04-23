extends Fighter

@onready var nav = get_parent()
@onready var player = get_parent().get_parent().get_node("Player").get_node("Fighter")

var mode = "nav"

func get_team():
	return "bot"

func determine_search_point(player_pos, bot_pos):
	if bot_pos.x < player_pos.x:
		return player_pos + Vector2(-400,0)
	else:
		return player_pos + Vector2(400,0)

func decide_actions():
	nav.search_point = determine_search_point(player.global_position, global_position)
	#print(nav.actions)
	
	if (nav.search_point - global_position).length_squared() > 3600 and mode == "atk":
		mode = "nav"
	if (nav.search_point - global_position).length_squared() < 1600 and mode == "nav":
		mode = "atk"
	
	if mode == "atk":
		if player.global_position.x < global_position.x and facing_dir != -1:
			action_walk(-1)
		elif player.global_position.x > global_position.x and facing_dir != 1:
			action_walk(1)
		else:
			action_walk(0)
	elif mode == "nav":
		action_walk(nav.get_movements()[0])
		if nav.get_movements()[1] > 0:
			action_jump()
	
	if player.global_position.y - global_position.y < 400 and player.global_position.y - global_position.y >= -100:
		action_ranged()

	
	if is_on_floor() and player.global_position.x - global_position.x > -10 and player.global_position.x - global_position.x < 10 and player.global_position.y - global_position.y < 500 and player.global_position.y - global_position.y > -500:
		action_dash()
	
	if (nav.get_vector_to_player().x > -100 and nav.get_vector_to_player().x < 100):
		action_melee()

	


##################################
##########EVERYTHING BELOW IS NOT USED########
#######################################

###########DON'T DELETE - LOGIC WILL BE TRANSLATED##########
#func _on_bot_sensor_area_entered(area: Area2D) -> void:
#	if area.is_in_group("hurtbox"):
#		attacking = true # Replace with function body.


#func _on_bot_sensor_area_exited(area: Area2D) -> void:
#	if area.is_in_group("hurtbox"):
#		attacking = false # Replace with function body.


#func _on_bot_ranged_sensor_area_entered(area: Area2D) -> void:
	#if area.is_in_group("hurtbox"):
		#shooting = true # Replace with function body.
		
#func _on_bot_ranged_sensor_area_entered(area: Area2D) -> void:
#	#print(area)
#	if area.is_in_group("hurtbox"):
#		var player_x = area.global_position.x
#		var bot_x = global_position.x
#
#		if player_x > bot_x:
#			# Player is to the right, strafe left
#			action_strafe(-1)
#		else:
#			# Player is to the left, strafe right
#			action_strafe(1)
#
#		shooting = true
#	elif(area.is_in_group("hitbox")):
#		print(area)
#		action_shield()
#
#
#func _on_bot_ranged_sensor_area_exited(area: Area2D) -> void:
#	if area.is_in_group("hurtbox"):
#		shooting = false # Replace with function body.
#		
#	elif(area.is_in_group("hitbox")):
#		action_shield_down()


#func _on_behind_sensor_area_entered(area: Area2D) -> void:
	#if area.is_in_group("hurtbox"):
		#action_walk(-1 * $AnimatedSprite2D.scale.x)
	##else:
	##	action_walk(0)
		#

#func _on_behind_sensor_area_entered(area: Area2D) -> void:
	#if area.is_in_group("hurtbox"):
		#action_walk(1)
		#
		#action_dash()
		#print("dashed")
		#action_walk(-1)
		#print("walk -1")

#func _on_behind_sensor_area_entered(area: Area2D) -> void:
#	if area.is_in_group("hurtbox"):
#		var player_x = area.global_position.x # Get the player's x position
#		var bot_x = global_position.x       # Get the bot's x position
#		var bot_facing_right = $AnimatedSprite2D.scale.x > 0
#
#		if (player_x > bot_x and bot_facing_right) or (player_x < bot_x and not bot_facing_right):
#			# Player is behind the bot, and bot is facing away
#			action_walk(-1 * $AnimatedSprite2D.scale.x) # walk in current direction
#			action_dash()
#			print("dashed")
#			action_walk($AnimatedSprite2D.scale.x) # walk in opposite direction
#			print("walk opposite")
#		else:
			# Player is behind the bot, and bot is already facing them
#			action_walk($AnimatedSprite2D.scale.x) #walk in current direction
#			action_dash()
#			print("dashed")
#			action_walk(-1 * $AnimatedSprite2D.scale.x) #walk in opposite direction
#			print("walk opposite")
#	elif area.is_in_group("hitbox"):
#		action_shield()

#func _on_behind_sensor_area_exited(area: Area2D) -> void:
#	if area.is_in_group("hurtbox"):
#		action_walk(0)
#	elif area.is_in_group("hitbox"):
#		action_shield_down()


#func _on_jump_timer_timeout() -> void:
#	jumping = not jumping # Replace with function body.
#
 
#func _on_jumptimer_2_timeout() -> void: 
#	# putting action_jump in here allows the bot to triple jump
	# because it jumps, but is still on the floor that frame, so it resets its jump
	# DO NOT under ANY circumstances put action_jump() under a signal
#	if jumping:
#		jump_this_frame = true# Replace with function body.


#func _on_above_sensor_area_entered(area: Area2D) -> void:
#	if area.is_in_group("hurtbox"):
#		action_walk(1)
#		#pass
#		action_dash() # bot loves throwing itself off walls
#		if position.x < -1326:
#			action_walk(1)
#			action_dash() # Replace with function body.
#			action_walk(0)
#		else:
#			action_walk(-1)
#			action_dash()
#			action_walk(0)
# again, signals mess with physics - bot will not move if action_walk is put like this in a signal
