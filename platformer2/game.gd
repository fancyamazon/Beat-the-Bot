extends Node2D
class_name GAME

### ---------------------------------- DEV TOOLS FOR DEBUGGING ----------------------------------
const INVINCIBILITY = false
const DIE_FROM_VOID = true 
const CAN_TELEPORT = true
const GRAPPLE_LIMITED_TO_SCREEN = true # Whether grappling is limited to on-screen walls
const BULLETS_GO_THROUGH_WALLS = false

## Easy mode preset
const PLAYER_SHIELD_RESETS_HEALTH = true
const PLAYER_PASSIVE_HEALING = 0.3 # per frame # Easy mode: 0.3 # Non-easy: 0.1
const BOTS_PASSIVE_HEALING = 0.05 # per frame # Easy mode: 0.02 # Non-easy: 0.05

@onready var main = get_tree().get_root().get_node("Game")

@onready var enemy = load("res://scenes/enemy.tscn")
@onready var camper = load("res://scenes/camper_bot.tscn")
@onready var sneaky = load("res://scenes/sneaky_bot.tscn")
@onready var aggressive = load("res://scenes/aggressive_bot.tscn")
@onready var passive = load("res://scenes/passive_bot.tscn")

func _ready() -> void:
	pass
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("spawn"): 
		var instance = enemy.instantiate()
		instance.global_position = get_global_mouse_position()
		main.add_child(instance) 
		for child in main.get_node("Characters").get_children():
			if child.name != "Player":
				child.queue_free()
	
	if Input.is_action_just_pressed("mass_spawn"): 
		var instance = null
		for x in range(-200, 1100, 20):
			instance = enemy.instantiate()
			instance.global_position.x = x
			instance.global_position.y = -400
			main.add_child(instance) 
			
	if Input.is_action_just_pressed("spawn-aggressive"): 
		var instance = aggressive.instantiate()
		instance.global_position = get_global_mouse_position()
		main.get_node("Characters").add_child(instance) 
	if Input.is_action_just_pressed("spawn-passive"): 
		var instance = passive.instantiate()
		instance.global_position = get_global_mouse_position()
		main.get_node("Characters").add_child(instance) 
	if Input.is_action_just_pressed("spawn-sneaky"): 
		var instance = sneaky.instantiate()
		instance.global_position = get_global_mouse_position()
		main.get_node("Characters").add_child(instance) 
	if Input.is_action_just_pressed("spawn-camper"): 
		var instance = camper.instantiate()
		instance.global_position = get_global_mouse_position()
		main.get_node("Characters").add_child(instance) 
		
