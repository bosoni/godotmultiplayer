# https://github.com/Sombresonge/Third-Person-Controller
extends Spatial

#export(NodePath) var PlayerPath  = "" #You must specify this in the inspector!
export(float) var MovementSpeed = 20
export(float) var Acceleration = 5
export(float) var MaxJump = 5
export(float) var MouseSensitivity = 5
export(float) var RotationLimit = 45
export(float) var MaxZoom = 0.5
export(float) var MinZoom = 1.5
export(float) var ZoomSpeed = 2

var Player
var InnerGimbal
var Direction = Vector3()
var Rotation = Vector2()
var gravity = -9
var Movement = Vector3()
var ZoomFactor = 1
var ActualZoom = 1
var Speed = Vector3()
var CurrentVerticalSpeed = Vector3()
var JumpAcceleration = 2
var IsAirborne = false
var is_moving = false;

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#Player = get_node(PlayerPath)
	Player = Globals.player.body;
	InnerGimbal =  $InnerGimbal

func _unhandled_input(event):
	if(Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE):
		return;

	if event is InputEventMouseMotion :
		Rotation = event.relative
	
	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_WHEEL_UP:
				ZoomFactor -= 0.05
			BUTTON_WHEEL_DOWN:
				ZoomFactor += 0.05
		ZoomFactor = clamp(ZoomFactor, MaxZoom, MinZoom)
		
	is_moving = false;
	Direction = Vector3();

	if(Input.is_action_pressed("ui_up")):
		Direction.z -= 1
		is_moving = true;
	if(Input.is_action_pressed("ui_down")):
		Direction.z += 1
		is_moving = true;
	if(Input.is_action_pressed("ui_left")):
		Direction.x -= 1
		is_moving = true;
	if(Input.is_action_pressed("ui_right")):
		Direction.x += 1
		is_moving = true;
	if(Input.is_action_pressed("ui_select")):
		if not IsAirborne:
			CurrentVerticalSpeed = Vector3(0, MaxJump, 0)
			IsAirborne = true
		
		
	Direction.z = clamp(Direction.z, -1,1)
	Direction.x = clamp(Direction.x, -1,1)
	
	if(is_moving):
		Globals.player.animName = "Walk";
	else:
		Globals.player.animName = "Idle";

func _physics_process(delta):
	if(Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE):
		return;
	
	#Rotation
	Player.rotate_y(deg2rad(-Rotation.x)*delta*MouseSensitivity)
	InnerGimbal.rotate_x(deg2rad(-Rotation.y)*delta*MouseSensitivity)
	InnerGimbal.rotation_degrees.x = clamp(InnerGimbal.rotation_degrees.x, -RotationLimit, RotationLimit)
	Rotation = Vector2()
	
	#Movement
	var MaxSpeed = MovementSpeed * Direction.normalized()
	Speed = Speed.linear_interpolate(MaxSpeed, delta * Acceleration)
	Movement = Player.transform.basis * (Speed)

	if(Speed.length()>0.1): CurrentVerticalSpeed.y += gravity * delta * JumpAcceleration
		
	Movement += CurrentVerticalSpeed
	
	Player.move_and_slide(Movement,Vector3(0,1,0))
	if Player.is_on_floor() :
		CurrentVerticalSpeed.y = 0
		IsAirborne = false
	
	#Zoom
	ActualZoom = lerp(ActualZoom, ZoomFactor, delta * ZoomSpeed)
	InnerGimbal.set_scale(Vector3(ActualZoom,ActualZoom,ActualZoom))

	# normalisoi arvot
	var d = delta*0.5;
	if(Globals.player.maxJump>1.0): Globals.player.maxJump-=d;
	if(Globals.player.speed>1.0): Globals.player.speed-=d;
	if(Globals.player.speed<1.0): Globals.player.speed+=d;
	MovementSpeed = 20*Globals.player.speed;
	MaxJump = 5*Globals.player.maxJump;
	#print("> "+str(MovementSpeed) + "   "+str(MaxJump));
