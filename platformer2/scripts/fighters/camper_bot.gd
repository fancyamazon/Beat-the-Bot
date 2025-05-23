class_name CamperBot extends Fighter

@onready var nav = get_parent()
@onready var player = get_parent().get_parent().get_node("Player").get_node("Fighter")

var mode = "nav"
var release = false
var is_charging = false # New state to track charging

func get_team():
	return "bot"

func determine_search_point(player_pos, bot_pos):
	if bot_pos.x < player_pos.x:
		return player_pos + Vector2(-550, 0)
	else:
		return player_pos + Vector2(550, 0)

func decide_actions():
	nav.search_point = determine_search_point(player.global_position, global_position)

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
		if nav.get_movements()[1] > 0:
			action_jump()

	if player.global_position.y - global_position.y < 400 and player.global_position.y - global_position.y >= -100:
		if not is_charging:
			action_charged_attack()
			is_charging = true
			await get_tree().create_timer(1.3).timeout
			if is_instance_valid(self): # Check if the node still exists
				action_release_charged_attack()
				is_charging = false

	if is_on_floor() and player.global_position.x - global_position.x > -10 and player.global_position.x - global_position.x < 10 and player.global_position.y - global_position.y < 500 and player.global_position.y - global_position.y > -500:
		action_dash()

	if (nav.get_vector_to_player().x > -100 and nav.get_vector_to_player().x < 100):
		action_melee()
