extends Fighter

@onready var nav = get_parent()
@onready var player = get_parent().get_parent().get_node("Player").get_node("Fighter")

var should_move = true
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
		if should_move:
			action_walk(nav.get_movements()[0])
	
	# on timer end, jump
	# while timer is running, do not jump
	
		if nav.get_movements()[1] > 0 and is_on_floor(): 
			action_jump()
			if nav.get_movements()[1] == 2:
				setup_double_jump()
		if nav.get_movements()[2] == 1:
			#print('lowkey wanna dash')
			pass
	
	if player.global_position.y - global_position.y < 400 and player.global_position.y - global_position.y >= -100:
		action_ranged()

	
	if is_on_floor() and player.global_position.x - global_position.x > -10 and player.global_position.x - global_position.x < 10 and player.global_position.y - global_position.y < 500 and player.global_position.y - global_position.y > -500:
		action_dash()
	
	if (nav.get_vector_to_player().x > -100 and nav.get_vector_to_player().x < 100):
		action_melee()

func setup_double_jump():
	should_move = false
	await get_tree().create_timer(0.3).timeout
	action_jump()
	should_move = true
