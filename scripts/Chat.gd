extends Node

func _process(delta):
	if Input.is_action_just_released("ui_focus_next"):
		var n = get_node("/root/Spatial/UI/chatLineEdit");
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			n.hide();
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			n.show();
			
	if(Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE):
		var n = get_node("/root/Spatial/UI/chatLineEdit");
		# Capturing/Freeing the cursor
		if(Input.is_key_pressed(KEY_ENTER)):
			if(n.text!="\n" && n.text!=""):
				Globals.scriptNode.rpc("chatSendMessage", Globals.player.name+": "+n.text + "\n");
			n.text = "";
