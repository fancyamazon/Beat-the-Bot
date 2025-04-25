extends Area2D
class_name Hurtbox

### Invulnerability time to prevent double hitting
const INVULN_TIME = 0.5 # Currently set to just the melee attack
var hit_by: Object = null

func _ready() -> void:
	add_to_group("hurtbox")
	collision_layer = 0
	collision_mask = 2

func _on_area_entered(hitbox: Area2D) -> void:
	# Ignore anything that isn't a hitbox, and ignore something that just hit you (double-hitting prevention)
	if hitbox == null or hitbox is not Hitbox or (hit_by != null and hitbox == hit_by):
		return
	
	#print("Entered bullet hurtbox: ----\n", hitbox, hitbox.get_groups(), "\n----\n")

	if owner.has_method("take_damage") and hitbox.owner.get_team() != owner.get_team():
		owner.take_damage(hitbox.damage)
		hit_by = hitbox
		
		# Slight invulnerability ONLY for the hitbox that just hit you
		await get_tree().create_timer(INVULN_TIME).timeout
		
		hit_by = null
