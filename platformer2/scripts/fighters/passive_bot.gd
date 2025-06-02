class_name PassiveBot extends Fighter

@onready var nav = get_parent()
@onready var player = get_parent().get_parent().get_node("Player").get_node("Fighter")

var search_direc = 0
var should_move = true
var mode = "nav"
var will_grapple = false
var grapplePoint = Vector2(0,0)

var BEST_DIST = 12
var X_FLEX = 5 #searches 2 * X_FLEX +1 values of x
var Y_FLEX = 5 # how much below the player

var grapple_allowed = false

func ready():
	nav.grapple_for_navigation = false

func get_team():
	return "bot"

func calc_bot_pos(player_pos, i, offset):
	return player_pos + 32 * Vector2(search_direc * (BEST_DIST + i), offset)

func isEmpty(player_pos, i, offset):
	return nav._pathFind2D.isCellEmpty(calc_bot_pos(player_pos, i, offset))

func isStandable(player_pos, i, offset):
	return (not isEmpty(player_pos, i, offset + 1)) and isEmpty(player_pos, i, offset) and isEmpty(player_pos, i, offset - 1)

func shootingBlocked(player_pos, i, offset):
	return (not isEmpty(player_pos, i, offset))

func searchGrapples(player_pos, i, offset):
	var grapple_search = [[1,0], [1,-1], [0,-2], [-1,-1], [-1,0], [0, 1]]
	if not (isEmpty(player_pos, i, offset) and isEmpty(player_pos, i, offset - 1)):
		return [];
	else:
		for coords in grapple_search:
			if isEmpty(player_pos, i, offset):
				grapple_search.erase(coords)
	return grapple_search;
	#check 6 adjacent tiles for being grapplable

func _draw():
	for i in range(-X_FLEX, X_FLEX + 1):
		for offset in range(-1, Y_FLEX):
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
	
	
	var found_spot_score = 0
	#0 = not found
	#1 = standable, not shootable
	#2 = grappleable, shootable
	#3 = shootable
	
	var best_spot = Vector2(0, 0) #shootable spot
	#var found_shootable_standable_spot = false
	var search_shootable_in_this_row = true
	
	var shootable_spot = Vector2(0,0) #grapple and shoot
	#var found_shootable_spot = false
	
	var backup_spot = Vector2(0, 0) #standable spot
	#var found_backup_spot = false
	 
	
	for j in range(-1, Y_FLEX):
		search_shootable_in_this_row = true
		for i in range(- BEST_DIST, X_FLEX + 1):
			if (shootingBlocked (player_pos,i,j)):
				search_shootable_in_this_row = false
				#if shooting blocked, also is not standable
			if (i >= -X_FLEX): #look for standable tiles
				if found_spot_score <= 3:
					if (isStandable(player_pos,i, j) and search_shootable_in_this_row):
						if 	(abs(i) + abs(j) < abs(best_spot.x) + abs(best_spot.y)) or found_spot_score <3:
							if search_shootable_in_this_row:
								best_spot.x = i
								best_spot.y = j
								found_spot_score = 3
				if found_spot_score <= 2:
					# if direction = 1, search tile to the right
					# if direction = -1, search tile to the left
					if ((not isEmpty(player_pos, i + 1, j)) and search_shootable_in_this_row):
						if 	(abs(i) + abs(j) < abs(shootable_spot.x) + abs(shootable_spot.y)) or found_spot_score < 2:
							if search_shootable_in_this_row:
								shootable_spot.x = i
								shootable_spot.y = j
								found_spot_score = 2
				if found_spot_score <= 1:
					if (isStandable(player_pos,i, j)):
					# only search for backups if no shootable spots found
						if ((abs(i) + abs(j) < abs(backup_spot.x) + abs(backup_spot.y)) or found_spot_score < 1):
							backup_spot.x = i
							backup_spot.y = j
							found_spot_score = 1
	if found_spot_score == 3:
		will_grapple = false
		return calc_bot_pos(player_pos, best_spot.x, best_spot.y)
	elif found_spot_score == 2:
		will_grapple = true
		grapplePoint = calc_bot_pos(player_pos, shootable_spot.x + 0.5, shootable_spot.y)
		return nav.get_searchpoint_from_grapplepoint(calc_bot_pos(player_pos, shootable_spot.x, shootable_spot.y))
	elif found_spot_score == 1:
		will_grapple = false
		return calc_bot_pos(player_pos, backup_spot.x, backup_spot.y)
	else:
		will_grapple = false
		return calc_bot_pos(player_pos, 0, 0)
	#return player_pos + Vector2(search_direc * 400, 0) #backup if no suitable spots are found

