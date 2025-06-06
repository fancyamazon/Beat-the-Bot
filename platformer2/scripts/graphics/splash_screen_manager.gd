extends Control

# Splash screen itself
@onready var splash_screen: TextureRect = $CenterContainer/TextureRect

# From tutorial.
var in_time : float
var fade_in_time : float
var pause_time : float
var fade_out_time : float
var out_time : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GAME.FULL_LENGTH_SPLASH_SCREEN:
		in_time = 0.2
		fade_in_time = 0.6
		pause_time = 0.6
		fade_out_time = 0.6
		out_time = 0.2
	else:
		in_time = 0.1
		fade_in_time = 0.3
		pause_time = 0.3
		fade_out_time = 0.3
		out_time = 0.1
	
	fade()

func fade() -> void: 
	splash_screen.modulate.a = 0.0 # Transparent
	var tween = self.create_tween()
	tween.tween_interval(in_time)
	tween.tween_property(splash_screen, "modulate:a", 1.0, fade_in_time)
	tween.tween_interval(pause_time)
	tween.tween_property(splash_screen, "modulate:a", 0.0, fade_out_time)
	tween.tween_interval(out_time)
	await tween.finished
	
	# Note that if we're going to the Start Menu, we want SCREEN_SIZING to be 1.0, but it'll update that
	get_tree().root.content_scale_factor = GAME.GAME_SCREEN_SIZING
	get_tree().change_scene_to_packed(GAME.SCENE_AFTER_SPLASH)
	
	
