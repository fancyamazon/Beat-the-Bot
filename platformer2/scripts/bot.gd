extends Fighter

@onready var nav=get_parent()
@onready var player = get_parent().get_parent().get_node("Player").get_node("Fighter")
@onready var djtimer = get_node("DoubleJumpTimer")

var djump_this_frame = false

func get_team():
	return "bot"


func decide_actions():
	nav.search_point = player.global_position 
	if nav.get_movements()[0] != 0 or nav.get_movements()[1] != 0:
		print(nav.get_movements())
	action_walk(nav.get_movements()[0])
	
	# on timer end, jump
	# while timer is running, do not jump
	
	if nav.get_movements()[1] > 0 and is_on_floor(): 
		action_jump()
		if nav.get_movements()[1] == 2:
			setup_double_jump()
			
	if (nav.get_vector_to_player().x > -100 and nav.get_vector_to_player().x < 100):
		action_melee()


func _on_double_jump_timer_timeout() -> void:
	djump_this_frame = true
	
func setup_double_jump():
	await get_tree().create_timer(0.3).timeout
	action_jump()
