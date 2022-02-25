
eka pelaaja kirjautuu ok.
sen jälkeen clientti joka kirjautuu, saa typeriä erroreita
	ERROR: Invalid packet received. Requested node was not found


tääl ehkä jotai toho..
	
https://www.reddit.com/r/godot/comments/cd5jv9/networking_tip/





extends Spatial
var IP := "localhost"
var PORT := 12000
var MAX_PLAYERS := 50;

var TEST := false; # jos testi, ei luoda serveriä eikä clienttiä

var useChat := true;
var counter := 0;
var firstTime := true;
var itemsNode = null;


# server settings---------------------------------------------------------------
var useWeather = true;
var groundName = "res://models/Ground2SB.tscn";
var rseed = 999;
var numOfObjects = 100;
#-------------------------------------------------------------------------------

func _ready():
	print("Testtttttt   v" + Globals.VERSION);
	print("parameters:");
	print("  server  create server");
	print("  ip=ipnum (not used if server)");
	print("  port=portnum");
	
	randomize();
	Globals.scriptNode = get_node("/root/Spatial/script");

	for argument in OS.get_cmdline_args():
		if(argument.find("TEST") > -1):
			TEST = true;
			break;
		if(argument.find("server") > -1):
			Globals.SERVER = true;

		if(argument.find("=") > -1):
			var val = argument.split("=");
			if(val[0].find("ip") > -1): IP = val[1];
			if(val[0].find("port") > -1): PORT = val[1];


	if(TEST):
		Globals.SERVER = false;
		print("TEST TEST TEST");
		
	else:
		if(Globals.SERVER):
			Globals.gameRunning = true;
			createServer();
		else:
			createClient();
	

# server ----------------------------------------------------------------------------
func createServer():
	get_tree().connect("network_peer_connected",    self, "clientConnected"   );
	get_tree().connect("network_peer_disconnected", self, "clientDisconnected");

	print("Create server");
	var server = NetworkedMultiplayerENet.new();
	server.create_server(PORT, MAX_PLAYERS);
	get_tree().set_network_peer(server);

# kun pelaaja kirjautuu servulle, servu käskee clienttiä
# luomaan pelaajahahmon ja lataamaan kartan. sitten servu
# lähettää karttainfot ja käynnistää pelin.
func clientConnected(id):
	print("Client " + str(id) + " connected to server");
	
	rpc_id(id, "loadMap", groundName);
	for n in Globals.mapScript.mapInfos.values():
		rpc_id(id, "addToMap", n.name, n.scriptName, 
			n.pos, n.rot, n.scale);

	rpc_id(id, "createPlayer", id, calcPos(), Vector3(0, randf()*1000, 0));
	
	if(useWeather): Globals.Module.add("weather", Globals.root, "res://scripts/Weather.gd");
	
	rpc_id(id, "startGame", useWeather);

func clientDisconnected(id):
	print("Client " + str(id) + " disconnected");
	rpc("removePlayer", id);
	
func createMap():
	Globals.Module.add("map", Globals.root, "res://scripts/Map.gd", groundName, true);
	Globals.mapScript = get_node("/root/map/Ground/script");
	Globals.mapScript.createRandomMap(rseed, numOfObjects);

func calcPos():
	var AREA=30;
	for _i in range(0, 100):
		# randomilla paikka
		var x = randf()*AREA-AREA/2;
		var z = randf()*AREA-AREA/2;
		var y = Globals.mapScript.getY(x, z);
		if(y>0 && y<100): 
			#print(" debug y="+str(y));
			return Vector3(x, y, z);
	return Vector3(0, 2+randf()*2, 0);

# ----------------------------------------------------------------------------------
# client ---------------------------------------------------------------------------
remote func loadMap(groundname):
	groundName = groundname;
	Globals.Module.add("map", Globals.root, "res://scripts/Map.gd", groundName, true);
	Globals.mapScript = get_node("/root/map/Ground/script");

