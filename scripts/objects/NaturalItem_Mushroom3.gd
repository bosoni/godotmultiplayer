extends "res://scripts/objects/NaturalItem.gd"

func _init():
	name = "Mushroom3";
	modelName = "Mushroom2SB.tscn";

	rot = Vector3(0, deg2rad(randi()%360), 0);

	var sc = 0.02 + randf()*0.02;
	scale = Vector3(sc, sc, sc);
	
	color = Color(0, 0, 1); # blue

func getItem():
	if(randi()%10 < 5):
		Globals.player.maxJump = 3;
	else:
		Globals.player.speed = 3;
		
	return "You ate a mushroom. Ding dong man, ding dong.";
