extends "res://scripts/objects/NaturalItem.gd"

func _init():
	name = "Rock";
	modelName = "RockSB.tscn";

	rot = Vector3(0, deg2rad(randi()%360), 0);

	var sc = 0.8 + randf()*0.3;
	scale = Vector3(sc, sc, sc);

func action():
	var rr = randi()%15;
	var strr = "";
	if(rr==1):
		strr = "Stupid rock.";
	if(rr==2):
		strr = "Take that you ugly stone.";
	if(rr==3):
		strr = "Fuck you stone!";
	if(rr==4):
		strr = "Playing hard, eh?";
	if(rr==5):
		strr = "I am harder than a stupid rock.";

	"""
	if(rr==6):
		strr = "Stupid fuck.";
	if(rr==7):
		strr = "Take that you ugly stoner.";
	if(rr==8):
		strr = "Fuck you stoner!";
	if(rr==9):
		strr = "Playing hard to get, eh?";
	if(rr==10):
		strr = "I am harder than u, stupid cunt.";
	"""
	
	return strr;
