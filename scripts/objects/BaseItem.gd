class_name BaseItem

var name := "";
var modelName := "";
var scriptName := "";

var pos := Vector3();
var rot := Vector3();
var scale := Vector3(1,1,1);
var color = null;


func _init():
	scriptName = get_script().get_path();

# palauttaa stringin
func action():
	pass

# palauttaa stringin
func getItem():
	pass
