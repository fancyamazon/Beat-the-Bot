extends Fighter

var attacking = false
var shooting = false
var jumping = true

func decide_actions():
	if jumping:
		action_jump()
	if attacking:
		action_melee()
		action_ranged()
	elif shooting:
		action_ranged()
	


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
