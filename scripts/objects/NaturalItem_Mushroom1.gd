extends "res://scripts/objects/NaturalItem.gd"

func _init():
	name = "Mushroom1";
	modelName = "Mushroom2SB.tscn";

	rot = Vector3(0, deg2rad(randi()%360), 0);

	var sc = 0.02 + randf()*0.02;
	scale = Vector3(sc, sc, sc);

	color = Color(1, 1, 1); # white

func getItem():
	return "You got a mushroom.";
