extends Node

var weatherType := 1; # 1=kirkas, 2=storm
var lightEnergy = 1.0; # ambient light
var rainRandom := 0;
var rainPos := Vector3(1000,1000,1000);
var rain := false;
var counter := 0;

var WEARHERTYPE = 1000; # mitä suurempi luku, sitä harvemmin sää vaihtuu
var RAINRANDOM = 500;  # mitä suurempi luku, sitä harevmmpin alkaa satamaan

func weather(serverweather, rainrandom, rainpos):
	weatherType = serverweather;
	rainRandom = rainrandom;
	rainPos = rainpos;

# server kutsuu tätä
func setWeather(): # randomilla sää
	var r = randi() % WEARHERTYPE;
	if(r==1):
		weatherType = 1; # kirkas
	if(r==2):
		weatherType = 2; # storm
		
	var rainrandom = randi() % RAINRANDOM;
	var x = randf() * 10 - 5;
	var y = 6;
	var z = randf() * 10 - 5;
	rainPos = Vector3(x, y, z);
	Globals.scriptNode.rpc("weather", weatherType, rainrandom, rainPos);

func _process(delta):
	
	if(Globals.SERVER):
		counter+=1;
		if(counter > 20): # ettei jatkuvasti lähetetä säätietoja
			counter = 0;
			setWeather();
		return;

	if(Globals.gameRunning == false || Globals.player == null):
		return;

	# server ei tule koskaan tänne
	
	# säähommelit	
	if(weatherType == 1):		# kirkas
		if(lightEnergy < 1):
			lightEnergy += 0.005;
			
		# sateen loppu
		if(rain==true):
			get_node("rain").queue_free();
			rain = false;
			rainPos = Vector3(1000,1000,1000);
		
	if(weatherType == 2):		# storm
		if(lightEnergy > 0.3): 
			lightEnergy -= 0.005;
				
		# jos myrsky, randomilla vesisade
		if(rain==false && rainRandom<3):
			rain=true;
			var rain = load("res://models/rainParticles.tscn");
			var ins : Particles = rain.instance();
			var pos = rainPos;
			ins.set_translation(pos);
			var SC = 1;
			ins.set_scale(Vector3(SC, SC, SC));
			ins.name = "rain";
			add_child(ins);
			#print("  debug rain: "+str(pos.x)+" "+str(pos.y)+" "+str(pos.z))
	
	Globals.env.get_environment().ambient_light_energy = lightEnergy;
	
	var dl = get_node_or_null("/root/map/Ground/Sun");
	if(dl!=null):
		dl.light_energy = lightEnergy;
	
	if(rain):
		# hidasta liikkuminen
		var l = Globals.player.pos - rainPos;
		l.y = 0; # käytä vain xz
		if(l.length() < 4): # jos sadealueella
			Globals.player.speed = 0.7;
	
	# jos myrsky, randomilla salama
	if(weatherType==2 && rainRandom==0):
		Globals.env.get_environment().ambient_light_energy = 5.0;
		#print("   debug flash.")	
		
	rainRandom = -1;
