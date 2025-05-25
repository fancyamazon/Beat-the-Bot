extends Node2D
class_name GAME

### ---------------------------------- DEV TOOLS FOR DEBUGGING ----------------------------------
const INVINCIBILITY = false
const DIE_FROM_VOID = true 
const GRAPPLE_LIMITED_TO_SCREEN = true # Whether grappling is limited to on-screen walls
const BULLETS_GO_THROUGH_WALLS = false
const GAME_SCREEN_SIZING = 2.0

## Testing preset
const PLAYER_SHIELD_RESETS_HEALTH = true
const PLAYER_PASSIVE_HEALING = 0.3 # per frame # Easy mode: 0.3 # Non-easy: 0.1
const BOTS_PASSIVE_HEALING = 0.05 # per frame # Easy mode: 0.02 # Non-easy: 0.05
const CAN_TELEPORT = true
const FULL_LENGTH_SPLASH_SCREEN = false
#const SCENE_AFTER_SPLASH : PackedScene = preload(SCENEPATH["game") # Loads game directly after splash

## Final gameplay preset (Ctrl Shift K to mass uncomment, Ctrl K to mass comment)
#const PLAYER_SHIELD_RESETS_HEALTH = false
#const PLAYER_PASSIVE_HEALING = 0 # per frame # Easy mode: 0.3 # Non-easy: 0.1
#const BOTS_PASSIVE_HEALING = 0 # per frame # Easy mode: 0.02 # Non-easy: 0.05
#const CAN_TELEPORT = false
#const FULL_LENGTH_SPLASH_SCREEN = true
const SCENE_AFTER_SPLASH : PackedScene = preload(SCENEPATH["startmenu"]) # Loads start menu after splash

## Path to .tscn scenes and .gd scripts
const SCENEPATH = {
	"game" = "res://game.tscn",
	"enemy" = "res://scenes/fighters/enemy.tscn",
	"camper" = "res://scenes/fighters/camper_bot.tscn",
	"sneaky" = "res://scenes/fighters/sneaky_bot.tscn",
	"aggressive" = "res://scenes/fighters/aggressive_bot.tscn",
	"passive" = "res://scenes/fighters/passive_bot.tscn",
	"bot" = "res://scenes/fighters/bot.tscn",
	"startmenu" = "res://scenes/graphics/start_menu.tscn",
	"bullet" = "res://scenes/abilities/bullet.tscn",
	"graphPoint" = "res://scenes/abilities/graphPoint.tscn"
}
# Note that the line: _graphpoint = ResourceLoader.Load<PackedScene>("res://scenes/abilities/graphPoint");
# in TileMapPathFind.cs still relies on MANUALLY INPUTTING the path.

const SCRIPTPATH = {
	"game" = "res://game.gd",
	"enemy" = "res://scripts/fighters/enemy.gd",
	"camper" = "res://scripts/fighters/camper_bot.gd",
	"sneaky" = "res://scripts/fighters/sneaky_bot.gd",
	"aggressive" = "res://scripts/fighters/aggressive_bot.gd",
	"passive" = "res://scripts/fighters/passive_bot.gd",
	"bot" = "res://scripts/fighters/bot.gd",
	"startmenu" = "res://scripts/graphics/start_menu.gd"
}

@onready var main = get_tree().get_root().get_node("Game")

@onready var enemy = load(SCENEPATH["enemy"])
@onready var camper = load(SCENEPATH["camper"])
@onready var sneaky = load(SCENEPATH["sneaky"])
@onready var aggressive = load(SCENEPATH["aggressive"])
@onready var passive = load(SCENEPATH["passive"])
@onready var bot = load(SCENEPATH["bot"])



func _ready() -> void:
	pass
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("spawn"): 
		var instance = bot.instantiate()
		instance.global_position = get_global_mouse_position()
		main.get_node("Characters").add_child(instance) 
	
	if Input.is_action_just_pressed("mass_spawn"): 
		var instance = null
		for x in range(-200, 1100, 20):
			instance = enemy.instantiate()
			instance.global_position.x = x
			instance.global_position.y = -400
			main.add_child(instance) 
		for child in main.get_node("Characters").get_children():
			if child.name != "Player":
				child.queue_free()
