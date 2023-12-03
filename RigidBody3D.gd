extends RigidBody3D
var mouse_sens := 0.001
var twist_input := 0.0
var pitch_input := 0.0

@onready var twist := $TwistPivot
@onready var pitch := $TwistPivot/PitchPivot

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var input = Vector3.ZERO 
	input.x = Input.get_axis("move_left", "move_right") #Returns 1.0 if first input is detected and -1.0 if second is, and updates input vector accordingly
	input.z = Input.get_axis("move_forward", "move_backward")
	apply_central_force(twist.basis * input * 1200 * delta)
	
	if (Input.is_action_just_pressed("ui_cancel")):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	twist.rotate_y(twist_input)
	pitch.rotate_x(pitch_input)
	pitch.rotation.x = clamp(
		pitch.rotation.x,
		deg_to_rad(-30),
		deg_to_rad(30)
	)
	twist_input = 0
	pitch_input = 0

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion: #If unhandled input is mouse motion, then:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED: #check that the mouse isn't free
			twist_input = event.relative.x * mouse_sens * -1 #update horizontal and vertical camera position based on mouse change and adjust for sensitivity
			pitch_input = event.relative.y * mouse_sens * -1
