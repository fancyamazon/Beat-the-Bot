extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var bullet_hitbox: Area2D = $BulletHitbox

### Changeable properties
@export var MAX_DISTANCE: float = 1500  # Max X position before destroying the bullet
@export var SPEED = 800

### Variables necessary to run
var dir: int  # Direction: 1 for right, -1 for left
var spawnPos: Vector2
var spawnRot: float
var velocity: Vector2

### Type-dependent
var team = "N/A: No Team Error" # This is set after being instantiated in fighter.gd
var bullet_type = 0 # 0 = Regular, 1 = Charged
var damage_dealt = 5 # Also edited from instantiation

func get_team():
	return team

func _ready():
	global_position = spawnPos
	global_rotation = spawnRot
	$BulletHitbox.add_to_group("hitbox")

func _physics_process(delta: float) -> void:
	if bullet_type == 1:
		$AnimatedSprite2D.animation = "charged"
		self.scale = Vector2(2,2)
	animated_sprite_2d.scale.x = dir * 2
	velocity = Vector2(SPEED * dir, 0)  # Only move horizontally, no vertical movement
	global_position += velocity * delta  # Move the bullet by its velocity
	# Destroy the bullet if it exceeds its max distance
	if abs(global_position.x - spawnPos.x) > MAX_DISTANCE:
		queue_free()  # Destroy the bullet

func _on_bullet_hitbox_area_entered(area: Area2D) -> void:
	#print("something entered bullet hitbox: ----\n", area, area.get_groups(), "\n----\n") # this was for debugging
	if area.is_in_group("hurtbox") and area.owner.get_team() != get_team():
		area.owner.take_damage(damage_dealt)
