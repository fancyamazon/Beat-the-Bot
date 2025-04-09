extends Fighter

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
		action_grapple()
	if Input.is_action_just_released("grapple"):
		action_grapple_retract()
	if Input.is_action_just_pressed("shield"):
		action_shield()
		health = 100
		health_bar.health = 100
	if Input.is_action_just_released("shield"):
		action_shield_down()
	action_walk(Input.get_axis("left", "right"))
	if Input.is_action_just_pressed("tp"):
		global_position = get_global_mouse_position()
