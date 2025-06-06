extends Control

@onready var v_box_container: VBoxContainer = $VBoxContainer
@onready var music_select: ItemList = $MusicSelect

var files = ["Battle", "Energy", "Darkness", "Hero", "Journey", "Menu"]


func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/graphics/start_menu.tscn")
	

func _on_music_select_item_activated(index: int) -> void:
	GLOBAL_MUSIC_PLAYER.music_path = GLOBAL_MUSIC_PLAYER.MUSICPATH[files[index]]
	GLOBAL_MUSIC_PLAYER.play_music(GLOBAL_MUSIC_PLAYER.music_path)


func _on_h_slider_drag_ended(value_changed: bool) -> void:
	if value_changed: # Replace with function body.
		GLOBAL_MUSIC_PLAYER.music_volume = $VBoxContainer/HSlider.value
		GLOBAL_MUSIC_PLAYER.set_volume()


func _on_h_slider_2_drag_ended(value_changed: bool) -> void:
	if value_changed: # Replace with function body.
		GLOBAL_MUSIC_PLAYER.sfx_volume = $VBoxContainer/HSlider2.value


func _on_keybinds_button_pressed() -> void:
	get_tree().change_scene_to_file(GAME.SCENEPATH["controlsmenu"])
