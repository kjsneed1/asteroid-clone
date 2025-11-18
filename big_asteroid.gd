extends RigidBody2D

class_name BigAsteroid

signal big_asteroid_shot(parent:Object)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Set monitor values
	contact_monitor = true
	max_contacts_reported = 1
	#Set sprite
	var big_ast_types = Array($BigAsteroidSprites.sprite_frames.get_animation_names())
	$BigAsteroidSprites.animation = big_ast_types.pick_random()
	add_to_group("asteroids")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass



func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	#Kill when off screen
	queue_free()



func _on_body_entered(body: Node) -> void:
	#Process getting shot by bullet
	if body is Bullet:
		big_asteroid_shot.emit(self)
		body.queue_free()
		queue_free()
