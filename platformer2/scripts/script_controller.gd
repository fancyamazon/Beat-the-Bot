extends Node

@onready var bot = get_parent().get_node("Fighter")
var behavior = "aggressive"


var script_aggro = load("res://scripts/aggressive_bot.gd")
var script_passive = load("res://scripts/passive_bot.gd")
var script_sneak = load("res://scripts/sneaky_bot.gd")
var script_camp = load("res://scripts/camper_bot.gd")

var behavior_scores = [0, 0, 0, 0] #aggro passive sneak camp
var current_script = 0
var scripts =[script_aggro, script_passive, script_sneak, script_camp]
var will_swap = true 


func change_behavior(i):
	bot.set_script(scripts[i])
	current_script = i
	bot._ready()
	
func _ready():
	change_behavior(current_script)
	bot._ready()
	bot.set_process(true)
	bot.set_physics_process(true)

func best_behavior(): #minimum damage taken
	var best_behavior = 0
	var best_score = behavior_scores[0]
	for i in range(1, 4):
		if behavior_scores[i] > behavior_scores[best_behavior]:
			best_behavior = i
			best_score = behavior_scores[i]
	return best_behavior
	

func _process(_delta):
	if Input.is_action_just_pressed("spawn-aggressive"): 
		bot.set_script(script_aggro)
		bot._ready()
	if Input.is_action_just_pressed("spawn-passive"): 
		bot.set_script(script_passive)
		bot._ready()
	if Input.is_action_just_pressed("spawn-sneaky"): 
		bot.set_script(script_sneak)
		bot._ready()
	if Input.is_action_just_pressed("spawn-camper"): 
		bot.set_script(script_camp)
		bot._ready()


func reconsider_behavior():
	if will_swap:
		print(behavior_scores)
		if current_script != best_behavior():
			change_behavior(best_behavior())
			print("behavior is now " + str(best_behavior()))
		will_swap = false
		await get_tree().create_timer(1).timeout
		will_swap = true

func _on_fighter_on_damage_taken(dmg_amt: Variant) -> void:
	behavior_scores[current_script] -= dmg_amt
	reconsider_behavior()


func _on_fighter_on_damage_dealt(dmg_amt: Variant) -> void:
	behavior_scores[current_script] += dmg_amt
	reconsider_behavior()
