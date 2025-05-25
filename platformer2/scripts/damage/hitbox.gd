extends Area2D
class_name Hitbox

@export var damage := 10

var able_to_hit = true # When disabled, preventing double-hit

func _ready() -> void:
	add_to_group("hitbox")
	
	collision_layer = 2
	collision_mask = 0
