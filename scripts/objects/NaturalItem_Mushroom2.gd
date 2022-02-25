extends "res://scripts/objects/NaturalItem.gd"

func _init():
	name = "Mushroom2";
	modelName = "Mushroom2SB.tscn";

	rot = Vector3(0, deg2rad(randi()%360), 0);

	var sc = 0.02 + randf()*0.02;
	scale = Vector3(sc, sc, sc);

	color = Color(1, 0, 0); # red

func getItem():
	var poison = 80;
	Globals.player.health -= poison;
	var tst = ["shit", "poison"]
	var strr = "You ate a mushroom. It tasted like "+tst[randi()%2]+".";
	return strr;
