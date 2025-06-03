extends Control

@onready var v_box_container: VBoxContainer = $VBoxContainer
@onready var music_select: ItemList = $MusicSelect

var files = ["Battle", "Energy", "Darkness", "Hero", "Journey", "Menu"]

func _ready():
	$AudioStreamPlayer.play(GlobalVars.menu_music_progress)

func _on_return_button_pressed() -> void:
	GlobalVars.menu_music_progress = $AudioStreamPlayer.get_playback_position() 
	get_tree().change_scene_to_file("res://scenes/graphics/start_menu.tscn")
	

func _on_music_select_item_activated(index: int) -> void:
	GlobalVars.music_path = "res://assets//Music//" + files[index] + ".wav"


func _on_h_slider_drag_ended(value_changed: bool) -> void:
	if value_changed: # Replace with function body.
		GlobalVars.music_volume = $VBoxContainer/HSlider.value


func _on_h_slider_2_drag_ended(value_changed: bool) -> void:
	if value_changed: # Replace with function body.
		GlobalVars.sfx_volume = $VBoxContainer/HSlider2.value


func _on_keybinds_button_pressed() -> void:
	
	GlobalVars.menu_music_progress = $AudioStreamPlayer.get_playback_position() 
	get_tree().change_scene_to_file("res://scenes/graphics/controls_menu.tscn") # Replace with function body.
