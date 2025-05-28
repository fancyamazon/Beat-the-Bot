extends Control

### Nodes
@onready var v_box_container: VBoxContainer = $VBoxContainer
@onready var start_button: Button = $VBoxContainer/StartButton
@onready var options_button: Button = $VBoxContainer/OptionsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var splash_text: Label = $SplashText

### UI Settings (easier to change in here than go to it in the Inspector)
const SEPARATION = 19 # px
const SCREEN_SIZING = 1.0
const HOVER_COLOR: Color = Color("#E8E9ED")
const PRESS_COLOR: Color = Color("#BABFD1")

### Splash text (like Mojang)
const SPLASH_TEXTS = [ ## List of all possible splash texts to choose from
	"hi", "Owen will go to chess nats in december", "Owen is buns at this game"
]
var time = 0.0
const MAX_SPLASH_TEXT_SCALE = 1.2
const MIN_SPLASH_TEXT_SCALE = 0.8
const SCALE_SPEED = 2
const SCALE_RANGE = 0.2

var inc = true # Whether increasing or decreasing 

func _ready() -> void:
	splash_text.text = SPLASH_TEXTS.pick_random()
	#splash_text. = Vector2(16,16)
	splash_text.set_pivot_offset(splash_text.size / 2)
	
	get_tree().root.content_scale_factor = SCREEN_SIZING
	
	v_box_container.add_theme_constant_override("separation", SEPARATION)
	
	var hover_stylebox = StyleBoxFlat.new()
	hover_stylebox.bg_color = HOVER_COLOR
	hover_stylebox.set_corner_radius_all(16)
	hover_stylebox.shadow_color = Color("#0000009f");
	hover_stylebox.shadow_size = 5;
	start_button.add_theme_stylebox_override("hover", hover_stylebox)
	options_button.add_theme_stylebox_override("hover", hover_stylebox)
	quit_button.add_theme_stylebox_override("hover", hover_stylebox)

	var press_stylebox = StyleBoxFlat.new()
	press_stylebox.bg_color = PRESS_COLOR
	press_stylebox.set_corner_radius_all(16)
	press_stylebox.shadow_color = Color("#0000009f");
	press_stylebox.shadow_size = 5;
	start_button.add_theme_stylebox_override("pressed", press_stylebox)
	options_button.add_theme_stylebox_override("pressed", press_stylebox)
	quit_button.add_theme_stylebox_override("pressed", press_stylebox)

func _on_start_button_pressed() -> void:
	get_tree().root.content_scale_factor = GAME.GAME_SCREEN_SIZING
	get_tree().change_scene_to_file(GAME.SCENEPATH["game"])

func _on_options_button_pressed() -> void:
	print("settings button pers. doesn't do nothin")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _physics_process(delta):
	time += delta * SCALE_SPEED
	var scale_factor = 1.0 + sin(time) * SCALE_RANGE
	splash_text.scale = Vector2(scale_factor, scale_factor)
