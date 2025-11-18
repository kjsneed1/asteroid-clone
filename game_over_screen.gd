extends CanvasLayer
signal start_game
signal to_menu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_retry_button_pressed() -> void:
	hide()
	start_game.emit()


func _on_menu_button_pressed() -> void:
	hide()
	to_menu.emit()
