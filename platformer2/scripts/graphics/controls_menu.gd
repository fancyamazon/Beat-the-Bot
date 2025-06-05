extends Control

var my_selected = -1

@onready var actions = $VBoxContainer/HBoxContainer/ActionsList
@onready var key_inputs = $VBoxContainer/HBoxContainer/KeysList

func _ready():
	$AudioStreamPlayer.play(GlobalVars.menu_music_progress)
	var actions_inputs
	for i in range(actions.get_item_count()):
		actions_inputs = InputMap.action_get_events(actions.get_item_text(i).to_lower())
		
		key_inputs.set_item_text(i, MapToText(actions_inputs[0]))

func MapToText(input):
	if input is InputEventKey:
		return cut_ending(input.as_text())
	else:
		return input.as_text()

func cut_ending(str):
	return str.substr(0, str.length() - 11)

func getText(event):
	if event is InputEventKey:
		return event.as_text_keycode()
	elif event is InputEventMouseButton:
		return event.as_text()
	return ""

func editInputMap(action, new_key):
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, new_key)

func _input(event):
	var actions_inputs
	if event is InputEventKey or event is InputEventMouseButton:
		if event.is_pressed() and my_selected != -1:
			key_inputs.set_item_text(my_selected, getText(event))
			editInputMap(actions.get_item_text(my_selected).to_lower(), event)
			my_selected = -1
			#print("done")
			key_inputs.deselect_all()
			print(getText(event))



func _on_keys_list_item_activated(index: int) -> void:
	my_selected = index


func _on_return_button_pressed() -> void:
	GlobalVars.menu_music_progress = $AudioStreamPlayer.get_playback_position() 
	get_tree().change_scene_to_file("res://scenes/graphics/options_menu.tscn")
