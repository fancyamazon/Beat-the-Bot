extends ProgressBar

### "Flash" animation
@onready var flash_timer: Timer = $FlashTimer
var flash_time = 0.4 # Amount, in seconds, of how long the white "flash" takes to catch up to the green bar

@onready var damage_bar: ProgressBar = $DamageBar

var health = 0 : set = _set_health

func _set_health(new_health):
	var prev_health = health
	health = min(max_value, new_health)
	value = health # Changes the value for HealthBar
	if health <= 0:
		self.visible = false 
		damage_bar.visible = false
		# don't queue_free() because then it throws error if I hit the slime again
	
	if health < prev_health: # taking damage
		flash_timer.start(flash_time)
	else:
		damage_bar.value = health

func _init_health(_health):
	health = _health
	max_value = _health
	value = _health
	damage_bar.max_value = _health
	damage_bar.value = _health

func _on_flash_timer_timeout() -> void:
	damage_bar.value = health
