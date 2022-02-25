extends Node

var targetIns : Spatial;
var itemsPath;
var logPath;
var UIPath;

func _ready():
	var target = load("res://models/Target.tscn");
	targetIns = target.instance();
	add_child(targetIns);
	itemsPath = get_node("/root/map/items");
	logPath = get_node("/root/Spatial/UI/log");
	UIPath = get_node("/root/Spatial/UI");

func deathCamera():
	# aseta kamera kuvaamaan raatoa
	var cam = get_node("/root/Spatial/deathCamera");
	var cpos = Vector3(0, 10, 0);
	cam.set_translation(cpos);
	cam.look_at(Globals.player.pos, Vector3.UP);
	cam.make_current();

func deadToRigidBody():
	
	# TODO pelaaja pitäis poistaa playersNode listasta
	#var nd = Globals.playersNode.get_node(Globals.player.name + str(Globals.player.clientId));
	#nd.free();
	
	Globals.player.body.set_translation(Vector3(1000,1000,1000)); # pois silmistä
	Globals.player.body.free(); # vapauta
	
	var body = RigidBody.new()
	var shape = CapsuleShape.new();

	# temp modeli
	var model = load("res://models/rock.escn"); 
	var ins = model.instance();
	var SC = 0.2;
	ins.set_scale(Vector3(SC,SC,SC));
	body.add_child(ins);

	var collision = CollisionShape.new();
	collision.shape = CapsuleShape.new();
	(collision.shape as CapsuleShape).radius = 0.1;
	(collision.shape as CapsuleShape).height = 0.5;
	body.add_child(collision);
		
	
	body.set_translation(Globals.player.pos);
	body.set_rotation(Globals.player.rot);
	Globals.playersNode.add_child(body);
	
	Globals.player.body = body;
		

func _process(delta):
	if(Globals.gameRunning==false): return;

	if(Globals.player.health<=0):
		Globals.player.health=0;
		if(Globals.player.alive):
			Globals.player.alive = false;
			deathCamera();
			deadToRigidBody();

	Utils.updateMouse();
	Utils.renderOnlyNearObjects(itemsPath);
	UIPath.get_node("health").text = "Health: "+str(Globals.player.health);

	if(Globals.player.alive):
		if(Globals.player.pos.y < -5):
			Globals.player.body.set_translation(Vector3(0,3,0)); # spawn
			
	# päivitä pelaajan tiedot
	Globals.player.pos = Globals.player.body.get_translation();
	Globals.player.rot = Globals.player.body.get_rotation();
	
	if(Globals.player.alive):
		if(Globals.player.pos.y < -0.05): # jos veden alla
			Globals.env.get_environment().ambient_light_energy = 0.2;
			Globals.player.speed = 0.5;
			Globals.player.health -= 1;
			if(Globals.player.health<=0):
				logPath.text += "Way to go. You drowned.\n";

	# päivitä muiden pelaajien tiedot
	for pl in Globals.players.values():
		if(pl.clientId != Globals.player.clientId): # ei pistetä pelaajan tietoja
			pl.body.set_translation(pl.pos);
			pl.body.set_rotation(pl.rot);
			pl.setLabel();

	# lähetä pelaajan infot muille clienteille
	Globals.scriptNode.rpc("setPlayerInfo", Globals.player.clientId, Globals.player.pos, Globals.player.rot, Globals.player.name, Globals.player.modelName);


# sekoilut
func seko():
	var strr="";
	var r = randi()%10000;
	if(r==1000):
		strr = "Dorf: Dum de dum.";
	if(r==2000):
		strr = "Zombi: Brains...brainss.";
	if(r==3000):
		strr = "Scarface: Say hello to my little friend.";
	if(strr!=""): logPath.text += strr+"\n";
	

func _physics_process(delta):
	# jos pelaaja kuollut, ei voi tehdä enää mitään
	if(Globals.player.health <= 0): return;

	checkCollision();
	seko();

#https://docs.godotengine.org/en/3.1/classes/class_kinematicbody.html#class-kinematicbody-method-move-and-collide
func checkCollision():
	targetIns.set_translation(Vector3(1000,1000,1000));
	var col = null;
	var cname = "";
	
	var forward = Globals.player.body.get_global_transform().basis.z;
	var VECTOR_LEN = -forward;
	
	#move_and_collide(Vector3 rel_vec, bool infinite_inertia=true, bool exclude_raycast_shapes=true, bool test_only=false)
	col = Globals.player.body.move_and_collide(VECTOR_LEN, true, true, true);
	if(col != null && col.get_collider() != null):
		var gc = col.get_collider();
		cname = gc.name.to_lower();
			
		# ei välitetä näistä
		if(cname.find("plane")!=-1 || cname.find("campfire")!=-1):
			return;
	
		if(cname.find("mushroom")!=-1):
			getItem(cname);
			return;
				
		if(Globals.mouseClicked):
			if(cname.find("tree")!=-1 || cname.find("rock")!=-1):
				action(cname);
				return;
			
			# jos cname on numero niin se on toisen pelaajan network id joten revi pää irti
			if(cname.is_valid_integer()):
				fight(cname);
				return;
		
		targetIns.set_translation(col.position);
		#print(" debug coll: "+cname);
	else: 
		return;

func getItem(name):
	var item:BaseItem = Globals.mapScript.mapInfos[name];
	if(item): 
		var strr = item.getItem();
		Globals.player.inventory.add(item);
		
		Globals.scriptNode.rpc_id(1, "removeFromMap", name);
		Globals.scriptNode.rpc("removeFromMap", name);
		
		if(Globals.player.health<=0):
			strr += "\nYou died. Now you are a ghost";
		
		if(strr!=""): logPath.text += strr+"\n";

func action(name):
	var item:BaseItem = Globals.mapScript.mapInfos[name];
	if(item): 
		var strr = item.action();

		if(item.life<=0):
			strr += "\n" + item.getItem();
			Globals.player.inventory.add(item);
			Globals.scriptNode.rpc_id(1, "removeFromMap", name);
			Globals.scriptNode.rpc("removeFromMap", name);
			
		if(strr!=""): logPath.text += strr+"\n";

func fight(name):
	# name == other player's clientId (at least should be)
	var otherId = name.to_int();
	Globals.scriptNode.rpc_id(otherId, "fight", Globals.player.clientId);
