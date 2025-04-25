extends Node2D

@onready var main = get_tree().get_root().get_node("Game")

@onready var enemy = load("res://scenes/enemy.tscn")

func _ready() -> void:
	pass 

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("spawn"): 
		var instance = enemy.instantiate()
		instance.global_position = get_global_mouse_position()
		main.add_child(instance) 
		print(main.get_node("Player").get_child(0).position)
	
	if Input.is_action_just_pressed("mass_spawn"): 
		var instance = null
		for x in range(-200, 1100, 20):
			instance = enemy.instantiate()
			instance.global_position.x = x
			instance.global_position.y = -400
			main.add_child(instance) 
