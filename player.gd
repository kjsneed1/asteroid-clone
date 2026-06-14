extends RigidBody2D

signal hit
signal moving
signal off_screen

var slow_down_rate = 150
var brake_rate = 300
var test_val = 334
var reset = false
var reset_pos
var hurt = false

var point_mode = true
var controller = false

func _ready() -> void:
	#Set monitor values
	contact_monitor = true
	max_contacts_reported = 1

func turn_right_input() -> bool:
	return Input.is_action_pressed("turn_right") || Input.is_action_pressed("controller_right") || Input.is_action_pressed("controller_stick_right")
	
func turn_left_input() -> bool:
	return Input.is_action_pressed("turn_left") || Input.is_action_pressed("controller_left") || Input.is_action_pressed("controller_stick_left")
	
func move_input() -> bool:
	return Input.is_action_pressed("move") || Input.is_action_pressed("controller_move")
	
func set_input_type() -> void:
	if Input.is_action_pressed("controller_down") || Input.is_action_pressed("controller_up") || Input.is_action_pressed("controller_left") || Input.is_action_pressed("controller_right") || Input.is_action_pressed("controller_stick_down") || Input.is_action_pressed("controller_stick_up") || Input.is_action_pressed("controller_stick_left") || Input.is_action_pressed("controller_stick_right") || Input.is_action_pressed("controller_move") || Input.is_action_pressed("controller_stick_shoot"):
		controller = true
	elif Input.is_action_pressed("turn_left") || Input.is_action_pressed("turn_right") || Input.is_action_pressed("move") || Input.is_action_pressed("brake") || Input.is_action_pressed("shoot"):
		controller = false
func _process(_delta: float) -> void:
	#Set input type
	set_input_type()
	
	#Set default player sprite
	if !hurt:
		$PlayerAnimation.animation = "default"
	
	#Set slow down rates
	linear_damp = 1.2
	angular_damp = 5
	
	if Input.is_action_pressed("brake"):
			linear_damp = 3
	
	if !point_mode:
		#Update rotation based on velocity
		if turn_right_input():
			angular_velocity = PI
			moving.emit()
		if turn_left_input():
			angular_velocity = -PI
			moving.emit()
		
		#Look for player input to move
		if move_input():
				moving.emit()
				if !hurt:
					$PlayerAnimation.animation = "moving"
				linear_velocity = Vector2(0.0,-200.0).rotated(rotation)
				if !turn_left_input() && !turn_right_input():
					angular_velocity = 0	
	else:
		if get_global_mouse_position().distance_to(position) > 40 || controller:
			#Look for player input to move
			if move_input():
					moving.emit()
					if !hurt:
						$PlayerAnimation.animation = "moving"
					linear_velocity = Vector2(0.0,-200.0).rotated(rotation)
					if !turn_left_input() && !turn_right_input():
						angular_velocity = 0
		else:
			linear_damp = 8

func _physics_process(_delta):
	if point_mode:
		#Set direction of player based on mouse or controller stick input
		if(!controller):
			rotation = get_global_mouse_position().angle_to_point(position) - PI/2
			
		if Input.get_vector("controller_stick_left","controller_stick_right","controller_stick_up","controller_stick_down").abs() > Vector2.ZERO:
			rotation = Input.get_vector("controller_stick_left","controller_stick_right","controller_stick_up","controller_stick_down").angle() + PI/2

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
