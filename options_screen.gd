extends CanvasLayer
signal back
signal resetScores

var default_settings = {
	"fullscreen": true
}

var reset_scores = false

var settings_obj = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	settings_obj = get_settings()
	
	if settings_obj.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_visibility_changed() -> void:
	if visible == true:
		$FullscreenCheck.button_pressed = settings_obj.fullscreen
		
		$ResetScore.button_pressed = false


func get_settings():
	if(FileAccess.file_exists("user://settings.json")):
		var save_file = FileAccess.open("user://settings.json", FileAccess.READ)
		
		var settings = ""
		
		while save_file.get_position() < save_file.get_length():
			settings += save_file.get_line()
		
		var parsed_settings = JSON.parse_string(settings)
		
				
		return parsed_settings
	
	return default_settings

func save_settings():
	var settings_string = JSON.stringify(settings_obj)
	var save_file = FileAccess.open("user://settings.json", FileAccess.WRITE)
	save_file.store_line(settings_string)
	
	if settings_obj.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
	if reset_scores:
		resetScores.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_fullscreen_check_toggled(toggled_on: bool) -> void:
	settings_obj.fullscreen = toggled_on

func _on_back_button_pressed() -> void:
	back.emit()
	hide()

func _on_apply_button_pressed() -> void:
	save_settings()
	back.emit()
	hide()


func _on_reset_score_toggled(toggled_on: bool) -> void:
	reset_scores = toggled_on