func dist_to_target():
	if will_grapple:
		return (grapplePoint - global_position).length_squared()
	return (nav.search_point - global_position).length_squared()

		

func decide_actions():																									
	queue_redraw()
	#print(mode)
	nav.search_point = determine_search_point(player.global_position, global_position)
	#print(nav.actions
	#print(dist_to_target())
	if ((dist_to_target() > 9000) and mode == "atk" and is_on_floor()):
		mode = "nav"
		action_grapple_retract()
		print(mode)
	if mode == "grapple" and (velocity.length_squared() < 0.1 and is_on_wall()) and (dist_to_target() > 900):
		mode = "nav"
		action_grapple_retract()
		print(mode)
	if ((nav.search_point - global_position).length_squared() < 1024 and mode == "nav" and is_on_floor()):
		if will_grapple:
			#action_grapple(grapplePoint)
			mode = "grapple"
		else:
			mode = "atk"
		print(mode)
	
	
	if abs(player.global_position.x - global_position.x) <= 32:
		mode = "nav"
		action_grapple_retract()
		action_dash()
		print(mode)


	if mode == "atk":
		face_player()
		
		if player.global_position.y < global_position.y - 32:
			action_jump()
	elif mode == "grapple":
		if is_facing_player():
			action_grapple(grapplePoint)
		else:
			face_player()
	elif mode == "nav":
		if should_move:
			action_walk(nav.get_movements()[0])
		else:
			action_walk(0)
		
		#if will_grapple and (nav.search_point - global_position).length_squared() < 256:
		#	action_walk(0)
		#	if true: #nav.get_movements()[3] == 1:
		#		action_grapple(grapplePoint)
		#if (grapplePoint - global_position).length_squared() < 256: #TO DO: FIX THIS
		#	print("huh")
		#	action_grapple_retract()
	# on timer end, jump
	# while timer is running, do not jump
	
		if nav.get_movements()[1] > 0 and is_on_floor(): 
			action_jump()
			if nav.get_movements()[1] == 2:
				setup_double_jump()
		#if nav.get_movements()[2] == 1:
		#	action_dash()
			
		#if will_grapple and (nav.search_point - global_position).length_squared() < 256:
		#	action_grapple(grapplePoint)
		#else:
		#	if nav.get_movements()[3] == 1:
		#		action_grapple(nav.get_target())
		#	elif nav.get_movements()[3] == -1:
		#		action_grapple_retract()
		#print(nav.get_movements())
	
	if player.global_position.y - global_position.y < 400 and player.global_position.y - global_position.y >= -100:
		action_ranged()
	
	if (nav.get_vector_to_player().x > -100 and nav.get_vector_to_player().x < 100):
		action_melee()



func setup_double_jump():
	should_move = false
	await get_tree().create_timer(0.3).timeout
	action_jump()
	should_move = true

func is_facing_player():
	return(player.global_position.x < global_position.x and facing_dir == -1) or (player.global_position.x > global_position.x and facing_dir == 1)

func face_player():
	if player.global_position.x < global_position.x and facing_dir != -1:
		action_walk(-1)
	elif player.global_position.x > global_position.x and facing_dir != 1:
		action_walk(1)
	else:
		action_walk(0)
