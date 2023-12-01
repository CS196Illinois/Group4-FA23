extends CharacterBody2D
@export var speed: int = 1000

func handleInput():
	var moveDirection = Input.get_vector("move_left", "move_right","move_up","move_down")
	velocity = moveDirection*speed
	
func _physics_process(delta):
	handleInput()
	move_and_slide()
