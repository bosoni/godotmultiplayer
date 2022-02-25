extends Node

const VERSION = "0.1.211221"; # year month day
var SERVER = false;

onready var root = get_node("/root");
var Module = load("res://scripts/Module.gd");
var playersNode;	# /root/players/
var scriptNode;		# Client.gd  /root/Spatial/script
var mapScript;		# Map.gd	/root/map/script

var gameRunning = false;
var env; # WorldEnvironment
var mouseClicked;


var players = {} # (Player class)
var player; # player = players[clientId]
