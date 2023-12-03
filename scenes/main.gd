extends Node

@export var snake_head = preload("res://Head.tscn")
@export var snake_body = preload("res://Body.tscn")
var snake_segment
var body

# game variables
var score := 0
var game_started := false

# grid variables
const cells := 20
const cell_size := 50

# food variables
var food_pos: Vector2
var regen_food: bool = true

# snake variables
var old_data: Array # previous grid coordinate of each segment
var snake_data: Array # grid coordinate of each segment
var snake: Array # actual segment scenes

# movement variables
const start_pos := Vector2(9, 9) # grid reference on 20x20 grid

const up := Vector2(0, -1)
const down := Vector2(0, 1)
const left := Vector2(-1, 0)
const right := Vector2(1, 0)
const offset := Vector2(25, 25)
var threshold = 5
var move_direction := up
var can_move := true
var rotated = false

# Music variables
@onready var twoDTheme = $twoDTheme
@onready var appleCrunch = $apple_crunch
@onready var gameOver = $game_over

# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()

func new_game():
	score = 0
	get_tree().paused = false
	get_tree().call_group("segments", "queue_free")
	$GameOverMenu.hide()
	$Hud.get_node("ScoreLabel").text = "SCORE: " + str(score)
	$GameOverMenu.get_node("FinalScoreLabel").text = "SCORE: " + str(score)
	$DistortionLocation2.material.set_shader_parameter("displacement", 0.0)
	$DistortionLocation2.position.x = 500
	$DistortionLocation2.position.y = 550
	generate_snake()
	move_food()

func generate_snake():
	old_data.clear()
	snake_data.clear()
	snake.clear()
	#starting with the start_pos, create tail segments vertically down
	snake_data.append(start_pos)
	snake_segment = snake_head.instantiate()
	snake_segment.position = (start_pos  * cell_size) + Vector2(0, cell_size) + offset
	add_child(snake_segment)
	snake.append(snake_segment)
		

func add_segment(pos):
	snake_data.append(pos)
	body = snake_body.instantiate()
	body.position = (pos * cell_size) + Vector2(0, cell_size) + offset
	add_child(body)
	snake.append(body)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_snake()
	
func move_snake():
	if can_move:
		#update mvmt from key press
		if Input.is_action_just_pressed("move_down") and move_direction != up:
			snake_segment.rotation_degrees = 90
			move_direction = down
			can_move = false
			if (game_started == false):
				start_game()
		if Input.is_action_just_pressed("move_up") and move_direction != down:
			snake_segment.rotation_degrees = -90
			move_direction = up
			can_move = false
			if (game_started == false):
				start_game()
		if Input.is_action_just_pressed("move_left") and move_direction != right:
			snake_segment.rotation_degrees = 180
			move_direction = left
			can_move = false
			if (game_started == false):
				start_game()
		if Input.is_action_just_pressed("move_right") and move_direction != left:
			snake_segment.rotation_degrees = 0
			move_direction = right
			can_move = false
			if (game_started == false):
				start_game()

func start_game():
	game_started = true
	$MoveTimer.start()
	twoDTheme.play()
	$MoveTimer.wait_time = 0.2


func _on_move_timer_timeout():
	can_move = true # allow snake mvmt
	# use snake's previous position to move each segment
	old_data = [] + snake_data
	snake_data[0] += move_direction
	for i in range(len(snake_data)):
		# move segs one by one
		if i > 0:
			snake_data[i] = old_data[i - 1]
		snake[i].position = (snake_data[i] * cell_size) + Vector2(0, cell_size) + offset
	check_out_of_bounds()
	check_self_eaten()
	check_food_eaten()
	
func check_out_of_bounds():
	if snake_data[0].x < 1 or snake_data[0].x > cells - 2 or snake_data[0].y < 1 or snake_data[0].y > cells - 2:
		end_game()

func check_self_eaten():
	for i in range(1, len(snake_data)):
		if snake_data[0] == snake_data[i]:
			end_game()

func check_food_eaten():
	if snake_data[0] == food_pos:
		score += 1
		appleCrunch.play()
		$MoveTimer.wait_time = $MoveTimer.wait_time * 0.95
		if score == threshold:
			gen_distortion()
			
		if score % 3 == 0 and score > threshold:
			$DistortionLocation2.material.set_shader_parameter("scrollRate", $DistortionLocation2.material.get_shader_parameter("scrollRate") + Vector2(0.175, 0.175))
			$DistortionLocation2.material.set_shader_parameter("displacement", clamp(($DistortionLocation2.material.get_shader_parameter("displacement") * 1.1), 0.0, 0.2))
		$MoveTimer.wait_time = clamp($MoveTimer.wait_time, 0.05, 0.2)
		$Hud.get_node("ScoreLabel").text = "SCORE: " + str(score)
		$GameOverMenu.get_node("FinalScoreLabel").text = "SCORE: " + str(score)
		add_segment(old_data[-1])
		move_food()

func move_food():
	while regen_food:
		regen_food = false
		food_pos = Vector2(randi_range(1, cells - 2), randi_range(1, cells - 2))
		for i in snake_data:
			if food_pos == i:
				regen_food = true
	$Food.position = (food_pos * cell_size) + Vector2(0, cell_size)
	regen_food = true
	
func gen_distortion():
	var placement = randi_range(0, 20)
	var edges = [Vector2(placement, 20), Vector2(placement, 0), Vector2(20, placement), Vector2(0, placement)]
	var placementNum = randi_range(0, edges.size() - 1)
	var distortionPos: Vector2 = edges[placementNum]
	var noiseTexture: NoiseTexture2D = $DistortionLocation2.material.get_shader_parameter("distortionTexture")
	if (placementNum < 2):
		noiseTexture.width = 200
		$DistortionLocation2.scale.x = 2
	else:
		noiseTexture.height = 200
		$DistortionLocation2.scale.y = 2
	$DistortionLocation2.position.x = distortionPos.x * cell_size
	$DistortionLocation2.position.y = distortionPos.y * cell_size + 50
	$DistortionLocation2.material.set_shader_parameter("scrollRate", Vector2(0.1, 0.1))
	$DistortionLocation2.material.set_shader_parameter("displacement", 0.005)
	

func end_game():
	twoDTheme.stop()
	$GameOverMenu.show()
	$MoveTimer.stop()
	game_started = false
	get_tree().paused = true
	
func _on_game_over_menu_restart():
	for i in range(snake.size()):
		snake[i].queue_free()
	new_game()
