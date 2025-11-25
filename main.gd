extends Node

@export var bullet_scene: PackedScene
@export var big_asteroid_scene: PackedScene
@export var medium_asteroid_scene: PackedScene
@export var small_asteroid_scene: PackedScene
var reloading = false
var score = 0
var lives = 3
var recovering = false
var player_moving = false
var prev_size = DisplayServer.window_get_size()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DisplayServer.window_set_min_size(Vector2i(640,480))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var screen_size = DisplayServer.window_get_size()
	
	if prev_size.x != screen_size.x || prev_size.y != screen_size.y:
		$PlayerBounds/CollisionPolygon2D.polygon[0] = Vector2(0,0)
		$PlayerBounds/CollisionPolygon2D.polygon[1] = Vector2(screen_size.x,0)
		$PlayerBounds/CollisionPolygon2D.polygon[2] = Vector2(screen_size.x,screen_size.y)
		$PlayerBounds/CollisionPolygon2D.polygon[3] = Vector2(0,screen_size.y)
		
		var new_curve = Curve2D.new()
		new_curve.add_point(Vector2(0,0))
		new_curve.add_point(Vector2(screen_size.x, 0))
		new_curve.add_point(Vector2(screen_size.x, screen_size.y))
		new_curve.add_point(Vector2(0, screen_size.y))
		new_curve.add_point(Vector2(0, 0))
		$AstroidPath.curve = new_curve
		
	prev_size = screen_size
	
	#Check for shooting input
	if Input.is_action_pressed("shoot") && !reloading && $Player.is_visible_in_tree():
		var bullet = bullet_scene.instantiate()
		bullet.position = $Player.position
		bullet.rotation = $Player.rotation
		add_child(bullet)
		$Shoot.play()
		reloading = true
		await get_tree().create_timer(0.3).timeout
		reloading = false
		
	if player_moving && $PlayerMusic.volume_db < 0.0:
		$PlayerMusic.volume_db += 24 * delta
	elif !player_moving && $PlayerMusic.volume_db > -16.0:
		$PlayerMusic.volume_db -= 4 * delta

#Functions to set score in state and display
func set_score(s) -> void:
	score = s
	$GameHud/Score/ScoreNumber.text = str(score)
func add_score(addition:int) -> void:
	score += addition
	$GameHud/Score/ScoreNumber.text = str(score)
	
#Functions to set lives in state and display
func set_lives(l) -> void:
	lives = l
	$GameHud/Lives/LivesNumber.text = str(lives)
func minus_life() -> void:
	if lives > 0:
		lives -= 1
		$GameHud/Lives/LivesNumber.text = str(lives)

func _on_asteroid_timer_timeout() -> void:
	#Pick which asteroid gets added
	var asteroid_chances = [0,0,0,0,0,1,1,1,2]
	var asteroid_roll = asteroid_chances.pick_random()
	
	#Add asteroid to scene
	#Pick location of asteroid
	var asteroid_spawn_location = $AstroidPath/AsteroidPathLocation
	asteroid_spawn_location.progress_ratio = randf()
	
	#Pick which asteroid is spawned
	var asteroid
	if asteroid_roll == 0:
		asteroid = big_asteroid_scene.instantiate()
		asteroid.connect("big_asteroid_shot",Callable(self,"_on_big_asteroid_shot"))
	elif asteroid_roll == 1:
		asteroid = medium_asteroid_scene.instantiate()
		asteroid.connect("medium_asteroid_shot",Callable(self,"_on_medium_asteroid_shot"))
	elif asteroid_roll == 2:
		asteroid = small_asteroid_scene.instantiate()
		asteroid.connect("small_asteroid_shot",Callable(self,"_on_small_asteroid_shot"))
	
	#Set Asteroid position and movement
	asteroid.position = asteroid_spawn_location.position
	
	var direction = asteroid_spawn_location.rotation + PI/2
	direction += randf_range(-PI/3, PI/3)
	asteroid.rotation = direction
	
	var velocity = Vector2(randf_range(40.0, 100.0), 0.0)
	asteroid.linear_velocity = velocity.rotated(direction)
	
	#Spawn asteroid in
	add_child(asteroid)

func _on_big_asteroid_shot(parent) -> void:
	$AsteroidHit.play()
	add_score(50)
	var medium_spawned_chances = [2,2,3,3,3,3]
	var medium_spawned = medium_spawned_chances.pick_random()
	for n in medium_spawned:
		var medium_asteroid = medium_asteroid_scene.instantiate()
		medium_asteroid.connect("medium_asteroid_shot",Callable(self,"_on_medium_asteroid_shot"))
		var med_rotation = parent.rotation + (((2 * PI)/medium_spawned)*n)
		medium_asteroid.rotation = med_rotation
		medium_asteroid.position = parent.position
		medium_asteroid.position += Vector2(30.0,0).rotated(med_rotation)
		medium_asteroid.linear_velocity = Vector2(randf_range(90.0,150.0),0.0).rotated(med_rotation + randf_range((-PI/3),(PI/3)))
		medium_asteroid.rotation = parent.rotation
		call_deferred("add_child",medium_asteroid)

func _on_medium_asteroid_shot(parent) -> void:
	$AsteroidHit.play()
	add_score(100)
	var small_spawned_chances = [2,2,2,2,3,3]
	var small_spawned = small_spawned_chances.pick_random()
	for n in small_spawned:
		var small_asteroid = small_asteroid_scene.instantiate()
		small_asteroid.connect("small_asteroid_shot",Callable(self,"_on_small_asteroid_shot"))
		var small_rotation = parent.rotation + (((2 * PI)/small_spawned)*n)
		small_asteroid.rotation = small_rotation
		small_asteroid.position = parent.position
		small_asteroid.position += Vector2(30.0,0).rotated(small_rotation)
		small_asteroid.linear_velocity = Vector2(randf_range(120.0,170.0),0.0).rotated(small_rotation + randf_range((-PI/3),(PI/3)))
		small_asteroid.rotation = parent.rotation
		call_deferred("add_child",small_asteroid)

func _on_small_asteroid_shot(_parent) -> void:
	$AsteroidHit.play()
	add_score(200)


func _on_start_game() -> void:
	set_score(0)
	set_lives(3)
	$MenuMusic.stop()
	$GameMusic.play()
	$PlayerMusic.play()
	var screen_size = DisplayServer.window_get_size()
	$Player.set_pos(Vector2(screen_size.x/2,screen_size.y/2))
	$Player.show()
	$GameHud.show()
	get_tree().call_group("asteroids", "queue_free")
	$AsteroidTimer.start()


func _on_player_hit() -> void:
	if !recovering && $Player.visible:
		minus_life()
		
		if lives == 0:
			game_over()
		else:
			$Crash.play()
			
		recovering = true
		await get_tree().create_timer(1.0).timeout
		recovering = false

func game_over() -> void:
	$GameHud.hide()
	$Player.hide()
	$GameMusic.stop()
	$PlayerMusic.stop()
	$GameOver.play()
	$AsteroidTimer.stop()
	$GameOverScreen.show()
	$GameOverScreen/Subtitle.text = "SCORE: " + str(score)


func _on_game_over_screen_to_menu() -> void:
	$StartScreen.show()
	$MenuMusic.play()


func _on_player_moving() -> void:
	player_moving = true
	#Start timer to wait to turn music down
	$SlowDownTimer.start()


func _on_slow_down_timer_timeout() -> void:
	player_moving = false


func _on_player_off_screen() -> void:
	var screen_size = DisplayServer.window_get_size()
	$Player.set_pos(Vector2(screen_size.x/2,screen_size.y/2))
