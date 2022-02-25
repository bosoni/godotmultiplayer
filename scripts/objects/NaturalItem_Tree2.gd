extends "res://scripts/objects/NaturalItem.gd"

func _init():
	name = "Tree2";
	modelName = "Tree2.tscn";

	rot = Vector3(0, deg2rad(randi()%360), 0);

	# eri pituisia puita
	var sc = 0.6 + randf()*0.3;
	var yscale = randf() * 0.3; 
	scale = Vector3(sc, sc + yscale, sc);
	
	life = 7.0;

func action():
	life -= 1; # TODO
	return "Knock knock you chopped tree.";

func getItem():
	return "You took some wood.";
