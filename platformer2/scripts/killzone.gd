extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body: Fighter) -> void:
	#print("Body: ", body, " just fell into the void")		
	if body.get_team() == "player" and body.INVINCIBILITY == false and body.DIE_FROM_VOID == true:
		print("Player fell into the void.")
		Engine.time_scale = 2
		timer.start()
	elif body.get_team() == "bot":
		print("Bot fell into the void. RIP.")
		body.owner.queue_free()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()
