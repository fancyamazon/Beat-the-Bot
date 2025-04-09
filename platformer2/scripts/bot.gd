extends Fighter

@onready var nav=get_parent()
@onready var player = get_parent().get_parent().get_node("Player").get_node("Fighter")

func get_team():
	return "bot"

func decide_actions():
	nav.search_point = player.global_position 
	#print(nav.actions)
	action_walk(nav.get_movements()[0])
	if nav.get_movements()[1] > 0:
		action_jump()
	if (nav.get_vector_to_player().x > -100 and nav.get_vector_to_player().x < 100):
		action_melee()