remote func addToMap(name, scriptName, pos, rot, scale):
	# func addToMap(name, scriptName, pos, rot, scale, color, life, parent):
	Globals.mapScript.addToMap(name, scriptName, pos, null, null, null, -1);
	#print("  debug add "+name)

func createClient():
	get_tree().connect("connected_to_server", self, "enter")
	get_tree().connect("server_disconnected", self, "leave")
	get_tree().connect("connection_failed", self, "failed")

	print("Create client");
	var host = NetworkedMultiplayerENet.new()
	host.create_client(IP, PORT)
	get_tree().set_network_peer(host)
	#set_network_master(get_tree().get_network_unique_id());
	
func enter():
	pass;

func leave():
	get_tree().set_network_peer(null);
	print("Disconnected from server");
	get_tree().quit();

func failed():
	print("Connection failed.");
	get_tree().quit();

# ----------------------------------------------------------------
remote func createPlayer(id, pos, rot):
	# luo /root/players/ path. sinne laitetaan kaikki pelaajat
	var node = Node.new();
	node.name = "players";
	Globals.playersNode = node;
	Globals.root.add_child(node);

	var pl = Player.new();
	Globals.players[id] = pl;
	Globals.player = Globals.players[id];
	pl.createPlayer(id, pos, rot);

remote func removePlayer(id):
	if(Globals.players.has(id)):
		var name = "/root/players/"+Globals.players[id].body.name;
		get_node(name).queue_free();
		Globals.players.erase(id);
	
remote func setPlayerInfo(id, pos, rot, name, modelname):
	if(Globals.SERVER): return;

	if(Globals.players.has(id)==false):
		print("+add "+str(id)+" "+name);
		var newpl = Player.new();
		newpl.setPlayerInfo(id, pos, rot, name, modelname);
		Globals.players[id] = newpl;
	else:
		Globals.players[id].setPlayerInfo(id, pos, rot);

remote func startGame(useweather):
	itemsNode = get_node("/root/map/items");
	useWeather = useweather;
	if(useweather): Globals.Module.add("weather", Globals.root, "res://scripts/Weather.gd");
	Globals.gameRunning = true;

remotesync func chatSendMessage(msg):
	get_node("/root/Spatial/UI/log").text += msg;

remote func weather(serverweather, rainrandom, rainpos):
	get_node("/root/weather/script").weather(serverweather, rainrandom, rainpos);


remotesync func removeFromMap(name):
	if(itemsNode==null): return;
	
	var n = itemsNode.get_node_or_null(name);
	if(n): n.queue_free();
	Globals.mapScript.mapInfos.erase(name);
	
remote func fight(fightingId):
	var p1 = Globals.player.pos;
	var p2 = Globals.players[fightingId].pos;
	var l = (p2-p1).length();
	if(l>1): return; # jos pelaajat liian kaukana toisistaan, poistu
	
	var strr = "You was attacked by " + Globals.players[fightingId].name;
	var sendstr = "You hit " + Globals.player.name;

	Globals.player.health -= 1; # TODO
	if(Globals.player.health <= 0):
		strr += "\n" + Globals.players[fightingId].name + " killed you.";
		sendstr += "\n" + "You killed " + Globals.player.name;

	chatSendMessage(strr+"\n");
	rpc_id(fightingId, "chatSendMessage", sendstr+"\n");
	
	
# ----------------------------------------
func _process(delta):
	if(TEST && Globals.player == null):
		createPlayer(0, Vector3(0,0,0), Vector3(0,0,0));
		createMap();
		return;

	if(Globals.gameRunning==false): return;
	
	# init
	if(firstTime): 
		firstTime = false;
	
		if(Globals.SERVER): 
			createMap(); 
			return;

		Globals.env = Globals.root.get_node_or_null("Spatial/WorldEnvironment");
		Globals.Module.add("game", Globals.root, "res://scripts/Game.gd");
		if(useChat): Globals.Module.add("chat", Globals.root, "res://scripts/Chat.gd");

