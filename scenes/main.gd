extends Node

@export var snake_scene: PackedScene

# game variables
var score: int
var game_started: bool = false

# grid variables
var cells: int = 20
var cell_size: int = 50

# food variables
var food_pos: Vector2
var regen_food: bool = true

# snake variables
var old_data: Array # previous grid coordinate of each segment
var snake_data: Array # grid coordinate of each segment
var snake: Array # actual segment scenes

# movement variables
var start_pos = Vector2(9,9) # grid reference on 20x20 grid
var up = Vector2(0, -1)
var down = Vector2(0, 1)
var left = Vector2(-1, 0)
var right = Vector2(1, 0)
var move_direction: Vector2
var can_move: bool

# Music variables
@onready var twoDTheme = $twoDTheme
@onready var appleCrunch = $apple_crunch
@onready var gameOver = $game_over


# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()

func new_game():
	get_tree().paused = false
	get_tree().call_group("segments", "queue_free")
	$GameOverMenu.hide()
	score = 0
	$Hud.get_node("ScoreLabel").text = "SCORE: " + str(score)
	$GameOverMenu.get_node("FinalScoreLabel").text = "SCORE: " + str(score)
	move_direction = up
	can_move = true
	generate_snake()
	move_food()

func generate_snake():
	old_data.clear()
	snake_data.clear()
	snake.clear()
	#starting with the start_pos, create tail segments vertically down
	for i in range(3):
		add_segment(start_pos + Vector2(0, 1))

func add_segment(pos):
	snake_data.append(pos)
	var SnakeSegment = snake_scene.instantiate()
	SnakeSegment.position = (pos * cell_size) + Vector2(0, cell_size)
	add_child(SnakeSegment)
	snake.append(SnakeSegment)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_snake()
	
func move_snake():
	if can_move:
		#update mvmt from key press
		if Input.is_action_just_pressed("move_down") and move_direction != up:
			move_direction = down
			can_move = false
			if (game_started == false):
				start_game()
		if Input.is_action_just_pressed("move_up") and move_direction != down:
			move_direction = up
			can_move = false
			if (game_started == false):
				start_game()
		if Input.is_action_just_pressed("move_left") and move_direction != right:
			move_direction = left
			can_move = false
			if (game_started == false):
				start_game()
		if Input.is_action_just_pressed("move_right") and move_direction != left:
			move_direction = right
			can_move = false
			if (game_started == false):
				start_game()

func start_game():
	game_started = true
	$MoveTimer.start()
	twoDTheme.play()


func _on_move_timer_timeout():
	can_move = true # allow snake mvmt
	# use snake's previous position to move each segment
	old_data = [] + snake_data
	snake_data[0] += move_direction
	for i in range(len(snake_data)):
		# move segs one by one
		if i > 0:
			snake_data[i] = old_data[i - 1]
		snake[i].position = (snake_data[i] * cell_size) + Vector2(0, cell_size)
	check_out_of_bounds()
	check_self_eaten()
	check_food_eaten()
	
func check_out_of_bounds():
	if snake_data[0].x < 0 or snake_data[0].x > cells - 1 or snake_data[0].y < 0 or snake_data[0].y > cells - 1:
		end_game()

func check_self_eaten():
	for i in range(1, len(snake_data)):
		if snake_data[0] == snake_data[i]:
			end_game()

func check_food_eaten():
	if snake_data[0] == food_pos:
		score += 1
		appleCrunch.play()
		$Hud.get_node("ScoreLabel").text = "SCORE: " + str(score)
		$GameOverMenu.get_node("FinalScoreLabel").text = "SCORE: " + str(score)
		add_segment(old_data[-1])
		move_food()

func move_food():
	while regen_food:
		regen_food = false
		food_pos = Vector2(randi_range(0, cells - 1), randi_range(0, cells - 1))
		for i in snake_data:
			if food_pos == i:
				regen_food = true
	$Food.position = (food_pos * cell_size) + Vector2(0, cell_size)
	regen_food = true

func end_game():
	twoDTheme.stop()
	$GameOverMenu.show()
	$MoveTimer.stop()
	game_started = false
	get_tree().paused = true
	
func _on_game_over_menu_restart():
	new_game()
