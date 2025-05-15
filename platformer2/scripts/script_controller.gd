extends Node

@onready var bot = get_parent().get_node("Fighter")
var behavior = "aggressive"

var script_aggro = load("res://scripts/aggressive_bot.gd")
var script_passive = load("res://scripts/passive_bot.gd")
var script_sneak = load("res://scripts/sneaky_bot.gd")
var script_camp = load("res://scripts/camper_bot.gd")

func _ready():
	bot.set_process(true)
	bot.set_physics_process(true)
	
func _process(delta):
	if Input.is_action_just_pressed("spawn-aggressive"): 
		bot.set_script(script_aggro)
		bot._ready()
	if Input.is_action_just_pressed("spawn-passive"): 
		bot.set_script(script_passive)
		bot._ready()
	if Input.is_action_just_pressed("spawn-sneaky"): 
		bot.set_script(script_sneak)
		bot._ready()
	if Input.is_action_just_pressed("spawn-camper"): 
		bot.set_script(script_camp)
		bot._ready()
