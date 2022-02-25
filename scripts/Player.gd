class_name Player

var strength := 10;
var speed := 1.0;
var health := 100;
var alive := true;

var name := "";
var modelName := "";
var clientId := -1;

var body;
var pos;
var rot;

var camins;
var animName : = "Idle";

var maxJump = 2;
var SC = 0.05;

var inventory := Inventory.new();

func createPlayer(id, pos_, rot_):
	# luo pelaaja
	clientId = id;
	if(randi()%2==0):
		modelName = "res://players/Player1.tscn";
		name = "nallepuh";
	else:
		modelName = "res://players/Player2.tscn";
		name = "titinalle";
		
	# ladataan modeli ja tps camera ja laita kamera pelaajaan
	var pl = load(modelName);
	var ins : KinematicBody = pl.instance();
	var cam = load("res://3rdPersonController.tscn");
	camins = cam.instance();
	ins.name = name + str(id);
	ins.add_child(camins);
	Globals.player.body = ins;
	Globals.playersNode.add_child(ins);
	camins.Player = ins;
	
	ins.set_scale(Vector3(SC, SC, SC));

	Globals.player.pos = pos_;
	Globals.player.rot = rot_;
	Globals.player.body.set_translation(Globals.player.pos);
	Globals.player.body.set_rotation(Globals.player.rot);
	
# aseta muiden pelaajien tiedot
func setPlayerInfo(id, pos_, rot_, name_=null, modelname_=null):
	if(Globals.players.has(id)==false):
		name = name_;
		modelName = modelname_;
		
		var pl = load(modelName);
		var ins = pl.instance();
		ins.name = str(id);
		body = ins;
		Globals.playersNode.add_child(ins);
		ins.set_scale(Vector3(SC, SC, SC));
		
		# luo label
		var label = Label.new();
		label.name = "Label";
		label.text = name;
		label.add_color_override("font_color", Color(randf(), randf(), randf()));
		ins.add_child(label);
		
	pos = pos_;
	rot = rot_;

func setLabel():
	var label = body.get_node("Label");
	if(Globals.player.health <= 0):
		label.hide();
		return;
		
	var camera = Globals.player.body.get_node("Controller/InnerGimbal/Camera");
	if(camera.is_position_behind(body.get_translation())):
		label.hide();
	else:
		label.show();
		var offset = Vector2(label.get_size().x/2, 10)
		label.set_position(camera.unproject_position(body.get_translation()) - offset)	

func setAnimation():
	#var animPlayer = body.get_node("UkkoArmature/AnimationPlayer");
	var animPlayer = body.find_node_or_null("AnimationPlayer");
	if(animPlayer==null):
		return;
	
	var currentAnim = animPlayer.get_current_animation();
	if(currentAnim != animName):
		animPlayer.play(animName);
