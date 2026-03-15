extends SpringArm3D

@export var followingDistance : float = 5.0
@export var upVector : Vector3 = Vector3(0,1,0) # y axis
var yaw : float = 0.0 # how far forwardDir is rotated around y axis (yaw)
var pitch : float = 0.0 # how much forwardDir is rotated around x axis (pitch)
var Player : Node
var forwardDir : Vector3 = Vector3(0,0,1) # global forward direction (lookat)

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		yaw -= event.relative.x*0.01
		pitch -= event.relative.y*0.01 # invert y axis
		
		pitch = clamp(pitch, -PI/2, PI/2)
		# map the yaw to 0, 2pi as well
		# clamp won't work since we want smooth rotation
		if (yaw < 0):
			yaw += 2*PI # coterminal angles
		if (yaw > 2*PI):
			yaw -= 2*PI # coterminal angles
		
	if (event.is_action_pressed("toggleMouse", true)):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if (event.is_action_released("toggleMouse")):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# scroll callback
	# can be shortened (remove following distance var)
	if (event.is_action_pressed("zoomIn")):
		if (followingDistance > 1.5):
			followingDistance -= 0.1
			spring_length = followingDistance
	if (event.is_action_pressed("zoomOut")):
		if (followingDistance < 10.0):
			followingDistance += 0.1
			spring_length = followingDistance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = get_node("../startposition").global_position
	Player = get_node("../Player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	spring_length = followingDistance

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:	
	
	# spring arm 3d is very straight forward 
	# set the rotation (this rotates the basis vectors)
	# consequently rotates the arm direction too
	rotation.x = pitch
	rotation.y = yaw
	
	# then just update the position of the spring, put it where the player is
	# the following distance is just the arm length (we set those when zoom changes)
	global_position = Player.global_position






# unused

func oldCamera():
	pass
	# the above rotates every frame, so i guess reset it after, but that's just strange
	# we instead get the basis vectors and rotate manually
	#var playerPosition = Player.get_global_position()
	# camera forward direction (originally the forward z axis)
	#var fDir : Vector3 = Vector3(0,0,1)
	# rotate this vector about (y axis) up direction
	# this gives us where around the player (yaw)
	# rotate the resulting vector about (x axis) right direction of the camera
	# this gives us where above the player (pitch)
	
	# this matrix captures exactly that
	# godot has this built in function
	# this is essentially the change of basis matrix
	# what this means is if you rotate the entire xyz plane
	# we're just rotating the basis vectors (x, y , z)
	# now we want to express our forward direction in terms of the new
	# rotated x,y,z
	# well that's just multiplying our old forward direction (expressed in x,y,z)
	# with the change of basis matrix
	# the result is a vector in the new coordinate space (the rotated version)
	#var newBasis : Basis = Basis.from_euler(Vector3(pitch, yaw, 0.0))
	
	# compute the new forwardDirection
	#forwardDir = newBasis*fDir
	
	# update camera position
	#global_position = followingDistance*forwardDir + playerPosition
	
	# update basis (this also rotates the camera)
	#basis = newBasis
