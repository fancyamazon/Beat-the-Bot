extends Control

func _on_return_to_menu_button_pressed() -> void:
	get_tree().root.content_scale_factor = 1.0
	get_tree().change_scene_to_file(GAME.SCENEPATH["startmenu"])
