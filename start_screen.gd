extends CanvasLayer
signal start_game


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

#Handle quit button
func _on_quit_button_pressed() -> void:
	get_tree().quit()

#Handle start button
func _on_start_button_pressed() -> void:
	start_game.emit()
	hide()
