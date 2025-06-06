extends Node

@onready var welcome: Label = $Welcome
@onready var jump: Label = $Jump
@onready var dash: Label = $Dash
@onready var grapple: Label = $Grapple
@onready var congrats: Label = $Congrats

func _process(_delta: float) -> void:
	welcome.text = "Welcome to the movement tutorial. Use " + KEY_BINDINGS.MAP["left"] + " and " + KEY_BINDINGS.MAP["right"] + " to move left and right."
	jump.text = "Use " + KEY_BINDINGS.MAP["jump"] + " to jump! You can jump twice."
	dash.text = "Try using Dash (" + KEY_BINDINGS.MAP["dash"] + ") and your jumps to get\nto the next platform."
	grapple.text = "Use your grapple (" + KEY_BINDINGS.MAP["grapple"] + ") to get into the clouds. →"
	congrats.text = "Congrats! You're now ready to Beat the Bot!"
