extends RigidBody2D

signal hit
signal moving
signal off_screen

var slow_down_rate = 150
var brake_rate = 300
var test_val = 334
var reset = false
var reset_pos

func _ready() -> void:
	#Set monitor values
	contact_monitor = true
	max_contacts_reported = 1


func _process(_delta: float) -> void:
	
	#Set default player sprite
	$PlayerAnimation.animation = "default"
	
	#Set slow down rates
	linear_damp = 1.2
	angular_damp = 5
	
	#Update rotation based on velocity
	if Input.is_action_pressed("turn_right"):
		angular_velocity = PI
		moving.emit()
	if Input.is_action_pressed("turn_left"):
		angular_velocity = -PI
		moving.emit()
	
	
	if Input.is_action_pressed("brake"):
		linear_damp = 3
		
	#Look for player input to move
	if Input.is_action_pressed("move"):
		moving.emit()
		$PlayerAnimation.animation = "moving"
		linear_velocity = Vector2(0.0,-200.0).rotated(rotation)
		if !Input.is_action_pressed("turn_left") && !Input.is_action_pressed("turn_right"):
			angular_velocity = 0

func _on_body_entered(body: Node) -> void:
	if body is BigAsteroid || body is MediumAsteroid || body is SmallAsteroid:
		hit.emit()
		
		
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if reset:
		state.transform.origin = reset_pos
		# Call reset_physics_interpolation() at the end of the frame once the physics engine has been updated
		reset_physics_interpolation.call_deferred()
		reset = false
		

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == self:
		reset = true
		
func set_pos(posit:Vector2):
	position = posit
	reset_pos = posit
	reset = true


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	off_screen.emit()
