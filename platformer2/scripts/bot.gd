extends Fighter

@onready var nav = get_parent()
@onready var player = get_parent().get_parent().get_node("Player").get_node("Fighter")

var should_move = true

func get_team():
	return "bot"

func decide_actions():
	nav.search_point = player.global_position 
	if should_move:
		action_walk(nav.get_movements()[0])
	else:
		action_walk(0)
	
	# on timer end, jump
	# while timer is running, do not jump
	
	if nav.get_movements()[1] > 0 and is_on_floor(): 
		action_jump()
		if nav.get_movements()[1] == 2:
			setup_double_jump()
	if nav.get_movements()[2] == 1:
		#print('lowkey wanna dash')
		action_dash()
	
	
	if abs(nav.get_vector_to_player().x) < 100:
		face_player()
		action_melee()
	
	
func setup_double_jump():
	should_move = false
	await get_tree().create_timer(0.3).timeout
	action_jump()
	should_move = true

func face_player():
	if player.global_position.x < global_position.x and facing_dir != -1:
		action_walk(-1)
	elif player.global_position.x > global_position.x and facing_dir != 1:
		action_walk(1)
	else:
		action_walk(0)
