extends Fighter

@onready var nav = get_parent()
@onready var player = get_parent().get_parent().get_node("Player").get_node("Fighter")

var search_direc = 0
var should_move = true
var mode = "nav"

var BEST_DIST = 12
var X_FLEX = 5 #searches 2 * X_FLEX +1 values of x
var Y_FLEX = 3 # how much below the player

func get_team():
	return "bot"

func calc_bot_pos(player_pos, i, offset):
	return player_pos + 32 * Vector2(search_direc * (BEST_DIST + i), offset)

func isEmpty(player_pos, i, offset):
	return nav._pathFind2D.isCellEmpty(calc_bot_pos(player_pos, i, offset))

func isStandable(player_pos, i, offset):
	return (not isEmpty(player_pos, i, offset + 1)) and isEmpty(player_pos, i, offset) and isEmpty(player_pos, i, offset - 1)

func _draw():
	for i in range(-X_FLEX, X_FLEX):
		for offset in range(Y_FLEX):
			if (isEmpty(player.global_position,i,offset)):
				draw_rect(Rect2(calc_bot_pos(player.global_position, i, offset) - global_position, Vector2(10,10)), Color.GREEN)
			else:
				draw_rect(Rect2(calc_bot_pos(player.global_position, i, offset)- global_position, Vector2(10,10)), Color.RED)
			if isStandable(player.global_position,i, offset):
				draw_rect(Rect2(calc_bot_pos(player.global_position, i, offset) - global_position, Vector2(5,5)), Color.YELLOW)
	draw_rect(Rect2(determine_search_point(player.global_position, global_position) - global_position + Vector2(5,5), Vector2(5,5)), Color.BLUE)
	#draw_rect(Rect2(determine_search_point(player.global_position, global_position) + Vector2(0,-32) - global_position, Vector2(5,5)), Color.YELLOW)


func determine_search_point(player_pos, bot_pos):
	if bot_pos.x < player_pos.x:
		search_direc = -1
	else:
		search_direc = 1
	for j in range(Y_FLEX):
		for i in range(- X_FLEX, X_FLEX):
			if (isStandable(player_pos,i, j)):
				return calc_bot_pos(player_pos, i, j)
	return player_pos + Vector2(search_direc * 400, 0) #backup if no suitable spots are found
	

func decide_actions():
	queue_redraw()
	nav.search_point = determine_search_point(player.global_position, global_position)
	#print(nav.actions)
	
	if (nav.search_point - global_position).length_squared() > 3600 and mode == "atk":
		mode = "nav"
	if (nav.search_point - global_position).length_squared() < 1600 and mode == "nav" and is_on_floor():
		mode = "atk"
	
	if mode == "atk":
		if player.global_position.x < global_position.x and facing_dir != -1:
			action_walk(-1)
		elif player.global_position.x > global_position.x and facing_dir != 1:
			action_walk(1)
		else:
			action_walk(0)
	elif mode == "nav":
		if should_move:
			action_walk(nav.get_movements()[0])
		else:
			action_walk(0)
	
	# on timer end, jump
	# while timer is running, do not jump
	
		if nav.get_movements()[1] > 0 and is_on_floor(): 
			action_jump()
			if nav.get_movements()[1] == 2:
				print("setup")
				setup_double_jump()
		if nav.get_movements()[2] == 1:
			#print('lowkey wanna dash')
			pass
	
	if player.global_position.y - global_position.y < 400 and player.global_position.y - global_position.y >= -100:
		action_ranged()
	
	if (nav.get_vector_to_player().x > -100 and nav.get_vector_to_player().x < 100):
		action_melee()

func setup_double_jump():
	should_move = false
	await get_tree().create_timer(0.3).timeout
	action_jump()
	should_move = true
