extends Node2D


@onready var main=get_tree().get_root().get_node("Game")
@onready var enemy=load("res://scenes/enemy.tscn")
var x_pos = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("spawn"): 
		var instance = enemy.instantiate()
		instance.global_position = get_global_mouse_position()
		main.add_child(instance) 
		print(main.get_node("Player").get_child(0).position)
	if Input.is_action_just_pressed("spawn2"): 
		var instance = null
		for x in range(-2600, 1300, 20):
			instance = enemy.instantiate()
			instance.global_position.x = x
			main.add_child(instance) 
