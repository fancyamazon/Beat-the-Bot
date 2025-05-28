class_name Player extends Fighter

func decide_actions():
	if Input.is_action_just_pressed("dash"):
		action_dash()
	if Input.is_action_just_pressed("jump"):
		action_jump()
	if Input.is_action_just_pressed("attack"):
		action_melee()
	if(Input.is_action_just_pressed("ranged")):
		action_ranged()
	if Input.is_action_just_pressed("grapple"):
		call_deferred("action_grapple_deferred")
	if Input.is_action_just_released("grapple"):
		action_grapple_retract()
	if Input.is_action_just_pressed("shield"):
		action_shield()
	if Input.is_action_just_released("shield"):
		action_shield_down()
	if Input.is_action_just_pressed("tp"):
		action_teleport()
	if Input.is_action_pressed("charged_attack"):
		action_charged_attack()
	if Input.is_action_just_released("charged_attack"):
		action_release_charged_attack()
	action_walk(roundi(Input.get_axis("left", "right")))
	if Input.is_action_just_pressed("crouch"):
		action_crouch()
	if Input.is_action_just_pressed("reset_game"):
		call_deferred("reload_scene")
