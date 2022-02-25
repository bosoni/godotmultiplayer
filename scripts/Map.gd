extends Spatial

var SIZE = 40;
var counter := 0;
var spaceState;
var modelCache = {} # ei ladata model kuin kerran
var mapInfos = {}; # (BaseItem)

func _ready():
	spaceState = get_world().direct_space_state;

func createRandomMap(rseed, numOfObjects):
	seed(rseed);

	print("Create level...");
	print(" Objects: "+str(numOfObjects));

	var positions = [];
	
	var n = get_node_or_null("../edge");
	if(n==null):
		print(" DEBUG: laita groundiin edge spatial maaston reunaan x-akselilla");
	else:
		SIZE = get_node("../edge").get_translation().x * 2;
		
	# ota ylös random paikat kartalla (ei aseteta modeleita mihinkään vielä)
	for c in numOfObjects:
		var x = randf() * SIZE - SIZE/2;
		var z = randf() * SIZE - SIZE/2;
		
		var from = Vector3(x, 1000, z);
		var to = Vector3(x, -1000, z);

		var result = spaceState.intersect_ray(from, to, [self]);
		if(result):
			if(result.position.y > 0): # älä laita veden alle
				positions.push_back(result.position);
		
	# pistä paikkoihin puu/sieni tai jottai
	for pos in positions:
		var obj;
		var rand = randi()%30;
		
		if(rand<5):
			obj = load("res://scripts/objects/Item_Rock1.gd").new();
		elif(rand<10):
			obj = load("res://scripts/objects/NaturalItem_Tree1.gd").new();
		elif(rand<15):
			obj = load("res://scripts/objects/NaturalItem_Tree2.gd").new();

		elif(rand<20):
			obj = load("res://scripts/objects/NaturalItem_Mushroom1.gd").new();
		elif(rand<25):
			obj = load("res://scripts/objects/NaturalItem_Mushroom2.gd").new();
		elif(rand<30):
			obj = load("res://scripts/objects/NaturalItem_Mushroom3.gd").new();

		obj.name += "_" + str(counter);
		obj.name = obj.name.to_lower();
		counter += 1;

		obj.pos = pos;
		mapInfos[obj.name] = obj;
	
	print("Level created.");

# lisää obu skeneen.
# scriptName määrää objektin.
# rot,scale,color voi olla null jolloin scriptissä olevat arvot säilyy.
# life voi olla -1 jolloin scriptissä oleva arvo säilyy.
func addToMap(name, scriptName, pos, rot, scale, color, life):
	#print("  #debug: add "+name);
	if(mapInfos.has(name)):
		print("  debug found "+name);
		return;

	var obj = load(scriptName).new();
	obj.name = name;
	obj.modelName = "res://models/" + obj.modelName;
	obj.pos = pos;

	if(rot!=null):
		obj.rot = rot;
	if(scale!=null):
		obj.scale = scale;
	if(color!=null):
		obj.color = color;
	if(life!=-1):
		obj.life = life;
		
	mapInfos[name] = obj;
	
	var model;
	if(modelCache.has(obj.modelName)):
		model = modelCache[obj.modelName];
	else:
		model = load(obj.modelName);
		modelCache[obj.modelName] = model;
	var ins = model.instance();
	ins.name = name;
	ins.set_translation(obj.pos);
	ins.set_rotation(obj.rot);
	ins.set_scale(obj.scale);
	
	# luo items path jos ei ole luotu
	if(!has_node("/root/map/items")):
		var nnode=Node.new();
		nnode.name="items";
		get_node("/root/map").add_child(nnode);
	get_node("/root/map/items").add_child(ins);
	
	var instanceName = "*";
	if(name.find("mushroom")!=-1):
		instanceName = "Sphere";

	# change color
	if(obj.color != null):
		var mat = SpatialMaterial.new();
		mat.albedo_color = obj.color;
		#var tex = preload("res://textures/bg1.png");
		#mat.albedo_texture = tex;
		var mi : MeshInstance = ins.find_node(instanceName);
		mi.material_override = mat;
	
	return ins;

func getY(x, z):
	var from = Vector3(x, 1000, z);
	var to = Vector3(x, -1000, z);
	var result = spaceState.intersect_ray(from, to, [self]);
	if(result):
		return result.position.y;
	return 100;
