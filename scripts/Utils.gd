extends Node

# monenko framen välein päivitetään objektit (tsekataan näkyykö vai ei)
var UPDATE_OBJECTS = 2;
var MAXLEN = 10*10; # len^2  kuinka kaukana olevat objektit piilotetaan
var rcounter=0;

func loadTxt(name):
	var f = File.new()
	if(f.open(name, File.READ)!=OK):
		print("Can't open file: "+name);
		return "";
	var strr = f.get_line();
	f.close();
	return strr;

func saveTxt(name, strr):
	var f = File.new()
	if(f.open(name, File.WRITE)!=OK):
		print("Can't save file: "+name);
		return;
	f.store_string(strr);
	f.close();

func updateMouse():
	Globals.mouseClicked = false;
	#if(Input.is_action_pressed("leftClick")):
	if(Input.is_action_just_released("leftClick")):
		Globals.mouseClicked = true;


func renderOnlyNearObjects(nodePath):
	rcounter+=1;
	if(rcounter >= UPDATE_OBJECTS): # ei tsekata joka framella
		rcounter=0;
	else:
		return;

	if(Globals.player.health <= 0):
		for p in nodePath.get_children():
			p.show();
	else:
		var camera = Globals.player.body.get_node("Controller/InnerGimbal/Camera");
		for p in nodePath.get_children():
			var l = p.get_translation() - Globals.player.pos;
			var llen = l.length_squared();
			if(llen >= MAXLEN):
				p.hide();
			else:
				if(camera.is_position_behind(p.get_translation())):
					p.hide();
				else:
					p.show();

