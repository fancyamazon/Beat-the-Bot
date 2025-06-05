extends Node2D

@onready var welcome: Label = $Instructions/Welcome
@onready var jump: Label = $Instructions/Jump

func _ready():
	welcome.text = "Welcome to the movement tutorial. Use " + KEY_BINDINGS.MAP["left"] + " and " + KEY_BINDINGS.MAP["right"] + " to move left and right."
	jump.text = "Jump onto this platform with +" + KEY_BINDINGS.MAP["jump"] + "!"
