class_name Inventory

var gold := 0;
var items = {} # (BaseItem)

var itemCount=0;

func _ready():
	pass
	
func add(item: BaseItem):
	items[itemCount] = item;
	itemCount += 1;

func remove():
	pass
