#Converted https://github.com/solarstrings/Godot4.x_Advanced2DPlatformerPathFinding/blob/main/Scenes/Skeleton/Skeleton.cs#L6
# to GDScript
extends Fighter

var attacking = false
var shooting = false
var jumping = true
var jump_this_frame = false


@onready var nav=get_parent()


func get_team():
	return "bot"

func decide_actions():
	#print(nav.actions)
	action_walk(nav.actions[0])
	if nav.actions[1] > 0:
		action_jump()
