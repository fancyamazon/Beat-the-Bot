extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -450.0

var health = 100

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var enemy_hurt_box: Area2D = $AnimatedSprite2D/EnemyHurtBox
@onready var health_bar: ProgressBar = $HealthBar

func _ready():
	enemy_hurt_box.add_to_group("hurtbox")
	health_bar._init_health(health)
	
func _physics_process(delta: float) -> void:
	
	if (velocity.x > 1 || velocity.x < -1):
		animated_sprite_2d.animation = "running"
	else:
		animated_sprite_2d.animation = "idle"
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("enemy_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
		
	var direction := Input.get_axis("enemy_left", "enemy_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	
	# Flip if moving left
	animated_sprite_2d.flip_h = velocity.x < 0
	
	move_and_slide()

func take_damage(amount: int) -> void:
	health -= amount
	health_bar.health = health
	if health <= 0:
		print("Enemy died")
	else:
		print("Enemy health left: ", health)
