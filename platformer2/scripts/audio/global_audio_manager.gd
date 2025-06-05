extends AudioStreamPlayer

### Constants
const MUSICPATH = {
	"Battle" = "res://assets/Music/Battle.wav",
	"Darkness" = "res://assets/Music/Darkness.wav",
	"Energy" = "res://assets/Music/Energy.wav",
	"Hero" = "res://assets/Music/Hero.wav",
	"Journey" = "res://assets/Music/Journey.wav",
	"Menu" = "res://assets/Music/Menu.wav",
}

### Changeable in other places
var music_path : String = "N/A" 
var music_volume : float = 8.0;
var sfx_volume : float = 8.0;

### Local stuff
var current_music_file : String = "N/A"

func set_volume():
	set_volume_linear(music_volume)

func play_music(music: String):
	if current_music_file == music:
		return
	
	stop()
	current_music_file = music
	stream = load(current_music_file) as AudioStream
	volume_db = music_volume
	play()
