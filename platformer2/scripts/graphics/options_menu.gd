extends Control

@onready var v_box_container: VBoxContainer = $VBoxContainer
@onready var music_select: ItemList = $MusicSelect

var files = ["Battle", "Energy", "Darkness", "Journey", "Hero"]

func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/graphics/start_menu.tscn")
	

func _on_music_select_item_activated(index: int) -> void:
	GlobalVars.music_path = "res://assets//Music//" + files[index] + ".wav"
