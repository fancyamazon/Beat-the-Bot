extends Fighter

var attacking = false

func decide_actions():
	if attacking:
		action_melee()
	#if Input.is_action_just_pressed("attack"):
	#	action_melee()
	


func _on_bot_sensor_area_entered(area: Area2D) -> void:
	if area.is_in_group("hurtbox"):
		attacking = true # Replace with function body.


func _on_bot_sensor_area_exited(area: Area2D) -> void:
	if area.is_in_group("hurtbox"):
		attacking = false # Replace with function body.
