extends StaticBody2D

class_name Bullet

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity = Vector2.from_angle(rotation - (PI/2))
	
	position += velocity * 800 * delta


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
