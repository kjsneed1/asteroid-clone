extends CanvasLayer
signal high_score_back
signal high_score_submit(name:String)

var default_scores = [
	{"name":"LeetGamer",
	"score":10000},
	{"name":"SwiftSneaker",
	"score":8000},
	{"name":"CosmicBlender",
	"score":6000},
	{"name":"ScorchCannon",
	"score":5000},
	{"name":"CosmicMoonbeam",
	"score":4000},
	{"name":"RevengeMage",
	"score":3000},
	{"name":"SwagHound",
	"score":2500},
	{"name":"BlastAngel",
	"score":2000},
	{"name":"StringSlinger",
	"score":1500},
	{"name":"AxeMaiden",
	"score":1000},
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func get_high_scores():
	if(FileAccess.file_exists("user://high_scores.json")):
		var save_file = FileAccess.open("user://high_scores.json", FileAccess.READ)
		
		var high_scores = ""
		
		while save_file.get_position() < save_file.get_length():
			high_scores += save_file.get_line()
		
		var parsed_scores = JSON.parse_string(high_scores)
		
		parsed_scores = sort_scores(parsed_scores)
		
		parsed_scores.resize(10)
		
		return parsed_scores
	
	return default_scores

func write_high_scores(scores):
	var scores_string = JSON.stringify(scores)
	var save_file = FileAccess.open("user://high_scores.json", FileAccess.WRITE)
	save_file.store_line(scores_string)

func get_high_score_string():
	var print_out = ""
	var high_scores = get_high_scores()
	
	for i in high_scores.size():
		var person = high_scores[i]
		if person.name && person.score:
			print_out += str(i + 1) + ". " + person.name + " - " + str(int(person.score)) + "\n"
			
	return print_out

func set_high_score_string():
	var high_score_string = get_high_score_string()
	$HighScoreScreen/List.text = high_score_string


func _on_back_button_pressed() -> void:
	high_score_back.emit()
	$HighScoreScreen.hide()
	
func sort_scores_descending(a,b):
	if a.score > b.score:
		return true
	return false

func sort_scores(scores):
	scores.sort_custom(sort_scores_descending)
	return scores

func get_min():
	var scores = get_high_scores()
	return scores[9].score


func _on_submit_button_pressed() -> void:
	var player_name = $NewHighScoreScreen/NameBox.text
	if(player_name.length() > 0):
		high_score_submit.emit(player_name)

func add_high_score(player_name, player_score):
	var new_score_obj = {
		"name":player_name,
		"score":player_score
	}
	var scores = get_high_scores()
	scores.append(new_score_obj)
	scores = sort_scores(scores)
	scores.resize(10)
	write_high_scores(scores)
