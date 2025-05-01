class_name SneakyBot extends Fighter

@onready var nav = get_parent()
@onready var player = get_parent().get_parent().get_node("Player").get_node("Fighter")

# How long it stays in "RUN" after being hit
const WAIT_UNTIL_REJOIN_FIGHT = 5 # sec

var should_move = true
var mode = "nav" # "nav", "atk", "run"
var switching_to_nav = false
var after_i_hit = false # before hit, go close; after hit, strafe around where player is looking. coded in hurtbox.gd

var escaped_distance = false # for tracking if running away but players get close to you
### Need to do
#what I need to do 
#
#sneaky bot moving safely away from player
#
#add dash to move away
#
#if it got away but lowered distance again, enter fight mode again

### PURE MELEE ATTACK STRATEGY (ranged is covered by passive bot)
 #- STAGE 1: NAVIGATE TO THE BOT
	#- special navigation: "dodging"
	#- have a ray pointing out that detects bullets
	#- if a bullet is about to hit it, it jumps (might have to calculate math related to this to time the jump w/ frames)
#
 #- STAGE 2: HITTING THEM (before get hit)
	#- switch directions to be in the direction the player isn't looking
	#- maybe navigate slightly away from player
#
 #- STAGE 3: RUN (after get hit, or take 20 dmg or smth)
	#- until a certain distance away, dash + run away
	#- let a timer run out until go back to stage 1
# nav -> atk
# atk not after_i_hit -> after_i_hit
# atk -> run
# run -> nav

func get_team():
	return "bot"
	
func away(player_pos, bot_pos, dist: int):
	if bot_pos.x < player_pos.x:
		return player_pos + Vector2(-dist,0)
	else:
		return player_pos + Vector2(dist,0)

func determine_search_point(player_pos, bot_pos):
	if mode == "nav":
		return player_pos
	elif mode == "atk":
		return away(player_pos, bot_pos, 30) if after_i_hit else player_pos
	elif mode == "run":
		var rand_offset = randf_range(300, 500) # Decently far away
		away(player_pos, bot_pos, rand_offset)

func wait_to_switch_to_nav():
	switching_to_nav = false
	await get_tree().create_timer(WAIT_UNTIL_REJOIN_FIGHT).timeout
	if mode == "run":
		mode = "nav"
	
func decide_actions():
	nav.search_point = determine_search_point(player.global_position, global_position)
	#print("sneaky bot in mode: " + mode.to_upper())
	### Transitions
	## Run -> Nav
	if mode == "run" and not switching_to_nav: # Runs ONCE and only once in "run"
		escaped_distance = false
		switching_to_nav = true
		wait_to_switch_to_nav()
		
	if mode == "run" and abs(player.global_position.x - global_position.x) > 400 and not escaped_distance:
		escaped_distance = true
	elif mode == "run" and abs(player.global_position.x - global_position.x) < 50 and escaped_distance:
		escaped_distance = false
		# Re-agress to avoid being brutalized
		mode = "atk"
		
	## Nav -> Atk
	if (nav.search_point - global_position).length_squared() < 1600 and mode == "nav":
		mode = "atk"
	
	## Atk -> Run is within fighter.gd take_damage()
	
	## Do behaviors
	#if mode == "atk":
		#if player.global_position.x < global_position.x and facing_dir != -1:
			#action_walk(-1)
		#elif player.global_position.x > global_position.x and facing_dir != 1:
			#action_walk(1)
		#else:
			#action_walk(0)
	#elif 
	if mode == "nav" || mode == "run" || mode == "atk":
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
	
	# Dash if running away, not jumping, and the direction your facing is the away from player
	if should_move and mode == "run" and \
	   direction == (-1 if player.global_position.x > global_position.x else 1):
		#action_dash()
		pass
	
	if mode == "atk" and (nav.get_vector_to_player().x > -100 and nav.get_vector_to_player().x < 100):
		action_melee()

func setup_double_jump():
	should_move = false
	await get_tree().create_timer(0.3).timeout
	action_jump()
	should_move = true

func _on_dodge_bullet_area_area_entered(area: Area2D) -> void:
	if area is Bullet and area.get_team() != get_team():
		if is_on_floor():
			action_jump()
		else:
			await get_tree().create_timer(0.2).timeout
			action_jump()
