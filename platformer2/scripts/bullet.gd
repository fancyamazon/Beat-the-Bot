extends Area2D

@export var max_distance: float = 3000  # Max X position before destroying the bullet
@export var SPEED = 800
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var dir: int  # Direction: 1 for right, -1 for left
var spawnPos: Vector2
var spawnRot: float
var velocity: Vector2
@onready var bullet_hitbox: Area2D = $BulletHitbox

func _ready():
	global_position = spawnPos
	global_rotation = spawnRot
	bullet_hitbox.add_to_group("hitbox")

func _physics_process(delta: float) -> void:
	# Horizontal movement only
	animated_sprite_2d.scale.x = dir*2
	velocity = Vector2(SPEED * dir, 0)  # Only move horizontally, no vertical movement
	global_position += velocity * delta  # Move the bullet by its velocity
		# Destroy the bullet if it exceeds a certain X position
	if abs(global_position.x) > max_distance:
		queue_free()  # Destroy the bullet


func _on_bullet_hitbox_area_entered(area: Area2D) -> void:
	#print("something entered player hitbox: ----\n", area, area.get_groups(), "\n----\n") # this was for debugging
	if area.is_in_group("hurtbox"):
		area.owner.take_damage(5)
