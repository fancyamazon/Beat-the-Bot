extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var bullet_hitbox: Hitbox = $BulletHitbox

### Changeable properties
@export var MAX_DISTANCE: float = 1500  # Max X position before destroying the bullet
@export var SPEED = 800

### Variables necessary to run
var dir: int  # Direction: 1 for right, -1 for left
var spawnPos: Vector2
var spawnRot: float
var velocity: Vector2

### Team
var team = "N/A: No Team Error" # This is set after being instantiated in fighter.gd

### Delete upon hitting wall
const DELETE_WHEN_HIT_WALL = true
@onready var wall_hit_detection: RayCast2D = $AnimatedSprite2D/WallHitDetection

func get_team():
	return team

func initiateBullet(damage_dealt: int, bullet_type: String, which_team: String) -> void:
	bullet_hitbox.damage = damage_dealt
	team = which_team
	
	if bullet_type == "charged":
		animated_sprite_2d.animation = "charged"
		self.scale = Vector2(2,2)

func _ready():
	global_position = spawnPos
	global_rotation = spawnRot

func _physics_process(delta: float) -> void:
	# Detect hitting wall
	if not GAME.BULLETS_GO_THROUGH_WALLS:
		wall_hit_detection.force_raycast_update()
		if wall_hit_detection.is_colliding() and DELETE_WHEN_HIT_WALL:
			var collider = wall_hit_detection.get_collider()
			#print("Collider:", collider, " | Type: ", typeof(collider))
			if collider is TileMapLayer:
				self.queue_free()
		
	animated_sprite_2d.scale.x = dir * 2
	velocity = Vector2(SPEED * dir, 0)  # Only move horizontally, no vertical movement
	global_position += velocity * delta  # Move the bullet by its velocity
	
	# Destroy the bullet if it exceeds its max distance
	if abs(global_position.x - spawnPos.x) > MAX_DISTANCE:
		queue_free()  # Destroy the bullet
